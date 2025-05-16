-- interfaces/growing/improveSelect.lua
local composer = require("composer")
local supa = require("config.supabase")
local json = require("json")
local network = require("network")
local widget = require("widget")
local userDataLib = require("lib.userData")
local cardCell = require("components.cardCell")
local topBack = require("components.backTop")
local navBar = require("components.navBar")

local scene = composer.newScene()

function scene:create(event)
	local sceneGroup = self.view
	local data = userDataLib.load() or {}
	local localUserId = tonumber(data.id) or 461752844
	self.userId = (event.params and event.params.userId) or localUserId

	local bg = display.newImageRect(
		sceneGroup,
		"assets/7bg/bg_yellow_large.jpg",
		display.contentWidth,
		display.contentHeight * 1.44
	)
	bg.x, bg.y = display.contentCenterX, display.contentCenterY

	local topBack = topBack.new({
		title = "Escolha a carta a ser elevada",
		func = "interfaces.growing.improve",
	})
	sceneGroup:insert(topBack)

	self.scrollView = widget.newScrollView({
		top = -79,
		left = 0,
		width = display.contentWidth,
		height = 1200,
		scrollWidth = display.contentWidth,
		scrollHeight = 0,
		hideScrollBar = false,
		hideBackground = true,
	})
	sceneGroup:insert(self.scrollView)

	local myNavBar = navBar.new()
	self.view:insert(myNavBar)

	local headers = {
		["Content-Type"] = "application/json",
		["apikey"] = supa.SUPABASE_ANON_KEY,
		["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY,
	}
	local url = string.format(
		"%s/rest/v1/user_characters?userId=eq.%s&select=id,characterId,name,stars,level,health,attack",
		supa.SUPABASE_URL,
		tostring(self.userId)
	)
	network.request(url, "GET", function(evt)
		if evt.isError then
			return
		end
		local chars = json.decode(evt.response) or {}
		local padding, cellH, y = 25, 132, 10 + 132 * 0.5
		for _, c in ipairs(chars) do
			local cell = cardCell.new({
				x = display.contentCenterX,
				y = y + 20,
				characterId = c.characterId,
				stars = c.stars,
				level = c.level,
				hp = c.health,
				atk = c.attack,
				name = c.name,
			})
			function cell:tap()
				_G.chaId = c.id
				composer.gotoScene("interfaces.growing.improve", {
					effect = "slideRight",
					time = 300,
				})
			end
			cell:addEventListener("tap", cell)
			self.scrollView:insert(cell)
			y = y + cellH + padding
		end
		self.scrollView:setScrollHeight(y)
	end, {
		headers = headers,
	})
end

function scene:hide(event)
	if event.phase == "will" then
		composer.removeScene("interfaces.growing.improveSelect")
	end
end

scene:addEventListener("create", scene)
scene:addEventListener("hide", scene)
return scene
