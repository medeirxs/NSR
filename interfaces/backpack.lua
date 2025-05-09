-- interfaces/backpackCards.lua
local composer = require("composer")
local widget = require("widget")
local json = require("json")
local network = require("network")
local supabase = require("config.supabase")
local userDataLib = require("lib.userData")
local cardCell = require("components.cardCell")
local itemCell = require("components.itemCell")

local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view

    -- Fundo opcional
    display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth,
        display.contentHeight):setFillColor(0.1)

    -- Dados do usuário
    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 461752844

    -- ScrollView para cartas e itens
    local scrollView = widget.newScrollView({
        top = 0,
        left = 0,
        width = display.contentWidth,
        height = display.contentHeight,
        horizontalScrollDisabled = true,
        backgroundColor = {0, 0, 0, 0}
    })
    sceneGroup:insert(scrollView)

    -- Parâmetros de layout
    local cardHeight = 132 -- altura da célula de carta
    local cardSpacing = 20 -- espaçamento extra entre cartas
    local cardCellH = cardHeight + cardSpacing
    local itemCellH = 100 + 10 -- altura + padding para itens
    local padding = 10
    local cardCount = 0

    -- Mapas locais de itens (sprites, nomes e estrelas)
    local spriteMap = {
        ["cd0d2985-9685-46d8-b873-5fa73bfaa5e8"] = "assets/7items/sushi.png",
        ["fdb9aa25-777c-4e0e-981e-151a6dc9a7d2"] = "assets/7items/sushi_legendary.png",
        ["df3844b9-4cf6-431d-91dc-1fff1f4501fd"] = "assets/7items/frog.png",
        ["822fc356-358e-4161-85e9-fa19858822f2"] = "assets/7items/frog_purple.png"
    }
    local nameMap = {
        ["cd0d2985-9685-46d8-b873-5fa73bfaa5e8"] = "Sushi de Exp",
        ["fdb9aa25-777c-4e0e-981e-151a6dc9a7d2"] = "Sushi de Exp Lendário",
        ["df3844b9-4cf6-431d-91dc-1fff1f4501fd"] = "Estátua de Sapo",
        ["822fc356-358e-4161-85e9-fa19858822f2"] = "Estátua de Sapo Elite"
    }
    local starMap = {
        ["cd0d2985-9685-46d8-b873-5fa73bfaa5e8"] = 5,
        ["fdb9aa25-777c-4e0e-981e-151a6dc9a7d2"] = 6,
        ["df3844b9-4cf6-431d-91dc-1fff1f4501fd"] = 4,
        ["822fc356-358e-4161-85e9-fa19858822f2"] = 5
    }

    -- Listener dos itens (duplica conforme quantity e ordena por stars e nome)
    local function onItemsResponse(evt)
        if evt.isError then
            native.showAlert("Erro", "Falha ao carregar itens.", {"OK"})
            return
        end
        local items = json.decode(evt.response)
        if items and #items > 0 then
            -- Ordena itens por stars (crescente) e depois por nome (alfabético)
            table.sort(items, function(a, b)
                local sa = starMap[a.itemId] or 0
                local sb = starMap[b.itemId] or 0
                if sa ~= sb then
                    return sa < sb
                end
                local na = nameMap[a.itemId] or ""
                local nb = nameMap[b.itemId] or ""
                return na < nb
            end)
            -- Calcula quantidade total de células (somatório dos quantities)
            local totalQty = 0
            for _, it in ipairs(items) do
                totalQty = totalQty + (tonumber(it.quantity) or 0)
            end

            local startY = cardCount * cardCellH + itemCellH * 0.5 + padding * 2
            local idx = 1
            for _, it in ipairs(items) do
                local qty = tonumber(it.quantity) or 0
                for i = 1, qty do
                    local y = startY + (idx - 1) * itemCellH
                    scrollView:insert(itemCell.new({
                        x = display.contentCenterX,
                        y = y,
                        itemId = it.itemId,
                        quantity = 1, -- cada célula exibe 1 unidade
                        name = nameMap[it.itemId] or "Item",
                        stars = starMap[it.itemId] or 0,
                        sprite = spriteMap[it.itemId] or ""
                    }))
                    idx = idx + 1
                end
            end
            scrollView:setScrollHeight(cardCount * cardCellH + totalQty * itemCellH + padding * 4)
        end
    end

    -- Listener das cartas (com espaçamento ajustável)
    local function onCardsResponse(evt)
        if evt.isError then
            native.showAlert("Erro", "Falha ao carregar cartas.", {"OK"})
            return
        end
        local cards = json.decode(evt.response) or {}
        cardCount = #cards
        for i = 1, cardCount do
            local c = cards[i]
            -- Calcula y incluindo cardSpacing
            local y = cardHeight * 0.5 + padding + (i - 1) * (cardHeight + cardSpacing)
            scrollView:insert(cardCell.new({
                x = display.contentCenterX,
                y = y,
                characterId = c.characterId,
                stars = c.stars,
                level = c.level,
                hp = c.hp,
                atk = c.atk,
                name = c.name or "Ninja"
            }))
        end
        -- Monta URL de itens
        local wanted = {"cd0d2985-9685-46d8-b873-5fa73bfaa5e8", "fdb9aa25-777c-4e0e-981e-151a6dc9a7d2",
                        "df3844b9-4cf6-431d-91dc-1fff1f4501fd", "822fc356-358e-4161-85e9-fa19858822f2"}
        local idsParam = table.concat(wanted, ",")
        local itemsUrl = string.format("%s/rest/v1/user_items?select=itemId,quantity&userId=eq.%s&itemId=in.(%s)",
            supabase.SUPABASE_URL, tostring(userId), idsParam)
        network.request(itemsUrl, "GET", onItemsResponse, {
            headers = {
                ["apikey"] = supabase.SUPABASE_ANON_KEY,
                ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
            }
        })
    end

    -- Dispara fetch de cartas
    local cardsUrl = string.format("%s/rest/v1/user_characters?select=characterId,name,level,stars,hp,atk&userId=eq.%s",
        supabase.SUPABASE_URL, tostring(userId))
    network.request(cardsUrl, "GET", onCardsResponse, {
        headers = {
            ["apikey"] = supabase.SUPABASE_ANON_KEY,
            ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
        }
    })
end

scene:addEventListener("create", scene)
return scene
