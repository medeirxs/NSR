-- hooks/basicAttacks/all_team_attack.lua

-- Hook de ataque em área: zoom in no atacante, animação de ação contínua,
-- overlay escuro + overlay animado + hit no centro da formação e aplica dano a todos

local all_team_attack = {}

-- Escalas responsivas
local designWidth       = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth
local hitEffectScale    = 8.0 * deviceScaleFactor
local overlayScale      = 3.0 * deviceScaleFactor
local actionScale       = 2.5 * deviceScaleFactor

--------------------------------------------------
-- Função auxiliar: createActionSprite
-- Exibe uma animação de ação sobre o atacante em loop contínuo
--------------------------------------------------
local function createActionSprite(cardGroup)
    local sheetOptions = {
        frames = {
            { x = 124, y = 106, width = 18,  height = 18 },
            { x = 714, y = 70,  width = 54,  height = 54 },
            { x = 456, y = 2,   width = 92,  height = 96 },
            { x = 714, y = 2,   width = 66,  height = 82 },
            { x = 630, y = 2,   width = 86,  height = 82 },
            { x = 278, y = 2,   width = 80,  height = 100 },
            { x = 202, y = 2,   width = 74,  height = 102 },
            { x = 550, y = 2,   width = 78,  height = 90 },
            { x = 124, y = 2,   width = 76,  height = 102 },
            { x = 360, y = 2,   width = 94,  height = 98 },
            { x = 2,   y = 2,   width = 120, height = 120 },
            { x = 770, y = 70,  width = 46,  height = 46 },
        }
    }
    local actionSheet = graphics.newImageSheet("assets/7effect/action_25.png", sheetOptions)
    local seqData     = { name="action", start=1, count=12, time=400, loopCount=0 }  -- 0 = loop infinito
    local sprite      = display.newSprite(actionSheet, seqData)

    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = 0, 0.3
    sprite.alpha                   = 0.5
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
            { x=   1, y=   1, width=640, height=360 },
            { x= 643, y=   1, width=640, height=360 },
            { x=   1, y= 363, width=640, height=360 },
            { x= 643, y= 363, width=640, height=360 },
            { x=   1, y= 725, width=640, height=360 },
            { x= 643, y= 725, width=640, height=360 },
            { x=1285, y=   1, width=640, height=360 },
            { x=1285, y= 363, width=640, height=360 },
        }
    }
    local overlaySheet = graphics.newImageSheet("assets/7effect/kirin.png", sheetOptions)
    local seqData      = { name="overlay", start=1, count=8, time=500, loopCount=6 }
    local sprite       = display.newSprite(overlaySheet, seqData)

    -- fade in / fade out do sprite de overlay
    local totalTime = seqData.time * seqData.loopCount
    local fadeTime  = seqData.time

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
            { x=   1, y=   1, width=  42, height=  72 },  -- hit_00
            { x=  45, y=   1, width=  74, height= 128 },  -- hit_01
            { x= 121, y=   1, width= 114, height= 134 },  -- hit_02
            { x=   1, y= 137, width= 120, height= 138 },  -- hit_03
            { x= 123, y= 137, width= 114, height= 136 },  -- hit_04
            { x= 237, y=   1, width= 110, height= 130 },  -- hit_05
            { x= 239, y= 133, width=  98, height= 132 },  -- hit_06
            { x= 349, y=   1, width=  76, height= 118 },  -- hit_07
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/hit_25.png", sheetOptions)
    local seqData  = { name="hit", start=1, count=8, time=500, loopCount=1 }
    local sprite   = display.newSprite(hitSheet, seqData)

    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = x, y  - 200
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
-- Função principal: zoom in, ação contínua,
-- overlay escuro com fade, overlay animado com fade,
-- hit, limpa e zoom out
--------------------------------------------------
function all_team_attack.attack(attacker, dummyTarget, battleFunctions, targetSlot, callback)
    local cardGroup      = attacker.group or attacker
    local enemyFormation = attacker.isOpponent and _G.playerFormationData or _G.opponentFormationData
    local center         = attacker.isOpponent and _G.playerFormationCenter or _G.opponentFormationCenter
    local atkVal         = tonumber(attacker.atk) or 0
    local damage         = math.max(1, math.floor(atkVal * 0.45))

    -- 1) Sem gráfico: aplica dano direto
    if not cardGroup or not center then
        for slot=1,6 do
            local tgt = enemyFormation[slot]
            if type(tgt)=="table" then
                battleFunctions.applyDamage(attacker, tgt, damage, slot)
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

                    -- 7) Aplica dano a todo o time
                    for slot=1,6 do
                        local tgt = enemyFormation[slot]
                        if type(tgt)=="table" then
                            battleFunctions.applyDamage(attacker, tgt, damage, slot)
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

return all_team_attack
