local composer = require("composer")
local widget = require("widget")

local textile = require("utils.textile")
local card = require("components.card")
local navBar = require("components.navBar")
local topBack = require("components.backTop")

local scene = composer.newScene()

function scene:create(event)

    local group = self.view

    local image = display.newImageRect(group, "assets/7bg/bg_yellow_large.jpg", display.contentWidth,
        display.contentHeight * 1.44) -- 
    image.x = display.contentCenterX
    image.y = display.contentCenterY

    local modalGroup = display.newGroup()
    group:insert(modalGroup)

    local dtModal = display.newImageRect(modalGroup, "assets/7bg/dt_modal.png", 600 * 1.05, 750 * 1.05)
    dtModal.x, dtModal.y = display.contentCenterX, display.contentCenterY

    local dtModalBgRemaining = display.newImageRect(modalGroup, "assets/7textbg/tbg_black_s9_11.png", 380 * 1.3, 50)
    dtModalBgRemaining.x, dtModalBgRemaining.y = display.contentCenterX, display.contentCenterY - 345
    dtModalBgRemaining.alpha = 0.6

    local remainingToChallenge = textile.new({
        group = group,
        texto = "Tempo restante para desafio:",
        x = dtModalBgRemaining.x,
        y = dtModalBgRemaining.y - 13,
        tamanho = 23,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })
    local remainingHours = textile.new({
        group = group,
        texto = "24 horas",
        x = dtModalBgRemaining.x,
        y = remainingToChallenge.y + 25,
        tamanho = 23,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local modalCardsT = display.newImageRect(modalGroup, "assets/7bg/bg_sociaty_1.png", 252 * 2.3, 244 * 2.1)
    modalCardsT.x, modalCardsT.y = display.contentCenterX, display.contentCenterY - 60
    local modalCardsB = display.newImageRect(modalGroup, "assets/7bg/bg_sociaty_1.png", 252 * 2.3, 244 * 2.1)
    modalCardsB.x, modalCardsB.y = display.contentCenterX, display.contentCenterY - 22
    modalCardsB.rotation = 180

    local cardLeft = display.newImageRect(modalGroup, "assets/7card/card_holder_m.png", 400 / 1.5, 460 / 1.5)
    cardLeft.x, cardLeft.y = display.contentCenterX - 150, display.contentCenterY - 150
    local emptyCard = display.newImageRect(modalGroup, "assets/7card/card_back_m.png", 400 / 1.85, 460 / 1.85)
    emptyCard.x, emptyCard.y = cardLeft.x, cardLeft.y + 5

    local cardRight = display.newImageRect(modalGroup, "assets/7card/card_holder_m.png", 400 / 1.5, 460 / 1.5)
    cardRight.x, cardRight.y = cardLeft.x + 300, cardLeft.y
    local card = card.new({
        x = cardRight.x,
        y = cardRight.y,
        stars = 11,
        characterId = "32f2f790-f02b-477b-ab49-28eaca42f584"
    })
    modalGroup:insert(card)

    local vsText = display.newImageRect(modalGroup, "assets/7misc/misc_vs.png", 156, 92)
    vsText.x, vsText.y = display.contentCenterX, cardLeft.y

    local nameModal = display.newImageRect(modalGroup, "assets/7textbg/tbg_black_s9_11.png", 380 * 1.3, 50)
    nameModal.x, nameModal.y = display.contentCenterX, display.contentCenterY + 30
    nameModal.alpha = 0.6
    local nameGroup = display.newGroup()
    modalGroup:insert(nameGroup)
    nameGroup.x, nameGroup.y = nameModal.x - 50, nameModal.y
    local playerNick = textile.new({
        group = nameGroup,
        texto = "Jogador ",
        x = 0,
        y = 0,
        tamanho = 23,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })
    local playerLevel = textile.new({
        group = nameGroup,
        texto = "(Nv160)",
        x = playerNick.x + 100,
        y = 0,
        tamanho = 23,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local powerModal = display.newImageRect(modalGroup, "assets/7textbg/tbg_black_s9_11.png", (380 * 1.3) / 2 - 10, 50)
    powerModal.x, powerModal.y = nameModal.x - 128, display.contentCenterY + 90
    powerModal.alpha = 0.6
    local powerIcon = display.newImageRect(modalGroup, "assets/7icon/icon_battle_ability.png", 72 / 1.2, 72 / 1.2)
    powerIcon.x, powerIcon.y = 100, display.contentCenterY + 90
    local powerText = textile.new({
        group = group,
        texto = 0 .. " ",
        x = powerModal.x - 65,
        y = powerModal.y,
        tamanho = 23,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local badgesModal = display.newImageRect(modalGroup, "assets/7textbg/tbg_black_s9_11.png", (380 * 1.3) / 2 - 10, 50)
    badgesModal.x, badgesModal.y = powerModal.x + 257, powerModal.y
    badgesModal.alpha = 0.6
    local badgeText = textile.new({
        group = group,
        texto = 0 .. " ",
        x = badgesModal.x - 65,
        y = badgesModal.y,
        tamanho = 23,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })
    local powerIcon = display.newImageRect(modalGroup, "assets/7icon/icon_badge.png", 48 / 1.2, 48 / 1.2)
    powerIcon.x, powerIcon.y = display.contentCenterX + 35, display.contentCenterY + 90

    local encouragement = display.newImageRect(modalGroup, "assets/7textbg/tbg_black_s9_11.png", 380 * 1.3, 80)
    encouragement.x, encouragement.y = display.contentCenterX, display.contentCenterY + 170
    encouragement.alpha = 0.6
    local encouragementTitle = textile.new({
        group = group,
        texto = "Encorajamento acumulado ",
        x = display.contentCenterX,
        y = encouragement.y - 15,
        tamanho = 22,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })
    local flowerIcon = display.newImageRect(modalGroup, "assets/7icon/icon_flower.png", 48, 48)
    flowerIcon.x, flowerIcon.y = encouragement.x - 135, encouragement.y + 10
    local flowersQuantity = textile.new({
        group = group,
        texto = 0 .. " ",
        x = flowerIcon.x + 30,
        y = flowerIcon.y + 5,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })
    local flowerPercentage = textile.new({
        group = group,
        texto = "(HP + 00.000%)",
        x = flowersQuantity.x + 55,
        y = flowersQuantity.y,
        tamanho = 24,
        corTexto = {0.33, 0.68, 0.42}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local startButton = display.newImageRect(modalGroup, "assets/7button/btn_common_green_s9_l.png", 400 * 1.27,
        60 * 1.27)
    startButton.x, startButton.y = display.contentCenterX, display.contentCenterY + 265
    startButton.fill.effect = "filter.grayscale"
    local startButtonText = textile.new({
        group = group,
        texto = "Oferecer Flores",
        x = startButton.x,
        y = startButton.y,
        tamanho = 24,
        corTexto = {0.7, 0.7, 0.7}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2

    })

    local ranking = display.newImageRect(modalGroup, "assets/7button/btn_common_yellow_s9.png", 220 * 1.15, 60 * 1.20)
    ranking.x, ranking.y = display.contentCenterX - 125, display.contentCenterY + 340
    local startButtonText = textile.new({
        group = group,
        texto = "Classificação",
        x = ranking.x,
        y = ranking.y,
        tamanho = 24,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local winners = display.newImageRect(modalGroup, "assets/7button/btn_common_yellow_s9.png", 220 * 1.15, 60 * 1.20)
    winners.x, winners.y = ranking.x + 252, ranking.y
    local startButtonText = textile.new({
        group = group,
        texto = "Vencedores",
        x = winners.x,
        y = winners.y,
        tamanho = 24,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local myNavBar = navBar.new()
    group:insert(myNavBar)
    local topBack = topBack.new({
        title = "Escolher Deuses"
    })
    group:insert(topBack)
end

scene:addEventListener("create", scene)
return scene

