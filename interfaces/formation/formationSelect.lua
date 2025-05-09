-- interfaces/formationSelection.lua
local composer = require("composer")
local widget = require("widget")
local json = require("json")
local network = require("network")
local supabase = require("config.supabase")
local apiUsers = require("api.getUsers")
local userDataLib = require("lib.userData")
local cardS = require("components.cardS")
local topBack = require("components.backTop")
local navbar = require("components.navBar")
local textile = require("utils.textile")
local cloudOn = require("utils.cloudOn")
local cloudOff = require("utils.cloudOff")
local cardCell = require("components.cardCell")

local scene = composer.newScene()
local MAX_SELECT = 5

local CharacterType = {}
local function getCardTypeImage(t)
    if t == "atk" then
        return "assets/7card/prof_attack.png"
    elseif t == "cr" then
        return "assets/7card/prof_heal.png"
    elseif t == "bal" then
        return "assets/7card/prof_balance.png"
    elseif t == "def" then
        return "assets/7card/prof_defense.png"
    end
    return nil
end
function CharacterType.new(params)
    local group = display.newGroup()
    group.x = params.x or display.contentCenterX
    group.y = params.y or display.contentCenterY

    local iconSize = params.size or 32
    local headers = {
        ["apikey"] = supabase.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
    }
    local url = string.format("%s/rest/v1/characters?select=card_type&uuid=eq.%s", supabase.SUPABASE_URL,
        tostring(params.characterId))

    local function networkListener(event)
        if event.isError then
            print("Erro ao buscar tipo de carta:", event.response)
            if params.callback then
                params.callback(nil)
            end
            return
        end
        local data = json.decode(event.response)
        if data and #data > 0 and data[1].card_type then
            local imgPath = getCardTypeImage(data[1].card_type)
            if imgPath then
                local icon = display.newImageRect(group, imgPath, iconSize, iconSize)
                icon.x, icon.y = 0, 0
                if params.callback then
                    params.callback(icon)
                end
            else
                if params.callback then
                    params.callback(nil)
                end
            end
        else
            if params.callback then
                params.callback(nil)
            end
        end
    end

    network.request(url, "GET", networkListener, {
        headers = headers
    })
    return group
end

-- helper para checar existência
local function contains(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

local function getCardTypeImage(t)
    if t == "atk" then
        return "assets/7card/prof_attack.png"
    elseif t == "cr" then
        return "assets/7card/prof_heal.png"
    elseif t == "bal" then
        return "assets/7card/prof_balance.png"
    elseif t == "def" then
        return "assets/7card/prof_defense.png"
    end
    return nil
end

function scene:create(event)
    local group = self.view
    local data = userDataLib.load() or {}
    local userId = data.id

    cloudOff.show({
        time = 600
    })

    local image = display.newImageRect(group, "assets/7bg/bg_yellow_large.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    image.x, image.y = display.contentCenterX, display.contentCenterY

    local topBack = topBack.new({
        title = "Escolher Membro do Time ",
        func = "interfaces.formation.formation"
    })
    group:insert(topBack)

    scene.selectedIDs = {}
    local initialFormation = {}

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

            table.sort(recs, function(a, b)
                if a.stars ~= b.stars then
                    return a.stars > b.stars
                else
                    return a.level > b.level
                end
            end)
            -- Cria ScrollView com scrollHeight adequado
            local rowHeight = 140
            local padding = 20
            local scrollView = widget.newScrollView({
                top = -100,
                left = 0,
                width = display.contentWidth,
                height = 1200,
                scrollHeight = #recs * rowHeight + padding,
                horizontalScrollDisabled = true,
                verticalScrollDisabled = false,
                hideBackground = true
            })
            group:insert(scrollView)

            -- css
            for i, rec in ipairs(recs) do
                local rowY = (i - 1) * 160 + 100

                local cardCell = cardCell.new({
                    x = scrollView.contentWidth * 0.5,
                    y = rowY,
                    characterId = rec.characterId,
                    name = rec.name,
                    stars = rec.stars,
                    level = rec.level,
                    hp = rec.hp,
                    atk = rec.atk
                })
                scrollView:insert(cardCell)

                local isSel = contains(scene.selectedIDs, rec.id)
                local cbSel = display.newImageRect("assets/7misc/misc_check_box_selected.png", 32 * 2.5, 32 * 2.5)
                local cbUns = display.newImageRect("assets/7misc/misc_check_box_unselected.png", 32 * 2.5, 32 * 2.5)
                cbSel.x = 40 + 520
                cbSel.y = rowY + 10
                cbUns.x = cbSel.x
                cbUns.y = cbSel.y
                cbSel.isVisible = isSel
                cbUns.isVisible = not isSel
                scrollView:insert(cbUns)
                scrollView:insert(cbSel)

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

                        end
                    end
                    return true
                end
                cbSel:addEventListener("tap", toggle)
                cbUns:addEventListener("tap", toggle)
                cardCell:addEventListener("tap", toggle)

            end

            local darkShadow = display.newImageRect(group, "assets/7bg/bg_battle_spirit_psychic_surgery.png", 768,
                1136 / 2)
            darkShadow.x, darkShadow.y = display.contentCenterX, display.contentCenterY + 500

            local navbar = navbar.new()
            group:insert(navbar)

            local modalConfirm = display.newImageRect(group, "assets/7textbg/backpack.png", 250 * 1.2, 80 * 1.2)
            modalConfirm.x, modalConfirm.y = display.contentCenterX + 200, display.contentHeight + 60

            local confirmBtn = display.newImageRect(group, "assets/7button/btn_common_yellow_s9.png", 244 / 1.1,
                76 / 1.1)
            confirmBtn.x, confirmBtn.y = modalConfirm.x - 10, modalConfirm.y
            local text = textile.new({
                group = group,
                texto = " Confirmar ",
                x = confirmBtn.x,
                y = confirmBtn.y,
                tamanho = 22,
                corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                corContorno = {0, 0, 0},
                espessuraContorno = 2
            })
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

                        cloudOn.show({
                            time = 300
                        })
                        timer.performWithDelay(300, function()
                            composer.removeScene("interfaces.formation.formation")
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
        end, {
            headers = headers
        })
    end)

end

scene:addEventListener("create", scene)
return scene
