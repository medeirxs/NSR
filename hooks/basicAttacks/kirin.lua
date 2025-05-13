local kirin = {}

-- Defina a largura de referência e calcule o fator responsivo
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth

-- Variáveis de controle de escala (valores base multiplicados pelo fator responsivo)
local attackerAnimScale = 0.8 * deviceScaleFactor
local overlayAnimScale = 2 * deviceScaleFactor   
local hitEffectScale = 3.0 * deviceScaleFactor

-- Variável para identificar se é o primeiro ataque
local firstAttackExecuted = false

--------------------------------------------------
-- Função auxiliar: safeCallback
--------------------------------------------------
local function safeCallback(cb)
    if cb and type(cb) == "function" then
        print("[safeCallback] Executando callback...")
        cb()
    else
        print("[safeCallback] Callback não é uma função ou está nil.")
    end
end

--------------------------------------------------
-- Função auxiliar: createFinishAttack
--------------------------------------------------
local function createFinishAttack(callback)
    local called = false
    return function()
        if not called then
            called = true
            print("[createFinishAttack] Chamando callback final.")
            safeCallback(callback)
        else
            print("[createFinishAttack] Callback já foi chamado anteriormente.")
        end
    end
end

--------------------------------------------------
-- Função auxiliar: getDamagePosition
--------------------------------------------------
local function getDamagePosition(target)
    if target and target.cardCenterX and target.cardCenterY then
        return target.cardCenterX, target.cardCenterY
    elseif target and target.index and _G.cardSlotPositions and _G.cardSlotPositions[target.index] then
        local pos = _G.cardSlotPositions[target.index]
        return pos.x, pos.y
    elseif target and target.x and target.y then
        return target.x, target.y
    elseif target and target.getContentBounds then
        local bounds = target:getContentBounds()
        return (bounds.xMin + bounds.xMax) / 2, (bounds.yMin + bounds.yMax) / 2
    end
    return display.contentCenterX, display.contentCenterY
end

