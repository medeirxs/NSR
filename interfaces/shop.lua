local composer = require("composer")
local widget = require("widget")
local navBar = require("components.navBar")
local text = require("utils.textile")
local scene = composer.newScene()

local shopBtn = {}

function shopBtn.new(params)
	-- Cria um grupo para agrupar os elementos do componente
	local group = display.newGroup()

	-- Valores padrão para os parâmetros (caso não sejam informados)
	local x = params.x or display.contentCenterX
	local y = params.y or display.contentCenterY
	local imagePath = params.imagePath or "assets/default.png"
	local imageWidth = params.imageWidth or 100
	local imageHeight = params.imageHeight or 100
	local font = params.font or native.systemFont
	local fontSize = params.fontSize or 20
	local padG = params.padG or 0
	local padF = params.padF or 0
	local value = params.value or "0"
	local receive = params.receive or "0"
	local free = params.free or "0% Gratis!!"

	-- Cria a imagem do componente
	local bg = display.newImageRect(group, "assets/7bg/bg_cell_brown_3.png", 584, 132)
	bg.x = x + 60
	bg.y = y + 25

	local image = display.newImageRect(group, imagePath, 104, 104)
	image.x = x - 160
	image.y = y + 25

	local registerText = text.new({
		group = group, -- ou qualquer outro grupo que você esteja usando
		texto = value,
		x = x - 40,
		y = y - 13, -- Ajuste a distância conforme necessário
		tamanho = 20,
		corTexto = { 1, 1, 1 }, -- Branco
		corContorno = { 0, 0, 0 }, -- Preto
		espessuraContorno = 2,
	})

	local goldIcon = display.newImageRect(group, "assets/7icon/icon_cash.png", 48 / 1.2, 48 / 1.2)
	goldIcon.x = x - 73
	goldIcon.y = y + 2 + 25

	local label = text.new({
		group = group, -- ou qualquer outro grupo que você esteja usando
		texto = receive .. " ",
		x = x + 7 + padG,
		y = y + 4 + 25, -- Ajuste a distância conforme necessário
		tamanho = 20,
		corTexto = { 1, 1, 1 }, -- Branco
		corContorno = { 0, 0, 0 }, -- Preto
		espessuraContorno = 2,
	})

	local label = text.new({
		group = group, -- ou qualquer outro grupo que você esteja usando
		texto = free,
		x = x + 5 + padF,
		y = y + 60, -- Ajuste a distância conforme necessário
		tamanho = 24,
		corTexto = { 0, 1, 1 }, -- Branco
		corContorno = { 0, 0, 0 }, -- Preto
		espessuraContorno = 2,
	})

	local label = text.new({
		group = group, -- ou qualquer outro grupo que você esteja usando
		texto = "Receber o dobro via pix!",
		x = x + 200,
		y = y - 13, -- Ajuste a distância conforme necessário
		tamanho = 20,
		corTexto = { 0, 1, 1 }, -- Branco
		corContorno = { 0, 0, 0 }, -- Preto
		espessuraContorno = 2,
	})

	local buyBtn = display.newImageRect(group, "assets/7button/btn_common_yellow_s9.png", 244 / 1.3, 76 / 1.3)
	buyBtn.x = x + 240
	buyBtn.y = y + 30

	local label = text.new({
		group = group, -- ou qualquer outro grupo que você esteja usando
		texto = "Comprar",
		x = x + 240,
		y = y + 30, -- Ajuste a distância conforme necessário
		tamanho = 22,
		corTexto = { 1, 1, 1 }, -- Branco
		corContorno = { 0, 0, 0 }, -- Preto
		espessuraContorno = 2,
	})

	local label = display.newText({
		parent = group,
		text = "Comprar",
		x = x + 240,
		y = y + 30, -- Ajuste a distância conforme necessário
		font = font,
		fontSize = 22,
	})
	label:setFillColor(1, 1, 1) -- Define a cor do texto (branco)

	return group
end

local function gotoHome()
	composer.removeScene("router.home")
	composer.gotoScene("router.home")
end

