local Cards = {}
local json = require("json")

-- Fator de escala para responsividade, baseado numa largura de referência (ex: 1080)
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth
local scaleFactor = 1.3 * deviceScaleFactor

-- Cria a formação padrão com 5 slots e um vazio
function Cards.createFormation()
    print("[Cards] createFormation called")
    local formation = {}
    for i = 1, 5 do
        formation[i] = {
            card_id = nil,
            uuid = nil,
            atk = 0,
            def = 0,
            hp = 0,
            vel = 0,
            eva = 0,
            prec = 0,
            card_image = "",
            ab = 0,
            sp = 0,
            card_type = "",
            name = "",
            index = i,
            stars = 0,
            isOpponent = false
        }
    end
    formation[6] = nil
    return formation
end

-- Atualiza os dados de uma carta. Se cardData for um número, considera-o como ID.
function Cards.updateCard(card, cardData)
    print("[Cards] updateCard called with:", json.encode(cardData))
    if type(cardData) ~= "table" then
        card.card_id = cardData
        print(string.format("[Cards] updateCard assigned id: %s", tostring(card.card_id)))
        return
    end

    card.card_id = cardData.card_id or cardData.id or nil
    card.uuid = cardData.uuid
    card.atk = cardData.atk or 0
    card.def = cardData.def or 0
    card.hp = cardData.hp or 0
    card.originalHP = cardData.hp or 0
    card.card_image = cardData.card_image or cardData.image or ""
    card.ab = cardData.ab or 0
    card.sp = cardData.sp or 0
    card.card_type = cardData.card_type or ""
    card.name = cardData.name or ""
    card.stars = cardData.stars or 0
    card.eva = cardData.eva or 0.0
    card.prec = cardData.prec or 0.0
    card.armor = cardData.armor or 0.0
    card.res = cardData.res or 0.0
    card.cri = cardData.cri or 0.0

    local reviveValue = cardData.isRevive or (cardData.characters and cardData.characters.isRevive)
    if type(reviveValue) == "string" then
        card.isRevive = (reviveValue:lower() == "true")
    else
        card.isRevive = reviveValue or false
    end

    print(string.format("[Cards] updateCard result -> id:%s name:%s stars:%s", tostring(card.card_id),
        tostring(card.name), tostring(card.stars)))
end

-- Função para retornar o ícone de tipo de carta
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

-- Exibe um card na tela
function Cards.displayCard(card, x, y, width, height)
    print(string.format("[Cards] displayCard called for id:%s name:%s stars:%s at (%.1f,%.1f)", tostring(card.card_id),
        tostring(card.name), tostring(card.stars), x, y))

    if type(card) ~= "table" then
        print("[Cards] displayCard: slot vazio ou inválido")
        return nil
    end

    local group = display.newGroup()
    group.anchorChildren = true
    group.anchorX = 0.5
    group.anchorY = 0.5

    -- Fundo conforme estrelas
    local starsVal = tonumber(card.stars) or 0
    local bgImagePath = "assets/7card/card_bg_purple_m.png"
    if starsVal == 2 then
        bgImagePath = "assets/7card/card_bg_white_m.png"
    elseif starsVal <= 4 then
        bgImagePath = "assets/7card/card_bg_green_m.png"
    elseif starsVal <= 7 then
        bgImagePath = "assets/7card/card_bg_blue_m.png"
    elseif starsVal <= 11 then
        bgImagePath = "assets/7card/card_bg_purple_m.png"
    elseif starsVal <= 13 then
        bgImagePath = "assets/7card/card_bg_orange_m.png"
    else
        bgImagePath = "assets/7card/card_bg_red_m.png"
    end
    print("[Cards] displayCard bgImagePath:", bgImagePath)

    local bgSprite = display.newImageRect(group, bgImagePath, (296 / 1.5) * scaleFactor, (364 / 1.5) * scaleFactor)
    bgSprite.x, bgSprite.y = 0, 0

    -- Sprite do personagem
    if card.card_image and card.card_image ~= "" then
        local spritePath = "assets/7card/card_sketch_m.png"
        local imageJson = card.card_image
        if type(imageJson) == "string" then
            imageJson = json.decode(imageJson)
        end
        if type(imageJson) == "table" then
            if starsVal <= 4 then
                spritePath = imageJson[1] or spritePath
            elseif starsVal <= 7 then
                spritePath = imageJson[2] or spritePath
            else
                spritePath = imageJson[3] or spritePath
            end
        end
        print("[Cards] displayCard spritePath:", spritePath)
        local cardImage = display.newImageRect(group, spritePath, (658 / 3.2) * scaleFactor, (835 / 3.2) * scaleFactor)
        cardImage.x, cardImage.y = 0, -20 * scaleFactor
    else
        print("[Cards] displayCard: nenhuma imagem definida")
    end

    -- Ícone de tipo de carta
    local cTypeIcon = getCardTypeImage(card.card_type)
    print("[Cards] displayCard cardTypeIconPath:", tostring(cTypeIcon))
    if cTypeIcon then
        local icon = display.newImageRect(group, cTypeIcon, 55 * scaleFactor, 55 * scaleFactor)
        icon.x = (bgSprite.width * 0.455) - (icon.width * 0.4)
        icon.y = (bgSprite.height * 0.5) - (icon.height * 0.6)
    end

    -- Exibe kunais conforme estrelas
    local function showKunais(starCount)
        print("[Cards] displayCard showKunais for stars:", starCount)
        local kunaiGroup = display.newGroup()
        local configs = {
            [2] = {},
            [3] = {"off"},
            [4] = {"on"},
            [5] = {"off", "off"},
            [6] = {"on", "off"},
            [7] = {"on", "on"},
            [8] = {"off", "off", "off"},
            [9] = {"on", "off", "off"},
            [10] = {"on", "on", "off"},
            [11] = {"on", "on", "on"},
            [12] = {"off"},
            [13] = {"on"},
            [14] = {}
        }
        local types = configs[starCount] or {}
        local spacing = -22 * scaleFactor
        local w = 44 * scaleFactor
        local totalW = #types * (w + spacing) - spacing
        local offX = 75 * scaleFactor
        local offY = 165 * scaleFactor
        local startX = offX - totalW
        for i, st in ipairs(types) do
            local img = (st == "on") and "assets/7card/card_form_on.png" or "assets/7card/card_form_off.png"
            local k = display.newImageRect(kunaiGroup, img, (44 / 1.35) * scaleFactor, (56 / 1.35) * scaleFactor)
            k.x = startX + (i - 1) * (w + spacing)
            k.y = offY - (70 * scaleFactor)
        end
        group:insert(kunaiGroup)
    end
    showKunais(starsVal)

    group.x, group.y = x, y - 15
    card.group = group
    print(string.format("[Cards] displayCard completed id:%s", tostring(card.card_id)))
    return group
end

return Cards
