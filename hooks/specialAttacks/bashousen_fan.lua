local bashousen_fan = {}

-- Defina a largura de referência e calcule o fator responsivo
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth

-- Variáveis de controle de escala responsivas
local attackerAnimScale = 2.5 * deviceScaleFactor
local hitEffectScale = 1.0 * deviceScaleFactor

--------------------------------------------------
-- Função auxiliar: shakeTarget
-- Aplica um pequeno tremor ao grupo alvo e, ao final, retorna à posição e rotação originais.
--------------------------------------------------
local function shakeTarget(targetGroup, onComplete)
    local origX = targetGroup.x
    local origY = targetGroup.y
    local origRotation = targetGroup.rotation or 0
    local shakeDistance = 5   -- distância do tremor (ajuste conforme necessário)
    local shakeTime = 50      -- tempo para cada movimento (ms)
    
    transition.to(targetGroup, {
        time = shakeTime,
        x = origX + shakeDistance,
        rotation = origRotation,  -- força a rotação original
        transition = easing.linear,
        onComplete = function()
            transition.to(targetGroup, {
                time = shakeTime,
                x = origX - shakeDistance,
                rotation = origRotation,  -- força a rotação original
                transition = easing.linear,
                onComplete = function()
                    transition.to(targetGroup, {
                        time = shakeTime,
                        x = origX,
                        rotation = origRotation,  -- força a rotação original
                        transition = easing.linear,
                        onComplete = function()
                            if onComplete and type(onComplete) == "function" then onComplete() end
                        end
                    })
                end
            })
        end
    })
end

