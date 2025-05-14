local userDataLib = require("lib.userData")
local card_s = require("components.cardS")

local component = {}

-- Componente para exibir sempre dois cards de evolução, mostrando ou ocultando o segundo
-- params:
--   x, y: posição inicial
--   characterId: ID do personagem
--   stars: nível de evolução recebido
--   scaleFactor: opcional, escala dos cards
function component.new(params)
    local group = display.newGroup()

    -- Parâmetros
    local baseX = params.x or display.contentCenterX
    local baseY = params.y or display.contentCenterY
    local characterId = params.characterId
    local stars = tonumber(params.stars) or 0
    local scaleFactor = params.scaleFactor or 1

    -- Mapeamento de how many cards to show and their star values
    local map = {
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
    local cfg = map[stars] or {
        first = 0,
        second = 0
    }

    -- Tamanhos e espaçamento
    local cardWidth = 104 * 1.15 * scaleFactor
    local gap = 20 * scaleFactor
    local spacing = cardWidth + gap

    -- Função auxiliar para criar e posicionar um card
    local function makeCard(starValue, offsetIndex)
        local card = card_s.new {
            characterId = characterId,
            stars = starValue,
            scaleFactor = scaleFactor
        }
        -- Ancoragem à esquerda e verticalmente central
        card.anchorChildren = true
        card.anchorX = 0
        card.anchorY = 0.5
        -- Posicionamento
        card.x = baseX + (offsetIndex - 1) * spacing
        card.y = baseY
        -- Oculta se necessário
        if starValue <= 0 then
            card.isVisible = false
        end
        group:insert(card)
    end

    -- Sempre dois slots
    makeCard(cfg.first, 1)
    makeCard(cfg.second, 2)

    return group
end

return component
