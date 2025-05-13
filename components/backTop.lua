local textile = require("utils.textile")
local composer = require("composer")
local cloudOn = require("utils.cloudOn") -- entrada
local cloudOff = require("utils.cloudOff") -- saida

local component = {}

function component.new(params)
    local group = display.newGroup()
    local title = params.title or " "
    local func = params.func or "router.home"
    local isntAsk = params.isntAsk or false
    local params = params

    local bgDecoTop = display.newImageRect(group, "assets/7bg/bg_deco_top_1.png", 640, 128)
    bgDecoTop.x = display.contentCenterX
    bgDecoTop.y = -142

    local text = textile.new({
        group = group,
        texto = title,
        x = 20,
        y = bgDecoTop.y + 15,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local backBg = display.newImageRect(group, "assets/7bg/bg_deco_top_3.png", 128, 128)
    backBg.x = display.contentCenterX + 170
    backBg.y = -142

    local btnFilter = display.newImageRect(group, "assets/7button/btn_help.png", 96, 96)
    btnFilter.x = display.contentCenterX + 180
    btnFilter.y = -133

    local btnBack = display.newImageRect(group, "assets/7button/btn_close.png", 96, 96)
    btnBack.x = display.contentCenterX + 270
    btnBack.y = -133
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

    return group
end

return component

-- local component = require("components.card")

-- local component = component.new({
--     x = display.contentCenterX,
--     y = display.contentCenterY,
-- })
-- group:insert(component)
