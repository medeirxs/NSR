-- hooks/basicAttacks/kotoamatsukami.lua

-- Hook de ataque em área: zoom in no atacante, animação de ação contínua,
-- overlay escuro + overlay animado + hit no centro da formação e aplica dano a todos

local kotoamatsukami = {}

-- Escalas responsivas
local designWidth       = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth
local hitEffectScale    = 8.0 * deviceScaleFactor
local overlayScale      = 3.0 * deviceScaleFactor
local actionScale       = 1.5 * deviceScaleFactor

--------------------------------------------------
-- Função auxiliar: createActionSprite
-- Exibe uma animação de ação sobre o atacante em loop contínuo
--------------------------------------------------
local function createActionSprite(cardGroup)
    local sheetOptions = {
        frames = {
            { x = 1208, y = 2, width = 132, height = 124 },
            { x = 1208, y = 136, width = 110, height = 118 },
            { x = 1208, y = 256, width = 100, height = 112 },
            { x = 2, y = 2, width = 400, height = 158 },
            { x = 806, y = 318, width = 400, height = 156 },
            { x = 806, y = 160, width = 400, height = 156 },
            { x = 806, y = 2, width = 400, height = 156 },
            { x = 404, y = 318, width = 400, height = 156 },
            { x = 404, y = 160, width = 400, height = 156 },
            { x = 404, y = 2, width = 400, height = 156 },
            { x = 2, y = 162, width = 400, height = 156 },
            { x = 2, y = 320, width = 400, height = 154 },
            { x = 1320, y = 136, width = 1, height = 1 },
            { x = 1320, y = 136, width = 1, height = 1 },
        }
    }
    local actionSheet = graphics.newImageSheet("assets/7effect/action_39.png", sheetOptions)
    local seqData     = { name="action", start=1, count=14, time= 1200, loopCount= 1 }  -- 0 = loop infinito
    local sprite      = display.newSprite(actionSheet, seqData)

    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = 0, 0.3
    sprite.alpha                   = 1.5
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
            { x = 568, y = 3, width = 559, height = 463 },
            { x = 1133, y = 3, width = 559, height = 463 },
            { x = 1698, y = 3, width = 559, height = 463 },
            { x = 2263, y = 3, width = 559, height = 463 },
            { x = 3, y = 472, width = 559, height = 463 },
            { x = 568, y = 472, width = 559, height = 463 },
            { x = 1133, y = 472, width = 559, height = 463 },
            { x = 1698, y = 472, width = 559, height = 463 },
            { x = 2263, y = 472, width = 559, height = 463 },
            { x = 3, y = 941, width = 559, height = 463 },
            { x = 568, y = 941, width = 559, height = 463 },
            { x = 1133, y = 941, width = 559, height = 463 },
            { x = 1698, y = 941, width = 559, height = 463 },
            { x = 2263, y = 941, width = 559, height = 463 },
            { x = 3, y = 1410, width = 559, height = 463 },
            { x = 568, y = 1410, width = 559, height = 463 },
            { x = 1133, y = 1410, width = 559, height = 463 },
            { x = 1698, y = 1410, width = 559, height = 463 },
            { x = 2263, y = 1410, width = 559, height = 463 },
            { x = 3, y = 1879, width = 559, height = 463 },
            { x = 568, y = 1879, width = 559, height = 463 },
            { x = 1133, y = 1879, width = 559, height = 463 },
            { x = 1698, y = 1879, width = 559, height = 463 },
            { x = 2263, y = 1879, width = 559, height = 463 },
            { x = 3, y = 2348, width = 559, height = 463 },
            { x = 568, y = 2348, width = 559, height = 463 },
            { x = 1133, y = 2348, width = 559, height = 463 },
            { x = 1698, y = 2348, width = 559, height = 463 },
            { x = 2263, y = 2348, width = 559, height = 463 },
            { x = 2828, y = 3, width = 559, height = 463 },
            { x = 2828, y = 472, width = 559, height = 463 },
            { x = 2828, y = 941, width = 559, height = 463 },
            { x = 2828, y = 1410, width = 559, height = 463 },
            { x = 2828, y = 1879, width = 559, height = 463 },
            { x = 2828, y = 2348, width = 559, height = 463 },
        }
    }
    local overlaySheet = graphics.newImageSheet("assets/7effect/kotoamatsukami.png", sheetOptions)
    local seqData      = { name="overlay", start=1, count=36, time=2500, loopCount=1 }
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
            { x=   1, y=   1, width=138, height= 76 },  -- hit_00-_1_
            { x=   1, y=  79, width=138, height= 76 },  -- hit_01-_1_
            { x= 141, y=   1, width=138, height= 78 },  -- hit_02-_1_
            { x= 141, y=  81, width=126, height= 76 },  -- hit_03-_1_
            { x=   1, y= 159, width=114, height= 66 },  -- hit_04-_1_
            { x= 117, y= 159, width=112, height= 32 },  -- hit_05-_1_
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/hit_24.png", sheetOptions)
    local seqData  = { name="hit", start=1, count=8, time=500, loopCount=1 }
    local sprite   = display.newSprite(hitSheet, seqData)

    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = x, y
    sprite:scale(hitEffectScale * 1.2, hitEffectScale)
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

                                if math.random() < 0.05 then
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
