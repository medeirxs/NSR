local kotoamatsukami = {}

-- Escalas responsivas
local designWidth       = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth
local hitEffectScale    = 2.3 * deviceScaleFactor
local overlayScale      = 3.0 * deviceScaleFactor
local actionScale       = 2.5 * deviceScaleFactor

--------------------------------------------------
-- Função auxiliar: createActionSprite
-- Exibe uma animação de ação sobre o atacante em loop contínuo
--------------------------------------------------
local function createActionSprite(cardGroup)
    local sheetOptions = {
        frames = {
            { x = 1,   y = 1,   width = 220, height = 82 },
            { x = 1,   y = 85,  width = 220, height = 82 },
            { x = 223, y = 1,   width = 216, height = 82 },
            { x = 223, y = 85,  width = 214, height = 82 },
            { x = 1,   y = 169, width = 206, height = 82 },
            { x = 209, y = 169, width = 206, height = 82 },
            { x = 209, y = 169, width = 206, height = 82 },
            { x = 209, y = 169, width = 206, height = 82 },
            { x = 209, y = 169, width = 206, height = 82 },
            { x = 209, y = 169, width = 206, height = 82 },
            { x = 209, y = 169, width = 206, height = 82 },
            { x = 209, y = 169, width = 206, height = 82 },
            { x = 209, y = 169, width = 206, height = 82 },
            { x = 1,   y = 253, width = 204, height = 82 },
            { x = 207, y = 253, width = 204, height = 82 },
            { x = 1,   y = 337, width = 202, height = 80 },
            { x = 205, y = 337, width = 202, height = 80 },
            { x = 441, y = 1,   width = 198, height = 78 },
        }
    }
    local actionSheet = graphics.newImageSheet("assets/7effect/action_42.png", sheetOptions)
    local seqData     = { name="action", start=1, count=18, time= 1000, loopCount= 1 }  -- 0 = loop infinito
    local sprite      = display.newSprite(actionSheet, seqData)

    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = 0, 0.3
    sprite.alpha                   = 1.0
    sprite:scale(actionScale, actionScale)
    cardGroup:insert(sprite)
    sprite:toFront()
    sprite:play()

    return sprite
end

--------------------------------------------------
-- Função auxiliar: showOverlayAnimationAtPosition
-- Exibe overlay animado via spritesheet em (x,y) com fade in/out
--------------------------------------------------
local function showOverlayAnimationAtPosition(x, y, callback)
    local sheetOptions = {
        frames = {
            { x = 3, y = 3, width = 559, height = 463 },
        }
    }
    local overlaySheet = graphics.newImageSheet("assets/7effect/kotoamatsukami.png", sheetOptions)
    local seqData      = { name="overlay", start=1, count=1, time=1, loopCount=1 }
    local sprite       = display.newSprite(overlaySheet, seqData)

    -- fade in / fade out do sprite de overlay
    local totalTime = seqData.time * seqData.loopCount
    local fadeTime  = 400

    sprite.alpha = 0
    transition.to(sprite, {
        alpha = 1,
        time  = fadeTime
    })
    transition.to(sprite, {
        alpha = 0,
        time  = fadeTime,
        delay = totalTime - fadeTime
    })

    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = x, y
    sprite:scale(overlayScale, overlayScale)
    display.getCurrentStage():insert(sprite)
    sprite:toFront()
    sprite:play()

    sprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if sprite.removeSelf then sprite:removeSelf() end
            if callback then callback() end
        end
    end)
end

