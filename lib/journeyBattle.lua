-- router/battle.lua
local composer = require("composer")
local json = require("json")
local network = require("network")
local supabase = require("config.supabase")

local formationHook = {}
function formationHook.fetchFormationData(userId, callback)
	local base_url = supabase.SUPABASE_URL
	local endpoint = "/rest/v1/user_formation"
	local query = "?userId=eq." .. userId
	local url = base_url .. endpoint .. query

	local headers = {
		["apikey"] = supabase.SUPABASE_ANON_KEY,
		["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
		["Content-Type"] = "application/json",
	}
	local params = {
		headers = headers,
	}

	local function listener(event)
		if event.isError then
			print("Erro na requisição formation:", event.response)
			callback(nil, "Erro na requisição formation")
		else
			local responseString = event.response
			print("Resposta formation:", responseString)
			local data = json.decode(responseString)
			if not data or #data == 0 then
				callback(nil, "Nenhuma formação encontrada para userId " .. userId)
				return
			end

			local formationRow = data[1]
			local formationData = formationRow.formation
			if type(formationData) == "string" then
				formationData = json.decode(formationData)
			end

			-- Garante que a formação seja um array de 6 posições
			local newFormation = {}
			for i = 1, 6 do
				newFormation[i] = formationData[i] -- Se formationData[i] for null, ficará nil
			end

			-- Atribui a cada carta (se for uma tabela) o campo cardData apontando para ela mesma
			for i = 1, #newFormation do
				if type(newFormation[i]) == "table" then
					newFormation[i].cardData = newFormation[i]
					-- Exibe o valor lido para debug
					print(
						"Carta: "
							.. (newFormation[i].name or "Sem Nome")
							.. " | passive: "
							.. tostring(newFormation[i].passive)
					)
					-- Se o campo passive não estiver definido, para testes você pode atribuir um valor padrão
					if newFormation[i].passive == nil then
						newFormation[i].passive = "ShukakuAwake"
					end
				end
			end

			print("Formação lida do banco:", newFormation)
			callback(newFormation, nil)
		end
	end

	network.request(url, "GET", listener, params)
end
function formationHook.updateFormation(userId, newFormation, callback)
	local base_url = supabase.SUPABASE_URL
	local endpoint = "/rest/v1/user_formation"
	local query = "?userId=eq." .. userId
	local url = base_url .. endpoint .. query

	local headers = {
		["apikey"] = supabase.SUPABASE_ANON_KEY,
		["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
		["Content-Type"] = "application/json",
		["Prefer"] = "return=representation",
	}
	local bodyData = {
		formation = json.encode(newFormation),
	}
	local params = {
		headers = headers,
		body = json.encode(bodyData),
		method = "PATCH",
	}

	network.request(url, "PATCH", function(event)
		if event.isError then
			print("Erro ao atualizar formação:", event.response)
			callback(nil, event.response)
		else
			print("Formação atualizada:", event.response)
			callback(event.response, nil)
		end
	end, params)
end

local expEarned
local silverEarned
local titleWs
local subtitleWs
local nochicaId
local returnTo
local shareVisionIcon
local defenseIcon

-- headers comuns
local defaultHeaders = {
	["Content-Type"] = "application/json",
	["apikey"] = supabase.SUPABASE_ANON_KEY,
	["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
}

-- ←– Aqui definimos rewardPlayer como FUNÇÃO
local function rewardPlayer(userId, silverAmount, levelAmount, onComplete)
	local url = supabase.SUPABASE_URL .. "/rest/v1/rpc/reward_user"
	local body = json.encode({
		p_user_id = userId,
		p_silver = silverAmount,
		p_level = levelAmount,
	})

	network.request(url, "POST", function(event)
		if event.isError then
			print("❌ Erro ao enviar prêmio:", event.response)
		else
			print("✅ Prêmio enviado com sucesso!")
		end
		if onComplete then
			onComplete(event)
		end
	end, {
		headers = defaultHeaders,
		body = body,
	})
end

local localOpponentModule
local opponentUserId
local teamG

local Cards = {}
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth
local scaleFactor = 1.24 * deviceScaleFactor
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
			isOpponent = false,
		}
	end
	formation[6] = nil
	return formation
end
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

	print(
		string.format(
			"[Cards] updateCard result -> id:%s name:%s stars:%s",
			tostring(card.card_id),
			tostring(card.name),
			tostring(card.stars)
		)
	)
end
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
function Cards.displayCard(card, x, y, width, height)
	print(
		string.format(
			"[Cards] displayCard called for id:%s name:%s stars:%s at (%.1f,%.1f)",
			tostring(card.card_id),
			tostring(card.name),
			tostring(card.stars),
			x,
			y
		)
	)

	if type(card) ~= "table" then
		print("[Cards] displayCard: slot vazio ou inválido")
		return nil
	end

	local group = display.newGroup()
	group.anchorChildren = true
	group.anchorX = 0.5
	group.anchorY = 0.5

	-- Card holder
	local holder = display.newImageRect(
		group,
		"assets/7battle/card_holder_battle_m.png",
		width + (35 * scaleFactor),
		height + (35 * scaleFactor)
	)
	if not holder then
		print("[Cards] displayCard: CardHolder não encontrado")
	end
	holder.anchorX, holder.anchorY = 0.5, 0.5
	holder.x, holder.y = 0, 13 * scaleFactor

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
			[3] = { "off" },
			[4] = { "on" },
			[5] = { "off", "off" },
			[6] = { "on", "off" },
			[7] = { "on", "on" },
			[8] = { "off", "off", "off" },
			[9] = { "on", "off", "off" },
			[10] = { "on", "on", "off" },
			[11] = { "on", "on", "on" },
			[12] = { "off" },
			[13] = { "on" },
			[14] = {},
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

	group.x, group.y = x * 1.1, y * 1.1
	card.group = group
	print(string.format("[Cards] displayCard completed id:%s", tostring(card.card_id)))

	-- aplica escala customizada, se houver
	local s = tonumber(card.size) or 1
	if card.isOpponent and s ~= 1 then
		group:scale(s, s)
	end

	return group
end

local baseWidth = 1080
local scaleFactor = display.actualContentWidth / baseWidth

local scene = composer.newScene()
local background

local deadPlayerSlots = {}
local deadOpponentSlots = {}
local deathMarkers = {}

local userDataLib = require("lib.userData")
local data = userDataLib.load() or {}
local userId = tonumber(data.id) or 461752844
local serverId = tonumber(data.server) or 1

local playerUserId = tonumber(data.id)

local formation = {} -- Formação do jogador
local totalSlots = 6

local gridSlotsPlayer = {} -- Referências dos slots do jogador
local gridSlotsOpponent = {} -- Referências dos slots do oponente

-- Variáveis para armazenar as formações carregadas (para os turnos)
local playerFormationData = nil
local opponentFormationData = nil
_G.playerFormationData = playerFormationData

-- Flags para indicar quando os grids estão prontos
local playerGridReady = false
local opponentGridReady = false

-- battleFunction global
_G.battleFunctions = battleFunctions

_G.opponentsDefeated = _G.opponentsDefeated or 0
--------------------------------------------------
-- FUNÇÃO: setBackgroundImage
--------------------------------------------------

function scene:setBackgroundImage(imagePath, originalWidth, originalHeight)
	if background then
		background:removeSelf()
		background = nil
	end

	local screenWidth = display.actualContentWidth
	local screenHeight = display.actualContentHeight

	-- A altura desejada é 1.5 vezes a altura da tela.
	local desiredHeight = 1.5 * screenHeight
	-- Calcula o scaleFactor para que a imagem original alcance a desiredHeight.
	local scaleFactor = desiredHeight / originalHeight
	local newWidth = originalWidth * scaleFactor
	local newHeight = desiredHeight

	background = display.newImageRect(self.view, imagePath, newWidth, newHeight)
	if background then
		-- Centraliza horizontalmente e alinha a parte inferior à base da tela.
		background.anchorX = 0.5
		background.anchorY = 1
		background.x = display.contentCenterX
		background.y = display.contentHeight + 210
	else
		print("Erro ao carregar a imagem:", imagePath)
	end
end

-- Opcional: Listener para garantir o reposicionamento em caso de mudança de resolução
local function onResize(event)
	if background then
		background.x = display.contentCenterX
		background.y = display.contentHeight
	end
end
Runtime:addEventListener("resize", onResize)
--------------------------------------------------
-- FUNÇÃO: createCardGrid
--------------------------------------------------
local function createCardGrid(parentGroup, posX, posY)
	local gridGroup = display.newGroup()
	parentGroup:insert(gridGroup)
	gridGroup.x = posX or display.contentCenterX
	gridGroup.y = posY or display.contentCenterY
	return gridGroup
end

--------------------------------------------------
-- FUNÇÃO: createHealthBar
-- Cria uma health bar com cantos arredondados para uma carta usando os valores de HP.
-- A health bar consiste em uma barra de fundo (cinza) e uma barra de vida (vermelha),
-- ambas com cantos arredondados, posicionadas na borda inferior da carta.
--------------------------------------------------
local function createHealthBar(cardData, cardDisplay)
	local barWidth = cardDisplay.contentWidth * 0.9
	local barHeight = 5
	local cornerRadius = 7 * 1 -- Raio dos cantos arredondados

	-- Armazena o HP original se ainda não estiver definido
	if not cardData.originalHP then
		cardData.originalHP = cardData.hp
	end

	local maxHP = cardData.maxHp or cardData.originalHP or 100
	local currentHP = cardData.hp or maxHP
	local healthRatio = currentHP / maxHP

	local bgBar = display.newRoundedRect(0, 0, barWidth, barHeight, cornerRadius)
	bgBar.anchorX = 0
	bgBar.anchorY = 0
	bgBar:setFillColor(25, 0, 0)

	local healthBar = display.newRoundedRect(0, 0, barWidth * healthRatio, barHeight, cornerRadius)
	healthBar.anchorX = 0
	healthBar.anchorY = 0
	healthBar:setFillColor(0, 255, 0)
	-- Armazena a largura original para uso na atualização
	healthBar.originalWidth = barWidth

	local healthGroup = display.newGroup()
	healthGroup:insert(bgBar) -- bgBar: índice 1
	healthGroup:insert(healthBar) -- healthBar: índice 2
	healthGroup.isHealthBar = true -- Marca este grupo para identificação
	healthGroup.originalWidth = barWidth

	local bounds = cardDisplay.contentBounds
	local cardBottomY = bounds.yMax
	local cardCenterX = (bounds.xMin + bounds.xMax) * 0.5
	healthGroup.x = cardCenterX - barWidth * 0.5
	healthGroup.y = cardBottomY - barHeight * 0.5

	return healthGroup
end

--------------------------------------------------------------------------------
-- Função specialEffect
--------------------------------------------------------------------------------
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth

local specialAnimScale = 2.6 * deviceScaleFactor
local spriteTime = 800 -- duração da animação em milissegundos
local fadeTime = 500 -- tempo para fade in/out

local function specialEffect(cardData, cardGroup)
	if not cardGroup then
		print("specialEffect: cardGroup é nil, não é possível exibir o efeito.")
		return
	end
	print("[specialEffect] Iniciando animação visual especial para " .. (cardData.name or "Sem Nome"))

	-- Configuração do spritesheet (ajuste as coordenadas conforme seu recurso)
	local sheetOptions = {
		frames = {
			{
				x = 2,
				y = 2,
				width = 134,
				height = 164,
			},
			{
				x = 1074,
				y = 2,
				width = 132,
				height = 162,
			},
			{
				x = 674,
				y = 2,
				width = 130,
				height = 164,
			},
			{
				x = 540,
				y = 2,
				width = 132,
				height = 164,
			},
			{
				x = 940,
				y = 2,
				width = 132,
				height = 162,
			},
			{
				x = 806,
				y = 2,
				width = 132,
				height = 162,
			},
			{
				x = 1472,
				y = 2,
				width = 130,
				height = 162,
			},
			{
				x = 1340,
				y = 2,
				width = 130,
				height = 162,
			},
			{
				x = 406,
				y = 2,
				width = 132,
				height = 164,
			},
			{
				x = 1208,
				y = 2,
				width = 130,
				height = 162,
			},
			{
				x = 272,
				y = 2,
				width = 132,
				height = 164,
			},
			{
				x = 138,
				y = 2,
				width = 132,
				height = 164,
			},
		},
	}

	local sheet = graphics.newImageSheet("assets/7effect/eff_special_skill_next_round.png", sheetOptions)
	if not sheet then
		print("[specialEffect] Falha ao carregar o spritesheet.")
		return
	end

	local sequenceData = {
		name = "specialVisualAnim",
		start = 1,
		count = 12,
		time = spriteTime,
		loopCount = 0, -- toca apenas uma vez
	}

	local sprite = display.newSprite(sheet, sequenceData)
	sprite.anchorX = 0.5
	sprite.anchorY = 0.55
	sprite.x = cardGroup.cardCenterX or cardGroup.x or 0
	sprite.y = cardGroup.cardCenterY or cardGroup.y or 0
	sprite:scale(specialAnimScale, specialAnimScale)

	sprite.alpha = 0 -- inicia invisível
	cardGroup:insert(1, sprite) -- insere atrás dos demais elementos
	transition.to(sprite, {
		alpha = 1,
		time = fadeTime,
	}) -- fade in

	sprite:play()

	cardData.specialEffectSprite = sprite
	print("[specialEffect] Animação visual especial iniciada para " .. (cardData.name or "Sem Nome"))
end

-- ============================================================
-- Função: displayCardWithHealthBar
-- Exibe a carta utilizando Cards.displayCard e adiciona uma healthbar
-- na borda inferior.
-- ============================================================
local function createHealthBar(cardData, cardDisplay)
	local barWidth = cardDisplay.contentWidth * 0.9
	local barHeight = cardDisplay.contentHeight * 0.03 -- 5% da altura do card
	local cornerRadius = math.floor(barHeight * 0.9)

	if not cardData.originalHP then
		cardData.originalHP = cardData.hp
	end

	local maxHP = cardData.maxHp or cardData.originalHP or 100
	local currentHP = cardData.hp or maxHP
	local healthRatio = currentHP / maxHP

	local bgBar = display.newRoundedRect(0, 0, barWidth, barHeight, cornerRadius)
	bgBar.anchorX = 0
	bgBar.anchorY = 0
	bgBar:setFillColor(255, 0, 0) -- Valores entre 0 e 1

	local healthBar = display.newRoundedRect(0, 0, barWidth * healthRatio, barHeight, cornerRadius)
	healthBar.anchorX = 0
	healthBar.anchorY = 0
	healthBar:setFillColor(0, 1, 0)
	healthBar.originalWidth = barWidth

	local healthGroup = display.newGroup()
	healthGroup:insert(bgBar)
	healthGroup:insert(healthBar)
	healthGroup.isHealthBar = true
	healthGroup.originalWidth = barWidth

	local bounds = cardDisplay.contentBounds
	local cardBottomY = bounds.yMax
	local cardCenterX = (bounds.xMin + bounds.xMax) * 0.5
	healthGroup.x = cardCenterX - barWidth * 0.5
	healthGroup.y = cardBottomY - barHeight * -0

	return healthGroup
end

-- Função que exibe a carta com health bar (modificada para chamar specialEffect)
local function displayCardWithHealthBar(cardData, x, y, width, height)
	local group = display.newGroup()
	local cardDisplay = Cards.displayCard(cardData, x, y, width, height)
	if cardDisplay then
		group:insert(cardDisplay)
		if cardDisplay.getContentBounds then
			local bounds = cardDisplay:getContentBounds()
			group.cardCenterX = (bounds.xMin + bounds.xMax) * 0.5
			group.cardCenterY = (bounds.yMin + bounds.yMax) * 0.5
		else
			group.cardCenterX = cardDisplay.x or x
			group.cardCenterY = cardDisplay.y or y
		end
		local healthBarGroup = createHealthBar(cardData, cardDisplay)
		if healthBarGroup then
			group:insert(healthBarGroup)
			group.healthBar = healthBarGroup
		end
	else
		print("Erro: não foi possível exibir a carta.")
	end
	group.cardData = cardData

	-- Se a carta for especial (possuir um star especial), exibe o efeito especial (bola amarela) imediatamente.
	local specialStars = {
		[4] = true,
		[6] = true,
		[7] = true,
		[9] = true,
		[10] = true,
		[11] = true,
		[12] = true,
		[13] = true,
		[14] = true,
	}
	local isSpecial = cardData.stars and specialStars[tonumber(cardData.stars)]
	if isSpecial then
		specialEffect(cardData, group)
		cardData.effectActive = true
		print("displayCardWithHealthBar: Carta especial gerada com efeito ativado.")
	end

	return group
end

--------------------------------------------------
-- FUNÇÃO: displayCardWithEntranceAnimation
-- Exibe a carta com healthbar e, se o campo E_A for true,
-- executa o hook de animação de entrada antes de exibir a carta.
-- O callback é chamado somente quando a animação de entrada terminar.
--------------------------------------------------
local function displayCardWithEntranceAnimation(cardData, x, y, width, height, parentGroup, callback)
	local group = display.newGroup()

	local function showCard()
		local cardGroup = displayCardWithHealthBar(cardData, x, y, width, height)
		group:insert(cardGroup)
		if callback then
			callback(group)
		end
	end

	if cardData.E_A == true then
		print("displayCardWithEntranceAnimation: E_A ativado para " .. (cardData.name or "Sem Nome"))
		local success, entranceHook = pcall(require, "hooks.entranceAnimation.entranceAnim")
		if success and entranceHook and entranceHook.play then
			-- O hook de entrada será executado e só chamará o callback após sua conclusão
			entranceHook.play(x, y, width, height, parentGroup, function()
				print(
					"displayCardWithEntranceAnimation: Animação de entrada concluída para "
						.. (cardData.name or "Sem Nome")
				)
				showCard()
			end)
		else
			print("displayCardWithEntranceAnimation: Hook de entrada não encontrado, exibindo carta normalmente.")
			showCard()
		end
	else
		showCard()
	end

	return group
end

--------------------------------------------------
-- FUNÇÃO: displayFormationInGrid
-- Exibe a formação (cartas) dentro do grid.
-- Calcula as posições dos slots com base em uma grade de 3 colunas e 2 linhas,
-- com espaçamentos definidos. Para cada slot, se houver dados de carta, exibe a carta
-- usando a função apropriada (com animação de entrada ou somente com healthbar).
-- O callback onComplete é chamado quando todos os slots foram processados.
--------------------------------------------------
local function displayFormationInGrid(formationData, gridGroup, gridSlots, onComplete, invertRows)
	-- Valores base de design
	local baseSlotWidth = 230
	local baseSlotHeight = 270
	local baseSpacingX = 65
	local baseSpacingY = 70

	local designWidth = 1080
	local scaleFactor = display.contentWidth / designWidth

	local slotWidth = baseSlotWidth * scaleFactor
	local slotHeight = baseSlotHeight * scaleFactor
	local spacingX = baseSpacingX * scaleFactor
	local spacingY = baseSpacingY * scaleFactor

	local cols = 3
	local rows = 2

	local totalWidth = cols * slotWidth + (cols - 1) * spacingX
	local totalHeight = rows * slotHeight + (rows - 1) * spacingY

	local startX = -totalWidth / 2 + slotWidth / 2
	local startY = -totalHeight / 2 + slotHeight / 2 * 1.2

	_G.cardSlotPositions = {}
	local processedCount = 0
	local totalSlots = 6

	local function slotProcessed()
		processedCount = processedCount + 1
		if processedCount == totalSlots and onComplete then
			onComplete()
		end
	end

	local function fetchCharacterData(cardId, callback)
		local base_url = supabase.SUPABASE_URL
		local endpoint = "/rest/v1/user_characters"
		local query = "?id=eq."
			.. tostring(cardId)
			.. "&select=*,stars,characters(name,image,card_type,ab,sp,uuid,E_A,isRevive)"
		local url = base_url .. endpoint .. query
		local headers = {
			["apikey"] = supabase.SUPABASE_ANON_KEY,
			["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
			["Content-Type"] = "application/json",
		}
		local params = {
			headers = headers,
		}
		network.request(url, "GET", function(event)
			if event.isError then
				print("Erro ao buscar personagem para id", cardId, event.response)
				callback(nil)
			else
				local res = json.decode(event.response)
				if res and #res > 0 then
					local uc = res[1]
					local character = nil
					if uc.characters then
						if uc.characters.name then
							character = uc.characters
						elseif type(uc.characters) == "table" and #uc.characters > 0 then
							character = uc.characters[1]
						end
					end
					if character then
						uc.name = character.name
						uc.card_image = character.image
						uc.card_type = character.card_type
						uc.ab = character.ab
						uc.sp = character.sp
						uc.uuid = character.uuid
						uc.E_A = character.E_A
						uc.isRevive = character.isRevive -- Campo isRevive adicionado
					end
					if not uc.card_id then
						uc.card_id = cardId
					end
					callback(uc)
				else
					callback(nil)
				end
			end
		end, params)
	end

	local specialStars = {
		[4] = true,
		[6] = true,
		[7] = true,
		[9] = true,
		[10] = true,
		[11] = true,
		[12] = true,
		[13] = true,
		[14] = true,
	}

	for i = 1, totalSlots do
		local row = math.floor((i - 1) / cols)
		local col = (i - 1) % cols
		if invertRows then
			row = (rows - 1) - row
		end

		-- posição base do slot
		local x = startX + col * (slotWidth + spacingX)
		local y = startY + row * (slotHeight + spacingY)

		-- aplica offset se definido na formação específica
		local offsetX = (formationData.offsetX or 0) * scaleFactor
		local offsetY = (formationData.offsetY or 0) * scaleFactor
		x = x + offsetX
		y = y + offsetY

		_G.cardSlotPositions[i] = {
			x = x,
			y = y,
		}
		gridSlots[i] = nil

		if formationData[i] then
			if type(formationData[i]) == "table" then
				-- exibe carta com healthbar ou animação
				formationData[i].roundsAttacked = 1
				if formationData[i].E_A then
					local cardGroup = displayCardWithEntranceAnimation(
						formationData[i],
						x,
						y,
						slotWidth,
						slotHeight,
						gridGroup,
						function(cg)
							gridSlots[i] = cg
							slotProcessed()
						end
					)
					gridGroup:insert(cardGroup)
				else
					local cardGroup = displayCardWithHealthBar(formationData[i], x, y, slotWidth, slotHeight)
					gridGroup:insert(cardGroup)
					gridSlots[i] = cardGroup
					slotProcessed()
				end
			else
				local cardId = formationData[i]
				local function handleCardData(cardData)
					if cardData then
						formationData[i] = cardData
						cardData.roundsAttacked = 1 -- Inicia roundsAttacked como 1 para todas as cartas
						print(
							"Slot "
								.. i
								.. ": Carta "
								.. (cardData.name or "Sem Nome")
								.. " iniciada com roundsAttacked = 1 (fetched)"
						)
						if cardData.E_A == true then
							local cardGroup = displayCardWithEntranceAnimation(
								cardData,
								x,
								y,
								slotWidth,
								slotHeight,
								gridGroup,
								function(cg)
									gridSlots[i] = cg
									slotProcessed()
								end
							)
							gridGroup:insert(cardGroup)
						else
							local cardGroup = displayCardWithHealthBar(cardData, x, y, slotWidth, slotHeight)
							gridGroup:insert(cardGroup)
							gridSlots[i] = cardGroup
							slotProcessed()
						end
					else
						slotProcessed()
					end
				end
				fetchCharacterData(cardId, handleCardData)
			end
		else
			slotProcessed()
		end
	end
end

--------------------------------------------------
-- Mapa de Prioridade para Alvo
--------------------------------------------------
local priorityMap = {
	[1] = { 1, 2, 3, 4, 5, 6 },
	[2] = { 2, 1, 3, 5, 4, 6 },
	[3] = { 3, 2, 1, 6, 5, 4 },
	[4] = { 1, 2, 3, 4, 5, 6 },
	[5] = { 2, 1, 3, 5, 4, 6 },
	[6] = { 3, 2, 1, 6, 5, 4 },
}

local function getTargetIndex(attackerSlot, enemyFormation)
	local priorities = priorityMap[attackerSlot]
	for _, targetIndex in ipairs(priorities) do
		if enemyFormation[targetIndex] and type(enemyFormation[targetIndex]) == "table" then
			return targetIndex
		end
	end
	return nil
end

--------------------------------------------------
-- function ensureCallback
--------------------------------------------------
local function ensureCallback(fn)
	return function(a, t, battleFuncs, targetSlot, callback)
		if not (callback and type(callback) == "function") then
			print("[ensureCallback] Callback inválido, utilizando dummy callback.")
			callback = function()
				print("[ensureCallback] Dummy callback executado.")
			end
		end
		return fn(a, t, battleFuncs, targetSlot, callback)
	end
end

----------------------------------------------------------------------------------------------------
-- FUNÇÃO: getAttackHook
-- Retorna dinamicamente o hook de ataque com base na propriedade "ab" da carta.
----------------------------------------------------------------------------------------------------
local function getAttackHook(cardData)
	local hookName = cardData.ab
	if not hookName then
		print("getAttackHook: Nenhum valor 'ab' encontrado para a carta " .. (cardData.name or "Sem Nome"))
		return nil
	end
	local success, hookModule = pcall(require, "hooks.basicAttacks." .. hookName)
	if success and hookModule then
		print(
			"getAttackHook: Hook '"
				.. hookName
				.. "' carregado com sucesso para a carta "
				.. (cardData.name or "Sem Nome")
		)
		if hookModule.attack then
			hookModule.attack = ensureCallback(hookModule.attack)
		end
		return hookModule
	else
		print("getAttackHook: Erro ao carregar hook para ab = " .. tostring(hookName))
		return nil
	end
end
----------------------------------------------------------------------------------------------------
-- FUNÇÃO: getSpecialAttackHook
-- Retorna dinamicamente o hook especial com base na propriedade "sp" da carta.
----------------------------------------------------------------------------------------------------
local function getSpecialAttackHook(cardData)
	local spValue = cardData.sp
	if not spValue then
		print("getSpecialAttackHook: Nenhum valor 'sp' encontrado para a carta " .. (cardData.name or "Sem Nome"))
		return nil
	end
	local success, hookModule = pcall(require, "hooks.specialAttacks." .. spValue)
	if success and hookModule then
		print(
			"getSpecialAttackHook: Hook especial '"
				.. spValue
				.. "' carregado com sucesso para a carta "
				.. (cardData.name or "Sem Nome")
		)
		if hookModule.attack then
			hookModule.attack = ensureCallback(hookModule.attack)
		end
		return hookModule
	else
		print("getSpecialAttackHook: Erro ao carregar hook especial para sp = " .. tostring(spValue))
		return nil
	end
end
----------------------------------------------------------------------------------------------------
-- Função auxiliar: checkMiss
-- Retorna true se o ataque deve errar (miss), de acordo com a porcentagem definida.
----------------------------------------------------------------------------------------------------
local function checkMiss(attacker, target, targetSlot)
	print("checkMiss: attacker =", attacker, "target =", target, "targetSlot =", targetSlot)
	local attackerData = (attacker and (attacker.cardData or attacker)) or nil
	local targetData = nil
	if target then
		targetData = target.cardData or target
	else
		if _G.opponentFormationData and _G.opponentFormationData[targetSlot] then
			targetData = _G.opponentFormationData[targetSlot]
		elseif _G.playerFormationData and _G.playerFormationData[targetSlot] then
			targetData = _G.playerFormationData[targetSlot]
		end
	end

	if not attackerData or not targetData then
		print("checkMiss: attackerData ou targetData é nil; retornando false.")
		return false
	end

	local attackerPrec = tonumber(attackerData.prec) or 0
	local targetEva = tonumber(targetData.eva) or 0
	local missChance = targetEva - attackerPrec
	if missChance < 0 then
		missChance = 0
	end

	print(
		"checkMiss: targetEva = " .. targetEva .. ", attackerPrec = " .. attackerPrec .. ", missChance = " .. missChance
	)
	return math.random() < missChance
end

----------------------------------------------------------------------------------------------------
-- Função auxiliar: getDamagePosition
----------------------------------------------------------------------------------------------------
local function getDamagePosition(target)
	if target and target.cardCenterX and target.cardCenterY then
		return target.cardCenterX, target.cardCenterY
	elseif target and target.index and _G.cardSlotPositions and _G.cardSlotPositions[target.index] then
		local pos = _G.cardSlotPositions[target.index]
		return pos.x, pos.y
	elseif target and target.x and target.y then
		return target.x, target.y
	elseif target and target.getContentBounds then
		local bounds = target:getContentBounds()
		return (bounds.xMin + bounds.xMax) / 2, (bounds.yMin + bounds.yMax) / 2
	end
	return display.contentCenterX, display.contentCenterY
end
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
local function showHit(target, value, hitType, isCrit)
	if value == nil then
		value = 0
	end

	-- posição
	local x, y = getDamagePosition(target)
	local posY = y - 20

	-- “Miss” continua inalterado
	if hitType == "damage" and value == "Missasd" then
		local missImage = display.newImageRect("assets/7text/misc_miss.png", 140 * 1.5, 60 * 1.5)
		missImage.anchorX, missImage.anchorY = 0.5, 0.5
		missImage.x, missImage.y = x, posY
		if target.parent then
			target.parent:insert(missImage)
		else
			display.getCurrentStage():insert(missImage)
		end
		missImage:toFront()
		transition.to(missImage, {
			time = 1000,
			y = posY - 30,
			alpha = 0,
			onComplete = function()
				if missImage.removeSelf then
					missImage:removeSelf()
				end
			end,
		})
		return
	end

	-- monta o texto
	local textValue = hitType == "heal" and ("+" .. tostring(value)) or ("-" .. tostring(value))
	-- local hitText = display.newText({
	--     text = textValue,
	--     x = x,
	--     y = posY,
	--     font = "assets/7fonts/Icarus.ttf",
	--     fontSize = 100,
	--     align = "center"
	-- })

	-- local textile = require("utils.textile")
	-- local hitText = textile.new({
	--     texto = textValue,
	--     x = x,
	--     y = posY,
	--     tamanho = 50,
	--     corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
	--     corContorno = {0, 0, 0},
	--     espessuraContorno = 2
	-- })
	local Critical = require("utils.crticial")

	local hueAngle
	if hitType == "heal" then
		hueAngle = 270
	elseif isCrit then
		hueAngle = 35
	end

	local hitText = Critical.new({
		texto = textValue,
		x = x,
		y = posY,
		spacing = -6,
		scaleFactor = 0.65,
		hueAngle = hueAngle,
	})
	-- insere e anima
	if target.parent then
		target.parent:insert(hitText)
	else
		display.getCurrentStage():insert(hitText)
	end
	hitText:toFront()
	transition.to(hitText, {
		time = 1000,
		y = posY - 30,
		alpha = 0,
		onComplete = function()
			if hitText.removeSelf then
				hitText:removeSelf()
			end
		end,
	})
end
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
local function showPlayerDefeatOverlay()
	-- 1) Cria um grupo só para os overlays e joga ele pra frente de tudo em scene.view
	local overlayGroup = display.newGroup()
	scene.view:insert(overlayGroup)

	-- 2) Halo: primeiro no grupo, vai ficar atrás do próximo overlay mas acima do resto
	local halo =
		display.newImageRect(overlayGroup, "assets/7battle/misc_halo.png", display.contentWidth, display.contentHeight)
	halo:scale(1, 0.57)
	halo.anchorX, halo.anchorY = 0.5, 0.5
	halo.x, halo.y = display.contentCenterX, display.contentCenterY
	halo.alpha = 0

	-- fade-in + rotação infinita
	transition.to(halo, {
		time = 700,
		alpha = 1,
		onComplete = function()
			local function spin(obj)
				transition.to(obj, {
					time = 2500,
					rotation = obj.rotation + 360,
					onComplete = function()
						spin(obj)
					end,
				})
			end
			spin(halo)
		end,
	})

	-- 3) Overlay de derrota: inserido depois, ficará acima do halo
	local defeat = display.newImageRect(
		overlayGroup,
		"assets/7battle/battle_ending_loose.png",
		display.contentWidth,
		display.contentHeight
	)
	defeat:scale(0.9, 0.5)
	defeat.anchorX, defeat.anchorY = 0.5, 0.5
	defeat.x, defeat.y = display.contentCenterX, display.contentCenterY
	defeat.alpha = 0
	transition.to(defeat, {
		time = 700,
		alpha = 1,
	})
