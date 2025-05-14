local userDataLib = require("lib.userData")
local card_s = require("components.cardS") -- ajuste o caminho conforme sua estrutura

local component = {}

-- Cria uma nova instância do componente para exibir itens de evolução ou cards
-- Parâmetros esperados em params:
--  params.x           : posição X inicial
--  params.y           : posição Y inicial
--  params.characterId : ID do personagem a consultar
--  params.stars       : quantidade de estrelas/nível de evolução
--  params.scaleFactor : escala dos assets (opcional)
function component.new(params)
    local group = display.newGroup()

    -- Posições iniciais e parâmetros
    local baseX = params.x or display.contentCenterX
    local baseY = params.y or display.contentCenterY
    local characterId = params.characterId
    local stars = tonumber(params.stars) or 0
    local scaleFactor = params.scaleFactor or 1

    -- Carrega ID do usuário e servidor (atualmente não utilizado diretamente)
    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 461752844
    local serverId = tonumber(data.server) or 1

    --------------------------------------------------------------------------------
    -- 1) Exibição de itens (imagens) para stars = 2,3,4,7
    --------------------------------------------------------------------------------
    local assetsByStars = {
        [2] = {"assets/7items/yellow_pill.png", "assets/7items/green_pill.png", "assets/7items/red_pill.png"},
        [3] = {"assets/7items/water_paper.png", "assets/7items/fire_paper.png", "assets/7items/thunder_paper.png"},
        [4] = {"assets/7items/water.png", "assets/7items/earth.png", "assets/7items/fire.png",
               "assets/7items/thunder.png", "assets/7items/wind.png"},
        [7] = {"assets/7items/ninja_certificate.png"}
    }

    local itemList = assetsByStars[stars]
    if itemList then
        -- Espaçamento e tamanho de cada imagem
        local spacing = 50 * scaleFactor
        local imgSize = 400 * scaleFactor

        for i, path in ipairs(itemList) do
            local img = display.newImageRect(group, path, imgSize, imgSize)
            if img then
                img.x = baseX + (i - 1) * spacing
                img.y = baseY
                group:insert(img)
            else
                print("Erro ao carregar item: " .. path)
            end
        end
        return group
    end

    --------------------------------------------------------------------------------
    -- 2) Exibição de cards para stars = 5,6,8,9,10
    --------------------------------------------------------------------------------
    local displayMap = {
        [5] = {
            count = 1,
            displayStars = 5
        },
        [6] = {
            count = 2,
            displayStars = 5
        },
        [8] = {
            count = 1,
            displayStars = 8
        },
        [9] = {
            count = 2,
            displayStars = 8
        },
        [10] = {
            count = 1,
            displayStars = 9
        }
    }
    local config = displayMap[stars]
    if not config then
        print("component.new: stars inválido ou não suportado:", stars)
        return group
    end

    -- Espaçamento horizontal entre cards e cálculo de centralização
    local cardWidth = 104 * scaleFactor * 1.15
    local spacing = cardWidth + 20
    local totalW = config.count * spacing - 20
    local startX = baseX - totalW * 0.5 + spacing * 0.5

    for i = 1, config.count do
        local card = card_s.new {
            x = startX + (i - 1) * spacing,
            y = baseY,
            characterId = characterId,
            stars = config.displayStars,
            scaleFactor = scaleFactor
        }
        group:insert(card)
    end

    return group
end

return component
