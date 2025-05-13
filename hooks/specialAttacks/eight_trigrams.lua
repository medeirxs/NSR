-- hooks/basicAttacks/palmadas.lua

-- Hook básico: o atacante se move até o centro da formação inimiga,
-- faz um zoom in/out, aplica dano a todas as cartas dessa formação e retorna.

local palmadas = {}

-- Escalas responsivas
local designWidth       = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth
local actionScale = 3.0 *deviceScaleFactor

-- Função auxiliar: exibe a animação principal de "action" sobre o atacante
local function playActionAnimation(cardGroup, onComplete)
    local sheetOptions = {
        frames = {
            { x = 1,   y = 1,   width = 274, height = 194 },
            { x = 277, y = 1,   width = 280, height = 192 },
            { x = 559, y = 1,   width = 280, height = 198 },
            { x = 1,   y = 201, width = 280, height = 194 },
            { x = 283, y = 201, width = 280, height = 200 },
            { x = 565, y = 201, width = 280, height = 200 },
            { x = 1,   y = 403, width = 280, height = 200 },
            { x = 283, y = 403, width = 280, height = 200 },
            { x = 565, y = 403, width = 280, height = 202 },
            { x = 1,   y = 607, width = 280, height = 202 },
            { x = 283, y = 607, width = 280, height = 202 },
            { x = 565, y = 607, width = 280, height = 200 },
            { x = 847, y = 1,   width = 280, height = 200 },
            { x = 847, y = 203, width = 280, height = 202 },
            { x = 847, y = 407, width = 280, height = 202 },
        }
    }
    local actionSheet = graphics.newImageSheet("assets/7effect/bullet_44_1.png", sheetOptions)
    local seqData     = { name="action", start=1, count=15, time=2000, loopCount=1 }
    local sprite      = display.newSprite(actionSheet, seqData)

    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = 0, 0
    sprite:scale(actionScale, actionScale)
    cardGroup:insert(sprite)
    sprite:toFront()
    sprite:play()

    sprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if sprite.removeSelf then sprite:removeSelf() end
            if onComplete then onComplete() end
        end
    end)
end

-- Função auxiliar: exibe a animação secundária de "action" sobre o atacante
local function playActionAnimationAbove(cardGroup)
    local sheetOptions = {
        frames = {
            { x = 1,    y = 1,   width = 148, height = 102 },
            { x = 151,  y = 1,   width = 222, height = 152 },
            { x = 375,  y = 1,   width = 294, height = 202 },
            { x = 1,    y = 205, width = 314, height = 236 },
            { x = 317,  y = 205, width = 320, height = 248 },
            { x = 1,    y = 455, width = 320, height = 246 },
            { x = 323,  y = 455, width = 320, height = 244 },
            { x = 671,  y = 1,   width = 320, height = 246 },
            { x = 645,  y = 249, width = 320, height = 246 },
            { x = 645,  y = 497, width = 320, height = 246 },
        }
    }
    local actionSheet = graphics.newImageSheet("assets/7effect/bullet_44_2.png", sheetOptions)
    local seqData     = { name="actionAbove", start=1, count=10, time=2000, loopCount=1 }
    local sprite      = display.newSprite(actionSheet, seqData)

    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = 0, 0
    sprite:scale(actionScale, actionScale)
    cardGroup:insert(sprite)
    sprite:toFront()
    sprite:play()

    sprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if sprite.removeSelf then sprite:removeSelf() end
        end
    end)
end

function palmadas.attack(attacker, dummyTarget, battleFunctions, targetSlot, callback)
    local cardGroup       = attacker.group or attacker
    local enemyFormation  = attacker.isOpponent and _G.playerFormationData or _G.opponentFormationData
    local formationCenter = attacker.isOpponent and _G.playerFormationCenter or _G.opponentFormationCenter
    local atkVal          = tonumber(attacker.atk) or 0
    local damage          = math.max(1, math.floor(atkVal * 2.5))

    -- Se não há gráfico ou centro, aplica dano direto e sai
    if not cardGroup or not formationCenter then
        for slot, tgt in pairs(enemyFormation) do
            if type(tgt) == "table" then
                battleFunctions.applyDamage(attacker, tgt, damage, slot)
            end
        end
        if callback then callback() end
        return
    end

    -- 1) guarda parent e posição global original
    local origParent           = cardGroup.parent
    local origGlobalX, origGlobalY = cardGroup:localToContent(0, 0)

    -- 2) reparent para o stage, mantendo posição global
    local stage = display.getCurrentStage()
    stage:insert(cardGroup)
    cardGroup.x, cardGroup.y = origGlobalX, origGlobalY
    cardGroup:toFront()

    -- 3) move para o centro da formação inimiga (coords globais)
    transition.to(cardGroup, {
        time       = 300,
        x          = formationCenter.x,
        y          = formationCenter.y,
        transition = easing.inOutQuad,
        onComplete = function()
            -- 4) zoom in
            transition.to(cardGroup, {
                time       = 150,
                xScale     = 1.2,
                yScale     = 1.2,
                transition = easing.outQuad,
                onComplete = function()
                    -- 5) inicia as duas animações de action em paralelo
                    playActionAnimation(cardGroup, function()
                        -- após a principal terminar, segue com zoom out e retorno
                        transition.to(cardGroup, {
                            time       = 150,
                            xScale     = 1.0,
                            yScale     = 1.0,
                            transition = easing.inQuad,
                            onComplete = function()
                                -- 6) aplica dano a toda a formação inimiga
                                local targetIsOpponent = not attacker.isOpponent
                                battleFunctions.applyDamageToFormation(attacker, targetIsOpponent, damage, { multiHit = true })
                                -- 7) retorna para a posição original global
                                transition.to(cardGroup, {
                                    time       = 300,
                                    x          = origGlobalX,
                                    y          = origGlobalY,
                                    transition = easing.inOutQuad,
                                    onComplete = function()
                                        -- 8) reparent de volta ao grupo original, convertendo coords
                                        local origLocalX, origLocalY = origParent:contentToLocal(origGlobalX, origGlobalY)
                                        origParent:insert(cardGroup)
                                        cardGroup.x, cardGroup.y = origLocalX, origLocalY
                                        if callback then callback() end
                                    end
                                })
                            end
                        })
                    end)
                    -- animação secundária, sem callback
                    playActionAnimationAbove(cardGroup)
                end
            })
        end
    })
end

return palmadas