end
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
local function showPlayerVictoryOverlay()
	-- 1) Cria grupo de overlays e garante que fique à frente
	local overlayGroup = display.newGroup()
	scene.view:insert(overlayGroup)
	overlayGroup:toFront()

	-- 2) Halo giratório
	local halo =
		display.newImageRect(overlayGroup, "assets/7battle/misc_halo.png", display.contentWidth, display.contentHeight)
	halo:scale(1, 0.57)
	halo.anchorX, halo.anchorY = 0.5, 0.5
	halo.x, halo.y = display.contentCenterX, display.contentCenterY
	halo.alpha = 0
	transition.to(halo, {
		time = 700,
		alpha = 1,
		onComplete = function()
			local function spin(obj)
				transition.to(obj, {
					time = 2500,
					rotation = obj.rotation + 360,
					onComplete = function()
						spin(obj)
					end,
				})
			end
			spin(halo)
		end,
	})

	-- 3) Overlay de vitória
	local victory = display.newImageRect(
		overlayGroup,
		"assets/7battle/battle_ending_victory.png",
		display.contentWidth,
		display.contentHeight
	)
	victory:scale(0.9, 0.5)
	victory.anchorX, victory.anchorY = 0.5, 0.5
	victory.x, victory.y = display.contentCenterX, display.contentCenterY
	victory.alpha = 0
	transition.to(victory, {
		time = 700,
		alpha = 1,
	})

	-- 4) 1 s depois, adiciona um retângulo transparente para capturar o toque
	timer.performWithDelay(1000, function()
		local touchRect = display.newRect(
			overlayGroup,
			display.contentCenterX,
			display.contentCenterY,
			display.contentWidth,
			display.contentHeight
		)
		touchRect:setFillColor(0, 0, 0, 0) -- totalmente transparente
		touchRect.isHitTestable = true -- garante que capte toques mesmo alpha=0

		-- ao tocar, troca para a próxima cena
		local function onScreenTap()
			-- 1) Remove listener de resize
			Runtime:removeEventListener("resize", onResize)
			transition.cancel()
			composer.removeScene("router.battle")
			composer.gotoScene("router.menu", {
				effect = "fade",
				time = 400,
			})

			return true
		end

		touchRect:addEventListener("tap", onScreenTap)
	end)
