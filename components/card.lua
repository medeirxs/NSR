-- components/card.lua
local card = {}
local json = require("json")
local supabase = require("config.supabase")

-- Função para retornar a imagem do tipo de carta
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

-- Função para buscar os dados do personagem na tabela characters
local function getCharacterData(characterId, callback)
    local headers = {
        ["apikey"] = supabase.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
        ["Content-Type"] = "application/json"
    }
    local url = supabase.SUPABASE_URL .. "/rest/v1/characters?select=card_type,image,image_s&uuid=eq." .. characterId

    local function networkListener(event)
        if event.isError then
            callback(nil, event.response)
        else
            local data = json.decode(event.response)
            if data and #data > 0 then
                callback(data[1])
            else
                callback(nil, "Nenhum dado encontrado")
            end
        end
    end

    network.request(url, "GET", networkListener, {
        headers = headers
    })
end

-- Declaração da variável kunaiGroup para acesso dentro de updateCardWithCharacterData
local kunaiGroup

function card.new(params)
    local group = display.newGroup()
    group.anchorChildren = true
    group.anchorX = 0.5
    group.anchorY = 0.5

    local x = params.x or display.contentCenterX
    local y = (params.y or display.contentCenterY) - 15
    local characterId = params.characterId
    local stars = tonumber(params.stars) or 2
    local scaleFactor = params.scaleFactor or 1

    -- 1) bgSprite
    local function getStarImage(starCount)
        if starCount >= 14 then
            return "assets/7card/card_bg_red_m.png"
        elseif starCount >= 12 then
            return "assets/7card/card_bg_orange_m.png"
        elseif starCount >= 8 then
            return "assets/7card/card_bg_purple_m.png"
        elseif starCount >= 5 then
            return "assets/7card/card_bg_blue_m.png"
        elseif starCount >= 3 then
            return "assets/7card/card_bg_green_m.png"
        else
            return "assets/7card/card_bg_white_m.png"
        end
    end

    local starImage = getStarImage(stars)
    local bgSprite = display.newImageRect(group, starImage, (296 / 1.5) * scaleFactor, (364 / 1.5) * scaleFactor)
    bgSprite.x, bgSprite.y = 0, 0

    local spriteImage -- será criado dentro de updateCardWithCharacterData

    -- Função para exibir kunais (depois de inserir sprite e icon)
    local function showKunais(starCount)
        kunaiGroup = display.newGroup()
        local kunaiConfigs = {
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
        local kunaiTypes = kunaiConfigs[starCount] or {}
        local spacing = -22 * scaleFactor
        local kunaiWidth = 44 * scaleFactor
        local totalW = #kunaiTypes * (kunaiWidth + spacing) - spacing

        local offsetX = 75 * scaleFactor
        local offsetY = 165 * scaleFactor
        local startX = offsetX - totalW

        for i, state in ipairs(kunaiTypes) do
            local path = (state == "on") and "assets/7card/card_form_on.png" or "assets/7card/card_form_off.png"
            local kunai = display.newImageRect(kunaiGroup, path, (44 / 1.35) * scaleFactor, (56 / 1.35) * scaleFactor)
            kunai.x = startX + (i - 1) * (kunaiWidth + spacing)
            kunai.y = offsetY - (70 * scaleFactor)
        end
        group:insert(kunaiGroup) -- garante kunais por cima
    end

    -- Função para atualizar o card com os dados do personagem
    local function updateCardWithCharacterData(cardData)
        -- 2) spriteImage
        local spritePath = "assets/7card/card_sketch_m.png"
        local imageJson = cardData.image
        if type(imageJson) == "string" then
            imageJson = json.decode(imageJson)
        end
        if imageJson and type(imageJson) == "table" then
            if stars <= 4 then
                spritePath = imageJson[1] or spritePath
            elseif stars <= 7 then
                spritePath = imageJson[2] or spritePath
            else
                spritePath = imageJson[3] or spritePath
            end
        end

        spriteImage = display.newImageRect(group, spritePath, (658 / 3.2) * scaleFactor, (835 / 3.2) * scaleFactor)
        spriteImage.x = 0
        spriteImage.y = -20 * scaleFactor

        -- 3) cardTypeIcon
        local typeImg = getCardTypeImage(cardData.card_type)
        if typeImg then
            local cardTypeIcon = display.newImageRect(group, typeImg, 55 * scaleFactor, 55 * scaleFactor)
            cardTypeIcon.x = (bgSprite.width * 0.455) - (cardTypeIcon.width * 0.4)
            cardTypeIcon.y = (bgSprite.height * 0.5) - (cardTypeIcon.height * 0.6)
        end

        -- 4) kunaiGroup por cima
        showKunais(stars)
    end

    -- Dispara fetch e atualização do card
    if characterId then
        getCharacterData(characterId, function(cardData, err)
            if err then
                print("Erro ao buscar dados do personagem: " .. err)
            else
                updateCardWithCharacterData(cardData)
            end
        end)
    end

    group.x, group.y = x, y
    return group
end

return card
