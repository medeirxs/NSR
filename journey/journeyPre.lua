local composer = require("composer")
local widget = require("widget")

local scene = composer.newScene()

local background

function scene:setBackgroundImage(imagePath, originalWidth, originalHeight)
    if background then
        background:removeSelf()
        background = nil
    end

    local screenWidth = display.actualContentWidth
    local screenHeight = display.actualContentHeight

    -- A altura desejada é 1.5 vezes a altura da tela.
    local desiredHeight = 1.5 * screenHeight
    -- Calcula o scaleFactor para que a imagem original alcance a desiredHeight.
    local scaleFactor = desiredHeight / originalHeight
    local newWidth = originalWidth * scaleFactor
    local newHeight = desiredHeight

    background = display.newImageRect(self.view, imagePath, newWidth, newHeight)
    if background then
        -- Centraliza horizontalmente e alinha a parte inferior à base da tela.
        background.anchorX = 0.5
        background.anchorY = 1
        background.x = display.contentCenterX
        background.y = display.contentHeight + 210
    else
        print("Erro ao carregar a imagem:", imagePath)
    end
end

function scene:create(event)
    local group = self.view

    local params = event.params or {}
    local bg = params.bg or 2

    local bgImagePath = "assets/7bg/campaign/" .. bg .. ".jpg"
    local bgWidth = 1068
    local bgHeight = 2548
    self:setBackgroundImage(bgImagePath, bgWidth, bgHeight)

    local transitionNinja = require("components.transitionNinja")
    local ninjaSprite = transitionNinja.new {
        x = display.contentCenterX,
        y = display.contentCenterY + 350,
        time = 700, -- opcional: duração total da animação
        loopCount = 1, -- opcional: 0 = infinito
        onComplete = function()
            print("Animação do ninja terminou!")
        end
    }
    group:insert(ninjaSprite)

end

scene:addEventListener("create", scene)
return scene