--------------------------------------------------
-- Função auxiliar: showHitEffect
--------------------------------------------------
local function showHitEffect(targetGroup, callback)
    print("[showHitEffect] Iniciando efeito de hit - animação 1.")

    -- Define a função onHitAnimation2 antes de usá-la
    local function onHitAnimation2()
        print("[showHitEffect] Segunda animação de hit iniciada.")
        local hitSheetOptions2 = {
            frames = {
                { x = 1,    y = 4333, width = 1280, height = 720 },
                { x = 1,    y = 4333, width = 1280, height = 720 },
                { x = 1,    y = 3611, width = 1280, height = 720 },
                { x = 1,    y = 3611, width = 1280, height = 720 },
                { x = 1,    y = 1,    width = 1280, height = 720 },
                { x = 1,    y = 723,  width = 1280, height = 720 },
                { x = 1,    y = 1,    width = 1280, height = 720 },
                { x = 1,    y = 723,  width = 1280, height = 720 },
                { x = 1,    y = 3611, width = 1280, height = 720 },
                { x = 1,    y = 3611, width = 1280, height = 720 },
                { x = 1,    y = 3611, width = 1280, height = 720 },
                { x = 1,    y = 3611, width = 1280, height = 720 },
                { x = 1,    y = 3611, width = 1280, height = 720 },
                { x = 1,    y = 3611, width = 1280, height = 720 },
                { x = 1,    y = 3611, width = 1280, height = 720 },
                { x = 1,    y = 3611, width = 1280, height = 720 },
            }
        }
        local hitSheet2 = graphics.newImageSheet("assets/7effect/hit_kirin_2.png", hitSheetOptions2)
        local hitSequenceData2 = {
            name = "hit2",
            start = 1,
            count = 16,      -- ajuste conforme seu spritesheet
            time = 1000,
            loopCount = 1
        }
        local hitSprite2 = display.newSprite(hitSheet2, hitSequenceData2)
        hitSprite2.anchorX = 0.5
        hitSprite2.anchorY = 0.5
        hitSprite2.x = 0
        hitSprite2.y = 0
        hitSprite2:scale(hitEffectScale, hitEffectScale)
        hitSprite2.alpha = 1   -- inicia totalmente visível para depois dar fade out
        targetGroup:insert(hitSprite2)
        hitSprite2:toFront()
        hitSprite2:play()
        
        transition.to(hitSprite2, { alpha = 0, time = hitSequenceData2.time, transition = easing.linear })
        
        local fallbackTimer2 = timer.performWithDelay(hitSequenceData2.time + 150, function()
            safeCallback(callback)
        end)
        
        hitSprite2:addEventListener("sprite", function(event2)
            if event2.phase == "ended" then
                print("[showHitEffect] Segunda animação de hit finalizada.")
                if hitSprite2.removeSelf then hitSprite2:removeSelf() end
                timer.cancel(fallbackTimer2)
                local origX = targetGroup.x
                transition.to(targetGroup, { 
                    x = origX + 5 * deviceScaleFactor, 
                    time = 50, 
                    onComplete = function()
                        transition.to(targetGroup, { 
                            x = origX - 5 * deviceScaleFactor, 
                            time = 50, 
                            onComplete = function()
                                transition.to(targetGroup, { 
                                    x = origX, 
                                    time = 50, 
                                    onComplete = function()
                                        print("[showHitEffect] Tremor finalizado. Chamando callback.")
                                        safeCallback(callback)
                                    end
                                })
                            end
                        })
                    end 
                })
            end
        end)
    end

    -- Configuração da primeira animação (hit 1)
    local hitSheetOptions1 = {
        frames = {
            { x = 871, y = 803, width = 204, height = 160 },
            { x = 871, y = 649, width = 210, height = 152 },
            { x = 871, y = 487, width = 202, height = 160 },
            { x = 861, y = 319, width = 208, height = 166 },
            { x = 811, y = 1,   width = 206, height = 316 },
            { x = 639, y = 643, width = 230, height = 310 },
            { x = 1,   y = 1,   width = 186, height = 318 },
            { x = 189, y = 1,   width = 206, height = 316 },
            { x = 397, y = 1,   width = 202, height = 316 },
            { x = 601, y = 1,   width = 208, height = 318 },
            { x = 1,   y = 321, width = 206, height = 318 },
            { x = 209, y = 321, width = 210, height = 320 },
            { x = 421, y = 321, width = 216, height = 276 },
            { x = 639, y = 321, width = 220, height = 320 },
            { x = 1,   y = 643, width = 224, height = 320 },
            { x = 227, y = 643, width = 204, height = 320 },
            { x = 433, y = 643, width = 204, height = 168 },
            { x = 639, y = 643, width = 230, height = 310 },
            { x = 811, y = 1,   width = 206, height = 316 },
            { x = 861, y = 319, width = 208, height = 166 },
            { x = 871, y = 487, width = 202, height = 160 },
            { x = 871, y = 649, width = 210, height = 152 },
            { x = 871, y = 803, width = 204, height = 160 },
        }
    }
    local hitSheet1 = graphics.newImageSheet("assets/7effect/hit_kirin_1.png", hitSheetOptions1)
    local hitSequenceData1 = {
        name = "hit1",
        start = 1,
        count = 23,      -- ajuste conforme seu spritesheet
        time = 1000,
        loopCount = 1
    }
    local hitSprite1 = display.newSprite(hitSheet1, hitSequenceData1)
    hitSprite1.anchorX = 0.5
    hitSprite1.anchorY = 0.5
    hitSprite1.x = 0
    hitSprite1.y = 0
    hitSprite1:scale(hitEffectScale, hitEffectScale)
    hitSprite1.alpha = 0.5
    targetGroup:insert(hitSprite1)
    hitSprite1:toFront()
    hitSprite1:play()
    
    transition.to(hitSprite1, { alpha = 1, time = hitSequenceData1.time, transition = easing.linear })
    
    local fallbackTimer1 = timer.performWithDelay(hitSequenceData1.time + 150, function()
        safeCallback(callback)
    end)
    
    hitSprite1:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            print("[showHitEffect] Primeira animação de hit finalizada.")
            if hitSprite1.removeSelf then hitSprite1:removeSelf() end
            timer.cancel(fallbackTimer1)
            onHitAnimation2()
        end
    end)
