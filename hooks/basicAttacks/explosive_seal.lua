local sand_coffing = {}

-- Defina a largura de referência e calcule o fator responsivo
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth

-- Variáveis de controle de escala responsivas
local attackerAnimScale = 4.0 * deviceScaleFactor
local hitEffectScale = 3.0 * deviceScaleFactor

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
            { x = 1,   y = 1,    width = 80,  height = 122 },
            { x = 83,  y = 1,    width = 126, height = 158 },
            { x = 211, y = 1,    width = 124, height = 138 },
            { x = 337, y = 1,    width = 108, height = 114 },
            { x = 211, y = 141,  width = 120, height = 150 },
            { x = 1,   y = 293,  width = 126, height = 150 },
            { x = 337, y = 117,  width = 102, height = 150 },
            { x = 129, y = 293,  width = 166, height = 146 },
            { x = 447, y = 1,    width = 200, height = 114 },
            { x = 441, y = 117,  width = 188, height = 108 },
            { x = 441, y = 227,  width = 190, height = 118 },                    
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/hit_32.png", hitSheetOptions)
    local hitSequenceData = {
        name = "hit",
        start = 1,
        count = 11,
        time = 700,
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
            { x = 366, y = 2,  width = 76, height = 24 },
            { x = 288, y = 2,  width = 76, height = 62 },
            { x = 78,  y = 2,  width = 76, height = 72 },
            { x = 2,   y = 2,  width = 74, height = 74 },
            { x = 222, y = 2,  width = 64, height = 68 },
            { x = 156, y = 2,  width = 64, height = 68 },                                
        }
    }
    local attackerSheet = graphics.newImageSheet("assets/7effect/action_32.png", attackerSheetOptions)
    local attackerSequenceData = {
        name = "attackAnim",
        start = 1,
        count = 6,
        time = 550,
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
    timer.performWithDelay(400, function()
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
            { x = 1,   y = 1,  width = 54, height = 74 },
            { x = 57,  y = 1,  width = 74, height = 84 },
            { x = 133, y = 1,  width = 60, height = 94 },
            { x = 1,   y = 97, width = 60, height = 124 },                
        }
    }
    local projectileSheet = graphics.newImageSheet("assets/7effect/bullet_32.png", projectileSheetOptions)
    local projectileSequenceData = {
        name = "projectile",
        start = 1,
        count = 4,
        time = 600,
        loopCount = 0
    }
    local projectileSprite = display.newSprite(projectileSheet, projectileSequenceData)
    projectileSprite.anchorX = 0.5
    projectileSprite.anchorY = 0.5
    projectileSprite.x = startX
    projectileSprite.y = startY
    projectileSprite:scale(5.0 * deviceScaleFactor, 5.0 * deviceScaleFactor)
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
                    time = 600,
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
-- Função principal: sand_coffing.attack
--------------------------------------------------
function sand_coffing.attack(attacker, target, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("sand_coffing.attack: Objeto de display do atacante não encontrado. Aplicando dano sem animação.")
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * 1.00))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback then callback() end
        return
    end

    cardGroup:toFront()
    print("sand_coffing.attack: Iniciando animação de ação do atacante via spritesheet.")
    playAttackerAnimation(cardGroup,
        function()  -- Callback para disparar o projetil durante a animação do atacante
            print("sand_coffing.attack: Disparando projetil durante a animação do atacante.")
            playProjectileAnimation(attacker, target, battleFunctions, function()
                print("sand_coffing.attack: Projetil completado.")
            end)
        end,
        function()  -- Callback final após a animação do atacante
            local targetGroup = target.group or target
            if targetGroup then
                print("sand_coffing.attack: Aplicando tremor no alvo.")
                shakeTarget(targetGroup, function()
                    print("sand_coffing.attack: Tremor concluído; exibindo efeito de hit no alvo.")
                    showHitEffect(targetGroup, function()
                        local atkValue = tonumber(attacker.atk) or 0
                        local damage = math.max(1, math.floor(atkValue * 0.50))
                        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                        print("sand_coffing.attack: Efeito de hit concluído; dano de " .. damage .. " aplicado.")
                        if callback then callback() end
                    end)
                end)
            else
                local atkValue = tonumber(attacker.atk) or 0
                local damage = math.max(1, math.floor(atkValue * 0.50))
                battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                print("sand_coffing.attack: Alvo sem objeto de display; dano aplicado sem efeito de hit.")
                if callback then callback() end
            end
        end
    )
end

return sand_coffing
