local critEffect = {}

local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth

local sheetOptions = {
    frames = {{
        x = 550,
        y = 2,
        width = 135,
        height = 87
    }, {
        x = 413,
        y = 2,
        width = 135,
        height = 97
    }, {
        x = 1098,
        y = 2,
        width = 135,
        height = 79
    }, {
        x = 961,
        y = 2,
        width = 135,
        height = 79
    }, {
        x = 1372,
        y = 65,
        width = 135,
        height = 49
    }, {
        x = 824,
        y = 2,
        width = 135,
        height = 85
    }, {
        x = 2,
        y = 2,
        width = 135,
        height = 109
    }, {
        x = 1235,
        y = 2,
        width = 135,
        height = 75
    }, {
        x = 1372,
        y = 2,
        width = 135,
        height = 61
    }, {
        x = 276,
        y = 2,
        width = 135,
        height = 105
    }, {
        x = 687,
        y = 2,
        width = 135,
        height = 85
    }, {
        x = 139,
        y = 2,
        width = 135,
        height = 107
    }}
}

local critSheet = graphics.newImageSheet("assets/7effect/action_mudra.png", sheetOptions)

local sequenceData = {
    name = "awake",
    start = 1,
    count = 12,
    time = 1000,
    loopCount = 1
}

function critEffect.playEffect(target, callback, scaleOverride)
    local scaleFactor = scaleOverride or target.scaleFactor or deviceScaleFactor

    local parentGroup = target.group or target
    if not parentGroup then
        print("critEffect.playEffect: Objeto de display não fornecido.")
        if callback then
            callback()
        end
        return
    end

    print("critEffect.playEffect: Criando sprite de efeito crítico.")

    local critSprite = display.newSprite(critSheet, sequenceData)
    if not critSprite then
        print("critEffect.playEffect: Falha ao criar sprite!")
        if callback then
            callback()
        end
        return
    end

    critSprite.anchorX = 0.505
    critSprite.anchorY = 0.5
    critSprite:scale(1.7 * deviceScaleFactor, 1.7 * deviceScaleFactor)

    local centerX, centerY = 0, 0
    if parentGroup.getContentBounds then
        local bounds = parentGroup:getContentBounds()
        centerX = (bounds.xMin + bounds.xMax) * 0.5
        centerY = (bounds.yMin + bounds.yMax) * 0.5
    else
        centerX = parentGroup.x or display.contentCenterX
        centerY = parentGroup.y or display.contentCenterY
    end

    critSprite.x = centerX
    critSprite.y = centerY

    if parentGroup.parent then
        parentGroup.parent:insert(critSprite)
    else
        display.getCurrentStage():insert(critSprite)
    end

    critSprite:toFront()
    critSprite:play()

    local function spriteListener(event)
        if event.phase == "ended" then
            critSprite:removeEventListener("sprite", spriteListener)
            timer.performWithDelay(50, function()
                if critSprite and critSprite.removeSelf then
                    critSprite:removeSelf()
                end
                if callback then
                    callback()
                end
            end)
        end
    end
    critSprite:addEventListener("sprite", spriteListener)
end

return critEffect
