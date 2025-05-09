local composer = require("composer")
local widget = require("widget")
local itemCell = require("components.itemCell")
local cardCell = require("components.cardCell")

local scene = composer.newScene()

function scene:create(event)
    local group = self.view

    local cardCell = cardCell.new({
        x = display.contentCenterX,
        y = display.contentCenterY,
        characterId = "058fab51-e43a-4896-86fe-83f579e701fd",
        name = "Sasuke: Maldição",
        stars = 11,
        level = 130,
        hp = 123,
        atk = 456
    })
end

scene:addEventListener("create", scene)
return scene