end
----------------------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------------------
local function showDeathMarker(slot)
	local pos = _G.cardSlotPositions[slot]
	if not pos then
		return
	end
	local parentGroup = playerGridGroup or display.getCurrentStage()
	if not parentGroup then
		return
	end

	-- Remove marcador antigo, se existir
	if deathMarkers[slot] then
		display.remove(deathMarkers[slot])
		deathMarkers[slot] = nil
	end

	-- Cria novo marcador
	local marker = display.newImageRect(parentGroup, "assets/7battle/misc_battle_tomb.png", 300, 340)
	marker.anchorX, marker.anchorY = 0.5, 0.5
	marker.x, marker.y = pos.x, pos.y
	marker:toBack()

	deathMarkers[slot] = marker
end
--------------------------------------------------

--------------------------------------------------
local function simulateTurnActions()
	local function buildActions()
		local validPlayerIndexes = {}
		local validOpponentIndexes = {}
		for i = 1, totalSlots do
			if gridSlotsPlayer[i] then
				table.insert(validPlayerIndexes, i)
			end
			if gridSlotsOpponent[i] then
				table.insert(validOpponentIndexes, i)
			end
		end
		local actions = {}
		local maxCount = math.max(#validPlayerIndexes, #validOpponentIndexes)
		for i = 1, maxCount do
			if validPlayerIndexes[i] then
				table.insert(actions, {
					side = "player",
					index = validPlayerIndexes[i],
				})
			end
			if validOpponentIndexes[i] then
				table.insert(actions, {
					side = "opponent",
					index = validOpponentIndexes[i],
				})
			end
		end
		table.sort(actions, function(a, b)
			if a.index == b.index then
				local aData, bData
				if a.side == "player" then
					aData = playerFormationData[a.index]
				else
					aData = opponentFormationData[a.index]
				end
				if b.side == "player" then
					bData = playerFormationData[b.index]
				else
					bData = opponentFormationData[b.index]
				end
				return (aData.vel or 0) > (bData.vel or 0)
			else
				return a.index < b.index
			end
		end)
		return actions
	end

	local function countTeam(teamFormation)
		local count = 0
		for i = 1, totalSlots do
			if teamFormation[i] and type(teamFormation[i]) == "table" then
				count = count + 1
			end
		end
		return count
	end

	local actions = buildActions()
	local totalActions = #actions
	local currentAction = 1

	local battleFunctions = {}
	_G.battleFunctions = battleFunctions

	local function fadeOutAndRemove(card, callback)
		transition.to(card, {
			time = 500,
			alpha = 0,
			onComplete = function()
				if card.removeSelf then
					card:removeSelf()
				end
				if callback then
					callback()
				end
			end,
		})
	end
	--------------------------------------------------------------------------------
	-- Função: getCriticalMultiplierWithEffect
	--------------------------------------------------------------------------------
	local function getCriticalMultiplierWithEffect(attacker, target, callback, playAnimation, targetSlot)
		print("getCriticalMultiplierWithEffect: attacker =", attacker, "target =", target, "targetSlot =", targetSlot)
		if type(callback) ~= "function" then
			print("Warning: callback não é uma função. Tipo recebido: " .. type(callback))
			callback = function(_) end -- função dummy que não faz nada
		end

		local attackerData = (attacker and (attacker.cardData or attacker)) or nil
		local targetData = nil
		if target then
			if type(target) == "function" then
				print("getCriticalMultiplierWithEffect: target é uma função, usando dados da formação global.")
				if _G.opponentFormationData and _G.opponentFormationData[targetSlot] then
					targetData = _G.opponentFormationData[targetSlot]
				elseif _G.playerFormationData and _G.playerFormationData[targetSlot] then
					targetData = _G.playerFormationData[targetSlot]
				end
			else
				targetData = target.cardData or target
			end
		else
			if _G.opponentFormationData and _G.opponentFormationData[targetSlot] then
				targetData = _G.opponentFormationData[targetSlot]
			elseif _G.playerFormationData and _G.playerFormationData[targetSlot] then
				targetData = _G.playerFormationData[targetSlot]
			end
		end

		if not attackerData or not targetData then
			print("getCriticalMultiplierWithEffect: attackerData ou targetData é nil; retornando multiplicador 1.")
			callback(1)
			return
		end

		local attackerCri = tonumber(attackerData.cri) or 0
		local targetRes = tonumber(targetData.res) or 0
		local critChance = attackerCri - targetRes
		if critChance < 0 then
			critChance = 0
		end

		print(
			"getCriticalMultiplierWithEffect: attackerCri = "
				.. attackerCri
				.. ", targetRes = "
				.. targetRes
				.. ", critChance = "
				.. critChance
		)
		if math.random() < critChance then
			print("Ataque crítico!")
			if playAnimation then
				local critEffect = require("hooks.effects.critEffect")
				if critEffect and critEffect.playEffect then
					critEffect.playEffect(attacker.group or attacker, function()
						callback(2) -- Chama o callback somente após o efeito crítico terminar
					end)
				else
					callback(2)
				end
			else
				callback(2)
			end
		else
			callback(1)
		end
	end

	battleFunctions.getCriticalMultiplierWithEffect = getCriticalMultiplierWithEffect

	--------------------------------------------------------------------------------
	-- Função: applyDamage
	--------------------------------------------------------------------------------
	local function safeManageCardTurn(cardData, action)
		if battleFunctions and battleFunctions.manageCardTurn then
			battleFunctions.manageCardTurn(cardData, action)
		elseif _G.manageCardTurn then
			_G.manageCardTurn(cardData, action)
		else
			print("manageCardTurn function not defined, skipping block action.")
		end
	end

	battleFunctions.applyDamage = function(attacker, target, damage, targetSlot)
		-- 0) calcula/faz fallback para o display do alvo
		local targetDisplay = target.isOpponent and gridSlotsOpponent[targetSlot] or gridSlotsPlayer[targetSlot]
		if not targetDisplay and target.group then
			targetDisplay = target.group
		end

		-- 1) verifica miss
		if checkMiss(attacker, target, targetSlot) then
			print("Ataque de " .. (attacker.name or "Sem Nome") .. " errou " .. (target.name or "Sem Nome"))
			if targetDisplay then
				showHit(targetDisplay, "Miss", "damage")
			end
			return
		end

		-- 2) escudo com múltiplos bloqueios
		if target.shieldHitsRemaining and target.shieldHitsRemaining > 0 then
			print(
				(target.name or "Carta")
					.. " bloqueou o ataque com escudo! Restam "
					.. (target.shieldHitsRemaining - 1)
					.. " bloqueios."
			)
			target.shieldHitsRemaining = target.shieldHitsRemaining - 1

			-- Atualiza contador gráfico de shield
			if target.defenseText then
				if target.shieldHitsRemaining > 0 then
					target.defenseText.text = tostring(target.shieldHitsRemaining)
				else
					if target.defenseIcon and target.defenseIcon.removeSelf then
						defenseIcon.alpha = 0
					end
					if target.defenseText and target.defenseText.removeSelf then
						defenseIcon.alpha = 0
					end
					target.defenseIcon, target.defenseText = nil, nil
				end
			end
			return
		end

		-- 3) shareVision com 40% de chance, consumindo carga sempre
		if target.shareVisionHitsRemaining and target.shareVisionHitsRemaining > 0 then
			-- consome uma carga
			target.shareVisionHitsRemaining = target.shareVisionHitsRemaining - 1

			-- atualiza contador gráfico
			if target.shareVisionText then
				if target.shareVisionHitsRemaining > 0 then
					target.shareVisionText.text = tostring(target.shareVisionHitsRemaining)
				else
					if target.shareVisionIcon and target.shareVisionIcon.removeSelf then
						shareVisionIcon.alpha = 0
					end
					if target.shareVisionText and target.shareVisionText.removeSelf then
						shareVisionIcon.alpha = 0
					end
					target.shareVisionIcon, target.shareVisionText = nil, nil
				end
			end

			-- 40% de chance de bloquear de fato
			if math.random() < 0.4 then
				print(
					(target.name or "Carta")
						.. " bloqueou o ataque com shareVision! Restam "
						.. target.shareVisionHitsRemaining
						.. " bloqueios."
				)

				-- feedback visual com PNG em fade in/out
				local grp = target.group
				if grp then
					local w, h = grp.contentWidth, grp.contentHeight
					-- cria a imagem já como filho do grupo da carta
					local img = display.newImageRect(
						grp,
						"assets/7battle/rinnegan.png", -- substitua pelo seu PNG
						w * 0.9 * deviceScaleFactor,
						h * 0.5 * deviceScaleFactor
					)
					img.anchorX, img.anchorY = 0.5, 0.5
					-- posiciona no centro da carta
					img.x = grp.cardCenterX or (w * 0 * deviceScaleFactor)
					img.y = grp.cardCenterY or (h * 0 * deviceScaleFactor)
					img.alpha = 0

					-- fade in rápido, depois fade out
					transition.to(img, {
						time = 200,
						alpha = 0.8,
						onComplete = function()
							transition.to(img, {
								time = 400,
								alpha = 0,
								onComplete = function()
									if img.removeSelf then
										img:removeSelf()
									end
								end,
							})
						end,
					})
				end

				return
			end
		end

		-- 3) prepara cálculo de dano
		local prevHP = target.hp or 0
		local targetData = target.cardData or target
		local armor = tonumber(targetData.armor) or 1
		print("applyDamage: damage = " .. damage .. ", armor = " .. armor)
		local baseDamage = math.max(1, math.floor(damage * armor))
		print("applyDamage: baseDamage calculado = " .. baseDamage)

		-- 4) aplica crítico e dano
		battleFunctions.getCriticalMultiplierWithEffect(attacker, target, function(critMultiplier)
			local finalDamage = math.max(1, math.floor(baseDamage * critMultiplier))
			print("applyDamage: finalDamage após crítico = " .. finalDamage)

			target.hp = prevHP - finalDamage
			if target.hp < 0 then
				target.hp = 0
			end
			local appliedDamage = prevHP - target.hp

			print(
				"Dano de "
					.. appliedDamage
					.. " aplicado de "
					.. (attacker.name or "Sem Nome")
					.. " a "
					.. (target.name or "Sem Nome")
					.. " no slot "
					.. targetSlot
					.. ". HP anterior: "
					.. prevHP
					.. " | HP restante: "
					.. target.hp
			)

			-- 5) mostra o hit
			if targetDisplay then
				local isCrit = (critMultiplier > 1)
				showHit(targetDisplay, appliedDamage, "damage", isCrit)
			end

			-- 6) atualiza health bar
			if targetDisplay and targetDisplay.healthBar and targetDisplay.healthBar.numChildren >= 2 then
				local bgBar = targetDisplay.healthBar[1]
				local healthBar = targetDisplay.healthBar[2]
				local origW = healthBar.originalWidth or bgBar.width
				local maxHP = target.currentMax or target.originalHP or 100
				local newW = origW * (target.hp / maxHP)
				healthBar.width = newW
			end

			-- 7) block on hit
			if attacker.blockTargetOnHit then
				safeManageCardTurn(targetData, "block")
			end

			-- 8) morte / remoção
			if target.hp <= 0 then
				if manageCardTurn(target, "die", targetSlot) then
					return
				end

				print(target.name .. " morreu!")

				if target.isOpponent then
					-- remove oponente sem marker
					_G.opponentsDefeated = (_G.opponentsDefeated or 0) + 1
					opponentFormationData[targetSlot] = nil
					if gridSlotsOpponent[targetSlot] then
						fadeOutAndRemove(gridSlotsOpponent[targetSlot])
						gridSlotsOpponent[targetSlot] = nil
					end
				else
					-- jogador: antes de remover o display, desenha o marker
					playerFormationData[targetSlot] = nil
					deadPlayerSlots[targetSlot] = true
					showDeathMarker(targetSlot)

					-- aí sim faz fade e remove o gráfico da carta
					if gridSlotsPlayer[targetSlot] then
						fadeOutAndRemove(gridSlotsPlayer[targetSlot])
						gridSlotsPlayer[targetSlot] = nil
					end
				end

				return
			end
		end, false)
	end

	--------------------------------------------------------------------------------
	-- Função: applyDamageToFormation
	--------------------------------------------------------------------------------
	-- Número total de slots por time (já definido em battle.lua)
	local totalSlots = 6

	battleFunctions.applyDamageToFormation = function(attacker, targetIsOpponent, damage, opts)
		-- opts = { multiHit = true/false, singleHit = true/false }
		opts = opts or {}
		local formation = targetIsOpponent and opponentFormationData or playerFormationData
		local slots = targetIsOpponent and gridSlotsOpponent or gridSlotsPlayer

		-- 1) animação única para a formação inteira
		if opts.singleHit then
			-- usa centro já calculado em defineFormationCenters()
			local center = targetIsOpponent and _G.opponentFormationCenter or _G.playerFormationCenter
			-- cria grupo dummy só para ter coords locais
			local dummy = display.newGroup()
			dummy.x, dummy.y = center.x, center.y
			showHitEffect(dummy)
		end

		-- 2) loop por cada slot definido na formação (pula índices nil e chaves não-numéricas)
		for slot, tgtData in pairs(formation) do
			if type(slot) == "number" and type(tgtData) == "table" and tonumber(tgtData.hp or 0) > 0 then
				local tgtDisp = slots[slot]
				tgtData.isOpponent = targetIsOpponent

				-- 2a) animação individual em cada carta
				if opts.multiHit and tgtDisp then
					showHitEffect(tgtDisp)
				end

				-- 2b) aplica o dano normal (inclui número de dano, miss, etc.)
				battleFunctions.applyDamage(attacker, tgtData, damage, slot)
			end
		end
	end

	--------------------------------------------------------------------------------
	-- Função: applyHealing (modificada)
	-- Aplica a cura, atualiza o HP (limitado ao máximo) e exibe o valor efetivamente
	-- curado usando showHit com o tipo "heal".
	--------------------------------------------------------------------------------
	battleFunctions.applyHealing = function(attacker, target, healAmount, targetSlot)
		local prevHP = target.hp or 0
		target.hp = prevHP + healAmount
		if target.hp > target.originalHP then
			target.hp = target.originalHP
		end
		local appliedHeal = target.hp - prevHP

		print(
			"Cura de "
				.. healAmount
				.. " aplicada a "
				.. (target.name or "sem nome")
				.. ". HP anterior: "
				.. prevHP
				.. " | HP atual: "
				.. target.hp
				.. " | Applied heal: "
				.. appliedHeal
		)

		if battleFunctions.updateHealthBar then
			battleFunctions.updateHealthBar(target)
		end

		-- Tenta obter o objeto de display da carta curada
		local targetDisplay = nil
		if target.isOpponent then
			targetDisplay = gridSlotsOpponent[targetSlot]
		else
			targetDisplay = gridSlotsPlayer[targetSlot]
		end

		-- Fallback: se targetDisplay não existir e se o target tiver um grupo,
		-- utiliza esse grupo; para o player, tenta usar _G.playerGridGroup
		if not targetDisplay then
			if target.group then
				targetDisplay = target.group
			elseif not target.isOpponent and _G.playerGridGroup then
				targetDisplay = _G.playerGridGroup
			end
		end

		if appliedHeal > 0 then
			if targetDisplay then
				showHit(targetDisplay, appliedHeal, "heal")
			else
				showHit(target, appliedHeal, "heal")
			end
		else
			print("Nenhuma cura efetiva aplicada (appliedHeal = " .. appliedHeal .. ")")
		end
	end
	--------------------------------------------------------------------------------
	-- battleFunctions getAllies & updateHealthBar
	--------------------------------------------------------------------------------
	battleFunctions.getAllies = function(attacker)
		local allies = {}
		if attacker.isOpponent then
			for i = 1, totalSlots do
				if opponentFormationData[i] and type(opponentFormationData[i]) == "table" then
					table.insert(allies, opponentFormationData[i])
				end
			end
		else
			for i = 1, totalSlots do
				if playerFormationData[i] and type(playerFormationData[i]) == "table" then
					table.insert(allies, playerFormationData[i])
				end
			end
		end
		return allies
	end

	battleFunctions.updateHealthBar = function(ally)
		local targetSlot = nil
		for i = 1, totalSlots do
			local current = ally.isOpponent and opponentFormationData[i] or playerFormationData[i]
			if current == ally then
				targetSlot = i
				break
			end
		end
		if targetSlot then
			local displayGroup = ally.isOpponent and gridSlotsOpponent[targetSlot] or gridSlotsPlayer[targetSlot]
			if displayGroup and displayGroup.healthBar and displayGroup.healthBar.numChildren >= 2 then
				local bgBar = displayGroup.healthBar[1]
				local healthBar = displayGroup.healthBar[2]
				local originalWidth = healthBar.originalWidth or bgBar.width
				local maxHP = ally.originalHP or originalWidth
				healthBar.width = originalWidth * (ally.hp / maxHP)
			end
		end
	end

	--------------------------------------------------------------------------------
	-- Função para criar o botão "Avançar para Fase"
	--------------------------------------------------------------------------------
	local function showAdvanceButton(callback, scale)
		scale = scale or 1
		local button = display.newImageRect("assets/7effect/eff_battle_go.png", 200 / 2, 300 / 2)
		button.anchorX = 0.5
		button.anchorY = 0.5
		button.x = display.contentCenterX
		button.y = display.contentCenterY
		button:scale(scale, scale)

		-- Função para criar o efeito de pulsação (fade in e fade out) de forma recursiva
		local function pulse(obj)
			transition.to(obj, {
				alpha = 0.5,
				time = 500,
				transition = easing.inOutSine,
				onComplete = function()
					transition.to(obj, {
						alpha = 1,
						time = 500,
						transition = easing.inOutSine,
						onComplete = function()
							pulse(obj)
						end,
					})
				end,
			})
		end

		pulse(button) -- Inicia a animação de pulsação

		button:addEventListener("tap", function(event)
			if button.removeSelf then
				button:removeSelf()
			end
			if callback and type(callback) == "function" then
				callback()
			end
			return true
		end)

		return button
	end

	--------------------------------------------------------------------------------
	-- Função fullyResetCard
	--------------------------------------------------------------------------------
	local function fullyResetCard(card)
		if card and type(card) == "table" then
			-- Reinicia o contador de rounds
			card.roundsAttacked = 1

			-- Reinicia a tabela de estatísticas de turno (ou remove se preferir que ela seja recriada)
			card.turnStats = {
				attacksPerformed = 0,
				timesAttacked = 0,
				blockedTurns = 0,
			}

			-- Remove efeitos visuais ativos e marca para efeito desativado
			card.effectActive = false
			if card.specialEffectSprite and card.specialEffectSprite.removeSelf then
				card.specialEffectSprite:removeSelf()
			end
			card.specialEffectSprite = nil

			-- Restaura o HP ao valor original, se definido
			if card.originalHP then
				card.hp = card.originalHP
			end

			-- Reseta sinalizadores de bloqueio ou outros efeitos de turno
			card.attackBlocked = false
			if card.stunImage and card.stunImage.removeSelf then
				card.stunImage:removeSelf()
			end
			card.stunImage = nil
			if card.stunText and card.stunText.removeSelf then
				card.stunText:removeSelf()
			end
			card.stunText = nil

			-- Aqui você pode adicionar a reinicialização de quaisquer outras propriedades modificadas durante o jogo.
		end
	end

	-- Função que percorre toda a formação e reinicializa cada carta
	local function fullyResetFormation(formation)
		for i = 1, #formation do
			fullyResetCard(formation[i])
		end
	end
	--------------------------------------------------------------------------------
	-- Função auxiliar: inTable
	--------------------------------------------------------------------------------
	local function inTable(tbl, value)
		for _, v in ipairs(tbl) do
			if v == value then
				return true
			end
		end
		return false
	end

	--------------------------------------------------------------------------------
	-- Tabelas definidas para os rounds
	--------------------------------------------------------------------------------
	local spRoundsNormal = { 3, 6, 9, 12, 15, 18, 21, 24, 27, 30 }
	local spRoundsSpecial = { 1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34, 37, 40 }
	local effectRoundsNormal = { 3, 6, 9, 12, 15, 18, 21, 24, 27, 30 }
	local effectRoundsSpecial = { 1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34, 37, 40 }

	--------------------------------------------------------------------------------
	-- Constante para fade out do efeito (quando o SP attack inicia)
	--------------------------------------------------------------------------------
	local fadeTime = 500

	local function ensureRoundsSet(formation)
		for key, card in pairs(formation) do
			if type(card) == "table" then
				card.roundsAttacked = tonumber(card.roundsAttacked) or 1
			end
		end
	end

	--------------------------------------------------------------------------------
	-- Função checkAndActivateSpecialEffect
	--------------------------------------------------------------------------------
	local function checkAndActivateSpecialEffect(
		cardData,
		cardGroup,
		attacker,
		target,
		battleFunctions,
		targetSlot,
		callback
	)
		local ok, err = pcall(function()
			if cardData.roundsAttacked == nil then
				cardData.roundsAttacked = 1
			end
			local r = tonumber(cardData.roundsAttacked) or 1

			local isSpecial = false
			if cardData.stars then
				local specialStars = {
					[4] = true,
					[6] = true,
					[7] = true,
					[9] = true,
					[10] = true,
					[11] = true,
					[12] = true,
					[13] = true,
					[14] = true,
				}
				isSpecial = specialStars[tonumber(cardData.stars)] or false
			end

			local shouldActivate = false
			if isSpecial then
				-- Para cartas especiais, o efeito só será ativado se o round estiver em effectRoundsSpecial
				if inTable(effectRoundsSpecial, r) then
					shouldActivate = true
				else
					shouldActivate = false
				end
			else
				if inTable(effectRoundsNormal, r) then
					shouldActivate = true
				else
					shouldActivate = false
				end
			end

			print(
				"[checkAndActivateSpecialEffect] "
					.. (cardData.name or "Sem Nome")
					.. " | Round: "
					.. r
					.. " | isSpecial: "
					.. tostring(isSpecial)
					.. " | Should Activate Effect: "
					.. tostring(shouldActivate)
			)

			if shouldActivate then
				if not cardData.effectActive then
					specialEffect(cardData, cardGroup)
					cardData.effectActive = true
					print("[checkAndActivateSpecialEffect] Effect ACTIVATED for " .. (cardData.name or "Sem Nome"))
				else
					print("[checkAndActivateSpecialEffect] Effect already active for " .. (cardData.name or "Sem Nome"))
				end
			else
				if cardData.effectActive then
					-- Se o efeito estiver ativo e não deve estar, removemos-o (opcionalmente com fade out)
					transition.to(cardData.specialEffectSprite, {
						alpha = 0,
						time = 500,
						onComplete = function()
							if cardData.specialEffectSprite.removeSelf then
								cardData.specialEffectSprite:removeSelf()
							end
							cardData.specialEffectSprite = nil
							cardData.effectActive = false
							print(
								"[checkAndActivateSpecialEffect] Effect REMOVED for " .. (cardData.name or "Sem Nome")
							)
						end,
					})
				else
					print("[checkAndActivateSpecialEffect] No effect for " .. (cardData.name or "Sem Nome"))
				end
			end
		end)
		if not ok then
			print("[checkAndActivateSpecialEffect] Error: " .. tostring(err))
		end
		if callback and type(callback) == "function" then
			callback()
		else
			print("[checkAndActivateSpecialEffect] Callback is nil or not a function")
		end
	end
	local sf = scaleFactor or (display.actualContentWidth / 1080)
	--------------------------------------------------------------------------------
	-- FUNÇÃO: manageCardTurn (com Bleed aplicado via applyDamage)
	--------------------------------------------------------------------------------
	local sf = scaleFactor or (display.actualContentWidth / 1080)

	local function manageCardTurn(cardData, action, value)
		-- Inicializa estatísticas de turno
		if not cardData.turnStats then
			cardData.turnStats = {
				attacksPerformed = 0,
				timesAttacked = 0,
				blockedTurns = 0,
			}
		end

		--------------------------------------------------------------------------------
		-- AÇÃO: ataque executado
		--------------------------------------------------------------------------------
		if action == "attackPerformed" then
			-- Trata stun/bloqueio de execução de ataque
			if cardData.turnStats.blockedTurns > 0 then
				print((cardData.name or "Carta") .. " está bloqueada para atacar neste turno!")
				cardData.turnStats.blockedTurns = cardData.turnStats.blockedTurns - 1

				if cardData.stunText then
					if cardData.turnStats.blockedTurns > 0 then
						cardData.stunText.text = tostring(cardData.turnStats.blockedTurns)
					else
						cardData.stunText:removeSelf()
						cardData.stunText = nil
					end
				end

				cardData.attackBlocked = true
				return true
			end

			-- Libera ataque
			cardData.attackBlocked = false
			if cardData.stunImage then
				cardData.stunImage:removeSelf()
			end
			if cardData.stunText then
				cardData.stunText:removeSelf()
			end
			cardData.stunImage, cardData.stunText = nil, nil
			return true

			--------------------------------------------------------------------------------
			-- AÇÃO: bloqueio por turnos (stun)
			--------------------------------------------------------------------------------
		elseif action == "block" then
			if
				(cardData.shieldHitsRemaining or 0) > 0
				or (cardData.shareVisionHitsRemaining or 0) > 0
				or cardData.lastAttackMiss
			then
				print((cardData.name or "Carta") .. " não recebeu block: proteção ativa ou miss.")
				cardData.lastAttackMiss = false
				return
			end

			-- caso contrário, aplica normal
			local turns = tonumber(value) or 1
			cardData.turnStats.blockedTurns = turns
			print((cardData.name or "Carta") .. " foi bloqueada por " .. turns .. " turno(s).")

			if cardData.group and not cardData.stunImage then
				local stunImage = display.newImageRect(
					"assets/7battle/icon_buffer_1.png",
					60 * deviceScaleFactor,
					60 * deviceScaleFactor
				)
				stunImage.anchorX, stunImage.anchorY = 0.5, 0.5
				stunImage.x = -cardData.group.contentWidth * 0.5 + 65 * 0.4 * deviceScaleFactor
				stunImage.y = cardData.group.contentHeight * 0.5 - 65 * 1.2 * deviceScaleFactor

				cardData.stunImage = stunImage
				cardData.group:insert(stunImage)

				local stunText = display.newText({
					text = tostring(turns),
					x = stunImage.x + stunImage.width * 0.5,
					y = stunImage.y,
					font = native.systemFontBold,
					fontSize = 30,
				})
				stunText:setFillColor(1, 1, 0)
				cardData.stunText = stunText
				cardData.group:insert(stunText)
			end
			return true
			--------------------------------------------------------------------------------
			-- AÇÃO: shield (bloqueio de N ataques)
			--------------------------------------------------------------------------------
		elseif action == "shield" then
			local hits = tonumber(value) or 1
			cardData.shieldHitsRemaining = hits
			print((cardData.name or "Carta") .. " recebeu escudo para bloquear " .. hits .. " ataque(s)!")

			if cardData.group then
				if not cardData.defenseIcon then
					defenseIcon = display.newImageRect(
						"assets/7battle/icon_buffer_2.png",
						60 * deviceScaleFactor,
						60 * deviceScaleFactor
					)
					defenseIcon.anchorX, defenseIcon.anchorY = 0.5, 0.5
					defenseIcon.x = display.contentCenterX
					defenseIcon.y = display.contentCenterY
					defenseIcon.alpha = 1
					cardData.group:insert(defenseIcon)
				end

				-- remove texto anterior com segurança
				display.remove(cardData.defenseText)
				cardData.defenseText = nil

				local icon = cardData.defenseIcon
				local iconX = icon and icon.x or (cardData.group.contentCenterX or 0)
				local iconY = icon and icon.y or (cardData.group.contentCenterY or 0)

				local txt = display.newText({
					text = tostring(hits),
					x = iconX + 10,
					y = iconY,
					font = "assets/7fonts/icarus.ttf",
					fontSize = 24,
				})
				txt:setFillColor(1, 1, 0)
				cardData.defenseText = txt
				cardData.group:insert(txt)
			end

			--------------------------------------------------------------------------------
			-- AÇÃO: shareVision (bloqueio de N ataques)
			--------------------------------------------------------------------------------
		elseif action == "shareVision" then
			local uses = tonumber(value) or 1
			cardData.shareVisionHitsRemaining = uses
			print((cardData.name or "Carta") .. " recebeu shareVision para bloquear " .. uses .. " ataque(s)!")

			if cardData.group then
				if not cardData.shareVisionIcon then
					shareVisionIcon = display.newImageRect(
						"assets/7battle/icon_buffer_14.png",
						65 * deviceScaleFactor,
						65 * deviceScaleFactor
					)
					shareVisionIcon.anchorX, shareVisionIcon.anchorY = 0.5, 0.5
					shareVisionIcon.x = -cardData.group.contentWidth * 0.5 + 65 * 4.2 * deviceScaleFactor
					shareVisionIcon.y = cardData.group.contentHeight * 0.5 - 65 * 2.7 * deviceScaleFactor
					shareVisionIcon.alpha = 1
					cardData.group:insert(shareVisionIcon)
				end

				-- remove texto anterior com segurança
				display.remove(cardData.shareVisionText)
				cardData.shareVisionText = nil

				local icon = cardData.shareVisionIcon
				local iconX = icon and icon.x or (cardData.group.contentCenterX or 0)
				local iconY = icon and icon.y or (cardData.group.contentCenterY or 0)

				local txt = display.newText({
					text = tostring(uses),
					x = iconX + 10,
					y = iconY,
					font = "assets/7fonts/icarus.ttf",
					fontSize = 24,
				})
				txt:setFillColor(1, 1, 0)
				cardData.shareVisionText = txt
				cardData.group:insert(txt)
			end

			--------------------------------------------------------------------------------
			-- AÇÃO: sofreu ataque (attacked)
			--------------------------------------------------------------------------------
		elseif action == "attacked" then
			-- Conta quantas vezes foi atacado
			cardData.turnStats.timesAttacked = cardData.turnStats.timesAttacked + 1

			--------------------------------------------------------------------------------
			-- AÇÃO: resetShield
			--------------------------------------------------------------------------------
		elseif action == "resetShield" then
			-- O shield é limpo em applyDamage, nada a fazer aqui
			print((cardData.name or "Carta") .. " mantém escudo até ser atacada.")

			--------------------------------------------------------------------------------
			-- AÇÃO: resetBlock
			--------------------------------------------------------------------------------
		elseif action == "resetBlock" then
			cardData.turnStats.blockedTurns = 0

			--------------------------------------------------------------------------------
			-- AÇÃO: bleedTick (aplica bleed ao final de cada ataque, se ainda houver rounds)
			--------------------------------------------------------------------------------
		elseif action == "bleedTick" then
			if cardData.bleed and cardData.bleed.rounds and cardData.bleed.rounds > 0 then
				-- calcula dano de bleed (por exemplo, percentagem do originalHP)
				local maxHP = cardData.originalHP or cardData.hp or 1
				local dmg = math.max(1, math.floor(maxHP * (cardData.bleed.percent or 0)))
				local prevHP = cardData.hp or 0
				cardData.hp = math.max(0, prevHP - dmg)
				cardData.bleed.rounds = cardData.bleed.rounds - 1

				-- mostra o hit (vermelho)
				local dispGroup = cardData.group
				if dispGroup then
					showHit(dispGroup, dmg, "damage", false)
					-- atualiza healthBar
					if dispGroup.healthBar and dispGroup.healthBar.numChildren >= 2 then
						local bg = dispGroup.healthBar[1]
						local fg = dispGroup.healthBar[2]
						local origW = fg.originalWidth or bg.width
						fg.width = origW * (cardData.hp / maxHP)
					end
				end
			end
			return
			--------------------------------------------------------------------------------
			-- AÇÃO: applyBleed
			--------------------------------------------------------------------------------
		elseif action == "applyBleed" then
			local params = value or {}
			cardData.bleed = {
				percent = tonumber(params.percent) or 0.01,
				rounds = tonumber(params.rounds) or 1,
			}

			--------------------------------------------------------------------------------
			-- AÇÃO: getStats
			--------------------------------------------------------------------------------
		elseif action == "getStats" then
			return {
				attacksPerformed = cardData.turnStats.attacksPerformed,
				timesAttacked = cardData.turnStats.timesAttacked,
				blockedTurns = cardData.turnStats.blockedTurns,
			}

			--------------------------------------------------------------------------------
			-- AÇÃO: die
			--------------------------------------------------------------------------------
		elseif action == "die" then
			if cardData.hp <= 0 then
				local reviveFlag = false
				if cardData.characters and type(cardData.characters) == "table" then
					reviveFlag = (cardData.characters.isRevive == true)
				end
				if reviveFlag and not cardData.reviveUsed then
					print(cardData.name .. " morreu, mas será revivida imediatamente!")
					cardData.reviveUsed = true
					local originalHP = (cardData.originalHP and cardData.originalHP > 0) and cardData.originalHP or 100
					local reviveHP = math.floor(originalHP * 0.2)
					cardData.currentMax = originalHP

					if cardData.group then
						transition.to(cardData.group, {
							time = 300,
							alpha = 0,
							onComplete = function()
								timer.performWithDelay(200, function()
									cardData.hp = reviveHP
									cardData.desactivated = true
									transition.to(cardData.group, {
										time = 1000,
										alpha = 1.0,
										onComplete = function()
											if
												cardData.group.healthBar
												and cardData.group.healthBar.numChildren >= 2
											then
												local hb = cardData.group.healthBar
												local bg = hb[1]
												local fg = hb[2]
												local origW = fg.originalWidth or bg.width
												fg.width = origW * (cardData.hp / originalHP)
											else
												cardData.group.healthBar = createHealthBar(cardData, cardData.group)
											end
											print(cardData.name .. " foi revivida com " .. cardData.hp .. " de HP!")
										end,
									})
								end)
							end,
						})
					else
						cardData.hp = reviveHP
						cardData.currentMax = originalHP
						cardData.desactivated = true
						print(cardData.name .. " foi revivida (sem gráfico) com " .. cardData.hp .. " de HP!")
					end

					return true
				else
					print(cardData.name .. " morreu definitivamente.")
					if cardData.group and cardData.group.healthBar then
						cardData.group.healthBar:removeSelf()
						cardData.group.healthBar = nil
					end
					return false
				end
			end
		else
			print("Ação desconhecida em manageCardTurn: " .. tostring(action))
		end
	end

	_G.manageCardTurn = manageCardTurn

	--------------------------------------------------------------------------------
	-- Função safeManageCardTurn
	--------------------------------------------------------------------------------
	local function safeManageCardTurn(cardData, action, value)
		if battleFunctions and battleFunctions.manageCardTurn then
			battleFunctions.manageCardTurn(cardData, action, value)
		elseif _G.manageCardTurn then
			_G.manageCardTurn(cardData, action, value)
		else
			print("manageCardTurn function not defined, skipping block action.")
		end
	end

	--------------------------------------------------------------------------------
	-- Função performAction (trecho relevante)
	--------------------------------------------------------------------------------
	local specialStars = { -- xereca defeituosa
		[4] = true,
		[6] = true,
		[7] = true,
		[9] = true,
		[10] = true,
		[11] = true,
		[12] = true,
		[13] = true,
		[14] = true,
	}

	local function performAction()
		if playerFormationData then
			ensureRoundsSet(playerFormationData)
		end
		if opponentFormationData then
			ensureRoundsSet(opponentFormationData)
		end

		-- garante que expectedOpponentsPhase1 nunca seja nil
		if expectedOpponentsPhase1 == nil then
			expectedOpponentsPhase1 = countTeam(opponentFormationData)
		end

		currentAction = tonumber(currentAction) or 1
		totalActions = tonumber(totalActions) or 0

		if currentPhase == nil then
			currentPhase = 1
			print("currentPhase estava nil; definindo currentPhase = 1")
		end

		if currentAction > totalActions then
			print("performAction - currentPhase: " .. tostring(currentPhase))
			local activeOpponents = countTeam(opponentFormationData)
			print("activeOpponents: " .. activeOpponents .. " | opponentsDefeated: " .. opponentsDefeated)

			-- Transição de fases
			if currentPhase == 1 and opponentsDefeated >= expectedOpponentsPhase1 then
				showAdvanceButton(function()
					-- 0a) Zera shareVision e shield para reaplicação futura
					for i, card in pairs(playerFormationData) do
						if card then
							card.shareVisionHitsRemaining = nil
							card.shieldHitsRemaining = nil
						end
					end

					-- 0b) Remove todas as instâncias antigas do deathMarker
					for slot, marker in pairs(deathMarkers) do
						display.remove(marker)
						deathMarkers[slot] = nil
					end

					local transitionNinja = require("components.transitionNinja")
					local ninjaSprite = transitionNinja.new({
						x = display.contentCenterX,
						y = _G.playerFormationCenter.y,
						time = 700, -- opcional: duração total da animação
						loopCount = 0, -- opcional: 0 = infinito
						onComplete = function()
							print("Animação do ninja terminou!")
						end,
					})
					timer.performWithDelay(700, function()
						ninjaSprite:removeSelf()
					end)

					for i = 1, totalSlots do
						if gridSlotsPlayer[i] and gridSlotsPlayer[i].removeSelf then
							gridSlotsPlayer[i]:removeSelf()
							gridSlotsPlayer[i] = nil
						end
					end

					currentPhase = 2

					-- Recriar a formação do jogador 500 ms antes do término do roll do background
					timer.performWithDelay(750, function()
						if not playerGridGroup then
							local parent = sceneGroup or display.getCurrentStage()
							playerGridGroup = createCardGrid(
								parent,
								display.contentCenterX,
								display.contentHeight - (400 / 1920) * display.actualContentHeight
							)
						end

						-- Aqui a formação é recriada utilizando o método original (displayFormationInGrid que chama displayCardWithHealthBar)
						displayFormationInGrid(playerFormationData, playerGridGroup, gridSlotsPlayer, function()
							print("Formação do jogador recriada (Fase 2) 500 ms antes do término do roll.")
						end, false)
					end)

					transition.to(background, {
						time = 750,
						y = background.y + 340,
						onComplete = function()
							-- Remover a formação do oponente para garantir que os objetos anteriores não se sobreponham
							for i = 1, totalSlots do
								if gridSlotsOpponent[i] and gridSlotsOpponent[i].removeSelf then
									gridSlotsOpponent[i]:removeSelf()
									gridSlotsOpponent[i] = nil
								end
							end

							if localOpponentModule and type(localOpponentModule.fetchFormationData) == "function" then
								local oldFormation = opponentFormationData
								localOpponentModule.fetchFormationData(teamG .. "002", function(newOppFormation, err)
									if err then
										print("Erro ao carregar formação para fase 2:", err)
										return
									end
									if not newOppFormation or countTeam(newOppFormation) == 0 then
										print("Formação da fase 2 retornou vazia!")
										return
									end
									for i = 1, #newOppFormation do
										if oldFormation[i] and newOppFormation[i] then
											newOppFormation[i].hp = oldFormation[i].hp
											newOppFormation[i].originalHP = oldFormation[i].originalHP
												or newOppFormation[i].hp
										end
									end
									-- Se desejar reinicializar os dados das cartas do oponente como um novo jogo, aqui você pode chamar o método de reset (por exemplo, fullyResetFormation)
									fullyResetFormation(newOppFormation)

									expectedOpponentsPhase2 = 0
									for i = 1, totalSlots do
										if newOppFormation[i] and type(newOppFormation[i]) == "table" then
											expectedOpponentsPhase2 = expectedOpponentsPhase2 + 1
										end
									end
									opponentsDefeated = 0
									opponentFormationData = newOppFormation

									displayFormationInGrid(
										newOppFormation,
										opponentGridGroup,
										gridSlotsOpponent,
										function()
											actions = buildActions()
											totalActions = #actions
											currentAction = 1
											performAction()
										end,
										true
									)
								end)
							else
								print("Erro: módulo localOpponentModule ou fetchFormationData não encontrado.")
							end
						end,
					})
				end)
				return
			elseif currentPhase == 2 and opponentsDefeated >= expectedOpponentsPhase2 then
				showAdvanceButton(function()
					-- 0a) Zera shareVision e shield para reaplicação futura
					for i, card in pairs(playerFormationData) do
						if card then
							card.shareVisionHitsRemaining = nil
							card.shieldHitsRemaining = nil
						end
					end

					local transitionNinja = require("components.transitionNinja")
					local ninjaSprite = transitionNinja.new({
						x = display.contentCenterX,
						y = _G.playerFormationCenter.y,
						time = 700, -- opcional: duração total da animação
						loopCount = 0, -- opcional: 0 = infinito
						onComplete = function()
							print("Animação do ninja terminou!")
						end,
					})
					timer.performWithDelay(700, function()
						ninjaSprite:removeSelf()
					end)

					-- 0b) Remove todas as instâncias antigas do deathMarker
					for slot, marker in pairs(deathMarkers) do
						display.remove(marker)
						deathMarkers[slot] = nil
					end

					for i = 1, totalSlots do
						if gridSlotsPlayer[i] and gridSlotsPlayer[i].removeSelf then
							gridSlotsPlayer[i]:removeSelf()
							gridSlotsPlayer[i] = nil
						end
					end

					currentPhase = 3

					-- Recriar a formação do jogador 500 ms antes do término do roll do background (transição total: 2000 ms; recriação aos 1500 ms)
					timer.performWithDelay(750, function()
						if not playerGridGroup then
							local parent = sceneGroup or display.getCurrentStage()
							playerGridGroup = createCardGrid(
								parent,
								display.contentCenterX,
								display.contentHeight - (400 / 1920) * display.actualContentHeight
							)
						end

						displayFormationInGrid(playerFormationData, playerGridGroup, gridSlotsPlayer, function()
							print("Formação do jogador recriada (Fase 3) 500 ms antes do término do roll.")
						end, false)
					end)

					transition.to(background, {
						time = 750,
						y = background.y + 350,
						onComplete = function()
							for i = 1, totalSlots do
								if gridSlotsOpponent[i] and gridSlotsOpponent[i].removeSelf then
									gridSlotsOpponent[i]:removeSelf()
									gridSlotsOpponent[i] = nil
								end
							end

							if localOpponentModule and type(localOpponentModule.fetchFormationData) == "function" then
								local oldFormation = opponentFormationData
								localOpponentModule.fetchFormationData(teamG .. "003", function(newOppFormation, err)
									if err then
										print("Erro ao carregar formação para fase 3:", err)
										return
									end
									if not newOppFormation or countTeam(newOppFormation) == 0 then
										print("Formação da fase 3 retornou vazia!")
										return
									end
									for i = 1, #newOppFormation do
										if oldFormation[i] and newOppFormation[i] then
											newOppFormation[i].hp = oldFormation[i].hp
											newOppFormation[i].originalHP = oldFormation[i].originalHP
												or newOppFormation[i].hp
										end
									end
									-- Reinicializa os dados do oponente para simular um novo jogo
									fullyResetFormation(newOppFormation)

									expectedOpponentsPhase3 = 0
									for i = 1, totalSlots do
										if newOppFormation[i] and type(newOppFormation[i]) == "table" then
											expectedOpponentsPhase3 = expectedOpponentsPhase3 + 1
										end
									end
									opponentsDefeated = 0
									opponentFormationData = newOppFormation

									displayFormationInGrid(
										newOppFormation,
										opponentGridGroup,
										gridSlotsOpponent,
										function()
											actions = buildActions()
											totalActions = #actions
											currentAction = 1
											performAction()
										end,
										true
									)
								end)
							else
								print("Erro: módulo localOpponentModule ou fetchFormationData não encontrado.")
							end
						end,
					})
				end)
				return
			elseif currentPhase == 3 and countTeam(opponentFormationData) == 0 then
				rewardPlayer(playerUserId, silverEarned, expEarned)
				local winScreen = require("journey.winScreen")
				local ws = winScreen.new({
					title = titleWs,
					subtitle = subtitleWs,
					exp = expEarned,
					silver = silverEarned,
					userId = nochicaId,
					returnTo = returnTo,
				})

				return
			else
				actions = buildActions()
				totalActions = #actions
				currentAction = 1
				performAction()
				return
			end
		end

		------------------------------------------------------------------------------
		-- Processamento da ação atual (ataques)
		------------------------------------------------------------------------------
		local action = actions[currentAction]
		if action.side == "player" then
			local pSlot = action.index
			local pData = playerFormationData[pSlot]
			if type(pData) ~= "table" then
				print("Ação " .. currentAction .. " - Jogador, slot " .. pSlot .. ": dados inválidos, pulando.")
				currentAction = currentAction + 1
				timer.performWithDelay(200, performAction)
				return
			end

			if pData.roundsAttacked == nil then
				pData.roundsAttacked = 1
			end
			local currentRound = tonumber(pData.roundsAttacked) or 1
			local cardGroup = gridSlotsPlayer[pSlot]
			local targetSlot = getTargetIndex(pSlot, opponentFormationData)
			if not targetSlot then
				print("Ação " .. currentAction .. " - Jogador, slot " .. pSlot .. ": sem alvo válido.")
				currentAction = currentAction + 1
				timer.performWithDelay(1000, performAction)
				return
			end
			local targetData = opponentFormationData[targetSlot]
			if not targetData then
				print("Ação " .. currentAction .. " - Jogador, slot " .. pSlot .. ": alvo morto, pulando.")
				currentAction = currentAction + 1
				timer.performWithDelay(500, performAction)
				return
			end

			-- Turno de ataque
			manageCardTurn(pData, "attackPerformed")
			local function onAttackComplete()
				manageCardTurn(pData, "attacked")
				pData.roundsAttacked = tonumber(pData.roundsAttacked) + 1

				-- Efeito especial (lógica original sem alteração)
				local newRound = tonumber(pData.roundsAttacked)
				local shouldActivate

				if pData.stars and specialStars[tonumber(pData.stars)] then
					-- carta especial: dispara só nos rounds definidos para efeito especial
					shouldActivate = inTable(effectRoundsSpecial, newRound)
				else
					-- carta normal: dispara só nos rounds definidos para efeito normal
					shouldActivate = inTable(effectRoundsNormal, newRound)
				end

				if shouldActivate and not pData.effectActive then
					specialEffect(pData, cardGroup)
					pData.effectActive = true
					print("[Effect] Activated for " .. (pData.name or "Sem Nome") .. " on new round " .. newRound)
				end

				-- BLEED TICK: aplica bleed após o ataque
				if pData.bleed then
					manageCardTurn(pData, "bleedTick")
				end

				-- Próxima ação
				currentAction = currentAction + 1
				timer.performWithDelay(500, performAction)
			end

			print("Jogador " .. (pData.name or "Sem Nome") .. " - Round: " .. currentRound)
			if pData.attackBlocked then
				print("Ataque bloqueado para " .. (pData.name or "Sem Nome") .. ": consumindo ação sem hook.")
				if pData.effectActive then
					if pData.specialEffectSprite and pData.specialEffectSprite.removeSelf then
						pData.specialEffectSprite:removeSelf()
					end
					pData.specialEffectSprite = nil
					pData.effectActive = false
					print("[Effect] Removed for " .. (pData.name or "Sem Nome"))
				end
				pData.attackBlocked = false
				onAttackComplete()
			else
				local isSpecialAttack = false
				if pData.stars and specialStars[tonumber(pData.stars)] then
					isSpecialAttack = inTable(spRoundsSpecial, currentRound)
				else
					isSpecialAttack = inTable(spRoundsNormal, currentRound)
				end

				if isSpecialAttack then
					local specialHook = getSpecialAttackHook(pData)
					if specialHook and specialHook.attack then
						battleFunctions.getCriticalMultiplierWithEffect(pData, targetData, function(_)
							if pData.effectActive and pData.specialEffectSprite then
								transition.to(pData.specialEffectSprite, {
									alpha = 0,
									time = fadeTime,
									onComplete = function()
										if pData.specialEffectSprite.removeSelf then
											pData.specialEffectSprite:removeSelf()
										end
										pData.specialEffectSprite = nil
										pData.effectActive = false
										specialHook.attack(
											pData,
											targetData,
											battleFunctions,
											targetSlot,
											onAttackComplete
										)
									end,
								})
							else
								specialHook.attack(pData, targetData, battleFunctions, targetSlot, onAttackComplete)
							end
						end, true, targetSlot)
					else
						local attackHook = getAttackHook(pData)
						if attackHook and attackHook.attack then
							battleFunctions.getCriticalMultiplierWithEffect(pData, targetData, function(_)
								attackHook.attack(pData, targetData, battleFunctions, targetSlot, onAttackComplete)
							end, true, targetSlot)
						else
							onAttackComplete()
						end
					end
				else
					local attackHook = getAttackHook(pData)
					if attackHook and attackHook.attack then
						battleFunctions.getCriticalMultiplierWithEffect(pData, targetData, function(_)
							attackHook.attack(pData, targetData, battleFunctions, targetSlot, onAttackComplete)
						end, true, targetSlot)
					else
						onAttackComplete()
					end
				end
			end
		elseif action.side == "opponent" then
			local oSlot = action.index
			local oData = opponentFormationData[oSlot]
			if type(oData) ~= "table" then
				print("Ação " .. currentAction .. " - Oponente, slot " .. oSlot .. ": dados inválidos, pulando.")
				currentAction = currentAction + 1
				timer.performWithDelay(500, performAction)
				return
			end

			if oData.roundsAttacked == nil then
				oData.roundsAttacked = 1
			end
			local currentRound = tonumber(oData.roundsAttacked) or 1
			local cardGroup = gridSlotsOpponent[oSlot]
			local targetSlot = getTargetIndex(oSlot, playerFormationData)
			if not targetSlot then
				print("Ação " .. currentAction .. " - Oponente, slot " .. oSlot .. ": sem alvo válido.")
				currentAction = currentAction + 1
				timer.performWithDelay(1000, performAction)
				return
			end
			local targetData = playerFormationData[targetSlot]
			if not targetData then
				print("Ação " .. currentAction .. " - Oponente, slot " .. oSlot .. ": alvo morto, pulando.")
				currentAction = currentAction + 1
				timer.performWithDelay(500, performAction)
				return
			end

			manageCardTurn(oData, "attackPerformed")
			local function onAttackComplete()
				manageCardTurn(oData, "attacked")
				oData.roundsAttacked = tonumber(oData.roundsAttacked) + 1

				-- Efeito especial (inalterado)
				local newRound = tonumber(oData.roundsAttacked)
				local shouldActivate

				if oData.stars and specialStars[tonumber(oData.stars)] then
					-- carta especial: dispara só nos rounds definidos para efeito especial
					shouldActivate = inTable(effectRoundsSpecial, newRound)
				else
					-- carta normal: dispara só nos rounds definidos para efeito normal
					shouldActivate = inTable(effectRoundsNormal, newRound)
				end

				if shouldActivate and not oData.effectActive then
					specialEffect(oData, cardGroup)
					oData.effectActive = true
					print("[Effect] Activated for " .. (oData.name or "Sem Nome") .. " on new round " .. newRound)
				end

				-- BLEED TICK para oponente
				if oData.bleed then
					manageCardTurn(oData, "bleedTick")
				end

				currentAction = currentAction + 1
				timer.performWithDelay(500, performAction)
			end

			print("Oponente " .. (oData.name or "Sem Nome") .. " - Round: " .. currentRound)
			if oData.attackBlocked then
				print("Ataque bloqueado para " .. (oData.name or "Sem Nome") .. ": consumindo ação sem hook.")
				if oData.effectActive then
					if oData.specialEffectSprite and oData.specialEffectSprite.removeSelf then
						oData.specialEffectSprite:removeSelf()
					end
					oData.specialEffectSprite = nil
					oData.effectActive = false
					print("[Effect] Removed for " .. (oData.name or "Sem Nome"))
				end
				oData.attackBlocked = false
				onAttackComplete()
			else
				local isSpecialAttack = false
				if oData.stars and specialStars[tonumber(oData.stars)] then
					isSpecialAttack = inTable(spRoundsSpecial, currentRound)
				else
					isSpecialAttack = inTable(spRoundsNormal, currentRound)
				end

				if isSpecialAttack then
					local specialHook = getSpecialAttackHook(oData)
					if specialHook and specialHook.attack then
						battleFunctions.getCriticalMultiplierWithEffect(oData, targetData, function(_)
							if oData.effectActive and oData.specialEffectSprite then
								transition.to(oData.specialEffectSprite, {
									alpha = 0,
									time = fadeTime,
									onComplete = function()
										if oData.specialEffectSprite.removeSelf then
											oData.specialEffectSprite:removeSelf()
										end
										oData.specialEffectSprite = nil
										oData.effectActive = false
										specialHook.attack(
											oData,
											targetData,
											battleFunctions,
											targetSlot,
											onAttackComplete
										)
									end,
								})
							else
								specialHook.attack(oData, targetData, battleFunctions, targetSlot, onAttackComplete)
							end
						end, true, targetSlot)
					else
						local attackHook = getAttackHook(oData)
						if attackHook and attackHook.attack then
							battleFunctions.getCriticalMultiplierWithEffect(oData, targetData, function(_)
								attackHook.attack(oData, targetData, battleFunctions, targetSlot, onAttackComplete)
							end, true, targetSlot)
						else
							onAttackComplete()
						end
					end
				else
					local attackHook = getAttackHook(oData)
					if attackHook and attackHook.attack then
						battleFunctions.getCriticalMultiplierWithEffect(oData, targetData, function(_)
							attackHook.attack(oData, targetData, battleFunctions, targetSlot, onAttackComplete)
						end, true, targetSlot)
					else
						onAttackComplete()
					end
				end
			end
		end
	end

	performAction()
