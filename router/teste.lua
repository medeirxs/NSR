local composer = require("composer")
local widget = require("widget")
local wS = require("journey.winScreen")

local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view

    local image = display.newImageRect(sceneGroup, "assets/7bg/campaign/1.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    image.x, image.y = display.contentCenterX, display.contentCenterY -- display.contentWidth, display.contentHeight \* 1.44

    local wS = wS.new({})
end

scene:addEventListener("create", scene)
return scene
