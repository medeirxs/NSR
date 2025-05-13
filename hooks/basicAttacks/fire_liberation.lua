local fire_liberation = {}

-- Defina a largura de referência e calcule o fator responsivo
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth

-- Variáveis de controle de escala responsivas
local attackerAnimScale = 1.5 * deviceScaleFactor
local hitEffectScale = 2.0 * deviceScaleFactor

--------------------------------------------------
-- Função auxiliar: shakeTarget
-- Aplica um pequeno tremor ao grupo alvo e, ao final, retorna à posição e rotação originais.
--------------------------------------------------
local function shakeTarget(targetGroup, onComplete)
    local origX = targetGroup.x
    local origY = targetGroup.y
    local origRotation = targetGroup.rotation or 0
    local shakeDistance = 5 -- distância do tremor (ajuste conforme necessário)
    local shakeTime = 50 -- tempo para cada movimento (ms)

    transition.to(targetGroup, {
        time = shakeTime,
        x = origX + shakeDistance,
        rotation = origRotation, -- força a rotação original
        transition = easing.linear,
        onComplete = function()
            transition.to(targetGroup, {
                time = shakeTime,
                x = origX - shakeDistance,
                rotation = origRotation, -- força a rotação original
                transition = easing.linear,
                onComplete = function()
                    transition.to(targetGroup, {
                        time = shakeTime,
                        x = origX,
                        rotation = origRotation, -- força a rotação original
                        transition = easing.linear,
                        onComplete = function()
                            if onComplete then
                                onComplete()
                            end
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
        frames = {{
            x = 842,
            y = 2,
            width = 182,
            height = 182
        }, {
            x = 634,
            y = 2,
            width = 186,
            height = 206
        }, {
            x = 426,
            y = 2,
            width = 186,
            height = 206
        }, {
            x = 214,
            y = 2,
            width = 194,
            height = 210
        }, {
            x = 2,
            y = 2,
            width = 194,
            height = 210
        }, {
            x = 1196,
            y = 2,
            width = 178,
            height = 204
        }, {
            x = 1026,
            y = 2,
            width = 168,
            height = 182
        }, {
            x = 1402,
            y = 2,
            width = 140,
            height = 154
        }}
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
            if hitSprite.removeSelf then
                hitSprite:removeSelf()
            end
            if callback then
                callback()
            end
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
        (bounds.yMin + bounds.yMax) * 0.5, bounds.xMax - bounds.xMin, bounds.yMax - bounds.yMin)
    highlight:setFillColor(1, 0, 0) -- Amarelo
    highlight.alpha = 0
    cardGroup.parent:insert(highlight)
    highlight:toFront()

    cardGroup:toFront()
    print("playAttackerAnimation: Iniciando animação do atacante via spritesheet.")
    local attackerSheetOptions = {
        frames = {{
            x = 1,
            y = 1,
            width = 284,
            height = 148
        }, {
            x = 287,
            y = 1,
            width = 292,
            height = 152
        }, {
            x = 1,
            y = 155,
            width = 300,
            height = 154
        }, {
            x = 303,
            y = 155,
            width = 300,
            height = 158
        }, {
            x = 1,
            y = 315,
            width = 300,
            height = 162
        }, {
            x = 303,
            y = 315,
            width = 300,
            height = 162
        }, {
            x = 605,
            y = 1,
            width = 300,
            height = 156
        }, {
            x = 605,
            y = 159,
            width = 222,
            height = 152
        }}
    }
    local attackerSheet = graphics.newImageSheet("assets/7effect/action_14.png", attackerSheetOptions)
    local attackerSequenceData = {
        name = "attackAnim",
        start = 1,
        count = 8,
        time = 350,
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
        if projectileCallback then
            projectileCallback()
        end
    end)
    attackerSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            print("playAttackerAnimation: Animação do atacante terminou.")
            if attackerSprite.removeSelf then
                attackerSprite:removeSelf()
            end
            transition.to(highlight, {
                time = 500,
                alpha = 0,
                onComplete = function()
                    if highlight.removeSelf then
                        highlight:removeSelf()
                    end
                    if finalCallback then
                        finalCallback()
                    end
                end
            })
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
        if callback then
            callback()
        end
        return
    end

    local cardImageAttacker = attackerGroup[1] or attackerGroup
    local startX, startY = cardImageAttacker:localToContent(cardImageAttacker.x, cardImageAttacker.y)

    local cardImageTarget = targetGroup[1] or targetGroup
    local targetX, targetY = cardImageTarget:localToContent(cardImageTarget.x, cardImageTarget.y)

    local projectileSheetOptions = {
        frames = {{
            x = 1,
            y = 1,
            width = 1280,
            height = 720
        }, {
            x = 1283,
            y = 1,
            width = 1280,
            height = 720
        }, {
            x = 1,
            y = 723,
            width = 1280,
            height = 720
        }, {
            x = 1283,
            y = 723,
            width = 1280,
            height = 720
        }, {
            x = 1,
            y = 1445,
            width = 1280,
            height = 720
        }, {
            x = 1283,
            y = 1445,
            width = 1280,
            height = 720
        }, {
            x = 1,
            y = 2167,
            width = 1280,
            height = 720
        }, {
            x = 1283,
            y = 2167,
            width = 1280,
            height = 720
        }, {
            x = 2565,
            y = 1,
            width = 1280,
            height = 720
        }, {
            x = 2565,
            y = 723,
            width = 1280,
            height = 720
        }, {
            x = 2565,
            y = 1445,
            width = 1280,
            height = 720
        }}
    }
    local projectileSheet = graphics.newImageSheet("assets/7effect/firebolas.png", projectileSheetOptions)
    local projectileSequenceData = {
        name = "projectile",
        start = 1,
        count = 11,
        time = 500,
        loopCount = 0
    }
    local projectileSprite = display.newSprite(projectileSheet, projectileSequenceData)
    projectileSprite.anchorX = 0.5
    projectileSprite.anchorY = 0.5
    projectileSprite.x = startX
    projectileSprite.y = startY
    projectileSprite:scale(0.6 * deviceScaleFactor, 0.6 * deviceScaleFactor)
    projectileSprite.alpha = 0 -- Inicia invisível para o fade in
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
                    time = 300,
                    x = targetX,
                    y = targetY,
                    transition = easing.linear,
                    onComplete = function()
                        if projectileSprite.removeSelf then
                            projectileSprite:removeSelf()
                        end
                        if callback then
                            callback()
                        end
                    end
                })
            end)
        end
    })