end

--------------------------------------------------
-- Função auxiliar: playAttackerAnimation
--------------------------------------------------
local function playAttackerAnimation(cardGroup, callback)
    print("[playAttackerAnimation] Iniciando animação do atacante.")
    local origX, origY = cardGroup.x, cardGroup.y
    local bounds = cardGroup.contentBounds
    local highlight = display.newRect(cardGroup.parent, (bounds.xMin + bounds.xMax) * 0.5,
                                      (bounds.yMin + bounds.yMax) * 0.5,
                                      bounds.xMax - bounds.xMin,
                                      bounds.yMax - bounds.yMin)
    highlight:setFillColor(1, 1, 0)
    highlight.alpha = 0.5
    cardGroup.parent:insert(highlight)
    highlight:toFront()
    cardGroup:toFront()
    transition.to(cardGroup, {
        time = 1000,
        xScale = 1.6,
        yScale = 1.6,
        transition = easing.outQuad,
        onComplete = function()
            local attackerSheetOptions = {
                frames = {
                    { x = 1,    y = 1,    width = 1280, height = 720 },
                    { x = 1283, y = 1,    width = 1280, height = 720 },
                    { x = 1,    y = 723,  width = 1280, height = 720 },
                    { x = 1283, y = 723,  width = 1280, height = 720 },
                    { x = 1,    y = 1445, width = 1280, height = 720 },
                    { x = 1283, y = 1445, width = 1280, height = 720 },
                    { x = 1,    y = 2167, width = 1280, height = 720 },
                    { x = 1283, y = 2167, width = 1280, height = 720 },
                    { x = 1,    y = 2889, width = 1280, height = 720 },
                    { x = 1283, y = 2889, width = 1280, height = 720 },
                    { x = 2565, y = 1,    width = 1280, height = 720 },
                    { x = 2565, y = 723,  width = 1280, height = 720 },
                    { x = 2565, y = 1445, width = 1280, height = 720 },
                    { x = 2565, y = 2167, width = 1280, height = 720 },
                    { x = 2565, y = 2889, width = 1280, height = 720 },
                }
            }
            local attackerSheet = graphics.newImageSheet("assets/7effect/action_kirin.png", attackerSheetOptions)
            local attackerSequenceData = {
                name = "attackAnim",
                start = 1,
                count = 15,
                time = 1200,
                loopCount = 1
            }
            local attackerSprite = display.newSprite(attackerSheet, attackerSequenceData)
            attackerSprite.anchorX = 0.5
            attackerSprite.anchorY = 0.5
            attackerSprite.x = cardGroup.x
            attackerSprite.y = cardGroup.y
            attackerSprite:scale(attackerAnimScale, attackerAnimScale)
            attackerSprite.alpha = 0
            cardGroup.parent:insert(attackerSprite)
            attackerSprite:toFront()
            transition.to(attackerSprite, {
                alpha = 0.7,
                time = 400,
                onComplete = function()
                    print("[playAttackerAnimation] Animação do atacante iniciada, disparando play().")
                    attackerSprite:play()
                end
            })
            attackerSprite:addEventListener("sprite", function(event)
                if event.phase == "ended" then
                    print("[playAttackerAnimation] Evento 'ended' disparado no attackerSprite.")
                    transition.to(attackerSprite, {
                        alpha = 0,
                        time = 100,
                        onComplete = function()
                            if attackerSprite.removeSelf then attackerSprite:removeSelf() end
                            transition.to(cardGroup, {
                                time = 1000,
                                xScale = 1,
                                yScale = 1,
                                transition = easing.inQuad,
                                onComplete = function()
                                    cardGroup.x = origX
                                    cardGroup.y = origY
                                    transition.to(highlight, {
                                        time = 500,
                                        alpha = 0,
                                        onComplete = function()
                                            if highlight.removeSelf then highlight:removeSelf() end
                                        end
                                    })
                                    print("[playAttackerAnimation] Finalizando animação do atacante e chamando callback.")
                                    safeCallback(callback)
                                end
                            })
                        end
                    })
                end
            end)
        end
    })
