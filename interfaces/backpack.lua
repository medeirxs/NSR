local composer = require("composer")
local widget = require("widget")
local json = require("json")
local network = require("network")
local supabase = require("config.supabase")
local cardCell = require("components.cardCell")
local itemCell = require("components.itemCell")
local userDataLib = require("lib.userData")
local cloudOn = require("utils.cloudOn")
local cloudOff = require("utils.cloudOff")
local textile = require("utils.textile")

local scene = composer.newScene()

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

	local topBack = require("components.backTop")
	local tp = topBack.new({ title = "" })
	sceneGroup:insert(tp)

	local cardTab = display.newImageRect(sceneGroup, "assets/7button/btn_tab_s9.png", 236, 82)
	cardTab.x, cardTab.y = 330, -128
	local changeMemberText = textile.new({
		group = sceneGroup,
		texto = " Acessórios ",
		x = cardTab.x,
		y = cardTab.y + 5,
		tamanho = 22,
		corTexto = { 0.6, 0.6, 0.6 }, -- Amarelo {0.95, 0.86, 0.31}
		corContorno = { 0, 0, 0 },
		espessuraContorno = 2,
	})

	local itemTabBg = display.newImageRect(sceneGroup, "assets/7button/btn_tab_light_s9.png", 236, 82)
	itemTabBg.x, itemTabBg.y = 110, -128
	local changeMemberText = textile.new({
		group = sceneGroup,
		texto = " Cartas ",
		x = itemTabBg.x,
		y = itemTabBg.y + 5,
		tamanho = 22,
		corTexto = { 1 }, -- Amarelo {0.95, 0.86, 0.31}
		corContorno = { 0, 0, 0 },
		espessuraContorno = 2,
	})
	-- tabFormationBg:addEventListener("tap", function()
	-- 	cloudOn.show({
	-- 		time = 300,
	-- 	})
	-- 	timer.performWithDelay(300, function()
	-- 		composer.removeScene("interfaces.formation.formation")
	-- 		composer.gotoScene("interfaces.formation.formation")
	-- 	end)
	-- 	timer.performWithDelay(300, function()
	-- 		cloudOff.show({
	-- 			group = display.getCurrentStage(),
	-- 			time = 600,
	-- 		})
	-- 	end)
	-- end)

	-- Obtém userId local
	local data = userDataLib.load() or {}
	local userId = tonumber(data.id) or 461752844

	-- Scroll view para listar personagens e itens
	local scrollView = widget.newScrollView({
		top = -79,
		left = 0,
		width = display.contentWidth,
		height = 1190,
		horizontalScrollDisabled = true,
		verticalScrollDisabled = false,
		hideBackground = true,
		hideScrollBar = true,
	})
	sceneGroup:insert(scrollView)

	local navBar = require("components.navBar")
	local nv = navBar.new({})
	sceneGroup:insert(nv)

	-- Cabeçalhos para as requisições Supabase
	local headers = {
		["apikey"] = supabase.SUPABASE_ANON_KEY,
		["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
		["Content-Type"] = "application/json",
	}

	-- Mapas de itens específicos
	local spriteMap = {
		["cd0d2985-9685-46d8-b873-5fa73bfaa5e8"] = "assets/7items/sushi.png",
		["fdb9aa25-777c-4e0e-981e-151a6dc9a7d2"] = "assets/7items/sushi_legendary.png",
		["83749125-dd27-4c01-93e2-49ae2b5de364"] = "assets/7items/ninja_certificate.png",
	}
	local nameMap = {
		["cd0d2985-9685-46d8-b873-5fa73bfaa5e8"] = "Sushi",
		["fdb9aa25-777c-4e0e-981e-151a6dc9a7d2"] = "Sushi Lendário",
		["83749125-dd27-4c01-93e2-49ae2b5de364"] = "Certificado de Nível",
	}
	local starMap = {
		["cd0d2985-9685-46d8-b873-5fa73bfaa5e8"] = 5,
		["fdb9aa25-777c-4e0e-981e-151a6dc9a7d2"] = 6,
		["83749125-dd27-4c01-93e2-49ae2b5de364"] = 5,
	}

	-- Função para buscar e exibir personagens
	local function onCharsResponse(event)
		if event.isError then
			native.showAlert("Erro", "Não foi possível carregar os personagens.", { "OK" })
			return
		end
		local chars = json.decode(event.response) or {}
		local paddingTop = 20
		local charSpacing = 160
		for i = 1, #chars do
			local c = chars[i]
			local posY = paddingTop + (i - 1) * charSpacing + charSpacing / 2
			local card = cardCell.new({
				x = display.contentCenterX,
				y = posY,
				characterId = c.characterId,
				name = c.name,
				level = c.level,
				stars = c.stars,
				hp = c.hp,
				atk = c.atk,
			})
			scrollView:insert(card)
			card.isHitTestable = true
			card:addEventListener("tap", function()
				cloudOn.show({
					time = 300,
				})
				timer.performWithDelay(300, function()
					composer.gotoScene("lib.characterInfo", {
						effect = "fade",
						time = 0,
						params = c,
					})
				end)
				timer.performWithDelay(300, function()
					cloudOff.show({
						group = display.getCurrentStage(),
						time = 600,
					})
				end)
			end)
		end
		local charsHeight = #chars * charSpacing + paddingTop

		-- Busca e exibe itens após os personagens, agrupando além de um limite
		local ids = {
			"cd0d2985-9685-46d8-b873-5fa73bfaa5e8",
			"fdb9aa25-777c-4e0e-981e-151a6dc9a7d2",
			"83749125-dd27-4c01-93e2-49ae2b5de364",
		}
		local idsParam = table.concat(ids, ",")
		local itemsUrl = string.format(
			"%s/rest/v1/user_items?select=itemId,quantity&userId=eq.%d&itemId=in.(%s)",
			supabase.SUPABASE_URL,
			userId,
			idsParam
		)
		network.request(itemsUrl, "GET", function(evt)
			if evt.isError then
				return
			end
			local items = json.decode(evt.response) or {}
			local itemStartY = charsHeight + 40
			local itemSpacing = 160
			local count = 0
			local threshold = 6
			for _, entry in ipairs(items) do
				local id = entry.itemId
				local qty = tonumber(entry.quantity) or 0
				-- Exibe até threshold unidades individualmente
				local displayCount = math.min(qty, threshold)
				for j = 1, displayCount do
					count = count + 1
					local posY = itemStartY + (count - 1) * itemSpacing + itemSpacing / 2
					local cell = itemCell.new({
						x = display.contentCenterX,
						y = posY - 40,
						sprite = spriteMap[id],
						name = nameMap[id],
						stars = starMap[id],
					})
					scrollView:insert(cell)
				end
				-- Agrupa o restante em um único componente
				local remaining = qty - displayCount
				if remaining > 0 then
					count = count + 1
					local posY = itemStartY + (count - 1) * itemSpacing + itemSpacing / 2
					local cell = itemCell.new({
						x = display.contentCenterX,
						y = posY - 40,
						sprite = spriteMap[id],
						name = nameMap[id] .. " x" .. remaining,
						stars = starMap[id],
					})
					scrollView:insert(cell)
				end
			end
			-- Ajusta altura do scroll para encaixar todos
			scrollView:setScrollHeight(itemStartY + count * itemSpacing + 20)
		end, { headers = headers })
	end

	-- Dispara requisição dos personagens
	local charUrl = string.format(
		"%s/rest/v1/user_characters?select=characterId,name,level,stars,hp,atk&userId=eq.%d",
		supabase.SUPABASE_URL,
		userId
	)
	network.request(charUrl, "GET", onCharsResponse, { headers = headers })
end

scene:addEventListener("create", scene)
return scene