end

--------------------------------------------------
-- Função principal: fire_liberation.attack
--------------------------------------------------
function fire_liberation.attack(attacker, target, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("fire_liberation.attack: Objeto de display do atacante não encontrado. Aplicando dano sem animação.")
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * 0.50))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback then
            callback()
        end
        return
    end

    cardGroup:toFront()
    print("fire_liberation.attack: Iniciando animação de ação do atacante via spritesheet.")
    playAttackerAnimation(cardGroup, function() -- Callback para disparar o projetil durante a animação do atacante
        print("fire_liberation.attack: Disparando projetil durante a animação do atacante.")
        playProjectileAnimation(attacker, target, battleFunctions, function()
            print("fire_liberation.attack: Projetil completado.")
        end)
    end, function() -- Callback final após a animação do atacante
        local targetGroup = target.group or target
        if targetGroup then
            print("fire_liberation.attack: Aplicando tremor no alvo.")
            shakeTarget(targetGroup, function()
                print("fire_liberation.attack: Tremor concluído; exibindo efeito de hit no alvo.")
                showHitEffect(targetGroup, function()
                    local atkValue = tonumber(attacker.atk) or 0
                    local damage = math.max(1, math.floor(atkValue * 0.50))
                    battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                    print("fire_liberation.attack: Efeito de hit concluído; dano de " .. damage .. " aplicado.")
                    if callback then
                        callback()
                    end
                end)
            end)
        else
            local atkValue = tonumber(attacker.atk) or 0
            local damage = math.max(1, math.floor(atkValue * 0.45))
            battleFunctions.applyDamage(attacker, target, damage, targetSlot)
            print("fire_liberation.attack: Alvo sem objeto de display; dano aplicado sem efeito de hit.")
            if callback then
                callback()
            end
        end
    end)
end

return fire_liberation