--------------------------------------------------
-- Fase 3: Efeito de hit com tremor
--------------------------------------------------
local function showHitEffect(targetGroup, callback)
    local hitSheetOptions = {
        frames = {
            { x = 1,    y = 1,    width = 1280, height = 720 },
            { x = 1,    y = 723,  width = 1280, height = 720 },
            { x = 1,    y = 1445, width = 1280, height = 720 },
            { x = 1283, y = 1,    width = 1280, height = 720 },
            { x = 1283, y = 723,  width = 1280, height = 720 },
            { x = 1283, y = 1445, width = 1280, height = 720 }, 
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/hit_101.png", hitSheetOptions)
    local hitSequenceData = {
        name = "hit",
        start = 1,
        count = 6,
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
            if callback and type(callback) == "function" then callback() end
        end
    end)
end

--------------------------------------------------
-- Fase 1: Animação do atacante (spritesheet de ação com destaque)
--------------------------------------------------
local function playAttackerAnimation(cardGroup, projectileCallback, finalCallback)
    local origX, origY = cardGroup.x, cardGroup.y

    -- Cria um destaque (overlay amarelo) sobre o atacante
    local bounds = cardGroup.contentBounds
    local highlight = display.newRect(cardGroup.parent, (bounds.xMin + bounds.xMax) * 0.5,
                                      (bounds.yMin + bounds.yMax) * 0.5,
                                      bounds.xMax - bounds.xMin,
                                      bounds.yMax - bounds.yMin)
    highlight:setFillColor(1, 0, 0)  -- Amarelo
    highlight.alpha = 0
    cardGroup.parent:insert(highlight)
    highlight:toFront()

    cardGroup:toFront()
    print("playAttackerAnimation: Iniciando animação do atacante via PNG com rotação.")

    -- Carrega a imagem PNG do atacante (substituta da animação via spritesheet)
    -- Ajuste o nome do arquivo e as dimensões (width, height) conforme seu asset
    local attackerImage = display.newImageRect(cardGroup.parent, "assets/7effect/action_101.png", 160, 120)
    attackerImage.anchorX = 0.5
    attackerImage.anchorY = 0.7
    attackerImage.x = cardGroup.x
    attackerImage.y = cardGroup.y
    attackerImage:scale(attackerAnimScale, attackerAnimScale)
    attackerImage.rotation = 0
    attackerImage:toFront()

    -- Dispara o callback para o projetil 400 ms antes do final da animação, como anteriormente
    timer.performWithDelay(400, function()
        if projectileCallback and type(projectileCallback) == "function" then
            projectileCallback()
        end
    end)

    -- Gira a imagem 180 graus com um efeito de transição
    transition.to(attackerImage, {
        time = 500,
        rotation = 90,
        transition = easing.inOutQuad,
        onComplete = function()
            print("playAttackerAnimation: Animação do atacante terminou (180 graus).")
            if attackerImage.removeSelf then attackerImage:removeSelf() end
            transition.to(highlight, {
                time = 500,
                alpha = 0,
                onComplete = function() 
                    if highlight.removeSelf then highlight:removeSelf() end 
                    if finalCallback and type(finalCallback) == "function" then finalCallback() end
                end
            })
        end
    })
end

--------------------------------------------------
-- Fase 2: Animação do projetil (do atacante até o alvo)
-- O projetil dispara a partir das coordenadas do primeiro filho do atacante, aparecendo com fade in e se movendo até o alvo preferencial.
--------------------------------------------------
local function playProjectileAnimation(attacker, battleFunctions, callback)
    local attackerGroup = attacker.group or attacker
    if not attackerGroup then
        if callback and type(callback) == "function" then callback() end
        return
    end

    local opponents = {}
    if battleFunctions.getOpponents then
        opponents = battleFunctions.getOpponents(attacker)
    else
        opponents = _G.opponentFormation or {}
    end

    local preferredSlot = 2
    if opponents[2] and tonumber(opponents[2].hp) and tonumber(opponents[2].hp) > 0 then
        preferredSlot = 2
    elseif opponents[1] and tonumber(opponents[1].hp) and tonumber(opponents[1].hp) > 0 then
        preferredSlot = 1
    elseif opponents[3] and tonumber(opponents[3].hp) and tonumber(opponents[3].hp) > 0 then
        preferredSlot = 3
    else
        preferredSlot = 2
    end

    local targetGroupForProjectile = nil
    if opponents[preferredSlot] and opponents[preferredSlot].group then
        targetGroupForProjectile = opponents[preferredSlot].group
    else
        targetGroupForProjectile = (attacker.isOpponent and _G.playerGridGroup) or _G.opponentGridGroup
    end

    local cardImageAttacker = attackerGroup[1] or attackerGroup
    local startX, startY = cardImageAttacker:localToContent(cardImageAttacker.x, cardImageAttacker.y)

    local cardImageTarget = targetGroupForProjectile[1] or targetGroupForProjectile
    local targetX, targetY = cardImageTarget:localToContent(cardImageTarget.x, cardImageTarget.y)

    local projectileSheetOptions = {
        frames = {
            { x = 435, y = 2,   width = 431, height = 312 },
            { x = 2,   y = 634, width = 435, height = 316 },
            { x = 439, y = 634, width = 427, height = 316 },
            { x = 2,   y = 2,   width = 431, height = 312 },
            { x = 2,   y = 316, width = 435, height = 316 },
            { x = 439, y = 316, width = 427, height = 316 },            
        }
    }
    local projectileSheet = graphics.newImageSheet("assets/7effect/bullet_102.png", projectileSheetOptions)
    local projectileSequenceData = {
        name = "projectile",
        start = 1,
        count = 5,
        time = 700,
        loopCount = 0
    }
    local projectileSprite = display.newSprite(projectileSheet, projectileSequenceData)
    projectileSprite.anchorX = 0.5
    projectileSprite.anchorY = 0.5
    projectileSprite.x = startX
    projectileSprite.y = startY
    projectileSprite:scale(2.5 * deviceScaleFactor, 1.0 * deviceScaleFactor)
    projectileSprite.alpha = 0
    projectileSprite:toFront()
    projectileSprite:play()
    transition.to(projectileSprite, {
        alpha = 1,
        time = 300,
        onComplete = function()
            timer.performWithDelay(0, function()
                local dx = targetX - startX
                local dy = targetY - startY
                local angle = math.deg(math.atan2(dy, dx))
                projectileSprite.rotation = angle + 90
                transition.to(projectileSprite, {
                    time = 400,
                    x = targetX,
                    y = targetY,
                    transition = easing.linear,
                    onComplete = function()
                        if projectileSprite.removeSelf then projectileSprite:removeSelf() end
                        if callback and type(callback) == "function" then callback() end
                    end
                })
            end)
        end
    })
end

--------------------------------------------------
-- Função principal: bashousen_fan.attack
--------------------------------------------------
function bashousen_fan.attack(attacker, target, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("bashousen_fan.attack: Objeto de display do atacante não encontrado. Aplicando dano sem animação.")
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * 0.50))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback and type(callback) == "function" then callback() end
        return
    end

    cardGroup:toFront()
    print("bashousen_fan.attack: Iniciando animação de ação do atacante via spritesheet.")
    playAttackerAnimation(cardGroup,
        function()  -- Callback para disparar o projetil durante a animação do atacante
            print("bashousen_fan.attack: Disparando projetil durante a animação do atacante.")
            playProjectileAnimation(attacker, battleFunctions, function()
                print("bashousen_fan.attack: Projetil completado.")
            end)
        end,
        function()  -- Callback final após a animação do atacante
            local opponents = {}
            if battleFunctions.getOpponents then
                opponents = battleFunctions.getOpponents(attacker)
            else
                opponents = _G.opponentFormation or {}
            end
            local damage = math.max(1, math.floor((tonumber(attacker.atk) or 0) * 0.50))
            
            -- Para cada slot 1, 2 e 3, se o inimigo estiver presente e com HP > 0,
            -- aplica o efeito de tremor e o hit individualmente.
            local hitDoneCount = 0
            local totalHits = 0
            for i = 1, 3 do
                local enemy = opponents[i]
                if enemy and tonumber(enemy.hp) and tonumber(enemy.hp) > 0 then
                    totalHits = totalHits + 1
                    local enemyGroup = enemy.group or enemy
                    shakeTarget(enemyGroup, function()
                        showHitEffect(enemyGroup, function()
                            battleFunctions.applyDamage(attacker, enemy, damage, i)
                            print("bashousen_fan.attack: Dano de " .. damage .. " aplicado ao inimigo de index " .. i)
                            hitDoneCount = hitDoneCount + 1
                            if hitDoneCount == totalHits then
                                print("bashousen_fan.attack: Efeito de hit concluído em todos os alvos; dano aplicado.")
                                transition.to(cardGroup, {
                                    time = 300,
                                    x = originalX,
                                    y = originalY,
                                    transition = easing.inQuad,
                                    onComplete = function()
                                        if callback and type(callback) == "function" then callback() end
                                    end
                                })
                            end
                        end)
                    end)
                end
            end
            if totalHits == 0 then
                if callback and type(callback) == "function" then callback() end
            end
        end
    )
end

return bashousen_fan