--------------------------------------------------
-- Função auxiliar: showHitAtPosition
-- Exibe hit via spritesheet em (x,y)
--------------------------------------------------
local function showHitAtPosition(x, y, callback)
    local sheetOptions = {
        frames = {
        { x =   1,   y =    1, width = 768, height = 768 },
        { x = 771,   y =    1, width = 768, height = 768 },
        { x = 1541,  y =    1, width = 768, height = 768 },
        { x = 2311,  y =    1, width = 768, height = 768 },
        { x =   1,   y =  771, width = 768, height = 768 },
        { x = 771,   y =  771, width = 768, height = 768 },
        { x = 1541,  y =  771, width = 768, height = 768 },
        { x = 2311,  y =  771, width = 768, height = 768 },
        { x =   1,   y = 1541, width = 768, height = 768 },
        { x = 771,   y = 1541, width = 768, height = 768 },
        { x = 1541,  y = 1541, width = 768, height = 768 },
        { x = 2311,  y = 1541, width = 768, height = 768 },
        { x =   1,   y = 2311, width = 768, height = 768 },
        { x = 771,   y = 2311, width = 768, height = 768 },
        { x = 1541,  y = 2311, width = 768, height = 768 },
        { x = 2311,  y = 2311, width = 768, height = 768 },
        { x = 3081,  y =    1, width = 768, height = 768 },
        { x = 3081,  y =  771, width = 768, height = 768 },
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/bullet_113.png", sheetOptions)
    local seqData  = { name="hit", start=1, count=18, time=2000, loopCount=1 }
    local sprite   = display.newSprite(hitSheet, seqData)

    sprite.anchorX, sprite.anchorY = 0.5, 0.75
    sprite.x, sprite.y = x, y
    sprite:scale(hitEffectScale, hitEffectScale)
    display.getCurrentStage():insert(sprite)
    sprite:toFront()
    sprite:play()

    sprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if sprite.removeSelf then sprite:removeSelf() end
            if callback then callback() end
        end
    end)
end

--------------------------------------------------
-- Função auxiliar: shakeTarget
--------------------------------------------------

local function shakeTarget(targetGroup)
    local origX, origY = targetGroup.x, targetGroup.y
    local shakeDist    = 5
    local shakeTime    = 50

    transition.to(targetGroup, {
        time = shakeTime,
        x    = origX + shakeDist,
        onComplete = function()
            transition.to(targetGroup, {
                time = shakeTime,
                x    = origX - shakeDist,
                onComplete = function()
                    transition.to(targetGroup, {
                        time = shakeTime,
                        x    = origX,
                    })
                end
            })
        end
    })
end

--------------------------------------------------
-- Função principal: zoom in, ação contínua,
-- overlay escuro com fade, overlay animado com fade,
-- hit, limpa e zoom out
--------------------------------------------------
function kotoamatsukami.attack(attacker, dummyTarget, battleFunctions, targetSlot, callback)
    local cardGroup      = attacker.group or attacker
    local enemyFormation = attacker.isOpponent and _G.playerFormationData or _G.opponentFormationData
    local center         = attacker.isOpponent and _G.playerFormationCenter or _G.opponentFormationCenter
    local atkVal         = tonumber(attacker.atk) or 0
    local damage         = math.max(1, math.floor(atkVal * 0.45))

    -- 1) Sem gráfico: aplica dano direto
    if not cardGroup or not center then
        for slot = 1, 6 do
            local tgt = enemyFormation[slot]
            if type(tgt) == "table" then
                battleFunctions.applyDamage(attacker, tgt, damage, slot)
                if tgt.group then
                    shakeTarget(tgt.group)
                end
            end
        end
        if callback then callback() end
        return
    end

    -- 2) Zoom in no atacante
    transition.to(cardGroup, {
        time       = 150,
        xScale     = 1.2,
        yScale     = 1.2,
        transition = easing.outQuad,
        onComplete = function()
            -- 3) Cria overlay preto semi-transparente cobrindo toda a tela
            local overlayRect = display.newRect(
                display.contentCenterX,
                display.contentCenterY,
                display.actualContentWidth,
                display.actualContentHeight
            )
            overlayRect:setFillColor(0)
            overlayRect.alpha = 0
            display.getCurrentStage():insert(overlayRect)

            -- fade in/out do overlayRect em sincronia com a animação
            local overlayLoops     = 6
            local overlayFadeTime  = 500
            local overlayTotalTime = overlayLoops * overlayFadeTime
            transition.to(overlayRect, {
                alpha = 0.5,
                time  = overlayFadeTime
            })
            transition.to(overlayRect, {
                alpha = 0,
                time  = overlayFadeTime,
                delay = overlayTotalTime - overlayFadeTime
            })

            -- 4) Inicia ação contínua no atacante
            local actionSprite = createActionSprite(cardGroup)

            -- 5) Overlay animado na formação
            showOverlayAnimationAtPosition(center.x, center.y, function()
                -- 6) Hit animado no centro da formação
                showHitAtPosition(center.x, center.y, function()
                    -- interrompe e remove ação contínua
                    if actionSprite and actionSprite.removeSelf then
                        actionSprite:removeSelf()
                    end
                    -- remove overlay escuro (já em fade out)
                    if overlayRect and overlayRect.removeSelf then
                        overlayRect:removeSelf()
                    end

                    -- 7) Aplica dano a todo o time e provoca um tremor em cada carta
                    for slot=1,6 do
                        local tgt = enemyFormation[slot]
                        if type(tgt)=="table" then
                            -- aplica dano
                            battleFunctions.applyDamage(attacker, tgt, damage, slot)
                            -- tremor
                            if tgt.group then shakeTarget(tgt.group) end

                                if math.random() < 0.10 then
                                    _G.manageCardTurn(tgt, "block", 1)
                                end
                            end
                        end

                    -- 8) Zoom out no atacante
                    transition.to(cardGroup, {
                        time       = 150,
                        xScale     = 1.0,
                        yScale     = 1.0,
                        transition = easing.inOutQuad,
                        onComplete = function()
                            if callback then callback() end
                        end
                    })
                end)
            end)
        end
    })
end

return kotoamatsukami
