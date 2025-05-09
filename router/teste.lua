local composer = require("composer")
local widget = require("widget")
local cardCell = require("components.cardCell")

local scene = composer.newScene()

function scene:create(event)
    local group = self.view

    local text = display.newText({
        text = "Teste",
        x = display.contentCenterX,
        y = 50,
        font = native.systemFontBold,
        fontSize = 28
    })

    local cardCell = cardCell.new({
        x = display.contentCenterX,
        y = display.contentCenterY,
        characterId = "49108f87-d863-4bb2-a294-8aad291d8fe2",
        stars = 10,
        level = 120,
        name = "Haku: Reencarnado"
    })

end

scene:addEventListener("create", scene)
return scene

