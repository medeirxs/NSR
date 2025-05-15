-- interfaces/growing/raise.lua
local composer = require("composer")
local Card = require("components.card")
local userDataLib = require("lib.userData")
local supa = require("config.supabase")
local json = require("json")
local network = require("network")
local widget = require("widget")
local textile = require("utils.textile")
local navbar = require("components.navBar")

local scene = composer.newScene()

-- máximo de stars permitidos
local MAX_STARS = 11

-- requisitos de items para evoluir cada star
local starRequirements = {
	[2] = {
		"fa6a4997-cc7e-4a9e-a977-f08ea4f7ae82",
		"4a66104b-d370-4582-a583-39750e223e6f",
		"02ea015b-e52c-4a60-89d6-b081048135c1",
	},
	[3] = {
		"f76b1b27-6eda-4e0f-b8f5-889d4444a892",
		"c9938580-3ad2-42c4-b526-3e92f9362367",
		"7b5c85fe-c11d-4e6d-8765-94dc39850e85",
	},
	[4] = {
		"2b70ab29-4c4d-4efa-9903-2207fb16a82c",
		"8bf99e1b-c655-47e4-8b3f-5ef778c995b7",
		"17603f91-cabc-4d09-8430-1b189066e8a6",
		"3c2b103f-2b41-4347-8ea2-cf79aeef220b",
		"88554fbd-ea57-4909-9c67-b370c6d7fb89",
	},
	[7] = { "83749125-dd27-4c01-93e2-49ae2b5de364" },
}

-- nível mínimo para evoluir cada star
local starLevelCap = {
	[2] = 20,
	[3] = 30,
	[4] = 40,
	[5] = 60,
	[6] = 70,
	[7] = 80,
	[8] = 100,
	[9] = 110,
	[10] = 120,
}

