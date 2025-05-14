-- interfaces/growing/raise.lua
local composer = require("composer")
local Card = require("components.card")
local userDataLib = require("lib.userData")
local cardSG = require("components.cardRise")
local supa = require("config.supabase")
local json = require("json")
local network = require("network")
local widget = require("widget")
local textile = require("utils.textile")

local scene = composer.newScene()

-- máximo de stars permitidos
local MAX_STARS = 11

-- requisitos de items para evoluir cada star
local starRequirements = {
    [2] = {"fa6a4997-cc7e-4a9e-a977-f08ea4f7ae82", "4a66104b-d370-4582-a583-39750e223e6f",
           "02ea015b-e52c-4a60-89d6-b081048135c1"},
    [3] = {"f76b1b27-6eda-4e0f-b8f5-889d4444a892", "c9938580-3ad2-42c4-b526-3e92f9362367",
           "7b5c85fe-c11d-4e6d-8765-94dc39850e85"},
    [4] = {"2b70ab29-4c4d-4efa-9903-2207fb16a82c", "8bf99e1b-c655-47e4-8b3f-5ef778c995b7",
           "17603f91-cabc-4d09-8430-1b189066e8a6", "3c2b103f-2b41-4347-8ea2-cf79aeef220b",
           "88554fbd-ea57-4909-9c67-b370c6d7fb89"},
    [7] = {"83749125-dd27-4c01-93e2-49ae2b5de364"}
}

local itemImages = {
    ["fa6a4997-cc7e-4a9e-a977-f08ea4f7ae82"] = "assets/7items/yellow_pill.png",
    ["4a66104b-d370-4582-a583-39750e223e6f"] = "assets/7items/green_pill.png",
    ["02ea015b-e52c-4a60-89d6-b081048135c1"] = "assets/7items/red_pill.png",
    ["f76b1b27-6eda-4e0f-b8f5-889d4444a892"] = "assets/7items/water_paper.png",
    ["c9938580-3ad2-42c4-b526-3e92f9362367"] = "assets/7items/fire_paper.png",
    ["7b5c85fe-c11d-4e6d-8765-94dc39850e85"] = "assets/7items/thunder_paper.png",
    ["2b70ab29-4c4d-4efa-9903-2207fb16a82c"] = "assets/7items/water.png",
    ["8bf99e1b-c655-47e4-8b3f-5ef778c995b7"] = "assets/7items/earth.png",
    ["17603f91-cabc-4d09-8430-1b189066e8a6"] = "assets/7items/fire.png",
    ["3c2b103f-2b41-4347-8ea2-cf79aeef220b"] = "assets/7items/thunder.png",
    ["88554fbd-ea57-4909-9c67-b370c6d7fb89"] = "assets/7items/wind.png",
    ["83749125-dd27-4c01-93e2-49ae2b5de364"] = "assets/7items/ninja_certificate.png"
}

local starLevelCap = {
    [2] = 20,
    [3] = 30,
    [4] = 40,
    [5] = 60,
    [6] = 70,
    [7] = 80,
    [8] = 100,
    [9] = 110,
    [10] = 120
}

