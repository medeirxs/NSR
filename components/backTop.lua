local textile = require("utils.textile")
local composer = require("composer")
local cloudOn = require("utils.cloudOn") -- entrada
local cloudOff = require("utils.cloudOff") -- saida

local component = {}

function component.new(params)
    local group = display.newGroup()
    local title = params.title or " "
    local func = params.func or "router.home"
    local params = params

    local image = display.newImageRect(group, "assets/7bg/bg_deco_top_1.png", display.contentWidth, 128)
    image.x, image.y = display.contentCenterX, -150
    local text = textile.new({
        group = group,
        texto = title,
        x = 20,
        y = image.y + 15,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local bgDecoTop3 = display.newImageRect(group, "assets/7bg/bg_deco_top_3.png", 128, 128)
    bgDecoTop3.x, bgDecoTop3.y = display.contentWidth - 150, -150

    local btnBack = display.newImageRect(group, "assets/7button/btn_close.png", 96, 96)
    btnBack.x, btnBack.y = bgDecoTop3.x + 100, bgDecoTop3.y + 9
    btnBack:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene(func)
            composer.gotoScene(func)
        end)
        timer.performWithDelay(300, function()
            cloudOff.show({
                group = display.getCurrentStage(),
                time = 600
            })
        end)
    end)

    local btnAsk = display.newImageRect(group, "assets/7button/btn_help.png", 96, 96)
    btnAsk.x, btnAsk.y = bgDecoTop3.x + 10, bgDecoTop3.y + 9

    return group
end

return component

-- local component = require("components.card")

-- local component = component.new({
--     x = display.contentCenterX,
--     y = display.contentCenterY,
-- })
-- group:insert(component)
