local jiongu = {}

-- Seleciona o alvo com menor vida na formação
local function getLowestLifeTarget(formation)
    if type(formation) ~= "table" then return nil, nil end
    local lowestRatio = math.huge
    local lowestTarget, lowestSlot = nil, nil
    for slot, card in pairs(formation) do
        if type(card) == "table" then
            local hp = tonumber(card.hp) or 0
            local maxHp = tonumber(card.maxHp) or tonumber(card.originalHP) or 1
            local ratio = (maxHp > 0) and (hp / maxHp) or 1
            if ratio < lowestRatio then
                lowestRatio = ratio
                lowestTarget = card
                lowestSlot = slot
            end
        end
    end
    return lowestTarget, lowestSlot
end

-- Fatores de escala
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth
local attackerAnimScale = 1.7 * deviceScaleFactor
local hitEffectScale   = 3.0 * deviceScaleFactor

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
                            if onComplete then onComplete() end
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
            { x = 842, y = 2, width = 182, height = 182 },
            { x = 634, y = 2, width = 186, height = 206 },
            { x = 426, y = 2, width = 186, height = 206 },
            { x = 214, y = 2, width = 194, height = 210 },
            { x = 2,   y = 2, width = 194, height = 210 },
            { x = 1196, y = 2, width = 178, height = 204 },
            { x = 1026, y = 2, width = 168, height = 182 },
            { x = 1402, y = 2, width = 140, height = 154 },
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/hit_13.png", hitSheetOptions)
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
            if callback then callback() end
        end
    end)
end

--------------------------------------------------
-- Fase 1: Animação do atacante (spritesheet de ação com destaque)
-- Modificação: Agora recebe dois callbacks – um para disparar o projetil (antes do final da ação)
-- e outro para o término. A animação inclui um efeito de zoom in e zoom out.
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
    print("playAttackerAnimation: Iniciando animação do atacante via spritesheet.")
    local attackerSheetOptions = {
        frames = {
          { x = 1,    y = 1,    width = 500, height = 500 },
          { x = 503,  y = 1,    width = 500, height = 500 },
          { x = 1005, y = 1,    width = 500, height = 500 },
          { x = 1507, y = 1,    width = 500, height = 500 },
          { x = 1,    y = 503,  width = 500, height = 500 },
          { x = 503,  y = 503,  width = 500, height = 500 },
          { x = 1005, y = 503,  width = 500, height = 500 },
          { x = 1507, y = 503,  width = 500, height = 500 },
          { x = 1,    y = 1005, width = 500, height = 500 },
          { x = 503,  y = 1005, width = 500, height = 500 },
          { x = 1005, y = 1005, width = 500, height = 500 },
          { x = 1507, y = 1005, width = 500, height = 500 },
          { x = 1,    y = 1507, width = 500, height = 500 },
          { x = 503,  y = 1507, width = 500, height = 500 },
          { x = 1005, y = 1507, width = 500, height = 500 },
          { x = 1507, y = 1507, width = 500, height = 500 },
          { x = 2009, y = 1,    width = 500, height = 500 },
          { x = 2009, y = 1,    width = 500, height = 500 },
          { x = 2009, y = 503,  width = 500, height = 500 },
          { x = 2009, y = 1005, width = 500, height = 500 },                     
        }
    }
    local attackerSheet = graphics.newImageSheet("assets/7effect/action_106.png", attackerSheetOptions)
    local attackerSequenceData = {
        name = "attackAnim",
        start = 1,
        count = 20,
        time = 1000,
        loopCount = 1
    }
    local attackerSprite = display.newSprite(attackerSheet, attackerSequenceData)
    attackerSprite.anchorX = 0.5
    attackerSprite.anchorY = 0.4
    attackerSprite.x = cardGroup.x
    attackerSprite.y = cardGroup.y
    attackerSprite:scale(attackerAnimScale, attackerAnimScale)
    cardGroup.parent:insert(attackerSprite)
    attackerSprite:toFront()
    attackerSprite:play()
    -- Dispara o callback para o projetil um pouco antes do final da animação (400 ms)
    timer.performWithDelay(500, function()
        if projectileCallback then projectileCallback() end
    end)
    attackerSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            print("playAttackerAnimation: Animação do atacante terminou.")
            if attackerSprite.removeSelf then attackerSprite:removeSelf() end
            transition.to(highlight, { time = 500, alpha = 0, onComplete = function() 
                if highlight.removeSelf then highlight:removeSelf() end 
                if finalCallback then finalCallback() end
            end })
        end
    end)