end

--------------------------------------------------
-- Variáveis auxiliares para controle de turnos
local playerActionCount = 0
local currentPhase = 1

--------------------------------------------------
-- FUNÇÃO: simulatePreTurnActions
-- Executa uma ação básica (no-op) para cada carta, permitindo a
-- inicialização completa das cartas e de seus efeitos.
-- Não altera a contagem de ataques (roundsAttacked).
--------------------------------------------------
local function simulatePreTurnActions(callback)
	local preActions = {}

	-- Adiciona uma entrada para cada carta válida
	local function addPreAction(side, index, cardData, cardGroup)
		table.insert(preActions, {
			side = side,
			index = index,
			cardData = cardData,
			cardGroup = cardGroup,
		})
	end

	for i = 1, totalSlots do
		if playerFormationData[i] and type(playerFormationData[i]) == "table" then
			addPreAction("player", i, playerFormationData[i], gridSlotsPlayer[i])
		end
		if opponentFormationData[i] and type(opponentFormationData[i]) == "table" then
			addPreAction("opponent", i, opponentFormationData[i], gridSlotsOpponent[i])
		end
	end

	local totalPreActions = #preActions
	local currentPreAction = 1

	local function processNextPreAction()
		if currentPreAction > totalPreActions then
			if callback then
				callback()
			end
			return
		end

		local action = preActions[currentPreAction]
		print("Pre-turn action executed for " .. (action.cardData.name or "Sem Nome") .. " (" .. action.side .. ")")
		-- Simula uma ação no-op com um delay para dar tempo à inicialização
		timer.performWithDelay(300, function()
			currentPreAction = currentPreAction + 1
			processNextPreAction()
		end)
	end

	if totalPreActions > 0 then
		processNextPreAction()
	else
		if callback then
			callback()
		end
	end