function scene:create(event)
	local sceneGroup = self.view

	-- Adicionar imagem de fundo
	local background = display.newImageRect(
		sceneGroup,
		"assets/7bg/bg_yellow_large.jpg",
		display.contentWidth,
		display.contentHeight * 1.44
	)
	background.x = display.contentCenterX
	background.y = display.contentCenterY

	-- Adicionar 3 imagens alinhadas no topo
	local image1 = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_1.png", 640, 128)
	image1.x = display.contentCenterX
	image1.y = image1.height / 1 - 270
	image1.opacity = 0.5

	local image2 = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_2.png", 640, 60)
	image2.x = display.contentCenterX
	image2.y = image1.y + image1.height / 2 + image2.height / 2

	local image3 = display.newImageRect(sceneGroup, "assets/7bg/bg_shop_charge_double_reward.jpg", 640, 132)
	image3.x = display.contentCenterX
	image3.y = image2.y + image2.height / 2 + image3.height / 2 - 3

	-- Adicionar a quarta imagem abaixo das outras
	local image4 = display.newImageRect(sceneGroup, "assets/7bg/bg_bottom_frame_2.png", 640, 10)
	image4.x = display.contentCenterX
	image4.y = image3.y + image3.height / 2 + image4.height / 2

	-- Botão de voltar para Home utilizando uma imagem
	local backTP = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_3.png", 128, 128)
	backTP.x = 580 -- ajuste conforme necessário
	backTP.y = -141 -- ajuste conforme necessário

	local backImgBtn = display.newImageRect(sceneGroup, "assets/7button/btn_back.png", 96, 96)
	backImgBtn.x = 590 -- ajuste conforme necessário
	backImgBtn.y = -130 -- ajuste conforme necessário
	backImgBtn:addEventListener("tap", gotoHome)

	-- Cria um scroll view para os itens da loja
	local scrollView = widget.newScrollView({
		top = 120, -- posição vertical do scroll view na tela
		left = 0,
		width = 640,
		height = 1000, -- área visível; ajuste conforme necessário
		scrollWidth = display.contentWidth,
		scrollHeight = 1350, -- altura total do conteúdo (deve ser maior que 'height' para permitir scroll)
		horizontalScrollDisabled = true,
		hideBackground = true,
	})
	sceneGroup:insert(scrollView)

	local shop1 = shopBtn.new({
		y = 50,
		x = 260,
		imagePath = "assets/7shop/diamond1.png",
		value = "BRL 12.99 ",
		receive = "798 + 42 ",
		padG = 0,
		free = "5% Gratis!!",
		padF = 15,
		font = "assets/7fonts/textile.ttf",
	})
	scrollView:insert(shop1)

	local shop2 = shopBtn.new({
		y = 185,
		x = 260,
		imagePath = "assets/7shop/diamond2.png",
		value = "BRL 25.99 ",
		receive = "1615 + 75 ",
		padG = 0,
		free = "5% Gratis!!",
		padF = 15,
		font = "assets/7fonts/textile.ttf",
	})
	scrollView:insert(shop2)

	local shop3 = shopBtn.new({
		y = 320,
		x = 260,
		imagePath = "assets/7shop/diamond3.png",
		value = "BRL 39.99 ",
		receive = "2470 + 130 ",
		padG = 10,
		free = "5% Gratis!!",
		padF = 15,
		font = "assets/7fonts/textile.ttf",
	})
	scrollView:insert(shop3)

	local shop4 = shopBtn.new({
		y = 455,
		x = 260,
		imagePath = "assets/7shop/diamond4.png",
		value = "BRL 52.99 ",
		receive = "3168 + 352 ",
		padG = 10,
		free = "10% Gratis!!",
		padF = 20,
		font = "assets/7fonts/textile.ttf",
	})
	scrollView:insert(shop4)

	local shop5 = shopBtn.new({
		y = 590,
		x = 260,
		imagePath = "assets/7shop/diamond5.png",
		value = "BRL 75.99 ",
		receive = "4708 + 642",
		padG = 9,
		free = "12% Gratis!!",
		padF = 20,
		font = "assets/7fonts/textile.ttf",
	})
	scrollView:insert(shop5)

	local shop6 = shopBtn.new({
		y = 725,
		x = 260,
		imagePath = "assets/7shop/diamond6.png",
		value = "BRL 129.99 ",
		receive = "7820 + 1380 ",
		padG = 9,
		free = "15% Gratis!!",
		padF = 20,
		font = "assets/7fonts/textile.ttf",
	})
	scrollView:insert(shop6)

	local shop7 = shopBtn.new({
		y = 860,
		x = 260,
		imagePath = "assets/7shop/diamond7.png",
		value = "BRL 249.99 ",
		receive = "15360 + 3840 ",
		padG = 14,
		free = "20% Gratis!!",
		padF = 20,
		font = "assets/7fonts/textile.ttf",
	})
	scrollView:insert(shop7)

	local shop8 = shopBtn.new({
		y = 860 + 135,
		x = 260,
		imagePath = "assets/7shop/diamond7.png",
		value = "BRL 624.99 ",
		receive = "37500 + 12500 ",
		padG = 14,
		free = "25% Gratis!!",
		padF = 20,
		font = "assets/7fonts/textile.ttf",
	})
	scrollView:insert(shop8)

	local txct1 = text.new({
		group = sceneGroup, -- ou qualquer outro grupo que você esteja usando
		texto = "Toda recarga com pagamento via pix",
		x = display.contentCenterX + 55,
		y = 50 - 45,
		tamanho = 22,
		corTexto = { 0, 1, 1 }, -- Branco
		corContorno = { 0, 0, 0 }, -- Preto
		espessuraContorno = 2,
	})

	local txct2 = text.new({
		group = sceneGroup, -- ou qualquer outro grupo que você esteja usando
		texto = "pode obter moedas de ouro a dobrar",
		x = display.contentCenterX + 55,
		y = 50 - 25,
		tamanho = 22,
		corTexto = { 0, 1, 1 }, -- Branco
		corContorno = { 0, 0, 0 }, -- Preto
		espessuraContorno = 2,
	})

	local moreCoins = display.newText({
		parent = sceneGroup,
		text = "Mais moedas",
		x = 115,
		y = -132,
		font = "assets/7fonts/textile.ttf",
		fontSize = 23,
		align = "center",
	})
	moreCoins:setFillColor(1, 1, 1)

	local myNavBar = navBar.new()
	sceneGroup:insert(myNavBar)
end

scene:addEventListener("create", scene)
return scene