function scene:create(event)
	local sceneGroup = self.view
	local sceneGroup = self.view
	local data = userDataLib.load() or {}
	local userId = tonumber(data.id) or 0
	self.userId = userId

	local background = display.newImageRect(
		sceneGroup,
		"assets/7bg/bg_tab_default.jpg",
		display.contentWidth,
		display.contentHeight * 1.44
	)
	background.x, background.y = display.contentCenterX, display.contentCenterY

	local riseGroup = display.newGroup()
	sceneGroup:insert(riseGroup)

	local characterModalL = display.newImageRect(riseGroup, "assets/7bg/dtModalInside.png", 275, 400)
	characterModalL.x, characterModalL.y = 153, display.contentCenterY - 200
	local characterModalR = display.newImageRect(riseGroup, "assets/7bg/dtModalInside.png", 275, 400)
	characterModalR.x, characterModalR.y = characterModalL.x + 335, characterModalL.y
	local itemsModal = display.newImageRect(riseGroup, "assets/7bg/riseModal.png", 500 * 1.21, 250 * 1.21)
	itemsModal.x, itemsModal.y = display.contentCenterX, display.contentCenterY + 160

	local arrow1 = display.newImageRect(riseGroup, "assets/7button/btn_arrow_3.png", 66 / 1.1, 90 / 1.1)
	arrow1.x, arrow1.y = display.contentCenterX, characterModalR.y - 100
	local arrow2 = display.newImageRect(riseGroup, "assets/7button/btn_arrow_3.png", 66 / 1.1, 90 / 1.1)
	arrow2.x, arrow2.y = display.contentCenterX, characterModalR.y + 100

	local emptyCardL = display.newImageRect(riseGroup, "assets/7card/card_holder_m.png", 400 / 1.6, 460 / 1.6)
	emptyCardL.x, emptyCardL.y = characterModalL.x, characterModalL.y - 45
	emptyCardL:addEventListener("tap", function()
		composer.gotoScene("interfaces.growing.raiseSelect", {
			effect = "slideLeft",
			time = 300,
			params = {
				userId = self.userId,
			},
		})
	end)

	local emptyCardR = display.newImageRect(riseGroup, "assets/7card/card_holder_m.png", 400 / 1.6, 460 / 1.6)
	emptyCardR.x, emptyCardR.y = characterModalR.x, characterModalR.y - 45

	local levelBgBefore = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
	levelBgBefore.x, levelBgBefore.y = emptyCardL.x, display.contentCenterY - 85
	local healthBgBefore = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
	healthBgBefore.x, healthBgBefore.y = emptyCardL.x, display.contentCenterY - 55
	local attackBgBefore = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
	attackBgBefore.x, attackBgBefore.y = emptyCardL.x, display.contentCenterY - 25

	local levelBgAfter = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
	levelBgAfter.x, levelBgAfter.y = emptyCardR.x, display.contentCenterY - 85
	local healthBgAfter = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
	healthBgAfter.x, healthBgAfter.y = emptyCardR.x, display.contentCenterY - 55
	local attackBgAfter = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
	attackBgAfter.x, attackBgAfter.y = emptyCardR.x, display.contentCenterY - 25

	local levelIconL = display.newImageRect(riseGroup, "assets/7icon/icon_level.png", 48 / 1.2, 48 / 1.2)
	levelIconL.x, levelIconL.y = levelBgBefore.x - 90, levelBgBefore.y - 5
	local levelIconL = display.newImageRect(riseGroup, "assets/7icon/icon_level.png", 48 / 1.2, 48 / 1.2)
	levelIconL.x, levelIconL.y = levelBgAfter.x - 90, levelBgAfter.y - 5
	local healthIcon = display.newImageRect(riseGroup, "assets/7icon/icon_hp.png", 48 / 1.2, 48 / 1.2)
	healthIcon.x, healthIcon.y = levelBgBefore.x - 90, levelBgBefore.y + 25
	local healthIcon = display.newImageRect(riseGroup, "assets/7icon/icon_hp.png", 48 / 1.2, 48 / 1.2)
	healthIcon.x, healthIcon.y = levelBgAfter.x - 90, levelBgBefore.y + 25
	local attackIcon = display.newImageRect(riseGroup, "assets/7icon/icon_atk.png", 48 / 1.2, 48 / 1.2)
	attackIcon.x, attackIcon.y = levelBgBefore.x - 90, levelBgBefore.y + 55
	local attackIcon = display.newImageRect(riseGroup, "assets/7icon/icon_atk.png", 48 / 1.2, 48 / 1.2)
	attackIcon.x, attackIcon.y = levelBgAfter.x - 90, levelBgAfter.y + 55

	local itemEvolveEmpty1 = display.newImageRect(riseGroup, "assets/7card/card_holder_s_1.png", 125, 125)
	itemEvolveEmpty1.x, itemEvolveEmpty1.y = 82, display.contentCenterY + 75
	local itemEvolveEmpty1 = display.newImageRect(riseGroup, "assets/7card/card_holder_s_1.png", 125, 125)
	itemEvolveEmpty1.x, itemEvolveEmpty1.y = 82 + 115 + 5, display.contentCenterY + 75
	local itemEvolveEmpty1 = display.newImageRect(riseGroup, "assets/7card/card_holder_s_1.png", 125, 125)
	itemEvolveEmpty1.x, itemEvolveEmpty1.y = 82 + 230 + 10, display.contentCenterY + 75
	local itemEvolveEmpty1 = display.newImageRect(riseGroup, "assets/7card/card_holder_s_1.png", 125, 125)
	itemEvolveEmpty1.x, itemEvolveEmpty1.y = 82 + 345 + 13, display.contentCenterY + 75
	local itemEvolveEmpty1 = display.newImageRect(riseGroup, "assets/7card/card_holder_s_1.png", 125, 125)
	itemEvolveEmpty1.x, itemEvolveEmpty1.y = 82 + 460 + 15, display.contentCenterY + 75

	local bgSilver = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_11.png", 380 * 1.5, 50 * 1.8)
	bgSilver.x, bgSilver.y = display.contentCenterX, display.contentCenterY + 190

	local topBack = require("components.backTop")
	local topBack = topBack.new({
		title = "",
	})
	riseGroup:insert(topBack)
	local navbar = require("components.navBar")
	local navbar = navbar.new()
	riseGroup:insert(navbar)

	local tabEquipmentBg = display.newImageRect(sceneGroup, "assets/7button/btn_tab_light_s9.png", 236, 82)
	tabEquipmentBg.x, tabEquipmentBg.y = 330, -128
	local changeMemberText = textile.new({
		group = sceneGroup,
		texto = " Elevar Ordem ",
		x = tabEquipmentBg.x,
		y = tabEquipmentBg.y + 5,
		tamanho = 22,
		corTexto = { 1 }, -- Amarelo {0.95, 0.86, 0.31}
		corContorno = { 0, 0, 0 },
		espessuraContorno = 2,
	})

	local tabFormationBg = display.newImageRect(sceneGroup, "assets/7button/btn_tab_s9.png", 236, 82)
	tabFormationBg.x, tabFormationBg.y = 110, -128
	local changeMemberText = textile.new({
		group = sceneGroup,
		texto = " Elevar ",
		x = tabFormationBg.x,
		y = tabFormationBg.y + 5,
		tamanho = 22,
		corTexto = { 0.6, 0.6, 0.6 }, -- Amarelo {0.95, 0.86, 0.31}
		corContorno = { 0, 0, 0 },
		espessuraContorno = 2,
	})

	local select = textile.new({
		texto = "Selec.\numa\ncarta.",
		x = emptyCardL.x,
		y = emptyCardL.y,
		tamanho = 28,
		corTexto = { 1, 1, 1 }, -- Amarelo {0.95, 0.86, 0.31}
		corContorno = { 0, 0, 0, 0.2 },
		espessuraContorno = 2,
	})
	riseGroup:insert(select)

	-- groups for card and stars
	self.cardGroup = display.newGroup()
	sceneGroup:insert(self.cardGroup)
	self.starsGroup = display.newGroup()
	sceneGroup:insert(self.starsGroup)
