local red_gate = {}

-- Configurações de design e escala
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth and (display.actualContentWidth / designWidth) or 1

-- Parâmetros do ataque (ajuste conforme necessário)
local baseDamageMultiplier = 0.70
local hitAnimScale = 1.4 * deviceScaleFactor
local zoomInAnimScale = 3 * deviceScaleFactor -- Controle de escala para a animação de zoom in

-- Configuração da spritesheet de zoom in (efeito extra)
local zoomInSheetOptions = {
    frames = {
        { x = 1,   y = 1,   width = 220, height = 82 },
        { x = 1,   y = 85,  width = 220, height = 82 },
        { x = 223, y = 1,   width = 216, height = 82 },
        { x = 223, y = 85,  width = 214, height = 82 },
        { x = 1,   y = 169, width = 206, height = 82 },
        { x = 209, y = 169, width = 206, height = 82 },
        { x = 1,   y = 253, width = 204, height = 82 },
        { x = 207, y = 253, width = 204, height = 82 },
        { x = 1,   y = 337, width = 202, height = 80 },
        { x = 205, y = 337, width = 202, height = 80 },
        { x = 441, y = 1,   width = 198, height = 78 },
    }
}
local zoomInSheet = graphics.newImageSheet("assets/7effect/action_42.png", zoomInSheetOptions)
local zoomInSequenceData = {
    name = "zoomInAnim",
    start = 1,
    count = 11,
    time = 800,  -- tempo total da animação de zoom in
    loopCount = 1
}

-- Configuração da spritesheet de hit
local hitSheetOptions = {
    frames = {
        { x = 1,    y = 1,    width = 400, height = 1500 },
        { x = 403,  y = 1,    width = 400, height = 1500 },
        { x = 805,  y = 1,    width = 400, height = 1500 },
        { x = 1207, y = 1,    width = 400, height = 1500 },
        { x = 1609, y = 1,    width = 400, height = 1500 },
        { x = 2011, y = 1,    width = 400, height = 1500 },
        { x = 2413, y = 1,    width = 400, height = 1500 },
        { x = 2815, y = 1,    width = 400, height = 1500 },
        { x = 1,    y = 1503, width = 400, height = 1500 },
        { x = 403,  y = 1503, width = 400, height = 1500 },
        { x = 805,  y = 1503, width = 400, height = 1500 },
        { x = 1207, y = 1503, width = 400, height = 1500 },
        { x = 1609, y = 1503, width = 400, height = 1500 },
        { x = 2011, y = 1503, width = 400, height = 1500 },
        { x = 2413, y = 1503, width = 400, height = 1500 },
        { x = 2815, y = 1503, width = 400, height = 1500 },
        { x = 3217, y = 1,    width = 400, height = 1500 },
        { x = 3217, y = 1503, width = 400, height = 1500 },
        { x = 1,    y = 3005, width = 400, height = 1500 },
        { x = 403,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },    
        { x = 805,  y = 3005, width = 400, height = 1500 },    
        { x = 805,  y = 3005, width = 400, height = 1500 },    
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },
        { x = 805,  y = 3005, width = 400, height = 1500 },       
    }
}
local hitSheet = graphics.newImageSheet("assets/7effect/bullet_105.png", hitSheetOptions)
local hitSequenceData = {
    name = "hitAnim",
    start = 1,
    count = 45,
    time = 1000,  -- tempo da animação de hit
    loopCount = 1
}

--------------------------------------------------------------------------------
-- Função auxiliar: safeManageCardTurn (já definida anteriormente)
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
-- Função principal: red_gate.attack
-- A carta permanece em sua posição original, executa zoom in (com animação do spritesheet),
-- retorna à escala original (zoom out) e, em seguida, exibe a animação de hit sobre o alvo.
--------------------------------------------------------------------------------
function red_gate.attack(attacker, target, battleFunctions, targetSlot, callback)
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
    local originalScaleX = cardGroup.xScale or 1
    local originalScaleY = cardGroup.yScale or 1

    -- Zoom In: aumenta a escala para 1.5× em 100ms
    transition.to(cardGroup, {
        time = 100,
        xScale = originalScaleX * 1.5,
        yScale = originalScaleY * 1.5,
        transition = easing.inOutQuad,
        onComplete = function()
            -- Reproduz a animação de zoom in com spritesheet durante 800ms
            local zoomInSprite = display.newSprite(zoomInSheet, zoomInSequenceData)
            zoomInSprite.anchorX = cardGroup.anchorX or 0.5
            zoomInSprite.anchorY = cardGroup.anchorY or 0.5
            zoomInSprite.x = cardGroup.x
            zoomInSprite.y = cardGroup.y
            zoomInSprite:scale(zoomInAnimScale, zoomInAnimScale)  -- Controle de escala adicionado
            parent:insert(zoomInSprite)
            zoomInSprite:toFront()
            zoomInSprite:play()
            timer.performWithDelay(zoomInSequenceData.time, function()
                if zoomInSprite and zoomInSprite.removeSelf then
                    zoomInSprite:removeSelf()
                end
                -- Zoom Out: retorna à escala original em 100ms
                transition.to(cardGroup, {
                    time = 100,
                    xScale = originalScaleX,
                    yScale = originalScaleY,
                    transition = easing.inOutQuad,
                    onComplete = function()
                        -- Exibe a animação de hit sobre o alvo
                        local targetGroup = target.group or target
                        local bounds
                        if targetGroup and targetGroup.contentBounds then
                            bounds = targetGroup.contentBounds
                        else
                            bounds = { xMin = target.x, xMax = target.x, yMin = target.y, yMax = target.y }
                        end
                        local globalTargetX = (bounds.xMin + bounds.xMax) * 0.5
                        local globalTargetY = (bounds.yMin + bounds.yMax) * 0.5

                        local hitSprite = display.newSprite(hitSheet, hitSequenceData)
                        hitSprite.anchorX = 0.5
                        hitSprite.anchorY = 0.9
                        hitSprite:scale(hitAnimScale or 1, hitAnimScale or 1)

                        if targetGroup.insert then
                            -- Converte as coordenadas globais para o sistema do grupo da carta
                            local localTargetX, localTargetY = targetGroup:contentToLocal(globalTargetX, globalTargetY)
                            hitSprite.x = localTargetX
                            hitSprite.y = localTargetY
                            targetGroup:insert(hitSprite)
                        else
                            local localTargetX, localTargetY = parent:contentToLocal(globalTargetX, globalTargetY)
                            hitSprite.x = localTargetX
                            hitSprite.y = localTargetY
                            parent:insert(hitSprite)
                        end

                        hitSprite:toFront()
                        hitSprite:play()
                        timer.performWithDelay(hitSequenceData.time, function()
                            if hitSprite and hitSprite.removeSelf then
                                hitSprite:removeSelf()
                            end
                            local atkValue = tonumber(attacker.atk) or 0
                            local damage = math.max(1, math.floor(atkValue * baseDamageMultiplier))
                            battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                            local targetData = target.cardData or target
                            if targetData and math.random() <= 0.3 then
                                safeManageCardTurn(targetData, "block", 1)
                            end                            
                            if callback then callback() end
                        end)
                    end
                })
            end)
        end
    })
end

return red_gate