end

--------------------------------------------------
-- Função auxiliar: playEnemyOverlay
--------------------------------------------------
local function playEnemyOverlay(enemyGroup, callback)
    print("[playEnemyOverlay] Iniciando overlay do inimigo.")
    if not enemyGroup then enemyGroup = display.getCurrentStage() end
    local bounds = enemyGroup.contentBounds or { xMin = 0, xMax = display.contentWidth, yMin = 0, yMax = display.contentHeight }
    local centerX = (bounds.xMin + bounds.xMax) * 0.5
    local centerY = (bounds.yMin + bounds.yMax) * 0.5

    local overlaySheetOptions = {
        frames = {
            { x = 1,    y = 1,    width = 1280, height = 720 },
            { x = 1283, y = 1,    width = 1280, height = 720 },
            { x = 2565, y = 1,    width = 1280, height = 720 },
            { x = 1,    y = 723,  width = 1280, height = 720 },
            { x = 1283, y = 723,  width = 1280, height = 720 },
            { x = 2565, y = 723,  width = 1280, height = 720 },
            { x = 1,    y = 1445, width = 1280, height = 720 },
            { x = 1283, y = 1445, width = 1280, height = 720 },
            { x = 2565, y = 1445, width = 1280, height = 720 },
            { x = 1,    y = 2167, width = 1280, height = 720 },
            { x = 1283, y = 2167, width = 1280, height = 720 },
            { x = 2565, y = 2167, width = 1280, height = 720 },
            { x = 1,    y = 2889, width = 1280, height = 720 },
            { x = 1283, y = 2889, width = 1280, height = 720 },
            { x = 2565, y = 2889, width = 1280, height = 720 },
            { x = 1,    y = 3611, width = 1280, height = 720 },
            { x = 1283, y = 3611, width = 1280, height = 720 },
            { x = 2565, y = 3611, width = 1280, height = 720 },
            { x = 3847, y = 1,    width = 1280, height = 720 },
            { x = 3847, y = 723,  width = 1280, height = 720 },
            { x = 3847, y = 1445, width = 1280, height = 720 },
            { x = 3847, y = 2167, width = 1280, height = 720 },
            { x = 3847, y = 2889, width = 1280, height = 720 },
            { x = 3847, y = 3611, width = 1280, height = 720 },
            { x = 1,    y = 4333, width = 1280, height = 720 },
        }
    }
    local overlaySheet = graphics.newImageSheet("assets/7effect/kirin.png", overlaySheetOptions)
    local overlaySequenceData = { name = "overlay", start = 1, count = 25, time = 1800, loopCount = 1 }
    local overlaySprite = display.newSprite(overlaySheet, overlaySequenceData)
    overlaySprite.anchorX = 0.48
    overlaySprite.anchorY = 0.5
    overlaySprite.x = centerX
    overlaySprite.y = centerY - 100 * deviceScaleFactor
    overlaySprite:scale(overlayAnimScale, overlayAnimScale)
    overlaySprite.alpha = 0  -- inicia invisível para o fade in
    overlaySprite:setFillColor(1, 1, 1)
    display.getCurrentStage():insert(overlaySprite)
    overlaySprite:toFront()

    local origX = enemyGroup.x
    enemyGroup._origX = origX
    local shakeOffset = 5 * deviceScaleFactor
    enemyGroup._shakeTimer = timer.performWithDelay(5, function()
        local offset = (math.random(0, 1) == 0) and -shakeOffset or shakeOffset
        enemyGroup.x = origX + offset
    end, 0)

    overlaySprite:play()
    transition.to(overlaySprite, {
        alpha = 1,
        time = 1200,
        transition = easing.inOutQuad,
        onComplete = function()
            transition.to(overlaySprite, {
                alpha = 0,
                delay = 600,
                time = 1200,
                transition = easing.inOutQuad,
                onComplete = function()
                    print("[playEnemyOverlay] Overlay animado concluído.")
                end
            })
        end
    })

    local callbackCalled = false
    local function safeOverlayCallback()
        if not callbackCalled then
            callbackCalled = true
            if enemyGroup._shakeTimer then
                timer.cancel(enemyGroup._shakeTimer)
                enemyGroup._shakeTimer = nil
            end
            enemyGroup.x = enemyGroup._origX or enemyGroup.x
            print("[playEnemyOverlay] Chamando callback do overlay.")
            safeCallback(callback)
        end
    end

    overlaySprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            print("[playEnemyOverlay] Evento 'ended' disparado no overlaySprite.")
            safeOverlayCallback()
        end
    end)

    timer.performWithDelay(overlaySequenceData.time + 100, safeOverlayCallback)