function scene:create(event)
    local sceneGroup = self.view
    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 0
    self.userId = userId

    local background = display.newImageRect(sceneGroup, "assets/7bg/bg_tab_default.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    background.x, background.y = display.contentCenterX, display.contentCenterY

    local riseGroup = display.newGroup()
    sceneGroup:insert(riseGroup)

    local characterModalL = display.newImageRect(riseGroup, "assets/7bg/dtModalInside.png", 275, 400)
    characterModalL.x, characterModalL.y = 153, display.contentCenterY - 200
    local characterModalR = display.newImageRect(riseGroup, "assets/7bg/dtModalInside.png", 275, 400)
    characterModalR.x, characterModalR.y = characterModalL.x + 335, characterModalL.y
    local itemsModal = display.newImageRect(riseGroup, "assets/7bg/riseModal.png", 500 * 1.21, 250 * 1.21)
    itemsModal.x, itemsModal.y = display.contentCenterX, display.contentCenterY + 160

    local arrow1 = display.newImageRect(riseGroup, "assets/7button/btn_arrow_3.png", 66 / 1.1, 90 / 1.1)
    arrow1.x, arrow1.y = display.contentCenterX, characterModalR.y - 100
    local arrow2 = display.newImageRect(riseGroup, "assets/7button/btn_arrow_3.png", 66 / 1.1, 90 / 1.1)
    arrow2.x, arrow2.y = display.contentCenterX, characterModalR.y + 100

    local emptyCardL = display.newImageRect(riseGroup, "assets/7card/card_holder_m.png", 400 / 1.6, 460 / 1.6)
    emptyCardL.x, emptyCardL.y = characterModalL.x, characterModalL.y - 45
    emptyCardL:addEventListener("tap", function()
        composer.gotoScene("interfaces.growing.raiseSelect", {
            effect = "slideLeft",
            time = 300,
            params = {
                userId = self.userId
            }
        })
    end)

    local emptyCardR = display.newImageRect(riseGroup, "assets/7card/card_holder_m.png", 400 / 1.6, 460 / 1.6)
    emptyCardR.x, emptyCardR.y = characterModalR.x, characterModalR.y - 45

    local levelBgBefore = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
    levelBgBefore.x, levelBgBefore.y = emptyCardL.x, display.contentCenterY - 85
    local healthBgBefore = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
    healthBgBefore.x, healthBgBefore.y = emptyCardL.x, display.contentCenterY - 55
    local attackBgBefore = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
    attackBgBefore.x, attackBgBefore.y = emptyCardL.x, display.contentCenterY - 25

    local levelBgAfter = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
    levelBgAfter.x, levelBgAfter.y = emptyCardR.x, display.contentCenterY - 85
    local healthBgAfter = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
    healthBgAfter.x, healthBgAfter.y = emptyCardR.x, display.contentCenterY - 55
    local attackBgAfter = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
    attackBgAfter.x, attackBgAfter.y = emptyCardR.x, display.contentCenterY - 25

    local levelIconL = display.newImageRect(riseGroup, "assets/7icon/icon_level.png", 48 / 1.2, 48 / 1.2)
    levelIconL.x, levelIconL.y = levelBgBefore.x - 90, levelBgBefore.y - 5
    local levelIconL = display.newImageRect(riseGroup, "assets/7icon/icon_level.png", 48 / 1.2, 48 / 1.2)
    levelIconL.x, levelIconL.y = levelBgAfter.x - 90, levelBgAfter.y - 5
    local healthIcon = display.newImageRect(riseGroup, "assets/7icon/icon_hp.png", 48 / 1.2, 48 / 1.2)
    healthIcon.x, healthIcon.y = levelBgBefore.x - 90, levelBgBefore.y + 25
    local healthIcon = display.newImageRect(riseGroup, "assets/7icon/icon_hp.png", 48 / 1.2, 48 / 1.2)
    healthIcon.x, healthIcon.y = levelBgAfter.x - 90, levelBgBefore.y + 25
    local attackIcon = display.newImageRect(riseGroup, "assets/7icon/icon_atk.png", 48 / 1.2, 48 / 1.2)
    attackIcon.x, attackIcon.y = levelBgBefore.x - 90, levelBgBefore.y + 55
    local attackIcon = display.newImageRect(riseGroup, "assets/7icon/icon_atk.png", 48 / 1.2, 48 / 1.2)
    attackIcon.x, attackIcon.y = levelBgAfter.x - 90, levelBgAfter.y + 55

    local itemEvolveEmpty1 = display.newImageRect(riseGroup, "assets/7card/card_holder_s_1.png", 125, 125)
    itemEvolveEmpty1.x, itemEvolveEmpty1.y = 82, display.contentCenterY + 75
    local itemEvolveEmpty1 = display.newImageRect(riseGroup, "assets/7card/card_holder_s_1.png", 125, 125)
    itemEvolveEmpty1.x, itemEvolveEmpty1.y = 82 + 115 + 5, display.contentCenterY + 75
    local itemEvolveEmpty1 = display.newImageRect(riseGroup, "assets/7card/card_holder_s_1.png", 125, 125)
    itemEvolveEmpty1.x, itemEvolveEmpty1.y = 82 + 230 + 10, display.contentCenterY + 75
    local itemEvolveEmpty1 = display.newImageRect(riseGroup, "assets/7card/card_holder_s_1.png", 125, 125)
    itemEvolveEmpty1.x, itemEvolveEmpty1.y = 82 + 345 + 13, display.contentCenterY + 75
    local itemEvolveEmpty1 = display.newImageRect(riseGroup, "assets/7card/card_holder_s_1.png", 125, 125)
    itemEvolveEmpty1.x, itemEvolveEmpty1.y = 82 + 460 + 15, display.contentCenterY + 75

    local bgSilver = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_11.png", 380 * 1.5, 50 * 1.8)
    bgSilver.x, bgSilver.y = display.contentCenterX, display.contentCenterY + 190

    local topBack = require("components.backTop")
    local topBack = topBack.new({
        title = ""
    })
    riseGroup:insert(topBack)
    local navbar = require("components.navBar")
    local navbar = navbar.new()
    riseGroup:insert(navbar)

    local tabEquipmentBg = display.newImageRect(sceneGroup, "assets/7button/btn_tab_light_s9.png", 236, 82)
    tabEquipmentBg.x, tabEquipmentBg.y = 330, -128
    local changeMemberText = textile.new({
        group = sceneGroup,
        texto = " Elevar Ordem ",
        x = tabEquipmentBg.x,
        y = tabEquipmentBg.y + 5,
        tamanho = 22,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local tabFormationBg = display.newImageRect(sceneGroup, "assets/7button/btn_tab_s9.png", 236, 82)
    tabFormationBg.x, tabFormationBg.y = 110, -128
    local changeMemberText = textile.new({
        group = sceneGroup,
        texto = " Elevar ",
        x = tabFormationBg.x,
        y = tabFormationBg.y + 5,
        tamanho = 22,
        corTexto = {0.6, 0.6, 0.6}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local select = textile.new({
        texto = "Selec.\numa\ncarta.",
        x = emptyCardL.x,
        y = emptyCardL.y,
        tamanho = 28,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0, 0.2},
        espessuraContorno = 2
    })
    riseGroup:insert(select)

    -- groups for card and stars
    self.cardGroup = display.newGroup()
    self.starsGroup = display.newGroup()
    sceneGroup:insert(self.cardGroup)
    sceneGroup:insert(self.starsGroup)
end

function scene:show(event)
    if event.phase ~= "did" then
        return
    end

    local recordId = _G.chaId
    if not recordId then
        return
    end

    -- clear previous
    self.cardGroup:removeSelf()
    self.cardGroup = display.newGroup()
    self.starsGroup:removeSelf()
    self.starsGroup = display.newGroup()
    self.view:insert(self.cardGroup)
    self.view:insert(self.starsGroup)

    -- headers
    local headers = {
        ["Content-Type"] = "application/json",
        ["apikey"] = supa.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
    }

    -- fetch characterId and stars
    local url = string.format(
        "%s/rest/v1/user_characters?select=characterId,stars,level,attack,health&limit=1&id=eq.%s", supa.SUPABASE_URL,
        recordId)
    network.request(url, "GET", function(evt)
        if evt.isError then
            print("Erro ao buscar character:", evt.response)
            return
        end
        local d = json.decode(evt.response)[1]
        if not d then
            return
        end

        -- show card
        local card = Card.new({
            x = 155,
            y = display.contentCenterY - 230,
            characterId = d.characterId,
            scaleFactor = 1,
            stars = d.stars
        })
        self.cardGroup:insert(card)

        local baseY = card.y + (card.height or 0) / 2 + 20 -- 20px de espaçamento

        local function getStars(stars)
            if stars == 5 then
                return 5
            elseif stars == 6 then
                return 5
            elseif stars == 8 then
                return 8
            elseif stars == 9 then
                return 8
            elseif stars == 10 then
                return 9
            end
            return nil
        end

        local convertedStars = getStars(d.stars)

        -- if d.stars == 5 then
        --     local card = cardSG.new({
        --         x = 50,
        --         y = 50,
        --         characterId = d.characterId,
        --         stars = convertedStars
        --     })
        -- end

        -- if d.stars == 6 then
        --     local card = cardSG.new({
        --         x = 50,
        --         y = 50,
        --         characterId = d.characterId,
        --         stars = convertedStars
        --     })
        --     local card2 = cardSG.new({
        --         x = card.x + 100,
        --         y = 50,
        --         characterId = d.characterId,
        --         stars = convertedStars
        --     })
        -- end

        -- if d.stars == 8 then
        --     local card = cardSG.new({
        --         x = 50,
        --         y = 50,
        --         characterId = d.characterId,
        --         stars = convertedStars
        --     })

        -- end

        -- if d.stars == 9 then
        --     local card = cardSG.new({
        --         x = 50,
        --         y = 50,
        --         characterId = d.characterId,
        --         stars = convertedStars
        --     })
        --     local card2 = cardSG.new({
        --         x = card.x + 100,
        --         y = 50,
        --         characterId = d.characterId,
        --         stars = convertedStars
        --     })
        -- end

        -- if d.stars == 10 then
        --     local card = cardSG.new({
        --         x = 50,
        --         y = 50,
        --         characterId = d.characterId,
        --         stars = convertedStars
        --     })

        -- end

        -- Level

        local function getMaxLevel(stars)
            if stars == 2 then
                return 20
            elseif stars == 3 then
                return 30
            elseif stars == 4 then
                return 40
            elseif stars == 5 then
                return 60
            elseif stars == 6 then
                return 70
            elseif stars == 7 then
                return 80
            elseif stars == 8 then
                return 100
            elseif stars == 9 then
                return 110
            elseif stars == 10 then
                return 120
            elseif stars == 11 then
                return 130
            end
            return nil
        end

        local function getNextMaxLevel(stars)
            if stars == 2 then
                return 30
            elseif stars == 3 then
                return 40
            elseif stars == 4 then
                return 60
            elseif stars == 5 then
                return 70
            elseif stars == 6 then
                return 80
            elseif stars == 7 then
                return 100
            elseif stars == 8 then
                return 110
            elseif stars == 9 then
                return 120
            elseif stars == 10 then
                return 130
            elseif stars == 11 then
                return 150
            end
            return nil
        end

        local maxLevel = getMaxLevel(d.stars)
        local upMaxLevel = getNextMaxLevel(d.stars)

        local levelText = textile.new({
            texto = d.level .. "/" .. maxLevel .. " ",
            x = display.contentCenterX - 65,
            y = display.contentCenterY - 107,
            tamanho = 20,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100,
            anchorY = 0
        })

        local healthText = textile.new({
            texto = d.health .. " ",
            x = levelText.x,
            y = display.contentCenterY - 77,
            tamanho = 20,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100,
            anchorY = 0
        })

        local attackText = textile.new({
            texto = d.attack .. " ",
            x = levelText.x,
            y = display.contentCenterY - 47,
            tamanho = 20,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100,
            anchorY = 0
        })

        local card2 = Card.new({
            x = display.contentCenterX + 170,
            y = display.contentCenterY - 230,
            characterId = d.characterId,
            scaleFactor = 1,
            stars = d.stars + 1
        })
        self.cardGroup:insert(card2)

        local baseY = card2.y + (card2.height or 0) / 2 + 20 -- 20px de espaçamento

        -- Level
        local levelText2 = textile.new({
            texto = maxLevel .. "/" .. upMaxLevel .. " ",
            x = display.contentCenterX + 270,
            y = display.contentCenterY - 107,
            tamanho = 20,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100,
            anchorY = 0
        })

        -- Health
        local healthValue = math.floor(d.health * 1.1)
        local healthText2 = textile.new({
            texto = healthValue .. " ",
            x = levelText2.x,
            y = display.contentCenterY - 77,
            tamanho = 20,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100,
            anchorY = 0
        })

        -- Attack
        local attackValue = math.floor(d.attack * 1.1)
        local attackText2 = textile.new({
            texto = attackValue .. " ",
            x = levelText2.x,
            y = display.contentCenterY - 47,
            tamanho = 20,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100,
            anchorY = 0
        })

        local advanceButton = display.newImageRect(self.starsGroup, "assets/7button/btn_common_yellow_s9_l.png",
            280 * 1.6, 40 * 1.6)
        advanceButton.x, advanceButton.y = display.contentCenterX, display.contentCenterY + 272

        local text = textile.new({
            texto = " Elevar Ordem ",
            x = advanceButton.x,
            y = advanceButton.y,
            tamanho = 24,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2
        })
        self.starsGroup:insert(text)

        -- raise handler
        local function onRaiseTap()
            -- 1) Verifica seleção
            if not _G.chaId then
                native.showAlert("Aviso", "Selecione um personagem primeiro", {"OK"})
                return
            end
            local recordId = _G.chaId

            -- cabeçalhos Supabase
            local headers = {
                ["Content-Type"] = "application/json",
                ["apikey"] = supa.SUPABASE_ANON_KEY,
                ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
            }

            -- 2) Busca characterId e stars atuais
            local getCharUrl = string.format(
                "%s/rest/v1/user_characters?select=characterId,stars,level&limit=1&id=eq.%s", supa.SUPABASE_URL,
                recordId)
            network.request(getCharUrl, "GET", function(evt)
                if evt.isError then
                    native.showAlert("Erro", "Não foi possível ler personagem", {"OK"})
                    return
                end
                local d = json.decode(evt.response)[1]
                if not d then
                    native.showAlert("Erro", "Personagem não encontrado", {"OK"})
                    return
                end

                local currentStars = d.stars or 0
                local currentLevel = d.level or 0
                local charUuid = d.characterId

                local requiredLevel = starLevelCap[currentStars]
                if requiredLevel and currentLevel < requiredLevel then
                    native.showAlert("Aviso", "Para evoluir de " .. currentStars .. "→" .. (currentStars + 1) ..
                        " stars, o personagem deve estar pelo menos no nível " .. requiredLevel, {"OK"})
                    return
                end

                -- CASE 1: Stars 2→3, 3→4, 4→5 via itens
                if currentStars >= 2 and currentStars < 8 then
                    local req = starRequirements[currentStars]
                    -- 3) Busca inventário do usuário
                    local fetchItemsUrl = string.format("%s/rest/v1/user_items?userId=eq.%s&select=itemId,quantity,id",
                        supa.SUPABASE_URL, scene.userId)
                    network.request(fetchItemsUrl, "GET", function(fe)
                        if fe.isError then
                            native.showAlert("Erro", "Não foi possível ler inventário", {"OK"})
                            return
                        end
                        local allItems = json.decode(fe.response) or {}
                        local map = {}
                        for _, r in ipairs(allItems) do
                            map[r.itemId] = r
                        end

                        -- 4) Verifica requisitos
                        for _, needed in ipairs(req) do
                            local rec = map[needed]
                            if not rec or rec.quantity < 1 then
                                native.showAlert("Aviso", "Faltam itens para evoluir stars", {"OK"})
                                return
                            end
                        end

                        -- 5) Consome itens
                        local pending = #req
                        for _, needed in ipairs(req) do
                            local rec = map[needed]
                            network.request(string.format("%s/rest/v1/user_items?id=eq.%s", supa.SUPABASE_URL, rec.id),
                                "PATCH", function(pi)
                                    pending = pending - 1
                                    if pending == 0 then
                                        -- 6) Evolui stars
                                        network.request(string.format("%s/rest/v1/user_characters?id=eq.%s",
                                            supa.SUPABASE_URL, recordId), "PATCH", function(pc)
                                            if pc.isError then
                                                native.showAlert("Erro", "Falha ao evoluir stars", {"OK"})
                                                return
                                            end
                                            native.showAlert("Sucesso", "Stars evoluídas!", {"OK"})
                                            composer.reloadScene()
                                        end, {
                                            headers = headers,
                                            body = json.encode({
                                                stars = currentStars + 1
                                            })
                                        })
                                    end
                                end, {
                                    headers = headers,
                                    body = json.encode({
                                        quantity = rec.quantity - 1
                                    })
                                })
                        end
                    end, {
                        headers = headers
                    })

                    -- CASE 2: Stars 5→6 via consumo de 1 personagem stars=5
                elseif currentStars == 5 then
                    local fetchUrl = string.format(
                        "%s/rest/v1/user_characters?select=id&characterId=eq.%s&stars=eq.5&id=neq.%s",
                        supa.SUPABASE_URL, charUuid, recordId)
                    network.request(fetchUrl, "GET", function(fe)
                        if fe.isError then
                            native.showAlert("Erro", "Não foi possível ler personagens", {"OK"})
                            return
                        end
                        local recs = json.decode(fe.response) or {}
                        if #recs < 1 then
                            native.showAlert("Aviso", "Você precisa de mais 1 personagem Stars 5", {"OK"})
                            return
                        end
                        -- 4) Deleta 1 personagem
                        local otherId = recs[1].id
                        network.request(
                            string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL, otherId), "DELETE",
                            function(pd)
                                if pd.isError then
                                    native.showAlert("Erro", "Falha ao consumir personagem", {"OK"})
                                    return
                                end
                                -- 5) Evolui o selecionado
                                network.request(string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL,
                                    recordId), "PATCH", function(pp)
                                    if pp.isError then
                                        native.showAlert("Erro", "Falha ao evoluir stars", {"OK"})
                                        return
                                    end
                                    native.showAlert("Sucesso", "Stars evoluídas para 6!", {"OK"})
                                    composer.reloadScene()
                                end, {
                                    headers = headers,
                                    body = json.encode({
                                        stars = 6
                                    })
                                })
                            end, {
                                headers = headers
                            })
                    end, {
                        headers = headers
                    })

                    -- CASE 3: Stars 6→7 via consumo de 2 personagens stars=5
                elseif currentStars == 6 then
                    local fetchUrl = string.format(
                        "%s/rest/v1/user_characters?select=id&characterId=eq.%s&stars=eq.5&id=neq.%s",
                        supa.SUPABASE_URL, charUuid, recordId)
                    network.request(fetchUrl, "GET", function(fe)
                        if fe.isError then
                            native.showAlert("Erro", "Não foi possível ler personagens", {"OK"})
                            return
                        end
                        local recs = json.decode(fe.response) or {}
                        if #recs < 2 then
                            native.showAlert("Aviso", "Você precisa de 2 personagens Stars 5", {"OK"})
                            return
                        end
                        -- 4) Deleta os dois primeiros
                        local deleted = 0
                        for i = 1, 2 do
                            local otherId = recs[i].id
                            network.request(string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL,
                                otherId), "DELETE", function(pd)
                                deleted = deleted + 1
                                if deleted == 2 then
                                    -- 5) Evolui o selecionado
                                    network.request(string.format("%s/rest/v1/user_characters?id=eq.%s",
                                        supa.SUPABASE_URL, recordId), "PATCH", function(pp)
                                        if pp.isError then
                                            native.showAlert("Erro", "Falha ao evoluir stars", {"OK"})
                                            return
                                        end
                                        native.showAlert("Sucesso", "Stars evoluídas para 7!", {"OK"})
                                        composer.reloadScene()
                                    end, {
                                        headers = headers,
                                        body = json.encode({
                                            stars = 7
                                        })
                                    })
                                end
                            end, {
                                headers = headers
                            })
                        end
                    end, {
                        headers = headers
                    })
                    -- Stars 8→9: consome 1 outro personagem stars=8
                elseif currentStars == 8 then
                    local fetchUrl = string.format(
                        "%s/rest/v1/user_characters?select=id&characterId=eq.%s&stars=eq.8&id=neq.%s",
                        supa.SUPABASE_URL, charUuid, recordId)
                    network.request(fetchUrl, "GET", function(fe)
                        local recs = json.decode(fe.response) or {}
                        if #recs < 1 then
                            native.showAlert("Aviso", "Precisa de 1 personagem Stars 8", {"OK"})
                            return
                        end
                        local otherId = recs[1].id
                        network.request(
                            string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL, otherId), "DELETE",
                            function(pd)
                                if pd.isError then
                                    return
                                end
                                -- evolui para 9
                                network.request(string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL,
                                    recordId), "PATCH", function(pp)
                                    composer.reloadScene()
                                end, {
                                    headers = headers,
                                    body = json.encode({
                                        stars = 9
                                    })
                                })
                            end, {
                                headers = headers
                            })
                    end, {
                        headers = headers
                    })

                    -- Stars 9→10: consome 2 personagens stars=8
                elseif currentStars == 9 then
                    local fetchUrl = string.format(
                        "%s/rest/v1/user_characters?select=id&characterId=eq.%s&stars=eq.8&id=neq.%s",
                        supa.SUPABASE_URL, charUuid, recordId)
                    network.request(fetchUrl, "GET", function(fe)
                        local recs = json.decode(fe.response) or {}
                        if #recs < 2 then
                            native.showAlert("Aviso", "Precisa de 2 personagens Stars 8", {"OK"})
                            return
                        end
                        local toDelete = {recs[1].id, recs[2].id}
                        local done = 0
                        for _, otherId in ipairs(toDelete) do
                            network.request(string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL,
                                otherId), "DELETE", function(pd)
                                done = done + 1
                                if done == 2 then
                                    network.request(string.format("%s/rest/v1/user_characters?id=eq.%s",
                                        supa.SUPABASE_URL, recordId), "PATCH", function(pp)
                                        composer.reloadScene()
                                    end, {
                                        headers = headers,
                                        body = json.encode({
                                            stars = 10
                                        })
                                    })
                                end
                            end, {
                                headers = headers
                            })
                        end
                    end, {
                        headers = headers
                    })

                    -- Stars 10→11: consome 1 personagem stars=9
                elseif currentStars == 10 then
                    local fetchUrl = string.format(
                        "%s/rest/v1/user_characters?select=id&characterId=eq.%s&stars=eq.9&id=neq.%s",
                        supa.SUPABASE_URL, charUuid, recordId)
                    network.request(fetchUrl, "GET", function(fe)
                        local recs = json.decode(fe.response) or {}
                        if #recs < 1 then
                            native.showAlert("Aviso", "Precisa de 1 personagem Stars 9", {"OK"})
                            return
                        end
                        local otherId = recs[1].id
                        network.request(
                            string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL, otherId), "DELETE",
                            function(pd)
                                if pd.isError then
                                    return
                                end
                                network.request(string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL,
                                    recordId), "PATCH", function(pp)
                                    composer.reloadScene()
                                end, {
                                    headers = headers,
                                    body = json.encode({
                                        stars = 11
                                    })
                                })
                            end, {
                                headers = headers
                            })
                    end, {
                        headers = headers
                    })

                else
                    native.showAlert("Aviso", "Evolução de Stars " .. currentStars .. " não implementada", {"OK"})
                end
            end, {
                headers = headers
            })
        end

        advanceButton:addEventListener("tap", onRaiseTap)
    end, {
        headers = headers
    })
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
