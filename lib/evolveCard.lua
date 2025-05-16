-- evolveCard.lua
-- Componente para tocar a animação de evolução de carta a partir da spritesheet

local evolveCard = {}

-- 1) Mapeamento dos frames da spritesheet de evolução de carta
local sheetOptions = {
	frames = {
		{ x = 2, y = 808, width = 22, height = 126 }, -- eff_evolve_card_00.png
		{ x = 2, y = 438, width = 178, height = 146 }, -- eff_evolve_card_01.png
		{ x = 2, y = 224, width = 212, height = 146 }, -- eff_evolve_card_02.png
		{ x = 2, y = 2, width = 220, height = 146 }, -- eff_evolve_card_03.png
		{ x = 2, y = 618, width = 188, height = 130 }, -- eff_evolve_card_04.png
		{ x = 2, y = 832, width = 46, height = 106 }, -- eff_evolve_card_05.png
	},
	sheetContentWidth = 150,
	sheetContentHeight = 880,
}

-- 2) Carrega a ImageSheet (ajuste o caminho se necessário)
local sheet = graphics.newImageSheet("assets/7effect/eff_evolve_card.png", sheetOptions)

-- 3) Configuração padrão da sequência
local defaultSequence = {
	name = "evolve",
	frames = { 1, 2, 3, 4, 5, 6 },
	time = 15000, -- duração total em ms
	loopCount = 1, -- toca uma vez
}

--- Cria e retorna o sprite de evolução de carta
-- @param params.group      display group (default = display.currentStage)
-- @param params.x          posição x (default = centerX)
-- @param params.y          posição y (default = centerY)
-- @param params.time       duração em ms (sobrescreve defaultSequence.time)
-- @param params.loopCount  quantas vezes repetir (sobrescreve defaultSequence.loopCount)
-- @param params.onComplete callback quando terminar a animação
function evolveCard.new(params)
	local group = params.group or display.currentStage
	local x = params.x or display.contentCenterX
	local y = params.y or display.contentCenterY
	local time = params.time or defaultSequence.time
	local loopCount = params.loopCount or defaultSequence.loopCount

	-- monta sequência customizada
	local sequenceData = {
		{
			name = defaultSequence.name,
			frames = defaultSequence.frames,
			time = time,
			loopCount = loopCount,
		},
	}

	-- cria o sprite
	local card = display.newSprite(group, sheet, sequenceData)
	card.x, card.y = x, y
	card:scale(2, 2)
	card:play()
	card.rotation = -90

	-- adiciona listener de fim, se tiver callback
	if params.onComplete then
		card:addEventListener("sprite", function(event)
			if event.phase == "ended" and event.target == card then
				params.onComplete()
			end
		end)
	end

	return card
end

return evolveCard
