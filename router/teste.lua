local composer = require("composer")
local widget = require("widget")
local wS = require("journey.winScreen")
local raiseItems = require("components.showRaiseItems")

local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view

    local image = display.newImageRect(sceneGroup, "assets/7bg/campaign/1.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    image.x, image.y = display.contentCenterX, display.contentCenterY -- display.contentWidth, display.contentHeight \* 1.44

    local raiseItems = raiseItems.new({
        x = display.contentCenterX - 110,
        y = 0,
        characterId = "058fab51-e43a-4896-86fe-83f579e701fd",
        stars = 4
    })
end

scene:addEventListener("create", scene)
return scene
