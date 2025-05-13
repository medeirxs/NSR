local punch = {}

-- Configurações de design e escala
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth and (display.actualContentWidth / designWidth) or 1

-- Parâmetros do ataque (ajuste conforme necessário)
local baseDamageMultiplier = 0.40

-- Controle de escala para a animação de transição
local transitionAnimScale = 0.5  -- ajuste esse valor conforme necessário

-- Controle de escala para a animação de hit
local hitAnimScale = 1.0  -- ajuste conforme necessário

-- Configuração da spritesheet de transição (dash)
local transitionSheetOptions = {
    frames = {
        { x = 1, y = 1,     width = 1280, height = 720 },
        { x = 1, y = 723,   width = 1280, height = 720 },
        { x = 1, y = 1445,  width = 1280, height = 720 },
        { x = 1, y = 2167,  width = 1280, height = 720 },
        { x = 1, y = 2889,  width = 1280, height = 720 },
        { x = 1, y = 3611,  width = 1280, height = 720 },
        { x = 1, y = 4333,  width = 1280, height = 720 },
        { x = 1, y = 5055,  width = 1280, height = 720 },
        { x = 1, y = 5777,  width = 1280, height = 720 },
        { x = 1, y = 6499,  width = 1280, height = 720 },
        { x = 1, y = 7221,  width = 1280, height = 720 },
        { x = 1, y = 7943,  width = 1280, height = 720 },
    }
}
local transitionSheet = graphics.newImageSheet("assets/7effect/dash.png", transitionSheetOptions)
local transitionSequenceData = {
    name = "moveAnim",
    start = 1,
    count = 12,
    time = 1500,  -- tempo total da animação (ajuste conforme necessário)
    loopCount = 1
}

-- Configuração da spritesheet de hit
local hitSheetOptions = {
    frames = {
        { x = 1,    y = 2167, width = 1280, height = 720 },
        { x = 1,    y = 2889, width = 1280, height = 720 },
        { x = 1,    y = 1,    width = 1280, height = 720 },
        { x = 1,    y = 723,  width = 1280, height = 720 },
        { x = 1,    y = 1445, width = 1280, height = 720 },
        { x = 1,    y = 3611, width = 1280, height = 720 },
    }
}
local hitSheet = graphics.newImageSheet("assets/7effect/punch_hit.png", hitSheetOptions)
local hitSequenceData = {
    name = "hitAnim",
    start = 1,
    count = 6,
    time = 400,  -- tempo da animação de hit
    loopCount = 1
}

--------------------------------------------------------------------------------
-- Função auxiliar: safeManageCardTurn (já definida acima)
--------------------------------------------------------------------------------
local function safeManageCardTurn(cardData, action, value)
    if battleFunctions and battleFunctions.manageCardTurn then
        battleFunctions.manageCardTurn(cardData, action, value)
    elseif _G.manageCardTurn then
        _G.manageCardTurn(cardData, action, value)
    else
        print("manageCardTurn function not defined, skipping block action.")
    end
end