end

function scene:show(event)
	if event.phase ~= "did" then
		return
	end

	local recordId = _G.chaId
	if not recordId then
		return
	end

	-- clear previous
	self.cardGroup:removeSelf()
	self.cardGroup = display.newGroup()
	self.view:insert(self.cardGroup)
	self.starsGroup:removeSelf()
	self.starsGroup = display.newGroup()
	self.view:insert(self.starsGroup)

	local headers = {
		["Content-Type"] = "application/json",
		["apikey"] = supa.SUPABASE_ANON_KEY,
		["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY,
	}

	-- fetch characterId and stars
	local url = string.format(
		"%s/rest/v1/user_characters?select=characterId,stars,level,health,attack&limit=1&id=eq.%s",
		supa.SUPABASE_URL,
		recordId
	)
	network.request(url, "GET", function(evt)
		if evt.isError then
			print("Erro ao buscar character:", evt.response)
			return
		end
		local d = json.decode(evt.response)[1]
		if not d then
			return
		end

		-- show card
		local actualCard = Card.new({
			x = 153,
			y = 255,
			characterId = d.characterId,
			scaleFactor = 0.95,
			stars = d.stars,
		})
		self.cardGroup:insert(actualCard)

		local function getMaxLevel(stars)
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
			end
			return nil
		end

		local function getNextMaxLevel(stars)
			if stars == 2 then
				return 30
			elseif stars == 3 then
				return 40
			elseif stars == 4 then
				return 60
			elseif stars == 5 then
				return 70
			elseif stars == 6 then
				return 80
			elseif stars == 7 then
				return 100
			elseif stars == 8 then
				return 110
			elseif stars == 9 then
				return 120
			elseif stars == 10 then
				return 130
			elseif stars == 11 then
				return 150
			end
			return nil
		end

		local maxLevel = getMaxLevel(d.stars)
		local upMaxLevel = getNextMaxLevel(d.stars)

		local levelText = textile.new({
			texto = d.level .. "/" .. maxLevel .. " ",
			x = display.contentCenterX - 65,
			y = display.contentCenterY - 107,
			tamanho = 20,
			corTexto = { 1, 1, 1 }, -- Amarelo {0.95, 0.86, 0.31}
			corContorno = { 0, 0, 0 },
			espessuraContorno = 2,
			anchorX = 100,
			anchorY = 0,
		})

		local healthText = textile.new({
			texto = d.health .. " ",
			x = levelText.x,
			y = display.contentCenterY - 77,
			tamanho = 20,
			corTexto = { 1, 1, 1 }, -- Amarelo {0.95, 0.86, 0.31}
			corContorno = { 0, 0, 0 },
			espessuraContorno = 2,
			anchorX = 100,
			anchorY = 0,
		})

		local attackText = textile.new({
			texto = d.attack .. " ",
			x = levelText.x,
			y = display.contentCenterY - 47,
			tamanho = 20,
			corTexto = { 1, 1, 1 }, -- Amarelo {0.95, 0.86, 0.31}
			corContorno = { 0, 0, 0 },
			espessuraContorno = 2,
			anchorX = 100,
			anchorY = 0,
		})

		local cardPreview = Card.new({
			x = actualCard.x + 335,
			y = 255,
			characterId = d.characterId,
			scaleFactor = 0.95,
			stars = d.stars + 1,
		})
		self.cardGroup:insert(cardPreview)

		local levelText2 = textile.new({
			texto = maxLevel .. "/" .. upMaxLevel .. " ",
			x = display.contentCenterX + 270,
			y = display.contentCenterY - 107,
			tamanho = 20,
			corTexto = { 1, 1, 1 }, -- Amarelo {0.95, 0.86, 0.31}
			corContorno = { 0, 0, 0 },
			espessuraContorno = 2,
			anchorX = 100,
			anchorY = 0,
		})

		-- Health
		local healthValue = math.floor(d.health * 1.1)
		local healthText2 = textile.new({
			texto = healthValue .. " ",
			x = levelText2.x,
			y = display.contentCenterY - 77,
			tamanho = 20,
			corTexto = { 1, 1, 1 }, -- Amarelo {0.95, 0.86, 0.31}
			corContorno = { 0, 0, 0 },
			espessuraContorno = 2,
			anchorX = 100,
			anchorY = 0,
		})

		-- Attack
		local attackValue = math.floor(d.attack * 1.1)
		local attackText2 = textile.new({
			texto = attackValue .. " ",
			x = levelText2.x,
			y = display.contentCenterY - 47,
			tamanho = 20,
			corTexto = { 1, 1, 1 }, -- Amarelo {0.95, 0.86, 0.31}
			corContorno = { 0, 0, 0 },
			espessuraContorno = 2,
			anchorX = 100,
			anchorY = 0,
		})

		local advanceButton =
			display.newImageRect(self.starsGroup, "assets/7button/btn_common_yellow_s9_l.png", 280 * 1.6, 40 * 1.6)
		advanceButton.x, advanceButton.y = display.contentCenterX, display.contentCenterY + 272

		local text = textile.new({
			texto = " Elevar Ordem ",
			x = advanceButton.x,
			y = advanceButton.y,
			tamanho = 24,
			corTexto = { 1, 1, 1 }, -- Amarelo {0.95, 0.86, 0.31}
			corContorno = { 0, 0, 0 },
			espessuraContorno = 2,
		})
		self.starsGroup:insert(text)

		-- raise handler
		local function onRaiseTap()
			transition.to(actualCard, {
				time = 300,
				alpha = 0,
			})
			transition.to(levelText, {
				time = 300,
				alpha = 0,
				onComplete = function()
					levelText.text = "0/" .. maxLevel
					levelText.alpha = 1
				end,
			})
			transition.to(healthText, {
				time = 300,
				alpha = 0,
				onComplete = function()
					healthText.text = "0"
					healthText.alpha = 1
				end,
			})
			transition.to(attackText, {
				time = 300,
				alpha = 0,
				onComplete = function()
					attackText.text = "0"
					attackText.alpha = 1
				end,
			})

			if not _G.chaId then
				native.showAlert("Aviso", "Selecione um personagem primeiro", { "OK" })
				return
			end

			-- fetch current full character record
			local fetchUrl = string.format(
				"%s/rest/v1/user_characters?select=characterId,stars,level,health,attack&limit=1&id=eq.%s",
				supa.SUPABASE_URL,
				recordId
			)
			network.request(fetchUrl, "GET", function(evt2)
				if evt2.isError then
					native.showAlert("Erro", "Não foi possível ler personagem", { "OK" })
					return
				end
				local d2 = json.decode(evt2.response)[1]
				if not d2 then
					native.showAlert("Erro", "Personagem não encontrado", { "OK" })
					return
				end

				local currentStars = d2.stars
				local currentLevel = d2.level
				local charUuid = d2.characterId

				-- level cap check
				local requiredLevel = starLevelCap[currentStars]
				if requiredLevel and currentLevel < requiredLevel then
					native.showAlert(
						"Aviso",
						("Para evoluir de %d→%d stars, precisa nível %d"):format(
							currentStars,
							currentStars + 1,
							requiredLevel
						),
						{ "OK" }
					)
					return
				end

				-- generic stars 2→3,3→4,4→5,5→6,6→7,7→8 via items
				if currentStars >= 2 and currentStars < 8 then
					local req = starRequirements[currentStars] or {}
					local invUrl = string.format(
						"%s/rest/v1/user_items?userId=eq.%s&select=itemId,quantity,id",
						supa.SUPABASE_URL,
						self.userId
					)
					network.request(invUrl, "GET", function(fe)
						if fe.isError then
							native.showAlert("Erro", "Não foi possível ler inventário", { "OK" })
							return
						end
						local items = json.decode(fe.response) or {}
						local map = {}
						for _, r in ipairs(items) do
							map[r.itemId] = r
						end

						-- verify
						for _, need in ipairs(req) do
							if not map[need] or map[need].quantity < 1 then
								native.showAlert("Aviso", "Faltam itens para evoluir stars", { "OK" })
								return
							end
						end

						-- consume
						local pending = #req
						for _, need in ipairs(req) do
							local rec = map[need]
							network.request(
								("%s/rest/v1/user_items?id=eq.%s"):format(supa.SUPABASE_URL, rec.id),
								"PATCH",
								function(pe)
									pending = pending - 1
									if pending == 0 then
										-- all items consumed → PATCH stars +10% buffs
										local newStars = currentStars + 1
										local newHealth = math.floor(d2.health * 1.10)
										local newAttack = math.floor(d2.attack * 1.10)
										network.request(
											("%s/rest/v1/user_characters?id=eq.%s"):format(supa.SUPABASE_URL, recordId),
											"PATCH",
											function(pc)
												if pc.isError then
													native.showAlert("Erro", "Falha ao evoluir stars", { "OK" })
													return
												end
												transition.to(actualCard, {
													time = 300,
													alpha = 0,
												})
												transition.to(levelText, {
													time = 300,
													alpha = 0,
													onComplete = function()
														levelText.text = "0/" .. maxLevel
														levelText.alpha = 1
													end,
												})
												transition.to(healthText, {
													time = 300,
													alpha = 0,
													onComplete = function()
														healthText.text = "0"
														healthText.alpha = 1
													end,
												})
												transition.to(attackText, {
													time = 300,
													alpha = 0,
													onComplete = function()
														attackText.text = "0"
														attackText.alpha = 1
													end,
												})
											end,
											{
												headers = headers,
												body = json.encode({
													stars = newStars,
													health = newHealth,
													attack = newAttack,
												}),
											}
										)
									end
								end,
								{
									headers = headers,
									body = json.encode({ quantity = rec.quantity - 1 }),
								}
							)
						end
					end, { headers = headers })

				-- stars 8→9 consume 1 char stars=8
				elseif currentStars == 8 then
					local fetchChars = string.format(
						"%s/rest/v1/user_characters?select=id,health,attack&characterId=eq.%s&stars=eq.8&id=neq.%s",
						supa.SUPABASE_URL,
						charUuid,
						recordId
					)
					network.request(fetchChars, "GET", function(fe)
						local recs = json.decode(fe.response) or {}
						if #recs < 1 then
							native.showAlert("Aviso", "Precisa de 1 personagem Stars 8", { "OK" })
							return
						end
						local other = recs[1]
						-- delete consumed char
						network.request(
							("%s/rest/v1/user_characters?id=eq.%s"):format(supa.SUPABASE_URL, other.id),
							"DELETE",
							function(pd)
								if pd.isError then
									native.showAlert("Erro", "Falha ao consumir personagem", { "OK" })
									return
								end
								-- now evolve
								local newStars = 9
								local newHealth = math.floor(d2.health * 1.10)
								local newAttack = math.floor(d2.attack * 1.10)
								network.request(
									("%s/rest/v1/user_characters?id=eq.%s"):format(supa.SUPABASE_URL, recordId),
									"PATCH",
									function(pc)
										transition.to(actualCard, {
											time = 300,
											alpha = 0,
										})
										transition.to(levelText, {
											time = 300,
											alpha = 0,
											onComplete = function()
												levelText.text = "0/" .. maxLevel
												levelText.alpha = 1
											end,
										})
										transition.to(healthText, {
											time = 300,
											alpha = 0,
											onComplete = function()
												healthText.text = "0"
												healthText.alpha = 1
											end,
										})
										transition.to(attackText, {
											time = 300,
											alpha = 0,
											onComplete = function()
												attackText.text = "0"
												attackText.alpha = 1
											end,
										})
									end,
									{
										headers = headers,
										body = json.encode({
											stars = newStars,
											health = newHealth,
											attack = newAttack,
										}),
									}
								)
							end,
							{ headers = headers }
						)
					end, { headers = headers })

				-- stars 9→10 consume 2 chars stars=8
				elseif currentStars == 9 then
					local fetchChars = string.format(
						"%s/rest/v1/user_characters?select=id,health,attack&characterId=eq.%s&stars=eq.8&id=neq.%s",
						supa.SUPABASE_URL,
						charUuid,
						recordId
					)
					network.request(fetchChars, "GET", function(fe)
						local recs = json.decode(fe.response) or {}
						if #recs < 2 then
							native.showAlert("Aviso", "Precisa de 2 personagens Stars 8", { "OK" })
							return
						end
						local toDel = { recs[1], recs[2] }
						local done = 0
						for _, other in ipairs(toDel) do
							network.request(
								("%s/rest/v1/user_characters?id=eq.%s"):format(supa.SUPABASE_URL, other.id),
								"DELETE",
								function(pd)
									done = done + 1
									if done == 2 then
										local newStars = 10
										local newHealth = math.floor(d2.health * 1.10)
										local newAttack = math.floor(d2.attack * 1.10)
										network.request(
											("%s/rest/v1/user_characters?id=eq.%s"):format(supa.SUPABASE_URL, recordId),
											"PATCH",
											function(pc)
												transition.to(actualCard, {
													time = 300,
													alpha = 0,
												})
												transition.to(levelText, {
													time = 300,
													alpha = 0,
													onComplete = function()
														levelText.text = "0/" .. maxLevel
														levelText.alpha = 1
													end,
												})
												transition.to(healthText, {
													time = 300,
													alpha = 0,
													onComplete = function()
														healthText.text = "0"
														healthText.alpha = 1
													end,
												})
												transition.to(attackText, {
													time = 300,
													alpha = 0,
													onComplete = function()
														attackText.text = "0"
														attackText.alpha = 1
													end,
												})
											end,
											{
												headers = headers,
												body = json.encode({
													stars = newStars,
													health = newHealth,
													attack = newAttack,
												}),
											}
										)
									end
								end,
								{ headers = headers }
							)
						end
					end, { headers = headers })

				-- stars 10→11 consume 1 char stars=9
				elseif currentStars == 10 then
					local fetchChars = string.format(
						"%s/rest/v1/user_characters?select=id,health,attack&characterId=eq.%s&stars=eq.9&id=neq.%s",
						supa.SUPABASE_URL,
						charUuid,
						recordId
					)
					network.request(fetchChars, "GET", function(fe)
						local recs = json.decode(fe.response) or {}
						if #recs < 1 then
							native.showAlert("Aviso", "Precisa de 1 personagem Stars 9", { "OK" })
							return
						end
						local other = recs[1]
						network.request(
							("%s/rest/v1/user_characters?id=eq.%s"):format(supa.SUPABASE_URL, other.id),
							"DELETE",
							function(pd)
								if pd.isError then
									native.showAlert("Erro", "Falha ao consumir personagem", { "OK" })
									return
								end
								local newStars = 11
								local newHealth = math.floor(d2.health * 1.10)
								local newAttack = math.floor(d2.attack * 1.10)
								network.request(
									("%s/rest/v1/user_characters?id=eq.%s"):format(supa.SUPABASE_URL, recordId),
									"PATCH",
									function(pc)
										transition.to(actualCard, {
											time = 300,
											alpha = 0,
										})
										transition.to(levelText, {
											time = 300,
											alpha = 0,
											onComplete = function()
												levelText.text = "0/" .. maxLevel
												levelText.alpha = 1
											end,
										})
										transition.to(healthText, {
											time = 300,
											alpha = 0,
											onComplete = function()
												healthText.text = "0"
												healthText.alpha = 1
											end,
										})
										transition.to(attackText, {
											time = 300,
											alpha = 0,
											onComplete = function()
												attackText.text = "0"
												attackText.alpha = 1
											end,
										})
									end,
									{
										headers = headers,
										body = json.encode({
											stars = newStars,
											health = newHealth,
											attack = newAttack,
										}),
									}
								)
							end,
							{ headers = headers }
						)
					end, { headers = headers })
				else
					native.showAlert("Aviso", "Evolução de Stars " .. currentStars .. " não implementada", { "OK" })
				end
			end, { headers = headers })
		end

		advanceButton:addEventListener("tap", onRaiseTap)
	end, { headers = headers })
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
