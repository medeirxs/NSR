local composer = require("composer")
local widget = require("widget")
local navBar = require("components.navBar")
local json = require("json")
local network = require("network")
local supabase = require("config.supabase")
local userDataLib = require("lib.userData")
local getUserDataAPI = require("api.getUserData")

local activitiesButton = {}
function activitiesButton.new(params)
	-- Cria um grupo para agrupar os elementos do componente
	local group = display.newGroup()

	-- Valores padrão para os parâmetros (caso não sejam informados)
	local x = params.x
	local y = params.y
	local item1 = params.item1

	local label1 = params.label1 or ""
	local label2 = params.label2 or ""

	local total = params.total or "0"
	local remaing = params.remaing or "0"

	local activitieCost = params.activitieCost or "1"

	-- Cria a imagem do componente
	local bg = display.newImageRect(group, "assets/7bg/bg_cell_brown.png", 620, 132 * 1.3)
	bg.x = x + 60
	bg.y = y + 45

	local image = display.newImageRect(group, item1, 104 * 1.1, 104 * 1.1)
	image.x = x - 175
	image.y = y + 30

	local bg = display.newImageRect(group, "assets/7bg/bg_cell_lock_border.png", 584 / 1.27, 136 / 1.5)
	bg.x = x + 117
	bg.y = y + 20
	bg.alpha = 0.5

	local label = display.newText({
		parent = group,
		text = label1,
		x = 160,
		y = y, -- Ajuste a distância conforme necessário
		font = "assets/7fonts/Textile.ttf",
		fontSize = 22,
	})
	label.anchorX = 0
	label:setFillColor(0.4333, 0.1686, 0.0235)
	local label2 = display.newText({
		parent = group,
		text = label2,
		x = 160,
		y = y + 25, -- Ajuste a distância conforme necessário
		font = "assets/7fonts/Textile.ttf",
		fontSize = 22,
	})
	label2.anchorX = 0
	label2:setFillColor(0.4333, 0.1686, 0.0235)

	local label2 = display.newText({
		parent = group,
		text = total .. "/" .. remaing,
		x = 160,
		y = y + 100, -- Ajuste a distância conforme necessário
		font = "assets/7fonts/Textile.ttf",
		fontSize = 26,
	})
	label2.anchorX = 0

	local activitieTest = display.newText({
		parent = group,
		text = "Nível da Atividade",
		x = 305,
		y = y + 100, -- Ajuste a distância conforme necessário
		font = "assets/7fonts/Textile.ttf",
		fontSize = 26,
	})
	activitieTest.anchorX = 0
	activitieTest:setFillColor(1, 0.85, 0)

	local label2 = display.newText({
		parent = group,
		text = activitieCost,
		x = display.contentWidth - 40,
		y = y + 100, -- Ajuste a distância conforme necessário
		font = "assets/7fonts/Textile.ttf",
		fontSize = 26,
	})
	label2.anchorX = 100

	return group
end

local achievementsButton = {}
function achievementsButton.new(params)
	-- Cria um grupo para agrupar os elementos do componente
	local group = display.newGroup()

	-- Valores padrão para os parâmetros (caso não sejam informados)
	local x = params.x
	local y = params.y
	local item1 = params.item1

	local label1 = params.label1 or ""
	local label2 = params.label2 or ""

	local quantity = params.quantity or ""

	local activitieCost = params.activitieCost or "1"

	-- Cria a imagem do componente
	local bg = display.newImageRect(group, "assets/7bg/bg_cell_brown.png", 620, 132 * 1.3)
	bg.x = x + 60
	bg.y = y + 45
	bg.fill.effect = "filter.grayscale"

	local image = display.newImageRect(group, item1, 104 * 1.1, 104 * 1.1)
	image.x = x - 175
	image.y = y + 30

	local bg = display.newImageRect(group, "assets/7bg/bg_cell_lock_border.png", 584 / 1.27, 136 / 1.5)
	bg.x = x + 117
	bg.y = y + 20
	bg.alpha = 0.5

	local label = display.newText({
		parent = group,
		text = label1,
		x = 160,
		y = y, -- Ajuste a distância conforme necessário
		font = "assets/7fonts/Textile.ttf",
		fontSize = 22,
	})
	label.anchorX = 0
	label:setFillColor(0.4333, 0.1686, 0.0235)

	local label2 = display.newText({
		parent = group,
		text = label2,
		x = 160,
		y = y + 25, -- Ajuste a distância conforme necessário
		font = "assets/7fonts/Textile.ttf",
		fontSize = 22,
	})
	label2.anchorX = 0
	label2:setFillColor(0.4333, 0.1686, 0.0235)

	local quantity = display.newText({
		parent = group,
		text = quantity,
		x = image.x,
		y = y + 105, -- Ajuste a distância conforme necessário
		font = "assets/7fonts/Textile.ttf",
		fontSize = 22,
	})
	label2.anchorX = 0
	label2:setFillColor(0.4333, 0.1686, 0.0235)

	return group
