local userDataLib = require("lib.userData")
local supabase = require("config.supabase")
local card_s = require("components.cardRise")
local json = require("json")

local component = {}

-- Exibe sempre dois cards de evolução, mostrando ou ocultando o segundo,
-- e nos casos de itens (stars 2,3,4,7), busca e exibe quantity / 1 para cada item
-- params:
--   x, y: posição base
--   characterId: ID do personagem
--   stars: nível de evolução
--   scaleFactor: escala opcional
function component.new(params)
    local group = display.newGroup()

    -- Parâmetros
    local baseX = params.x or display.contentCenterX
    local baseY = params.y or display.contentCenterY
    local characterId = params.characterId
    local stars = tonumber(params.stars) or 0
    local scaleFactor = params.scaleFactor or 1

    -- User info
    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 461752844
    local serverId = tonumber(data.server) or 1

    --------------------------------------------------------------------------------
    -- 1) Exibição de items especiais (stars = 2,3,4,7)
    --------------------------------------------------------------------------------
    local assetsByStars = {
        [2] = {
            ["fa6a4997-cc7e-4a9e-a977-f08ea4f7ae82"] = "assets/7items/yellow_pill.png",
            ["4a66104b-d370-4582-a583-39750e223e6f"] = "assets/7items/green_pill.png",
            ["02ea015b-e52c-4a60-89d6-b081048135c1"] = "assets/7items/red_pill.png"
        },
        [3] = {
            ["f76b1b27-6eda-4e0f-b8f5-889d4444a892"] = "assets/7items/water_paper.png",
            ["c9938580-3ad2-42c4-b526-3e92f9362367"] = "assets/7items/fire_paper.png",
            ["7b5c85fe-c11d-4e6d-8765-94dc39850e85"] = "assets/7items/thunder_paper.png"
        },
        [4] = {
            ["2b70ab29-4c4d-4efa-9903-2207fb16a82c"] = "assets/7items/water.png",
            ["8bf99e1b-c655-47e4-8b3f-5ef778c995b7"] = "assets/7items/earth.png",
            ["17603f91-cabc-4d09-8430-1b189066e8a6"] = "assets/7items/fire.png",
            ["3c2b103f-2b41-4347-8ea2-cf79aeef220b"] = "assets/7items/thunder.png",
            ["88554fbd-ea57-4909-9c67-b370c6d7fb89"] = "assets/7items/wind.png"
        },
        [7] = {
            ["83749125-dd27-4c01-93e2-49ae2b5de364"] = "assets/7items/ninja_certificate.png"
        }
    }
    local itemMap = assetsByStars[stars]
    if itemMap then
        local spacing = 110 * scaleFactor

        local idx = 0
        -- Para cada itemId e imagem
        for itemId, imgPath in pairs(itemMap) do
            idx = idx + 1
            local img = display.newImageRect(group, imgPath, 104, 104)
            img.anchorX = 0;
            img.anchorY = 0.5
            img.x = baseX + (idx - 1) * spacing
            img.y = baseY
            group:insert(img)

            -- Requisita quantity em user_items
            local url = string.format("%s/rest/v1/user_items?userId=eq.%d&itemId=eq.%s&select=quantity",
                supabase.SUPABASE_URL, userId, itemId)
            local function onItemsResponse(event)
                if not event.isError then
                    local data = json.decode(event.response)
                    local qty = (data and data[1] and data[1].quantity) or 0
                    local txt = display.newText {
                        text = qty .. " / 1",
                        x = img.x + img.contentWidth * 0.5,
                        y = img.y + img.contentHeight * 0.5 + 10,
                        font = native.systemFont,
                        fontSize = 14
                    }
                    txt.anchorX = 0.5;
                    txt.anchorY = 0
                    group:insert(txt)
                else
                    print("Erro ao buscar user_items:", event.response)
                end
            end
            network.request(url, "GET", onItemsResponse, {
                headers = {
                    ["apikey"] = supabase.SUPABASE_ANON_KEY,
                    ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
                }
            })
        end
        return group
    end

    --------------------------------------------------------------------------------
    -- 2) Exibição de cards para stars = 5,6,8,9,10 (sempre dois slots)
    --------------------------------------------------------------------------------
    local displayMap = {
        [5] = {
            first = 5,
            second = 0
        },
        [6] = {
            first = 5,
            second = 5
        },
        [8] = {
            first = 8,
            second = 0
        },
        [9] = {
            first = 8,
            second = 8
        },
        [10] = {
            first = 9,
            second = 0
        }
    }
    local cfg = displayMap[stars] or {
        first = 0,
        second = 0
    }
    local cardWidth = 104 * 1.15 * scaleFactor
    local gap = 20 * scaleFactor
    local spacing = cardWidth + gap

    -- Primeiro card
    local c1 = card_s.new {
        characterId = characterId,
        stars = cfg.first,
        scaleFactor = scaleFactor - 0.1
    }
    c1.anchorChildren = true;
    c1.anchorX = 0;
    c1.anchorY = 0.5
    c1.x = baseX;
    c1.y = baseY
    c1.isVisible = cfg.first > 0
    group:insert(c1)
    -- Segundo card
    local c2 = card_s.new {
        characterId = characterId,
        stars = cfg.second,
        scaleFactor = scaleFactor - 0.1

    }
    c2.anchorChildren = true;
    c2.anchorX = 0;
    c2.anchorY = 0.5
    c2.x = baseX + spacing;
    c2.y = baseY
    c2.isVisible = cfg.second > 0
    group:insert(c2)

    return group
end

return component
