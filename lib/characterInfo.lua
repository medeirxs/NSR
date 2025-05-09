-- lib/characterInfo.lua
local composer = require("composer")
local widget = require("widget")
local json = require("json")
local network = require("network")
local supabase = require("config.supabase")
local abilityData = require("lib.abilityData")

local cardCell = require("components.cardCell")
local card = require("components.card")
local topBack = require("components.backTop")
local textile = require("utils.textile")
local cloudOn = require("utils.cloudOn")
local cloudOff = require("utils.cloudOff")

local scene = composer.newScene()

local function wrapText(text, maxLen)
    local wrapped = ""
    local pos = 1

    while pos <= #text do
        local chunk = text:sub(pos, pos + maxLen - 1)
        wrapped = wrapped .. chunk
        if (pos + maxLen - 1) < #text then
            wrapped = wrapped .. "\n"
        end
        pos = pos + maxLen
    end

    return wrapped
end

function scene:create(event)
    local params = event.params or {}
    local characterId = params.characterId
    local sceneGroup = self.view

    -- fundo
    local background = display.newImageRect(sceneGroup, "assets/7bg/bg_yellow_large.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    background.x, background.y = display.contentCenterX, display.contentCenterY

    local bgDecoTop = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_1.png", 640, 128)
    bgDecoTop.x = display.contentCenterX
    bgDecoTop.y = -142

    local backBg = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_3.png", 128, 128)
    backBg.x = display.contentCenterX + 170
    backBg.y = -142

    local btnFilter = display.newImageRect(sceneGroup, "assets/7button/btn_help.png", 96, 96)
    btnFilter.x = display.contentCenterX + 180
    btnFilter.y = -133

    local btnBack = display.newImageRect(sceneGroup, "assets/7button/btn_close.png", 96, 96)
    btnBack.x = display.contentCenterX + 270
    btnBack.y = -133
    btnBack:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("interfaces.backpack")
            composer.gotoScene("interfaces.backpack")
            composer.removeScene("lib.characterInfo")
        end)
        timer.performWithDelay(300, function()
            cloudOff.show({
                group = display.getCurrentStage(),
                time = 600
            })
        end)
    end)

    -- placeholders de UI
    local cardDetail = display.newImageRect(sceneGroup, "assets/7bg/bg_card_detail_property.png", 588, 311)
    cardDetail.x, cardDetail.y = display.contentCenterX, 90
    local cardInfo = display.newImageRect(sceneGroup, "assets/7bg/bg_characterInfo.png", 270 * 1.95, 300 * 1.95)
    cardInfo.x, cardInfo.y = display.contentCenterX, display.contentCenterY + 70

    local abBg = display.newImageRect(sceneGroup, "assets/7textbg/tbg_brown_s9_l.png", 380 * 1.2, 40 * 1.2)
    abBg.x, abBg.y = cardInfo.x, cardInfo.y - 225
    local abTitle = textile.new({
        group = sceneGroup,
        texto = "Habilidade Comum ",
        x = abBg.x - 210,
        y = abBg.y - 26,
        tamanho = 18,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local spBg = display.newImageRect(sceneGroup, "assets/7textbg/tbg_brown_s9_l.png", 380 * 1.2, 40 * 1.2)
    spBg.x, spBg.y = cardInfo.x, cardInfo.y - 50
    local abTitle = textile.new({
        group = sceneGroup,
        texto = "Habilidade Especial ",
        x = spBg.x - 210,
        y = spBg.y - 26,
        tamanho = 18,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    -- loading
    local loading = display.newText({
        parent = sceneGroup,
        text = "Carregando...",
        x = display.contentCenterX,
        y = display.contentCenterY,
        font = native.systemFontBold,
        fontSize = 18
    })

    local function formatAbilityKey(key)
        local s = key:gsub("_", " ")
        return (s:gsub("(%w)(%w*)", function(a, b)
            return a:upper() .. b:lower()
        end))
    end

    local function onFetch(event)
        loading:removeSelf()
        if event.isError then
            native.showAlert("Erro", "Não foi possível carregar detalhes.", {"OK"})
            return
        end
        local list = json.decode(event.response) or {}
        local detail = list[1] or {}

        -- exibe cardCell com dados reais
        local card = card.new({
            x = 143,
            y = cardDetail.y - 8,
            characterId = params.characterId,
            stars = params.stars,
            scaleFactor = 1.05
        })
        sceneGroup:insert(card)

        -- texto nome
        local nameText = textile.new({
            group = card,
            texto = " " .. params.name .. " ",
            x = cardDetail.x + 108,
            y = cardDetail.y - 105,
            tamanho = 20,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2
        })
        sceneGroup:insert(nameText)

        local function calculateMaxLevel(stars)
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
            else
                return 130 -- valor máximo, caso ultrapasse
            end
        end

        local starsCount = calculateMaxLevel(params.star)
        local levelText = textile.new({
            group = card,
            texto = " " .. params.level .. "/" .. starsCount .. " ",
            x = cardDetail.x + 250,
            y = cardDetail.y - 45,
            tamanho = 22,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100
        })
        sceneGroup:insert(levelText)

        local function cardType(card_type)
            if card_type == "atk" then
                return "Ataque"
            elseif card_type == "cr" then
                return "Cura"
            elseif card_type == "def" then
                return "Defesa"
            elseif card_type == "bal" then
                return "Balanço"
            else
                return "Ataque" -- valor máximo, caso ultrapasse
            end
        end

        local type = cardType(tostring(detail.card_type))
        local typeText = textile.new({
            group = card,
            texto = " " .. type .. " ",
            x = cardDetail.x + 250,
            y = cardDetail.y - 5,
            tamanho = 22,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100
        })
        sceneGroup:insert(typeText)

        local atkText = textile.new({
            group = card,
            texto = " " .. params.atk .. " ",
            x = cardDetail.x + 250,
            y = cardDetail.y + 35,
            tamanho = 22,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100
        })
        sceneGroup:insert(atkText)

        local atkText = textile.new({
            group = card,
            texto = " " .. params.hp .. " ",
            x = cardDetail.x + 250,
            y = cardDetail.y + 35 + 41,
            tamanho = 22,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100
        })
        sceneGroup:insert(atkText)

        local nvIcon = display.newImageRect(sceneGroup, "assets/7icon/icon_level.png", 48, 48)
        nvIcon.x, nvIcon.y = cardDetail.x - 10, cardDetail.y - 53

        local function imgType(cardT)
            if cardT == "atk" then
                return "assets/7card/prof_attack.png"
            elseif cardT == "cr" then
                return "assets/7card/prof_heal.png"
            elseif cardT == "def" then
                return "assets/7card/prof_defense.png"
            elseif cardT == "bal" then
                return "assets/7card/prof_balance.png"
            else
                return "Ataque" -- valor máximo, caso ultrapasse
            end
        end

        local type = imgType(tostring(detail.card_type))
        local cardTye = display.newImageRect(sceneGroup, type, 48 / 1.2, 48 / 1.2)
        cardTye.x, cardTye.y = cardDetail.x - 10, cardDetail.y - 10

        local iconAtk = display.newImageRect(sceneGroup, "assets/7icon/icon_atk.png", 48, 48)
        iconAtk.x, iconAtk.y = cardDetail.x - 10, cardDetail.y + 30

        local iconHp = display.newImageRect(sceneGroup, "assets/7icon/icon_hp.png", 48, 48)
        iconHp.x, iconHp.y = cardDetail.x - 10, cardDetail.y + 70
        -- mapeia ab/sp
        local abKey = detail.ab or ""
        local spKey = detail.sp or ""
        local abInfo = abilityData[abKey] or {
            name = formatAbilityKey(abKey),
            desc = ""
        }
        local spInfo = abilityData[spKey] or {
            name = spKey,
            desc = ""
        }

        local abName = textile.new({
            group = sceneGroup,
            texto = abInfo.name .. " ",
            x = abBg.x - 210,
            y = abBg.y + 3,
            tamanho = 22,
            corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 0
        })

        local ABdesc = abInfo.desc .. " "
        local abDescFormated = wrapText(ABdesc, 36)
        local abDesc = textile.new({
            group = sceneGroup,
            texto = abDescFormated,
            x = abBg.x - 212,
            y = abBg.y + 25,
            tamanho = 21.5,
            corTexto = {0.5137, 0.2841, 0.0588},
            corContorno = {0, 0, 0, 0},
            espessuraContorno = 2,
            anchorX = 0,
            anchorY = 0
        })

        local spName = textile.new({
            group = sceneGroup,
            texto = spInfo.name .. " ",
            x = spBg.x - 210,
            y = spBg.y + 3,
            tamanho = 22,
            corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 0
        })
        local spDesc = spInfo.desc .. " "
        local spDescFormated = wrapText(spDesc, 36)
        local spDesc = textile.new({
            group = sceneGroup,
            texto = spDescFormated,
            x = spBg.x - 212,
            y = spBg.y + 25,
            tamanho = 21.5,
            corTexto = {0.5137, 0.2841, 0.0588},
            corContorno = {0, 0, 0, 0},
            espessuraContorno = 2,
            anchorX = 0,
            anchorY = 0
        })

    end

    local url = string.format("%s/rest/v1/characters?select=ab,sp,health,attack,name,stars,card_type&uuid=eq.%s",
        supabase.SUPABASE_URL, tostring(characterId))
    network.request(url, "GET", onFetch, {
        headers = {
            ["apikey"] = supabase.SUPABASE_ANON_KEY,
            ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
        }
    })
end

scene:addEventListener("create", scene)
return scene
