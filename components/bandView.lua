-- components/bandView.lua
local bandView = {}
local composer = require("composer")
local json = require("json")
local network = require("network")
local supabase = require("config.supabase")
local apiUsers = require("api.getUsers")
local card_s = require("components.cardS")
local textile = require("utils.textile")
local cloudOn = require("utils.cloudOn") -- entrada

function bandView.new(params)
    local group = display.newGroup()
    local x0, y0 = params.x or display.contentCenterX, params.y or display.contentCenterY
    local userId = params.userId
    local serverId = params.serverId
    local offsetX = params.offsetX or 110
    local offsetY = params.offsetY or 0
    local scaleFactor = params.scaleFactor or 1
    local offsetList = params.offsetList or {}

    local image = display.newImageRect(group, "assets/7bg/band_view_bg.png", 640, 260)
    image.x, image.y = x0, y0

    local text = textile.new({
        group = group,
        texto = " Meu Grupo ",
        x = x0,
        y = y0 - 85,
        tamanho = 28,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })
    group:insert(text)

    local placeHolder1 = display.newImageRect(group, "assets/7card/card_placeholder_s.png", 102, 102)
    placeHolder1.x, placeHolder1.y = 87, y0 - 15
    placeHolder1.alpha = 0.7
    local placeHolder2 = display.newImageRect(group, "assets/7card/card_placeholder_s.png", 102, 102)
    placeHolder2.x, placeHolder2.y = 203, y0 - 15
    placeHolder2.alpha = 0.7
    local placeHolder3 = display.newImageRect(group, "assets/7card/card_placeholder_s.png", 102, 102)
    placeHolder3.x, placeHolder3.y = 319, y0 - 15
    placeHolder3.alpha = 0.7
    local placeHolder4 = display.newImageRect(group, "assets/7card/card_placeholder_s.png", 102, 102)
    placeHolder4.x, placeHolder4.y = 435, y0 - 15
    placeHolder4.alpha = 0.7
    local placeHolder5 = display.newImageRect(group, "assets/7card/card_placeholder_s.png", 102, 102)
    placeHolder5.x, placeHolder5.y = 551, y0 - 15
    placeHolder5.alpha = 0.7

    local addButton1 = display.newImageRect(group, "assets/7button/btn_add.png", 92 * 1.1, 92 * 1.1)
    addButton1.x, addButton1.y = placeHolder1.x, placeHolder1.y - 2
    addButton1:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("interfaces.formation.formation")
            composer.gotoScene("interfaces.formation.formation")
        end)
    end)
    local addButton2 = display.newImageRect(group, "assets/7button/btn_add.png", 92 * 1.1, 92 * 1.1)
    addButton2.x, addButton2.y = placeHolder2.x, placeHolder2.y - 2
    addButton2:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("interfaces.formation.formation")
            composer.gotoScene("interfaces.formation.formation")
        end)
    end)
    local addButton3 = display.newImageRect(group, "assets/7button/btn_add.png", 92 * 1.1, 92 * 1.1)
    addButton3.x, addButton3.y = placeHolder3.x, placeHolder3.y - 2
    addButton3:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("interfaces.formation.formation")
            composer.gotoScene("interfaces.formation.formation")
        end)
    end)
    local addButton4 = display.newImageRect(group, "assets/7button/btn_add.png", 92 * 1.1, 92 * 1.1)
    addButton4.x, addButton4.y = placeHolder4.x, placeHolder4.y - 2
    addButton4:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("interfaces.formation.formation")
            composer.gotoScene("interfaces.formation.formation")
        end)
    end)
    local addButton5 = display.newImageRect(group, "assets/7button/btn_add.png", 92 * 1.1, 92 * 1.1)
    addButton5.x, addButton5.y = placeHolder5.x, placeHolder5.y - 2
    addButton5:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("interfaces.formation.formation")
            composer.gotoScene("interfaces.formation.formation")
        end)
    end)

    local costIcon = display.newImageRect(group, "assets/7icon/icon_cost.png", 48 / 1.2, 48 / 1.2)
    costIcon.x, costIcon.y = x0 - 215, y0 + 78
    local costText = textile.new({
        group = group,
        texto = " 0/210 ",
        x = costIcon.x + 70,
        y = costIcon.y + 4,
        tamanho = 22,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local powerIcon = display.newImageRect(group, "assets/7icon/icon_battle_ability.png", 72 / 1.2, 72 / 1.2)
    powerIcon.x, powerIcon.y = x0 + 65, y0 + 78
    local costText = textile.new({
        group = group,
        texto = " 128878 ",
        x = powerIcon.x + 20,
        y = powerIcon.y + 4,
        tamanho = 22,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    -- busca formação do usuário
    apiUsers.fetchFormation(userId, function(formation, err)
        if err then
            print("Erro ao carregar formation:", err)
            return
        end

        -- compacta formation tirando nils (não usar ipairs aqui)
        local cleanFormation = {}
        for idx = 1, #formation do
            local id = formation[idx]
            if id ~= nil then
                table.insert(cleanFormation, id)
            end
        end
        formation = cleanFormation

        -- para cada slot na formation, busca dados e cria card_s
        for i, ucId in ipairs(formation) do
            local baseX = x0 + (i - 1) * offsetX - 233
            local baseY = y0 + (i - 1) * offsetY - 14
            local extra = offsetList[i] or {}
            local px = baseX + (extra.x or 0)
            local py = baseY + (extra.y or 0)

            if ucId then
                -- busca characterId e stars na tabela user_characters
                local url = string.format("%s/rest/v1/user_characters?select=characterId,stars,level&id=eq.%d",
                    supabase.SUPABASE_URL, ucId)
                local headers = {
                    ["apikey"] = supabase.SUPABASE_ANON_KEY,
                    ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
                }
                network.request(url, "GET", function(ev)
                    if ev.isError or ev.status ~= 200 then
                        print("Erro ao buscar user_characters:", ev.response)
                        -- fallback: card vazio
                        local card = card_s.new {
                            x = px,
                            y = py,
                            scaleFactor = scaleFactor
                        }
                        group:insert(card)
                        return
                    end
                    local rec = json.decode(ev.response)
                    if rec and #rec > 0 then
                        local charId = rec[1].characterId
                        local stars = rec[1].stars or 2
                        local lvl = rec[1].level or 1
                        local card = card_s.new {
                            x = px,
                            y = py,
                            characterId = charId,
                            stars = stars,
                            scaleFactor = 0.9
                        }
                        group:insert(card)

                        local levelText = textile.new({
                            group = group,
                            texto = " Nv" .. lvl .. ' ',
                            x = card.x,
                            y = card.y + 63,
                            tamanho = 20,
                            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                            corContorno = {0, 0, 0},
                            espessuraContorno = 2

                        })
                    else
                        -- placeholder vazio
                        local card = card_s.new {
                            x = px,
                            y = py,
                            scaleFactor = scaleFactor
                        }
                        group:insert(card)
                    end
                end, {
                    headers = headers
                })
            else
                -- slot vazio
                local card = card_s.new {
                    x = px,
                    y = py,
                    scaleFactor = scaleFactor
                }
                group:insert(card)
            end
        end

    end)

    return group
end

return bandView
