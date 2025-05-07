local card_s = {}
local json = require("json")
local supabase = require("config.supabase")

-- Função para buscar os dados do personagem na tabela characters
local function getCharacterData(characterId, callback)
    local headers = {
        ["apikey"] = supabase.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
        ["Content-Type"] = "application/json"
    }
    local url = supabase.SUPABASE_URL .. "/rest/v1/characters?select=image_s&uuid=eq." .. characterId

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

-- Função para retornar o background do card com base nos stars
local function getCardBg(stars)
    if stars == 2 then
        return "assets/7card/empty_white_s.png"
    elseif stars >= 3 and stars <= 4 then
        return "assets/7card/empty_green_s.png"
    elseif stars >= 5 and stars <= 7 then
        return "assets/7card/empty_blue_s.png"
    elseif stars >= 8 and stars <= 11 then
        return "assets/7card/empty_purple_s.png"
    end
    return "assets/7card/empty_white_s.png"
end

function card_s.new(params)
    local group = display.newGroup()

    -- Configura o group para ancorar pelo centro
    group.anchorChildren = true
    group.anchorX = 0.5
    group.anchorY = 0.5

    local scaleFactor = params.scaleFactor or 1
    local stars = tonumber(params.stars) or 2
    local x = params.x or display.contentCenterX
    local y = params.y or display.contentCenterY
    local characterId = params.characterId

    -- Cria o background do card (primeiro elemento)
    local bgPath = getCardBg(stars)
    local spriteBg = display.newImageRect(group, bgPath, (104 * 1.15) * scaleFactor, (104 * 1.15) * scaleFactor)
    spriteBg.x = 0
    spriteBg.y = 0

    local sprite -- sprite do personagem
    local cardType -- exibe o tipo do card (caso informado)
    local kunaiGroup -- grupo de kunais

    -- Função para criar o card_type (se definido)
    local function createCardType()
        if params.card_type then
            cardType = display.newText({
                text = params.card_type,
                x = 0,
                y = 0, -- a posição será ajustada logo abaixo do sprite
                font = native.systemFont,
                fontSize = 16
            })
            cardType:setFillColor(1) -- exemplo: branco
            -- Posiciona o card_type logo abaixo do sprite
            cardType.y = sprite.y + (sprite.height * 0.5) + 10
            group:insert(cardType)
        end
    end

    -- Função para criar o sprite e depois o card_type
    local function setSprite(spritePath)
        sprite = display.newImageRect(group, spritePath, (104 * 1.12) * scaleFactor, (104 * 1.12) * scaleFactor)
        sprite.x = 0
        sprite.y = 0
        -- Após criar o sprite, cria o card_type (se definido)
        createCardType()
        -- Se as kunais já foram criadas, garante que elas fiquem no topo
        if kunaiGroup then
            kunaiGroup:toFront()
        end
    end

    if characterId then
        -- Busca os dados do personagem no Supabase
        getCharacterData(characterId, function(cardData, err)
            if err then
                print("Erro ao buscar dados do personagem: " .. err)
                setSprite("assets/7card/card_sketch_s.png") -- sprite default
            else
                local spritePath = "assets/7card/card_sketch_s.png"
                local imageTable = cardData.image_s
                if type(imageTable) == "string" then
                    imageTable = json.decode(imageTable)
                end
                if imageTable and type(imageTable) == "table" then
                    if stars >= 2 and stars <= 4 then
                        spritePath = imageTable[1] or spritePath
                    elseif stars >= 5 and stars <= 7 then
                        spritePath = imageTable[2] or spritePath
                    elseif stars >= 8 and stars <= 11 then
                        spritePath = imageTable[3] or spritePath
                    end
                end
                setSprite(spritePath)
            end
        end)
    else
        -- Se não houver characterId, usa sprite default ou o informado em params.sprite
        setSprite(params.sprite or "assets/7card/card_sketch_s.png")
    end

    -- Função para exibir as kunais (último elemento)
    local function showKunais(starCount)
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
        local spacing = -25 * scaleFactor
        local kunaiWidth = 44 * scaleFactor
        local totalWidth = #kunaiTypes * (kunaiWidth + spacing) - spacing

        local offsetX = 75 * scaleFactor
        local offsetY = 110 * scaleFactor
        local startX = offsetX - totalWidth

        kunaiGroup = display.newGroup()
        for i, state in ipairs(kunaiTypes) do
            local imagePath = (state == "on") and "assets/7card/card_form_on.png" or "assets/7card/card_form_off.png"
            local kunai =
                display.newImageRect(kunaiGroup, imagePath, (44 / 1.6) * scaleFactor, (56 / 1.6) * scaleFactor)
            kunai.x = startX + (i - 0.3) * (kunaiWidth + spacing)
            kunai.y = offsetY - (70 * scaleFactor)
        end
        group:insert(kunaiGroup)
        -- Traz as kunais para o topo para que fiquem acima de todos os demais elementos
        kunaiGroup:toFront()
    end

    -- Chama a função para exibir as kunais
    showKunais(stars)

    -- Posiciona o group na tela
    group.x = x
    group.y = y

    return group
end

return card_s