end

--------------------------------------------------------------------------------
-- Calcula o centro de uma formação com base nos grupos de cada slot
--------------------------------------------------------------------------------
local function computeFormationCenter(gridSlots)
	local sumX, sumY, count = 0, 0, 0

	-- percorre todos os slots não-nil, sem parar em buracos
	for _, cardGroup in pairs(gridSlots) do
		if cardGroup and cardGroup.parent and cardGroup.x and cardGroup.y then
			-- converte para coordenadas globais
			local gx, gy = cardGroup.parent:localToContent(cardGroup.x, cardGroup.y)
			sumX = sumX + gx
			sumY = sumY + gy
			count = count + 1
		end
	end

	if count > 0 then
		return {
			x = sumX / count,
			y = sumY / count,
		}
	else
		-- fallback: centro da tela
		return {
			x = display.contentCenterX,
			y = display.contentCenterY,
		}
	end
end
--------------------------------------------------------------------------------
-- Define os centros das formações de jogador e oponente
--------------------------------------------------------------------------------
local function defineFormationCenters()
	_G.opponentFormationCenter = computeFormationCenter(gridSlotsOpponent)
	print(
		string.format(
			"Centro da formação do oponente: (%.1f, %.1f)",
			_G.opponentFormationCenter.x,
			_G.opponentFormationCenter.y
		)
	)

	_G.playerFormationCenter = computeFormationCenter(gridSlotsPlayer)
	print(
		string.format(
			"Centro da formação do jogador: (%.1f, %.1f)",
			_G.playerFormationCenter.x,
			_G.playerFormationCenter.y
		)
	)
