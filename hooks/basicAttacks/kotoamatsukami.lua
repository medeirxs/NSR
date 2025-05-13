local fireLiberation = {}

-- Variáveis de controle de escala (ajuste conforme necessário)
local attackerAnimScale = 1.7
local overlayAnimScale = 1.8   
local hitEffectScale = 1.0

--------------------------------------------------
-- Fase 3: Efeito de hit com tremor
local function showHitEffect(targetGroup, callback)
    local hitSheetOptions = {
        frames = {
          { x = 338, y = 778, width = 230, height = 338 },
          { x = 792, y = 2, width = 324, height = 406 },
          { x = 2, y = 394, width = 334, height = 418 },
          { x = 338, y = 394, width = 362, height = 382 },
          { x = 2, y = 2, width = 390, height = 390 },
          { x = 702, y = 678, width = 344, height = 356 },
          { x = 702, y = 340, width = 392, height = 336 },
          { x = 394, y = 2, width = 396, height = 336 },
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/hit_85_1.png", hitSheetOptions)
    local hitSequenceData = {
        name = "hit",
        start = 1,
        count = 8,
        time = 500,
        loopCount = 1
    }
    local hitSprite = display.newSprite(hitSheet, hitSequenceData)
    hitSprite.anchorX = 0.5
    hitSprite.anchorY = 0.5
    hitSprite.x = 0
    hitSprite.y = 0
    hitSprite:scale(hitEffectScale, hitEffectScale)
    targetGroup:insert(hitSprite)
    hitSprite:toFront()
    hitSprite:play()
    hitSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if hitSprite.removeSelf then hitSprite:removeSelf() end
            local origX = targetGroup.x
            transition.to(targetGroup, { x = origX + 5, time = 50, onComplete = function()
                transition.to(targetGroup, { x = origX - 5, time = 50, onComplete = function()
                    transition.to(targetGroup, { x = origX, time = 50, onComplete = function()
                        if callback then callback() end
                    end})
                end})
            end})
        end
    end)
end

--------------------------------------------------
-- Fase 1: Animação do atacante (zoom + spritesheet) com destaque
local function playAttackerAnimation(cardGroup, callback)
    local origX, origY = cardGroup.x, cardGroup.y

    -- Cria um destaque (overlay amarelo) sobre o atacante
    local bounds = cardGroup.contentBounds
    local highlight = display.newRect(cardGroup.parent, (bounds.xMin + bounds.xMax) * 0.5,
                                      (bounds.yMin + bounds.yMax) * 0.5,
                                      bounds.xMax - bounds.xMin,
                                      bounds.yMax - bounds.yMin)
    highlight:setFillColor(1, 1, 0)  -- Amarelo
    highlight.alpha = 0.5
    cardGroup.parent:insert(highlight)
    highlight:toFront()

    -- Traz o grupo do atacante para a frente (para ficar acima do overlay escuro)
    cardGroup:toFront()
    print("playAttackerAnimation: Iniciando zoom do atacante.")
    transition.to(cardGroup, {
        time = 1000,
        xScale = attackerAnimScale,
        yScale = attackerAnimScale,
        transition = easing.outQuad,
        onComplete = function()
            local attackerSheetOptions = {
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
            local attackerSheet = graphics.newImageSheet("assets/7effect/action_39.png", attackerSheetOptions)
            local attackerSequenceData = {
                name = "attackAnim",
                start = 1,
                count = 14,
                time = 1200,
                loopCount = 1
            }
            local attackerSprite = display.newSprite(attackerSheet, attackerSequenceData)
            attackerSprite.anchorX = 0.5
            attackerSprite.anchorY = 0.6
            attackerSprite.x = cardGroup.x
            attackerSprite.y = cardGroup.y
            attackerSprite:scale(attackerAnimScale, attackerAnimScale)
            -- Insere o sprite em um grupo que já esteja acima do overlay
            cardGroup.parent:insert(attackerSprite)
            attackerSprite:toFront()
            attackerSprite:play()
            attackerSprite:addEventListener("sprite", function(event)
                if event.phase == "ended" then
                    print("playAttackerAnimation: Animação do atacante terminou.")
                    if attackerSprite.removeSelf then attackerSprite:removeSelf() end
                    transition.to(cardGroup, {
                        time = 1000,
                        xScale = 1.0,
                        yScale = 1.0,
                        transition = easing.inQuad,
                        onComplete = function()
                            cardGroup.x = origX
                            cardGroup.y = origY
                            transition.to(highlight, { time = 500, alpha = 0, onComplete = function() 
                                if highlight.removeSelf then highlight:removeSelf() end 
                            end })
                            if callback then callback() end
                        end
                    })
                end
            end)
        end
    })
end
--------------------------------------------------
-- Fase 2: Animação de overlay sobre o grupo inimigo com fade in
local function playEnemyOverlay(enemyGroup, callback)
    local overlayExposure = 1.0  -- Controle de exposição/brilho (1.0 = normal)
    
    -- Se enemyGroup for nil, usamos o stage
    if not enemyGroup then
        print("playEnemyOverlay: enemyGroup é nil, usando stage como fallback.")
        enemyGroup = display.getCurrentStage()
    else
        print("playEnemyOverlay: enemyGroup encontrado, parent =", enemyGroup.parent)
    end
    
    local bounds = enemyGroup.contentBounds or { xMin = 0, xMax = display.contentWidth, yMin = 0, yMax = display.contentHeight }
    local centerX = (bounds.xMin + bounds.xMax) * 0.5
    local centerY = (bounds.yMin + bounds.yMax) * 0.5
    print("playEnemyOverlay: Calculated center:", centerX, centerY)
    
    local overlaySheetOptions = {
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
    
    local overlaySheet = graphics.newImageSheet("assets/7effect/kotoamatsukami.png", overlaySheetOptions)
    local overlaySequenceData = {
        name = "overlay",
        start = 1,
        count = 35,
        time = 2000,
        loopCount = 1
    }
    
    local overlaySprite = display.newSprite(overlaySheet, overlaySequenceData)
    overlaySprite.anchorX = 0.5
    overlaySprite.anchorY = 0.5
    overlaySprite.x = centerX 
    overlaySprite.y = centerY - 100
    overlaySprite:scale(overlayAnimScale, overlayAnimScale)
    overlaySprite.alpha = 0
    overlaySprite:setFillColor(1, 1, 1)  -- Exposição normal
    
    print("playEnemyOverlay: Iniciando fade in do overlay.")
    transition.to(overlaySprite, { alpha = 1, time = 500, onComplete = function()
        overlaySprite:play()
        print("playEnemyOverlay: Overlay animado iniciado.")
    end })
    
    -- Insere o overlaySprite diretamente no stage para garantir visibilidade
    display.getCurrentStage():insert(overlaySprite)
    overlaySprite:toFront()
    
    local callbackCalled = false
    local function safeCallback()
        if not callbackCalled then
            callbackCalled = true
            if callback then callback() end
        end
    end
    
    overlaySprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            print("playEnemyOverlay: Animação do overlay terminou.")
            if overlaySprite.removeSelf then overlaySprite:removeSelf() end
            safeCallback()
        end
    end)
    timer.performWithDelay(overlaySequenceData.time + 100, safeCallback)
end

--------------------------------------------------
-- Função de ataque com 3 fases: atacante, overlay e hit individual nos alvos.
function fireLiberation.attack(attacker, target, battleFunctions)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("fireLiberation: Objeto de display do atacante não encontrado. Aplicando dano sem animação.")
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * 0.45))
        local targetIndex = target.index or 1
        battleFunctions.applyDamage(attacker, target, damage, targetIndex)
        return
    end

    cardGroup:toFront()
    local darkOverlay = display.newRect(cardGroup.parent, display.contentCenterX, display.contentCenterY, display.actualContentWidth * 10, display.actualContentHeight * 10)
    darkOverlay:setFillColor(0, 0, 0)
    darkOverlay.alpha = 0
    cardGroup.parent:insert(darkOverlay)
    darkOverlay:toBack()
    transition.to(darkOverlay, { time = 500, alpha = 0.7 })

    print("fireLiberation: Iniciando animação do atacante.")
    playAttackerAnimation(cardGroup, function()
        print("fireLiberation: Animação do atacante concluída.")
        local enemyGroup = nil
        if battleFunctions.getEnemyGroup then
            enemyGroup = battleFunctions.getEnemyGroup(attacker)
        end
        if not enemyGroup then
            print("fireLiberation: Grupo inimigo não encontrado via battleFunctions; usando _G.opponentGridGroup")
            enemyGroup = _G.opponentGridGroup or display.getCurrentStage()
        end
        if enemyGroup then
            print("fireLiberation: Iniciando animação de overlay no grupo inimigo.")
            playEnemyOverlay(enemyGroup, function()
                transition.to(darkOverlay, {
                    time = 500,
                    alpha = 0,
                    onComplete = function()
                        if darkOverlay.removeSelf then darkOverlay:removeSelf() end
                        print("fireLiberation: Overlay escuro concluído. Iniciando efeitos de hit em cada inimigo.")
                        local atkValue = tonumber(attacker.atk) or 0
                        local damage = math.max(1, math.floor(atkValue * 0.45))
                        local opponents = {}
                        if battleFunctions.getOpponents then
                            opponents = battleFunctions.getOpponents(attacker)
                        else
                            opponents = _G.opponentFormation or {}
                        end
                        for i = 1, #opponents do
                            local enemy = opponents[i]
                            if enemy and tonumber(enemy.hp) > 0 then
                                local enemyGroup = enemy.group
                                if not enemyGroup then
                                    enemyGroup = gridSlotsOpponent[ enemy.index or i ]
                                    -- Se ainda não houver grupo e o índice for 1, use o _G.opponentGridGroup como fallback
                                    if not enemyGroup and ( (enemy.index or i) == 1 ) then
                                        enemyGroup = _G.opponentGridGroup
                                    end
                                end
                                if enemyGroup then
                                    print("fireLiberation: Exibindo efeito de hit no inimigo de index " .. (enemy.index or i))
                                    showHitEffect(enemyGroup, function()
                                        battleFunctions.applyDamage(attacker, enemy, damage, enemy.index or i)
                                        print("fireLiberation: Dano de " .. damage .. " aplicado ao inimigo de index " .. (enemy.index or i))
                                    end)
                                else
                                    battleFunctions.applyDamage(attacker, enemy, damage, enemy.index or i)
                                    print("fireLiberation: Inimigo de index " .. (enemy.index or i) .. " sem objeto de display; dano aplicado sem efeito de hit.")
                                end
                            end
                        end
                    end
                })
            end)
        else
            print("fireLiberation: Grupo inimigo não encontrado; aplicando efeitos de hit diretamente.")
            local atkValue = tonumber(attacker.atk) or 0
            local damage = math.max(1, math.floor(atkValue * 0.45))
            local opponents = {}
            if battleFunctions.getOpponents then
                opponents = battleFunctions.getOpponents(attacker)
            else
                opponents = _G.opponentFormation or {}
            end
            for i = 1, #opponents do
                local enemy = opponents[i]
                if enemy and tonumber(enemy.hp) > 0 then
                    local enemyGroup = enemy.group or gridSlotsOpponent[ enemy.index or i ] or enemy
                    if enemyGroup then
                        showHitEffect(enemyGroup, function()
                            battleFunctions.applyDamage(attacker, enemy, damage, enemy.index or i)
                        end)
                    else
                        battleFunctions.applyDamage(attacker, enemy, damage, enemy.index or i)
                    end
                end
            end
            transition.to(darkOverlay, { time = 500, alpha = 0, onComplete = function() if darkOverlay.removeSelf then darkOverlay:removeSelf() end end })
        end
    end)
end

return fireLiberation