end

--------------------------------------------------
-- Função principal: kirin.attack
--------------------------------------------------
function kirin.attack(attacker, target, battleFunctions, targetSlot, callback)
    print("[kirin.attack] Iniciando ataque.")
    
    local function proceedAttack()
        local finishAttack = createFinishAttack(callback)
        local cardGroup = attacker.group or attacker
        if not cardGroup then
            local atkValue = tonumber(attacker.atk) or 0
            local damage = math.max(1, math.floor(atkValue * 0.45))
            local targetIndex = targetSlot or (target.index or 1)
            battleFunctions.applyDamage(attacker, target, damage, targetIndex)
            finishAttack()
            return
        end

        cardGroup:toFront()
        playAttackerAnimation(cardGroup, function()
            local darkOverlay = display.newRect(cardGroup.parent, display.contentCenterX, display.contentCenterY,
                                                  display.actualContentWidth * 10, display.actualContentHeight * 10)
            darkOverlay:setFillColor(0, 0, 0)
            darkOverlay.alpha = 0
            cardGroup.parent:insert(darkOverlay)
            darkOverlay:toBack()
            transition.to(darkOverlay, { time = 500, alpha = 0.5, onComplete = function()
                local enemyGroup = nil
                if battleFunctions.getEnemyGroup then
                    enemyGroup = battleFunctions.getEnemyGroup(attacker)
                end
                if not enemyGroup then
                    enemyGroup = _G.opponentGridGroup or display.getCurrentStage()
                end

                local opponents = {}
                if attacker.isOpponent then
                    -- Se o atacante for oponente, os alvos são a formação do jogador
                    opponents = _G.playerFormation or {}
                else
                    if battleFunctions.getOpponents then
                        opponents = battleFunctions.getOpponents(attacker)
                    else
                        opponents = _G.opponentFormation or {}
                    end
                    if #opponents == 0 then
                        opponents = _G.opponentFormation or {}
                    end
                end

                print("[kirin.attack] Valor de atk do atacante: " .. tonumber(attacker.atk) .. " | Dano calculado: " .. math.max(1, math.floor(tonumber(attacker.atk) * 0.5)))
                print("[kirin.attack] Número de oponentes: " .. #opponents)
                for i, enemy in ipairs(opponents) do
                    print("[kirin.attack] Oponente " .. i .. " - HP: " .. tostring(enemy.hp))
                end
                            
                playEnemyOverlay(enemyGroup, function()
                    transition.to(darkOverlay, { time = 500, alpha = 0, onComplete = function()
                        if darkOverlay.removeSelf then darkOverlay:removeSelf() end
                        local atkValue = tonumber(attacker.atk) or 0
                        local damage = math.max(1, math.floor(atkValue * 0.5))
                            
                        showHitEffect(enemyGroup, function()
                            for i = 1, #opponents do
                                local enemy = opponents[i]
                                if enemy and tonumber(enemy.hp) > 0 then
                                    battleFunctions.applyDamage(attacker, enemy, damage, enemy.index or i)
                                end
                            end
                            print("[kirin.attack] Acabou animação de ataque, chamando finishAttack.")
                            finishAttack()
                        end)
                    end })
                end)
            end })
        end)
    end

    if not firstAttackExecuted then
        firstAttackExecuted = true
        print("[kirin.attack] Primeiro ataque - inserindo delay inicial de 300ms.")
        timer.performWithDelay(300, proceedAttack)
    else
        proceedAttack()
    end
end

return kirin
