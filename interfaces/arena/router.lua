local composer = require("composer")
local widget = require("widget")

local scene = composer.newScene()

function scene:create(event)
	local group = self.view
end

scene:addEventListener("create", scene)
return scene
