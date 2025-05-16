-- equipmentSelect.lua
local composer = require("composer")
local widget = require("widget")
local supabaseClient = require("api.getCharacters")
local cardCell = require("components.cardCell")
local json = require("json")

local cloudOn = require("utils.cloudOn")
local cloudOff = require("utils.cloudOff")

local navBar = require("components.navBar")
local topBack = require("components.backTop")

local scene = composer.newScene()
local scrollView, params

-- Função para popular a lista
local function populateList()
	scrollView:removeSelf()
	scrollView = widget.newScrollView({
		top = -100,
		left = 0,
		width = display.contentWidth,
		height = 1200,
		scrollWidth = display.contentWidth,
		scrollHeight = 0,
		hideScrollBar = false,
		hideBackground = true,
	})
	scene.view:insert(scrollView)

	supabaseClient:request(
		"GET",
		string.format("user_characters?userId=eq.%d&order=stars.desc,name", params.userId or 461752844),
		nil,
		function(event)
			if event.isError then
				print("Erro na requisição:", event.response)
				return
			end

			print("Resposta bruta:", event.response)
			local data = json.decode(event.response) or {}
			if #data == 0 then
				print("Nenhum personagem retornado")
			end

			for i, char in ipairs(data) do
				local yPos = (i - 1) * 160 + 110
				local label = char.name or ("Personagem " .. char.id)
				print(string.format("Item %d: %s (charId=%s)", i, label, char.characterId))

				local cardCell = cardCell.new({
					x = display.contentCenterX,
					y = yPos,
					characterId = char.characterId,
					stars = char.stars,
					level = char.level,
					name = char.name,
					hp = char.hp,
					atk = char.atk,
				})
				scrollView:insert(cardCell)
				cardCell:addEventListener("tap", function()
					cloudOn.show({
						time = 300,
					})
					timer.performWithDelay(300, function()
						composer.gotoScene("interfaces.formation.equipment", {
							params = {
								userId = params.userId,
								selectedCharacterId = char.characterId,
								selectedStars = char.stars,
							},
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
		end
	)
end

function scene:create(event)
	params = event.params or {}
	-- if not params.userId then
	--     error("userId não informado")
	-- end

	local bg = display.newImageRect(
		self.view,
		"assets/7bg/bg_yellow_large.jpg",
		display.contentWidth,
		display.contentHeight * 1.44
	)
	bg.x, bg.y = display.contentCenterX, display.contentCenterY

	local topBack = topBack.new({
		title = "Escolher Ninja",
		func = "interfaces.formation.equipment",
	})
	self.view:insert(topBack)

	scrollView = widget.newScrollView({
		top = 50,
		left = 0,
		width = display.contentWidth,
		height = display.contentHeight,
		scrollWidth = display.contentWidth,
		scrollHeight = 0,
		hideScrollBar = false,
	})
	self.view:insert(scrollView)

	local myNavBar = navBar.new()
	self.view:insert(myNavBar)
end

function scene:show(event)
	if event.phase == "did" then
		populateList()
	end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