--------------------------------------------------------------------------------
-- Função principal: punch.attack
-- Após aplicar o dano, executa o hit e o retorno da carta.
--------------------------------------------------------------------------------
function punch.attack(attacker, target, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * baseDamageMultiplier))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback then callback() end
        return
    end

    local parent = cardGroup.parent
    local origX, origY = cardGroup.x, cardGroup.y
    local origScaleX, origScaleY = cardGroup.xScale or 1, cardGroup.yScale or 1

    -- Zoom in: aumenta a escala da carta antes da transição
    transition.to(cardGroup, {
        time = 100,
        xScale = origScaleX * 1.2,
        yScale = origScaleY * 1.2,
        transition = easing.inOutQuad,
        onComplete = function()
            -- Após o zoom in, inicia a transição de movimento
            -- Cria o sprite de transição para a ida
            local transSprite = display.newSprite(transitionSheet, transitionSequenceData)
            transSprite.anchorX = cardGroup.anchorX or 0.5
            transSprite.anchorY = cardGroup.anchorY or 0.5
            transSprite.x = cardGroup.x
            transSprite.y = cardGroup.y
            parent:insert(transSprite)
            transSprite:toFront()
            local dashScale = (transitionAnimScale * deviceScaleFactor) or 1
            transSprite:scale(dashScale, dashScale)
            transSprite:play()

            -- Oculta a carta original
            cardGroup.isVisible = false

            -- Calcula o centro do alvo usando contentBounds
            local targetGroup = target.group or target
            if not targetGroup then
                local atkValue = tonumber(attacker.atk) or 0
                local damage = math.max(1, math.floor(atkValue * baseDamageMultiplier))
                battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                transSprite:removeSelf()
                cardGroup.isVisible = true
                if callback then callback() end
                return
            end

            local bounds = targetGroup.contentBounds
            local globalTargetX = (bounds.xMin + bounds.xMax) * 0.5
            local globalTargetY = (bounds.yMin + bounds.yMax) * 0.5
            local localTargetX, localTargetY = parent:contentToLocal(globalTargetX, globalTargetY)

            -- Transição: move o sprite de transição até o centro do alvo
            transition.to(transSprite, {
                time = 500,
                x = localTargetX,
                y = localTargetY,
                transition = easing.linear,
                onComplete = function()
                    transSprite:removeSelf()
                    -- Reaparece a carta original no destino com fade in de 100ms
                    cardGroup.x = localTargetX
                    local offsetY = 120
                    if attacker.isOpponent then
                        offsetY = -120
                    end
                    cardGroup.y = localTargetY + offsetY
                    cardGroup.alpha = 0
                    cardGroup.isVisible = true
                    transition.to(cardGroup, {
                        time = 100,
                        alpha = 1,
                        onComplete = function()
                            -- Garante que a carta fique em primeiro plano
                            cardGroup:toFront()
                            parent:insert(cardGroup)
                            -- Exibe a animação de hit sobre o alvo
                            local hitSprite = display.newSprite(hitSheet, hitSequenceData)
                            hitSprite.anchorX = targetGroup.anchorX or 0.5
                            hitSprite.anchorY = targetGroup.anchorY or 0.5
                            hitSprite.x = localTargetX
                            hitSprite.y = localTargetY
                            parent:insert(hitSprite)
                            hitSprite:toFront()
                            hitSprite:scale(hitAnimScale or 1, hitAnimScale or 1)
                            hitSprite:play()
                            hitSprite:addEventListener("sprite", function(event)
                                if event.phase == "ended" then
                                    hitSprite:removeSelf()
                                    -- Fade out da carta original antes de aplicar o dano
                                    transition.to(cardGroup, {
                                        time = 100,
                                        alpha = 0,
                                        onComplete = function()
                                            local atkValue = tonumber(attacker.atk) or 0
                                            local damage = math.max(1, math.floor(atkValue * baseDamageMultiplier))
                                            battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                                            
                                            -- Cria o sprite de transição para o retorno
                                            local returnSprite = display.newSprite(transitionSheet, transitionSequenceData)
                                            returnSprite.anchorX = cardGroup.anchorX or 0.5
                                            returnSprite.anchorY = cardGroup.anchorY or 0.5
                                            returnSprite.x = cardGroup.x
                                            returnSprite.y = cardGroup.y
                                            parent:insert(returnSprite)
                                            returnSprite:toFront()
                                            returnSprite:scale(dashScale, dashScale)
                                            returnSprite:play()
                                            
                                            -- Zoom out: retorna a carta à escala original no retorno
                                            transition.to(cardGroup, {
                                                time = 100,
                                                xScale = origScaleX,
                                                yScale = origScaleY,
                                                transition = easing.inOutQuad
                                            })
                                            
                                            -- Oculta a carta original durante o retorno
                                            cardGroup.isVisible = false
                                            
                                            transition.to(returnSprite, {
                                                time = 400,
                                                x = origX,
                                                y = origY,
                                                transition = easing.linear,
                                                onComplete = function()
                                                    returnSprite:removeSelf()
                                                    cardGroup.x = origX
                                                    cardGroup.y = origY
                                                    cardGroup.alpha = 1
                                                    cardGroup.isVisible = true
                                                    parent:insert(cardGroup)
                                                    if callback then callback() end
                                                end
                                            })
                                        end
                                    })
                                end
                            end)
                        end
                    })
                end
            })
        end
    })

end

return punch