end

local scene = composer.newScene()
local tabContents = {
	chestActivities = nil,
	dailyLogin = nil,
	ongakuRamen = nil,
	achievements = nil,
	moneyTree = nil,
}

local currentTab = nil
local selectedTab = nil

local function chestActivities()
	local group = display.newGroup()

	local title = display.newText({
		text = "Baú da Atividade",
		x = display.contentCenterX,
		y = -55,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 24,
	})
	group:insert(title)

	local scrollView = widget.newScrollView({
		top = 230, -- posição vertical do scroll view na tela
		left = 0,
		width = 640,
		height = 865, -- área visível; ajuste conforme necessário
		scrollWidth = display.contentWidth,
		scrollHeight = 1350, -- altura total do conteúdo (deve ser maior que 'height' para permitir scroll)
		horizontalScrollDisabled = true,
		hideBackground = true,
	})
	group:insert(scrollView)

	-- Modal -----------------------------------------------------------------------------------------------------------
	local modalBg = display.newImageRect(group, "assets/7bg/bg_item_exchange_cell_1.png", 610, 195 * 1.3)
	modalBg.x = display.contentCenterX
	modalBg.y = 125

	local modalDetails =
		display.newImageRect(group, "assets/7bg/bg_custom_gift_pack_stuff_1.png", 590 / 1.16, 275 / 1.26)
	modalDetails.x = display.contentCenterX
	modalDetails.y = 125
	modalDetails.alpha = 0.5

	-- ActivitesChests -------------------------------------------------------------------------------------------------
	local activitiesBg = display.newImageRect(group, "assets/7bg/bg_mopup2.png", 309 * 1.8, 49 * 1.8)
	activitiesBg.x = display.contentCenterX
	activitiesBg.y = 170
	activitiesBg.alpha = 0.4

	-- activitiesChestButtons
	local chest50 = display.newImageRect(group, "assets/7button/btn_daily_active.png", 80, 75)
	chest50.x = display.contentCenterX - 125
	chest50.y = 65
	local chest80 = display.newImageRect(group, "assets/7button/btn_daily_active.png", 80, 75)
	chest80.x = display.contentCenterX + 80
	chest80.y = 65
	local chest100 = display.newImageRect(group, "assets/7button/btn_daily_active.png", 80, 75)
	chest100.x = display.contentCenterX + 175
	chest100.y = 65
	local arrow = display.newImageRect(group, "assets/7button/btn_arrow_8.png", 88 / 2.5, 68 / 2.5)
	arrow.x = display.contentCenterX - 125
	arrow.y = 120
	local arrow = display.newImageRect(group, "assets/7button/btn_arrow_8.png", 88 / 2.5, 68 / 2.5)
	arrow.x = display.contentCenterX + 80
	arrow.y = 120
	local arrow = display.newImageRect(group, "assets/7button/btn_arrow_8.png", 88 / 2.5, 68 / 2.5)
	arrow.x = display.contentCenterX + 175
	arrow.y = 120

	-- activitesCount
	local progressBar = display.newImageRect(group, "assets/7misc/pb_gray.png", 540, 44)
	progressBar.x = display.contentCenterX
	progressBar.y = 155

	local progress = display.newText({
		text = "0/121",
		x = display.contentCenterX,
		y = 155,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 24,
	})
	group:insert(progress)
	progress:setFillColor(0, 1, 1)

	local progress = display.newText({
		text = "50",
		x = display.contentCenterX - 125,
		y = 195,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 24,
	})
	group:insert(progress)
	local progress = display.newText({
		text = "80",
		x = display.contentCenterX + 80,
		y = 195,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 24,
	})
	group:insert(progress)
	local progress = display.newText({
		text = "100",
		x = display.contentCenterX + 175,
		y = 195,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 24,
	})
	group:insert(progress)

	-- activitesButton

	local shop1200 = activitiesButton.new({
		y = 70,
		x = 260,
		item1 = "assets/7shop/arena1.png",
		label1 = "Enfrentar jornadas comum",
		label2 = "",
		total = "0",
		remaing = "2",
		activitieCost = "5",
	})
	scrollView:insert(shop1200)

	local shop1200 = activitiesButton.new({
		y = 70 + 170,
		x = 260,
		item1 = "assets/7shop/arena1.png",
		label1 = "Enfrentar jornadas especial",
		label2 = "",
		total = "0",
		remaing = "2",
		activitieCost = "10",
	})
	scrollView:insert(shop1200)

	local shop1200 = activitiesButton.new({
		y = 70 + 340,
		x = 260,
		item1 = "assets/7shop/arena1.png",
		label1 = "Desafiar um oponente",
		total = "0",
		remaing = "3",
		activitieCost = "10",
	})
	scrollView:insert(shop1200)

	local shop1200 = activitiesButton.new({
		y = 70 + 340 + 170,
		x = 260,
		item1 = "assets/7shop/arena1.png",
		label1 = "Entrar no Reino Sombrio",
		total = "0",
		remaing = "2",
		activitieCost = "10",
	})
	scrollView:insert(shop1200)

	local shop1200 = activitiesButton.new({
		y = 70 + 340 + 340,
		x = 260,
		item1 = "assets/7shop/arena1.png",
		label1 = "Balançar a Arvore de Prata ",
		total = "0",
		remaing = "2",
		activitieCost = "10",
	})
	scrollView:insert(shop1200)

	local shop1200 = activitiesButton.new({
		y = 70 + 340 + 340 + 170,
		x = 260,
		item1 = "assets/7shop/arena1.png",
		label1 = "Vender itens de prata",
		total = "0",
		remaing = "3",
		activitieCost = "10",
	})
	scrollView:insert(shop1200)

	local shop1200 = activitiesButton.new({
		y = 70 + 340 + 340 + 340,
		x = 260,
		item1 = "assets/7shop/arena1.png",
		label1 = "Comprar energia",
		total = "0",
		remaing = "2",
		activitieCost = "10",
	})
	scrollView:insert(shop1200)

	local shop1200 = activitiesButton.new({
		y = 70 + 340 + 340 + 340 + 170,
		x = 260,
		item1 = "assets/7shop/arena1.png",
		label1 = "Comprar na loja do Desafio",
		total = "0",
		remaing = "1",
		activitieCost = "10",
	})
	scrollView:insert(shop1200)

	local shop1200 = activitiesButton.new({
		y = 70 + 340 + 340 + 340 + 340,
		x = 260,
		item1 = "assets/7shop/arena1.png",
		label1 = "Comprar na loja do Reino Sombrio",
		total = "0",
		remaing = "1",
		activitieCost = "10",
	})
	scrollView:insert(shop1200)

	local shop1200 = activitiesButton.new({
		y = 70 + 340 + 340 + 340 + 340 + 170,
		x = 260,
		item1 = "assets/7shop/arena1.png",
		label1 = "Enfrentar Jornada Herói",
		total = "0",
		remaing = "1",
		activitieCost = "10",
	})
	scrollView:insert(shop1200)

	local myNavBar = navBar.new()
	group:insert(myNavBar)

	return group
