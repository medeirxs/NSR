local confusion = {}

-- Configurações de design e escala
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth and (display.actualContentWidth / designWidth) or 1

-- Parâmetros do ataque (ajuste conforme necessário)
local baseDamageMultiplier = 0.70 * deviceScaleFactor
local hitAnimScale = 1.8 * deviceScaleFactor
local zoomInAnimScale = 0.5 * deviceScaleFactor

-- Configuração da spritesheet de zoom in (efeito extra)
local zoomInSheetOptions = {
    frames = {
      { x =   1,   y =    1, width = 768, height = 768 },  -- .-58-Sem-T_tulo_20250507064101
      { x =   1,   y =    1, width = 768, height = 768 },  -- .-58-Sem-T_tulo_20250507064101
      { x =   1,   y =    1, width = 768, height = 768 },  -- .-58-Sem-T_tulo_20250507064101
      { x =   1,   y =    1, width = 768, height = 768 },  -- .-58-Sem-T_tulo_20250507064101
      { x = 771,   y =    1, width = 768, height = 768 },  -- .-58-Sem-T_tulo_20250507064200
      { x =   1,   y =  771, width = 768, height = 768 },  -- .-58-Sem-T_tulo_20250507064315
      { x = 771,   y =  771, width = 768, height = 768 },  -- .-58-Sem-T_tulo_20250507064452
      { x = 1541,  y =    1, width = 768, height = 768 },  -- .-58-Sem-T_tulo_20250507064828
      { x = 1541,  y =  771, width = 768, height = 768 },  -- .-58-Sem-T_tulo_20250507065053
      { x =   1,   y = 1541, width = 768, height = 768 },  -- .-58-Sem-T_tulo_20250507065158
    }
}
local zoomInSheet = graphics.newImageSheet("assets/7effect/action_112.png", zoomInSheetOptions)
local zoomInSequenceData = {
    name = "zoomInAnim",
    start = 1,
    count = 10,
    time = 700,  -- tempo total da animação de zoom in
    loopCount = 1
}

-- Configuração da spritesheet de hit
local hitSheetOptions = {
    frames = {
      { x =   1,   y =    1, width = 640, height = 360 },
      { x = 643,   y =    1, width = 640, height = 360 },
      { x =   1,   y =  363, width = 640, height = 360 },
      { x = 643,   y =  363, width = 640, height = 360 },
      { x =   1,   y =  725, width = 640, height = 360 },
      { x = 643,   y =  725, width = 640, height = 360 },
      { x =   1,   y = 1087, width = 640, height = 360 },
      { x = 643,   y = 1087, width = 640, height = 360 },
      { x = 1285,  y =    1, width = 640, height = 360 },
      { x = 1285,  y =  363, width = 640, height = 360 },
      { x = 1285,  y =  725, width = 640, height = 360 },
      { x = 1285,  y = 1087, width = 640, height = 360 },
    }
}
local hitSheet = graphics.newImageSheet("assets/7effect/bullet_117.png", hitSheetOptions)
local hitSequenceData = {
    name = "hitAnim",
    start = 1,
    count = 12,
    time = 1300,  -- tempo da animação de hit
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
-- Função principal: confusion.attack
-- A carta permanece em sua posição original, executa zoom in (com animação do spritesheet),
-- retorna à escala original (zoom out) e, em seguida, exibe a animação de hit sobre o alvo.
--------------------------------------------------------------------------------
function confusion.attack(attacker, target, battleFunctions, targetSlot, callback)
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
                        hitSprite.anchorX = 0.47
                        hitSprite.anchorY = 0.5
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
                            local damage = math.max(1, math.floor(atkValue * 0.50))
                            battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                            local targetData = target.cardData or target
                            if targetData then
                            end
                            if callback then callback() end
                        end)
                    end
                })
            end)
        end
    })
end

return confusion
