-- interfaces/formationSelection.lua
local composer = require("composer")
local widget = require("widget")
local json = require("json")
local network = require("network")
local supabase = require("config.supabase")
local apiUsers = require("api.getUsers")
local userDataLib = require("lib.userData")
local cardS = require("components.cardS")

local scene = composer.newScene()
local MAX_SELECT = 5

-- helper para checar existência
local function contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

function scene:create(event)
    local group = self.view
    local data = userDataLib.load() or {}
    local userId = data.id

    -- Título
    display.newText({
        parent = group,
        text = "Selecione até 5 cartas:",
        x = display.contentCenterX,
        y = 40,
        font = native.systemFontBold,
        fontSize = 24
    })

    -- Botão Confirmar
    local confirmBtn = display.newText({
        parent = group,
        text = "Confirmar",
        x = display.contentCenterX,
        y = display.contentHeight - 50,
        font = native.systemFontBold,
        fontSize = 20
    })
    confirmBtn:setFillColor(0, 0.5, 1)

    scene.selectedIDs = {}
    local initialFormation = {}

    function confirmBtn:tap()
        if #scene.selectedIDs == 0 then
            native.showAlert("Atenção", "Selecione ao menos uma carta.", {"OK"})
            return true
        end
        local url = string.format("%s/rest/v1/user_formation?userId=eq.%d", supabase.SUPABASE_URL, userId)
        network.request(url, "PATCH", function(ev)
            if ev.isError then
                native.showAlert("Erro", "Falha ao atualizar.", {"OK"})
            else
                native.showAlert("Sucesso", "Formação salva!", {"OK"}, function()
                    composer.gotoScene("interfaces.formation.formation")
                end)
            end
        end, {
            headers = {
                ["apikey"] = supabase.SUPABASE_ANON_KEY,
                ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
                ["Content-Type"] = "application/json"
            },
            body = json.encode({
                formation = scene.selectedIDs
            })
        })
        return true
    end
    confirmBtn:addEventListener("tap", confirmBtn)

    -- 1) Carrega formação existente
    apiUsers.fetchFormation(userId, function(fetched, ferr)
        if not ferr then
            -- compacta mantendo ordem, elimina nils
            initialFormation = {}
            local maxIdx = 0
            for k, v in pairs(fetched) do
                if type(k) == "number" and k > maxIdx then
                    maxIdx = k
                end
            end
            for i = 1, maxIdx do
                if fetched[i] then
                    table.insert(initialFormation, fetched[i])
                end
            end
            scene.selectedIDs = {}
            for _, id in ipairs(initialFormation) do
                table.insert(scene.selectedIDs, id)
            end
        end
        -- 2) Busca user_characters
        local headers = {
            ["apikey"] = supabase.SUPABASE_ANON_KEY,
            ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
        }
        local url = string.format(
            "%s/rest/v1/user_characters?select=id,characterId,stars,level,name,hp,atk,characters(card_type)&userId=eq.%d",
            supabase.SUPABASE_URL, userId)
        network.request(url, "GET", function(ev)
            if ev.isError then
                return
            end
            local recs = json.decode(ev.response)
            -- Cria ScrollView com scrollHeight adequado
            local rowHeight = 140
            local padding = 20
            local scrollView = widget.newScrollView({
                top = 80,
                left = 20,
                width = display.contentWidth - 40,
                height = display.contentHeight - 160,
                scrollHeight = #recs * rowHeight + padding,
                horizontalScrollDisabled = true,
                verticalScrollDisabled = false
            })
            group:insert(scrollView)

            for i, rec in ipairs(recs) do
                local rowY = (i - 1) * rowHeight + rowHeight * 0.5
                -- Card
                local card = cardS.new({
                    x = 60,
                    y = rowY,
                    characterId = rec.characterId,
                    stars = rec.stars,
                    scaleFactor = 0.8
                })
                scrollView:insert(card)

                -- Checkbox de seleção
                local isSel = contains(scene.selectedIDs, rec.id)
                -- cria ambos ícones
                local cbSel = display.newImageRect("assets/7misc/misc_check_box_selected.png", 32, 32)
                local cbUns = display.newImageRect("assets/7misc/misc_check_box_unselected.png", 32, 32)
                cbSel.x = card.x + card.width * 0.5 + 40
                cbSel.y = card.y - card.height * 0.4
                cbUns.x = cbSel.x
                cbUns.y = cbSel.y
                cbSel.isVisible = isSel
                cbUns.isVisible = not isSel
                scrollView:insert(cbUns)
                scrollView:insert(cbSel)

                -- toggle visibility e atualizar lista
                local function toggle()
                    if cbSel.isVisible then
                        -- desmarcar
                        for j, id in ipairs(scene.selectedIDs) do
                            if id == rec.id then
                                table.remove(scene.selectedIDs, j);
                                break
                            end
                        end
                        cbSel.isVisible = false
                        cbUns.isVisible = true
                    else
                        -- marcar
                        if #scene.selectedIDs < MAX_SELECT then
                            table.insert(scene.selectedIDs, rec.id)
                            cbSel.isVisible = true
                            cbUns.isVisible = false
                        else
                            native.showAlert("Atenção", "Máximo 5 cartas.", {"OK"})
                        end
                    end
                    return true
                end
                cbSel:addEventListener("tap", toggle)
                cbUns:addEventListener("tap", toggle)

                -- Informações ao lado
                local infoX = 150
                local nameTxt = display.newText(rec.name or "", infoX, rowY - 40, native.systemFont, 16)
                nameTxt.anchorX = 0;
                scrollView:insert(nameTxt)
                local lvlTxt = display.newText("Lv." .. (rec.level or 1), infoX, rowY - 20, native.systemFont, 14)
                lvlTxt.anchorX = 0;
                scrollView:insert(lvlTxt)
                local ctype = (rec.characters and rec.characters[1] and rec.characters[1].card_type) or ""
                local typeTxt = display.newText(ctype, infoX, rowY, native.systemFont, 14)
                typeTxt.anchorX = 0;
                scrollView:insert(typeTxt)
                local hpTxt = display.newText("HP:" .. rec.hp, infoX, rowY + 20, native.systemFont, 14)
                hpTxt.anchorX = 0;
                scrollView:insert(hpTxt)
                local atkTxt = display.newText("ATK:" .. rec.atk, infoX, rowY + 40, native.systemFont, 14)
                atkTxt.anchorX = 0;
                scrollView:insert(atkTxt)
                local starsTxt = display.newText("★" .. rec.stars, infoX, rowY + 60, native.systemFont, 14)
                starsTxt.anchorX = 0;
                scrollView:insert(starsTxt)
            end
        end, {
            headers = headers
        })
    end)
end

scene:addEventListener("create", scene)
return scene