end

local function dailyLogin()
	local group = display.newGroup()
	local title = display.newText({
		text = "Login Diário",
		x = display.contentCenterX,
		y = -52,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 24,
	})
	group:insert(title)

	local dailyBg = display.newImageRect(group, "assets/7bg/bg_event_0.jpg", 640, 1080)
	dailyBg.x = display.contentCenterX
	dailyBg.y = 535
	local border = display.newImageRect(group, "assets/7bg/bg_bottom_frame_2.png", 640, 12)
	border.x = display.contentCenterX
	border.y = 0
	local border = display.newImageRect(group, "assets/7bg/bg_bottom_frame_2.png", 640, 12)
	border.x = display.contentCenterX
	border.y = dailyBg.y + 545

	-- Cards
	local card1 = display.newImageRect(group, "assets/7card/card_back_s.png", 104 * 1.4, 104 * 1.4)
	card1.x = 125
	card1.y = 125 + 100
	local card2 = display.newImageRect(group, "assets/7card/card_back_s.png", 104 * 1.4, 104 * 1.4)
	card2.x = card1.x + 190
	card2.y = 125 + 100
	local card1 = display.newImageRect(group, "assets/7card/card_back_s.png", 104 * 1.4, 104 * 1.4)
	card1.x = card2.x + 190
	card1.y = 125 + 100
	local card1 = display.newImageRect(group, "assets/7card/card_back_s.png", 104 * 1.4, 104 * 1.4)
	card1.x = 125
	card1.y = 125 + 150 + 120
	local card2 = display.newImageRect(group, "assets/7card/card_back_s.png", 104 * 1.4, 104 * 1.4)
	card2.x = card1.x + 190
	card2.y = 125 + 150 + 120
	local card1 = display.newImageRect(group, "assets/7card/card_back_s.png", 104 * 1.4, 104 * 1.4)
	card1.x = card2.x + 190
	card1.y = 125 + 150 + 120
	local card7 = display.newImageRect(group, "assets/7card/card_back_s.png", 104 * 1.4, 104 * 1.4)
	card7.x = 125
	card7.y = 125 + 300 + 140
	local card8 = display.newImageRect(group, "assets/7card/card_back_s.png", 104 * 1.4, 104 * 1.4)
	card8.x = card7.x + 190
	card8.y = 125 + 300 + 140
	local card9 = display.newImageRect(group, "assets/7card/card_back_s.png", 104 * 1.4, 104 * 1.4)
	card9.x = card8.x + 190
	card9.y = 125 + 300 + 140

	local label1 = display.newText({
		text = "Voce hoje ainda pode virar 1",
		x = 25,
		y = display.contentHeight - 100,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 25,
	})
	label1:setFillColor(0.4333, 0.1686, 0.0235)
	label1.anchorX = 0
	group:insert(label1)

	local label2 = display.newText({
		text = "vezes, continue fazendo logins",
		x = 25,
		y = label1.y + 30,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 25,
	})
	label2:setFillColor(0.4333, 0.1686, 0.0235)
	label2.anchorX = 0
	group:insert(label2)

	local label3 = display.newText({
		text = "diariamente e podera ter a",
		x = 25,
		y = label2.y + 30,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 25,
	})
	label3:setFillColor(0.4333, 0.1686, 0.0235)
	label3.anchorX = 0
	group:insert(label3)

	local label4 = display.newText({
		text = "oportunidade de virar mais cartas.",
		x = 25,
		y = label3.y + 30,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 25,
	})
	label4:setFillColor(0.4333, 0.1686, 0.0235)
	label4.anchorX = 0
	group:insert(label4)

	local dotButton1 = display.newImageRect(group, "assets/7misc/misc_page_selected.png", 32 * 1.3, 32 * 1.3)
	dotButton1.x = card7.x - 50
	dotButton1.y = card7.y + 223
	local dotButton2 = display.newImageRect(group, "assets/7misc/misc_page_selected.png", 32 * 1.3, 32 * 1.3)
	dotButton2.x = card8.x - 50
	dotButton2.y = card8.y + 223
	local dotButton3 = display.newImageRect(group, "assets/7misc/misc_page_selected.png", 32 * 1.3, 32 * 1.3)
	dotButton3.x = card9.x - 90
	dotButton3.y = card9.y + 223

	local day1 = display.newText({
		text = "1 dia",
		x = dotButton1.x + 60,
		y = dotButton1.y,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 25,
	})
	day1:setFillColor(0.8706, 0.7451, 0.5176)
	group:insert(day1)

	local day2 = display.newText({
		text = "2 dias",
		x = dotButton2.x + 65,
		y = dotButton1.y,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 25,
	})
	day2:setFillColor(0.8706, 0.7451, 0.5176)
	group:insert(day2)

	local day3 = display.newText({
		text = "3 dias",
		x = dotButton3.x + 65,
		y = dotButton1.y,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 25,
	})
	day3:setFillColor(0.8706, 0.7451, 0.5176)
	group:insert(day3)

	return group