end

--------------------------------------------------
-- Fase 2: Animação do projetil (do atacante até o alvo)
-- Modificação: O projetil agora inicia a partir das coordenadas do primeiro filho do atacante,
-- aparece com fade in e é disparado até o alvo.
--------------------------------------------------
local function playProjectileAnimation(attacker, target, battleFunctions, callback)
    local attackerGroup = attacker.group or attacker
    local targetGroup = target.group or target
    if not attackerGroup or not targetGroup then
        if callback then callback() end
        return
    end

    local cardImageAttacker = attackerGroup[1] or attackerGroup
    local startX, startY = cardImageAttacker:localToContent(cardImageAttacker.x, cardImageAttacker.y)

    local cardImageTarget = targetGroup[1] or targetGroup
    local targetX, targetY = cardImageTarget:localToContent(cardImageTarget.x, cardImageTarget.y)

    local projectileSheetOptions = {
        frames = {
          { x = 2, y = 884, width = 54, height = 114 },
          { x = 2, y = 756, width = 60, height = 126 },
          { x = 2, y = 626, width = 64, height = 128 },
          { x = 2, y = 482, width = 70, height = 142 },
          { x = 2, y = 324, width = 74, height = 156 },
          { x = 2, y = 164, width = 74, height = 158 },
          { x = 2, y = 2,   width = 74, height = 160 },          
        }
    }
    local projectileSheet = graphics.newImageSheet("assets/7effect/bullet_12.png", projectileSheetOptions)
    local projectileSequenceData = {
        name = "projectile",
        start = 1,
        count = 7,
        time = 700,
        loopCount = 2
    }
    local projectileSprite = display.newSprite(projectileSheet, projectileSequenceData)
    projectileSprite.anchorX = 0.5
    projectileSprite.anchorY = 0.5
    projectileSprite.x = startX
    projectileSprite.y = startY
    projectileSprite:scale(4.0 * deviceScaleFactor, 4.0 * deviceScaleFactor)
    projectileSprite.alpha = 0  -- Inicia invisível para o fade in
    projectileSprite:toFront()
    projectileSprite:play()
    transition.to(projectileSprite, {
        alpha = 1,
        time = 0,
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
                        if callback then callback() end
                    end
                })
            end)
        end
    })
end

--------------------------------------------------
-- Função principal: jiongu.attack
--------------------------------------------------
function jiongu.attack(attacker, target, battleFunctions, targetSlot, callback)
    -- Redefine target para inimigo com menor vida
    local formation = attacker.isOpponent and playerFormationData or opponentFormationData
    local lowestTarget, lowestSlot = getLowestLifeTarget(formation)
    if lowestTarget then
        target = lowestTarget
        targetSlot = lowestSlot
    end

    local cardGroup = attacker.group or attacker
    if not cardGroup then
        -- aplicação direta de dano
        local atkValue = tonumber(attacker.atk) or 0
        local damage   = math.max(1, math.floor(atkValue * 0.50))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback then callback() end
        return
    end

    playAttackerAnimation(cardGroup,
        function()
            playProjectileAnimation(attacker, target, battleFunctions)
        end,
        function()
            local targetGroup = target.group or target
            if targetGroup then
                shakeTarget(targetGroup, function()
                    showHitEffect(targetGroup, function()
                        local atkValue = tonumber(attacker.atk) or 0
                        local damage   = math.max(1, math.floor(atkValue * 1.30))
                        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                        if callback then callback() end
                    end)
                end)
            else
                local atkValue = tonumber(attacker.atk) or 0
                local damage   = math.max(1, math.floor(atkValue * 0.50))
                battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                if callback then callback() end
            end
        end
    )
end

return jiongu