end

--------------------------------------------------------------------------------
-- Aguarda grids prontos e só então define os centros e inicia a batalha
--------------------------------------------------------------------------------
local battleStarted = false
local function checkAndStartTurn()
	if playerGridReady and opponentGridReady and not battleStarted then
		defineFormationCenters()
		battleStarted = true
		-- dá um tempo para as animações de entrada terminarem
		timer.performWithDelay(1500, simulateTurnActions)
	end
end
--------------------------------------------------
-- FUNÇÃO: scene:create
--------------------------------------------------

local backgroundMusic = audio.loadStream("assets/sound/music/bgm_battlea.mp3")
local backgroundMusicChannel

function scene:create(event)
	local sceneGroup = self.view

	local params = event.params or {}
	local moduleName = params.op or "modules.opponents.localOpponent1"
	local team = tostring(params.form) or "opponent_"
	teamG = tostring(team)
	localOpponentModule = require(moduleName)
	opponentUserId = localOpponentModule.userId
	silverEarned = params.silver
	expEarned = params.exp
	titleWs = params.title
	subtitleWs = params.subtitle
	nochicaId = params.userId
	returnTo = params.returnTo

	-- Define o background
	local bgImagePath = "assets/7bg/campaign/" .. params.bg .. ".jpg"
	local bgWidth = 1068
	local bgHeight = 2548
	self:setBackgroundImage(bgImagePath, bgWidth, bgHeight)

	--------------------------------------------------
	-- Cria o grid para o oponente (parte superior)
	--------------------------------------------------
	local opponentGridX = display.contentCenterX
	local opponentGridY = (70 / 1920) * display.actualContentHeight -- padrão
	local opponentGridGroup = createCardGrid(sceneGroup, opponentGridX, opponentGridY)
	_G.opponentGridGroup = opponentGridGroup

	--------------------------------------------------
	-- Cria o grid para o jogador (parte inferior)
	--------------------------------------------------
	local playerGridX = display.contentCenterX
	local playerGridY = display.contentHeight - (200 / 1920) * display.actualContentHeight
	local playerGridGroup = createCardGrid(sceneGroup, playerGridX, playerGridY)
	_G.playerGridGroup = playerGridGroup

	--------------------------------------------------
	-- Hooks para acesso aos grids e formações
	--------------------------------------------------
	battleFunctions = {}
	battleFunctions.getEnemyGroup = function(attacker)
		return attacker.isOpponent and playerGridGroup or opponentGridGroup
	end
	battleFunctions.getOpponents = function(attacker)
		return attacker.isOpponent and playerFormationData or opponentFormationData
	end

	playerGridReady = false
	opponentGridReady = false

	--------------------------------------------------
	-- Carrega a formação do oponente (fase 1)
	--------------------------------------------------
	localOpponentModule.fetchFormationData(opponentUserId, function(opponentFormation, err)
		if err then
			local errTxt = display.newText({
				text = "Erro ao carregar formação do oponente",
				x = display.contentCenterX,
				y = 200,
				font = native.systemFontBold,
				fontSize = 20,
			})
			sceneGroup:insert(errTxt)
			return
		end

		opponentFormationData = opponentFormation
		_G.opponentFormationData = opponentFormationData

		displayFormationInGrid(opponentFormationData, opponentGridGroup, gridSlotsOpponent, function()
			opponentGridReady = true
			print("Grid do oponente pronto.")
			if playerGridReady then
				defineFormationCenters()
				timer.performWithDelay(1500, simulateTurnActions)
			end
		end, true)
	end)

	--------------------------------------------------
	-- Carrega a formação do jogador
	--------------------------------------------------
	formationHook.fetchFormationData(playerUserId, function(data, err)
		if err then
			local errTxt = display.newText({
				text = "Erro ao carregar formação do jogador",
				x = display.contentCenterX,
				y = display.contentCenterY,
				font = native.systemFontBold,
				fontSize = 20,
			})
			sceneGroup:insert(errTxt)
			return
		end

		playerFormationData = data
		_G.playerFormationData = playerFormationData

		displayFormationInGrid(playerFormationData, playerGridGroup, gridSlotsPlayer, function()
			playerGridReady = true
			print("Grid do jogador pronto.")
			if opponentGridReady then
				defineFormationCenters()
				timer.performWithDelay(1500, simulateTurnActions)
			end
		end, false)
	end)
end

--------------------------------------------------
-- FUNÇÃO: scene:show
--------------------------------------------------
function scene:show(event)
	if event.phase == "did" then
		-- Reproduz a música em loop (número de loops = -1 para infinito)
		backgroundMusicChannel = audio.play(backgroundMusic, {
			channel = 1,
			loops = -1,
			fadein = 500,
		})
	end
end
--------------------------------------------------
-- FUNÇÃO: scene:hide
--------------------------------------------------
function scene:hide(event)
	if event.phase == "will" then
		if backgroundMusicChannel then
			audio.stop(backgroundMusicChannel)
		end
	end
end

--------------------------------------------------
-- FUNÇÃO: scene:destroy
--------------------------------------------------
function scene:destroy(event)
	if backgroundMusic then
		audio.dispose(backgroundMusic)
		backgroundMusic = nil
	end
end

--------------------------------------------------
-- ADICIONANDO LISTENERS DE EVENTOS À CENA
--------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)

return scene