end

local function ongakuRamen()
	local group = display.newGroup()

	local data = userDataLib.load()
	if not data or not data.id or not data.server then
		display.newText({
			parent = group,
			text = "Erro: dados do usuário não encontrados",
			x = display.contentCenterX,
			y = display.contentCenterY,
			font = native.systemFontBold,
			fontSize = 20,
		})
		return
	end

	-- UI estática
	local title = display.newText({
		text = "Ongaku Ramen",
		x = display.contentCenterX,
		y = -53,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 24,
	})
	group:insert(title)

	local dailyBg = display.newImageRect(group, "assets/7bg/bg_event_1.jpg", 640, 1080)
	dailyBg.x, dailyBg.y = display.contentCenterX, 535

	local frameTop = display.newImageRect(group, "assets/7bg/bg_bottom_frame_2.png", 640, 12)
	frameTop.x, frameTop.y = display.contentCenterX, 0
	local frameBot = display.newImageRect(group, "assets/7bg/bg_bottom_frame_2.png", 640, 12)
	frameBot.x, frameBot.y = display.contentCenterX, dailyBg.y + 545

	local label1 = display.newText({
		text = "O mestre pode vir todos os dias apreciar um macarrão",
		x = display.contentCenterX,
		y = display.contentCenterY + 90,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 18,
	})
	group:insert(label1)

	local label2 = display.newText({
		text = "delicioso. Cada vez recupera 60 pontos de força física!",
		x = display.contentCenterX,
		y = label1.y + 25,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 19,
	})
	group:insert(label2)

	-- botão de receber energia
	local btnBless = display.newImageRect(group, "assets/7button/btn_event_bless_accept.png", 400 / 1.2, 400 / 1.2)
	btnBless.x, btnBless.y = display.contentCenterX, dailyBg.y + 245

	-- temporizador (mantém seu código aqui...)
	local timerBg = display.newImageRect(group, "assets/7textbg/tbg_gray_s9.png", 144 * 2, 32 * 2)
	timerBg.x, timerBg.y = display.contentCenterX, dailyBg.y + 380

	local label3 = display.newText({
		text = "",
		x = display.contentCenterX,
		y = timerBg.y,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 26,
	})
	group:insert(label3)

	local function updateTimer()
		-- 1) pega horário UTC e ajusta para Brasília (UTC−3)
		local utc = os.time(os.date("!*t"))
		local brTime = utc - 3 * 3600
		local t = os.date("*t", brTime)

		-- 2) calcula segundos desde 00:00
		local nowSec = t.hour * 3600 + t.min * 60 + t.sec

		-- 3) escolhe alvo: 18:00 ou meia-noite
		local targetSec
		if nowSec < 18 * 3600 then
			targetSec = 18 * 3600
		else
			targetSec = 24 * 3600
		end

		-- 4) tempo restante
		local rem = targetSec - nowSec
		if rem < 0 then
			rem = 0
		end

		-- 5) formata em HH:MM:SS
		local h = math.floor(rem / 3600)
		local m = math.floor((rem % 3600) / 60)
		local s = rem % 60
		label3.text = string.format("%02d:%02d:%02d", h, m, s)
	end

	-- 6) atualiza a cada segundo
	timer.performWithDelay(1000, updateTimer, 0)
	updateTimer()

	local userId = data.id

	-- GET inicial: verifica sushi e só aí registra listener
	network.request(supabase.SUPABASE_URL .. "/rest/v1/users?id=eq." .. userId, "GET", function(event)
		if event.isError or event.status ~= 200 then
			print("Erro ao buscar usuário:", event.response)
			return
		end
		local users = json.decode(event.response)
		local user = users[1]

		if user and user.sushi == false then
			-- já usado: aplica grayscale e sai
			btnBless.fill.effect = "filter.grayscale"
		else
			-- disponível: cria função nomeada para o tap
			local function onBlessTap()
				-- garante que só remova o listener que registramos
				btnBless:removeEventListener("tap", onBlessTap)

				-- recarrega do DB pra pegar energia/sushi atuais
				network.request(supabase.SUPABASE_URL .. "/rest/v1/users?id=eq." .. userId, "GET", function(getE)
					if getE.isError or getE.status ~= 200 then
						print("GET interno falhou:", getE.response)
						-- reabilita em caso de erro
						btnBless:addEventListener("tap", onBlessTap)
						return
					end
					local tbl = json.decode(getE.response) or {}
					local u = tbl[1]
					if not u or u.sushi == false then
						-- alguém já usou no intervalo: desabilita e sai
						btnBless.fill.effect = "filter.grayscale"
						return
					end

					-- soma +60 de energia
					local newEnergy = (u.energy or 0) + 60
					local body = json.encode({
						energy = newEnergy,
						sushi = false,
					})

					-- PATCH para salvar no DB
					network.request(
						supabase.SUPABASE_URL .. "/rest/v1/users?id=eq." .. userId,
						"PATCH",
						function(patchE)
							if not patchE.isError and patchE.status == 204 then
								print("Energia +60 aplicada")
								-- efeito grayscale pra indicar uso
								btnBless.fill.effect = "filter.grayscale"
							else
								print("Falha ao atualizar:", patchE.response)
								-- reabilita onTap se falhar
								btnBless:addEventListener("tap", onBlessTap)
							end
						end,
						{
							headers = {
								["apikey"] = supabase.SUPABASE_ANON_KEY,
								["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
								["Content-Type"] = "application/json",
							},
							body = body,
						}
					)
				end, {
					headers = {
						["apikey"] = supabase.SUPABASE_ANON_KEY,
						["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
					},
				})
			end

			-- registra o listener nomeado
			btnBless:addEventListener("tap", onBlessTap)
		end
	end, {
		headers = {
			["apikey"] = supabase.SUPABASE_ANON_KEY,
			["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
		},
	})

	return group
end

local function achievements()
	local group = display.newGroup()
	local title = display.newText({
		text = "Missão",
		x = display.contentCenterX,
		y = -52,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 24,
	})
	group:insert(title)

	local scrollView = widget.newScrollView({
		top = -24, -- posição vertical do scroll view na tela
		left = 0,
		width = 640,
		height = 1120, -- área visível; ajuste conforme necessário
		scrollWidth = display.contentWidth,
		scrollHeight = 1350, -- altura total do conteúdo (deve ser maior que 'height' para permitir scroll)
		horizontalScrollDisabled = true,
		hideBackground = true,
	})
	group:insert(scrollView)

	local achiev1 = achievementsButton.new({
		y = 50,
		x = 260,
		item1 = "assets/7shop/diamond1.png",
		label1 = "Ninja alcançou o nível 5",
		total = "0",

		quantity = "100",
	})
	scrollView:insert(achiev1)

	local achiev2 = achievementsButton.new({
		y = 50 + 170,
		x = 260,
		item1 = "assets/7shop/diamond1.png",
		label1 = "Alcançou rank 20 no desafio",
		total = "0",

		quantity = "100",
	})
	scrollView:insert(achiev2)

	local achiev2 = achievementsButton.new({
		y = 50 + 340,
		x = 260,
		item1 = "assets/7shop/diamond1.png",
		label1 = "Terminou o capítulo 1 da",
		label2 = "Jornada Herói.",
		total = "0",

		quantity = "25",
	})
	scrollView:insert(achiev2)

	local achiev2 = achievementsButton.new({
		y = 50 + 340 + 170,
		x = 260,
		item1 = "assets/7shop/diamond1.png",
		label1 = "Terminou o nível 1 do",
		label2 = "Reino Sombrio.",
		total = "0",

		quantity = "50",
	})
	scrollView:insert(achiev2)

	local achiev2 = achievementsButton.new({
		y = 50 + 340 + 340,
		x = 260,
		item1 = "assets/7shop/energy1.png",
		label1 = "Terminou o capítulo 1 da",
		label2 = "Jornada Comum",
		total = "0",

		quantity = "60",
	})
	scrollView:insert(achiev2)

	local achiev2 = achievementsButton.new({
		y = 50 + 340 + 340 + 170,
		x = 260,
		item1 = "assets/7shop/rune2.png",
		label1 = "Sintetiza runa de nível 2 ou",
		label2 = "superior.",
		total = "0",

		quantity = "1",
	})
	scrollView:insert(achiev2)

	local achiev2 = achievementsButton.new({
		y = 50 + 340 + 340 + 340,
		x = 260,
		item1 = "assets/7shop/coin1.png",
		label1 = "VIP ativado com sucesso.",
		total = "0",

		quantity = "50000",
	})
	scrollView:insert(achiev2)

	local achiev2 = achievementsButton.new({
		y = 50 + 340 + 340 + 340 + 170,
		x = 260,
		item1 = "assets/7items/sushi.png",
		label1 = "VIP ativado com sucesso.",
		total = "0",

		quantity = "5",
	})
	scrollView:insert(achiev2)

	local myNavBar = navBar.new()
	group:insert(myNavBar)

	return group
end

local function moneyTree()
	-- seed para o random
	math.randomseed(os.time())

	local group = display.newGroup()

	local data = userDataLib.load()
	if not data or not data.id or not data.server then
		display.newText({
			parent = group,
			text = "Erro: dados do usuário não encontrados",
			x = display.contentCenterX,
			y = display.contentCenterY,
			font = native.systemFontBold,
			fontSize = 20,
		})
		return
	end

	-- 1) UI estática
	local title = display.newText({
		text = "Árvore de Dinheiro",
		x = display.contentCenterX,
		y = -53,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 24,
	})
	group:insert(title)

	local dailyBg = display.newImageRect(group, "assets/7bg/bg_event_6.jpg", 640, 1080)
	dailyBg.x, dailyBg.y = display.contentCenterX, 535

	local frameTop = display.newImageRect(group, "assets/7bg/bg_bottom_frame_2.png", 640, 12)
	frameTop.x, frameTop.y = display.contentCenterX, 0

	local frameBot = display.newImageRect(group, "assets/7bg/bg_bottom_frame_2.png", 640, 12)
	frameBot.x, frameBot.y = display.contentCenterX, dailyBg.y + 545

	local moneyTreeDesc = display.newImageRect(group, "assets/7textbg/tbg_brown_s9_2.png", 301 * 2, 36)
	moneyTreeDesc.x, moneyTreeDesc.y = display.contentCenterX, display.contentCenterY + 235

	local moneyText = display.newText({
		text = "Tem probabilidade de crítico, obtém 10× mais.",
		x = display.contentCenterX,
		y = moneyTreeDesc.y + 1,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 18,
	})
	group:insert(moneyText)

	local obter = display.newText({
		text = "Obter:",
		x = 100,
		y = moneyTreeDesc.y + 50,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 22,
	})
	group:insert(obter)

	local coinbg = display.newImageRect(group, "assets/7textbg/tbg_brown_s9_3_button.png", 150, 30)
	coinbg.x, coinbg.y = obter.x + 125, obter.y

	local coinIcon = display.newImageRect(group, "assets/7icon/icon_coin.png", 48 / 1.15, 48 / 1.15)
	coinIcon.x, coinIcon.y = obter.x + 55, obter.y

	local consumo = display.newText({
		text = "Consumo:",
		x = coinbg.x + 165,
		y = moneyTreeDesc.y + 50,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 22,
	})
	group:insert(consumo)

	local cashbg = display.newImageRect(group, "assets/7textbg/tbg_brown_s9_3_button.png", 150, 30)
	cashbg.x, cashbg.y = consumo.x + 145, consumo.y

	local cashIcon = display.newImageRect(group, "assets/7icon/icon_cash.png", 48 / 1.15, 48 / 1.15)
	cashIcon.x, cashIcon.y = consumo.x + 75, consumo.y

	local coinText = display.newText({
		text = "2000",
		x = coinbg.x,
		y = coinbg.y,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 22,
	})
	group:insert(coinText)

	local cashText = display.newText({
		text = "10",
		x = cashbg.x,
		y = cashbg.y,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 22,
	})
	group:insert(cashText)

	-- 2) Botão “Agitar”
	local buttonBg = display.newImageRect(group, "assets/7button/btn_common_yellow_s9.png", 244, 76)
	buttonBg.x, buttonBg.y = display.contentCenterX, display.contentCenterY + 365
	group:insert(buttonBg)

	local agitar = display.newText({
		text = "Agitar",
		x = buttonBg.x,
		y = buttonBg.y,
		font = "assets/7fonts/Textile.ttf",
		fontSize = 22,
	})
	group:insert(agitar)

	local userId = data.id

	-- 3) Listener de tap
	local function onShake()
		-- GET para saber estado atual
		network.request(supabase.SUPABASE_URL .. "/rest/v1/users?id=eq." .. userId, "GET", function(getE)
			if getE.isError or getE.status ~= 200 then
				print("❌ GET falhou:", getE.response)
				return
			end

			local tbl = json.decode(getE.response) or {}
			local user = tbl[1]
			-- se silverTree == false, aplica grayscale e sai
			if user.silverTree == false or user.silverTree == "false" then
				buttonBg.fill.effect = "filter.grayscale"
				return
			end

			-- sorteia entre 2000 e 20000
			local reward = math.random(2000, 20000)
			local newSilver = (user.silver or 0) + reward

			-- PATCH para atualizar silver e silverTree = false
			local body = json.encode({
				silver = newSilver,
				silverTree = false,
			})
			network.request(supabase.SUPABASE_URL .. "/rest/v1/users?id=eq." .. userId, "PATCH", function(patchE)
				if not patchE.isError and patchE.status == 204 then
					print("✅ Ganhou " .. reward .. " e desativou a árvore")
					-- aplica grayscale para mostrar desabilitado
					buttonBg.fill.effect = "filter.grayscale"
				else
					print("❌ PATCH falhou:", patchE.response)
				end
			end, {
				headers = {
					["apikey"] = supabase.SUPABASE_ANON_KEY,
					["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
					["Content-Type"] = "application/json",
				},
				body = body,
			})
		end, {
			headers = {
				["apikey"] = supabase.SUPABASE_ANON_KEY,
				["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
			},
		})
	end
	buttonBg:addEventListener("tap", onShake)

	-- 4) GET inicial para aplicar estado ao botão
	network.request(supabase.SUPABASE_URL .. "/rest/v1/users?id=eq." .. userId, "GET", function(initE)
		if initE.isError or initE.status ~= 200 then
			print("❌ GET inicial falhou:", initE.response)
			return
		end
		local arr = json.decode(initE.response) or {}
		local u = arr[1]
		if u and (u.silverTree == false or u.silverTree == "false") then
			buttonBg.fill.effect = "filter.grayscale"
		end
	end, {
		headers = {
			["apikey"] = supabase.SUPABASE_ANON_KEY,
			["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
		},
	})

	return group
end

-- Atualizar o conteúdo da aba selecionada
local function updateTabContent(tabName)
	for _, group in pairs(tabContents) do
		if group then
			group.isVisible = false
		end
	end

	if not tabContents[tabName] then
		if tabName == "chestActivities" then
			tabContents[tabName] = chestActivities()
		elseif tabName == "dailyLogin" then
			tabContents[tabName] = dailyLogin()
		elseif tabName == "ongakuRamen" then
			tabContents[tabName] = ongakuRamen()
		elseif tabName == "achievements" then
			tabContents[tabName] = achievements()
		elseif tabName == "moneyTree" then
			tabContents[tabName] = moneyTree()
		end
		scene.view:insert(tabContents[tabName])
	end

	tabContents[tabName].isVisible = true
	currentTab = tabName
end

-- Criar os botões das abas
local function createTabs()
	local tabGroup = display.newGroup()
	scene.view:insert(tabGroup)

	local tabNames = { "chestActivities", "dailyLogin", "ongakuRamen", "achievements", "moneyTree" }
	local icons = {
		chestActivities = "assets/7button/btn_daily_active.png",
		dailyLogin = "assets/7button/btn_event_daily_bonus.png",
		ongakuRamen = "assets/7button/btn_event_bless.png",
		achievements = "assets/7button/btn_event_quest.png",
		moneyTree = "assets/7button/btn_event_levy.png", -- Ícone para a nova aba
	}
	local labels = { "Síntese", "Decompor", "Diario", "Sushi", "Conquistas", "Arvore" }
	local tabs = {}

	local scrollView = widget.newScrollView({
		x = 245,
		y = -129, -- Ajustado para ser visível
		width = 490,
		height = 90,
		horizontalScrollDisabled = false,
		verticalScrollDisabled = true,
		scrollWidth = #tabNames * 200,
		scrollHeight = 90,
		isBounceEnabled = true,
		hideBackground = true,
	})
	scene.view:insert(scrollView)

	local startX = 70
	local spacing = 130

	for i, name in ipairs(tabNames) do
		local tab = display.newGroup()
		scrollView:insert(tab)

		local bg = display.newImageRect(tab, "assets/7button/btn_tab_s9_s.png", 132, 82)
		bg.x, bg.y = startX + (i - 1) * spacing, 45 -- Ajustado para dentro do `scrollView`
		tab:insert(bg)

		-- Ícone da aba (em vez do texto)
		local icon = display.newImageRect(tab, icons[name], 80, 75) -- Ajuste o tamanho do ícone conforme necessário
		icon.x, icon.y = bg.x, bg.y -- Centraliza o ícone sobre o fundo
		tab:insert(icon)

		tab.bg = bg
		tabs[i] = tab

		function tab:tap()
			if selectedTab then
				selectedTab.bg.fill = {
					type = "image",
					filename = "assets/7button/btn_tab_s9_s.png",
				}
			end

			bg.fill = {
				type = "image",
				filename = "assets/7button/btn_tab_light_s9_s.png",
			}

			selectedTab = tab
			updateTabContent(name)
			return true
		end
		tab:addEventListener("tap", tab)
	end

	return tabGroup, tabs
end

local function setInitialActiveTab(tabs)
	if not selectedTab and tabs[1] then
		selectedTab = tabs[1]
		selectedTab.bg.fill = {
			type = "image",
			filename = "assets/7button/btn_tab_light_s9_s.png",
		}
	end
end

-- Criar a cena
function scene:create(event)
	local sceneGroup = self.view

	local background = display.newImageRect(
		sceneGroup,
		"assets/7bg/bg_yellow_large.jpg",
		display.contentWidth,
		display.contentHeight * 1.44
	)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	local bgDecoTop = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_1.png", 640, 128)
	bgDecoTop.x = display.contentCenterX
	bgDecoTop.y = -142

	local decotop2 = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_2.png", 640, 60)
	decotop2.x = display.contentCenterX
	decotop2.y = -50

	local backBg = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_3.png", 128, 128)
	backBg.x = display.contentCenterX + 260
	backBg.y = bgDecoTop.y

	local btnFilter = display.newImageRect(sceneGroup, "assets/7button/btn_arrow_3.png", 66 / 2.2, 90 / 1.6)
	btnFilter.x = display.contentCenterX + 190
	btnFilter.y = bgDecoTop.y + 10

	local btnBack = display.newImageRect(sceneGroup, "assets/7button/btn_close.png", 96, 96)
	btnBack.x = display.contentCenterX + 270
	btnBack.y = bgDecoTop.y + 10

	local myNavBar = navBar.new()
	sceneGroup:insert(myNavBar)

	local function goToHome(event)
		if event.phase == "ended" then
			composer.removeScene("router.home")
			composer.gotoScene("router.home")
		end
		return true
	end
	btnBack:addEventListener("touch", goToHome)

	local tabGroup, tabs = createTabs()
	setInitialActiveTab(tabs)
	updateTabContent("chestActivities")
end

scene:addEventListener("create", scene)
return scene
