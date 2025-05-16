-- improveCardShine.lua
-- Componente para tocar a animação de brilho de melhora de carta a partir da spritesheet

local improveCardShine = {}

-- 1) Mapeamento dos frames da spritesheet de brilho de upgrade
local sheetOptions = {
	frames = {
		{ x = 2, y = 78, width = 102, height = 88 }, -- eff_enhance_upgrading_00.png
		{ x = 2, y = 384, width = 96, height = 106 }, -- eff_enhance_upgrading_01.png
		{ x = 2, y = 168, width = 98, height = 120 }, -- eff_enhance_upgrading_02.png
		{ x = 2, y = 290, width = 98, height = 92 }, -- eff_enhance_upgrading_03.png
		{ x = 2, y = 2, width = 104, height = 74 }, -- eff_enhance_upgrading_04.png
	},
	sheetContentWidth = 108,
	sheetContentHeight = 492,
}

-- 2) Carrega a ImageSheet (ajuste o caminho se necessário)
local sheet = graphics.newImageSheet("assets/7effect/eff_enhance_upgrading.png", sheetOptions)

-- 3) Configuração padrão da sequência de brilho
local defaultSequence = {
	name = "shine",
	frames = { 1, 2, 3, 4, 5 },
	time = 600, -- duração total em ms
	loopCount = 1, -- toca uma vez
}

--- Cria e retorna o sprite de brilho de upgrade da carta
-- @param params.group      display group (default = display.currentStage)
-- @param params.x          posição x (default = centerX)
-- @param params.y          posição y (default = centerY)
-- @param params.time       duração em ms (sobrescreve defaultSequence.time)
-- @param params.loopCount  quantas vezes repetir (sobrescreve defaultSequence.loopCount)
-- @param params.scaleFactor fator de escala (default = 1)
-- @param params.onComplete callback quando terminar a animação
function improveCardShine.new(params)
	local group = params.group or display.currentStage
	local x = params.x or display.contentCenterX
	local y = params.y or display.contentCenterY
	local time = params.time or defaultSequence.time
	local loopCount = params.loopCount or defaultSequence.loopCount
	local scaleFactor = params.scaleFactor or 1

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
	local shineSprite = display.newSprite(group, sheet, sequenceData)
	shineSprite.x, shineSprite.y = x, y
	shineSprite:scale(scaleFactor, scaleFactor)
	shineSprite:play()

	-- adiciona listener de fim, se tiver callback
	if params.onComplete then
		shineSprite:addEventListener("sprite", function(event)
			if event.phase == "ended" and event.target == shineSprite then
				params.onComplete()
			end
		end)
	end

	return shineSprite
end

return improveCardShine
