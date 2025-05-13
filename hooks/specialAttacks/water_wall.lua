local senbon = {}

-- Variáveis de controle de escala (ajuste conforme necessário)
local attackerAnimScale = 1.5
local hitEffectScale = 2.9

--------------------------------------------------
-- Função auxiliar: shakeTarget
-- Aplica um pequeno tremor (shake) ao grupo passado.
--------------------------------------------------
local function shakeTarget(targetGroup, onComplete)
    local originalX = targetGroup.x
    local shakeDistance = 5 -- distância do tremor (ajuste conforme necessário)
    local shakeTime = 50 -- tempo de cada tremor (em ms)
    transition.to(targetGroup, {
        time = shakeTime,
        x = originalX + shakeDistance,
        transition = easing.inOutSine,
        onComplete = function()
            transition.to(targetGroup, {
                time = shakeTime,
                x = originalX - shakeDistance,
                transition = easing.inOutSine,
                onComplete = function()
                    transition.to(targetGroup, {
                        time = shakeTime,
                        x = originalX,
                        transition = easing.inOutSine,
                        onComplete = onComplete
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
            x = 446,
            y = 88,
            width = 1,
            height = 1
        }, {
            x = 328,
            y = 2,
            width = 88,
            height = 116
        }, {
            x = 328,
            y = 2,
            width = 88,
            height = 116
        }, {
            x = 2,
            y = 2,
            width = 148,
            height = 90
        }, {
            x = 2,
            y = 2,
            width = 148,
            height = 90
        }, {
            x = 152,
            y = 2,
            width = 174,
            height = 88
        }, {
            x = 446,
            y = 2,
            width = 132,
            height = 84
        }, {
            x = 446,
            y = 2,
            width = 132,
            height = 84
        }, {
            x = 580,
            y = 2,
            width = 114,
            height = 84
        }}
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/hit_2.png", hitSheetOptions)
    local hitSequenceData = {
        name = "hit",
        start = 1,
        count = 9,
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
-- Fase 1: Animação do atacante com zoom in e zoom out
-- A própria carta (cardGroup) executa o zoom antes de disparar o projetil.
--------------------------------------------------
local function playAttackerAnimation(cardGroup, projectileCallback, finalCallback)
    -- Salva a escala original
    local origScaleX = cardGroup.xScale or 1
    local origScaleY = cardGroup.yScale or 1

    cardGroup:toFront()
    print("playAttackerAnimation: Iniciando zoom in/out na carta atacante.")
    -- Executa zoom in e depois zoom out
    transition.to(cardGroup, {
        time = 100,
        xScale = origScaleX * 1.2,
        yScale = origScaleY * 1.2,
        transition = easing.inOutQuad,
        onComplete = function()
            transition.to(cardGroup, {
                time = 100,
                xScale = origScaleX,
                yScale = origScaleY,
                transition = easing.inOutQuad,
                onComplete = function()
                    if projectileCallback then
                        projectileCallback()
                    end
                end
            })
        end
    })

    if finalCallback then
        timer.performWithDelay(300, function()
            finalCallback()
        end)
    end
end

--------------------------------------------------
-- Fase 2: Animação do projetil (do atacante até o alvo)
-- O projetil inicia a partir do primeiro filho do atacante, aparece com fade in
-- e é disparado até o alvo.
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
            width = 18,
            height = 62
        }, {
            x = 21,
            y = 1,
            width = 32,
            height = 74
        }, {
            x = 55,
            y = 1,
            width = 32,
            height = 74
        }, {
            x = 89,
            y = 1,
            width = 32,
            height = 74
        }, {
            x = 123,
            y = 1,
            width = 30,
            height = 74
        }, {
            x = 1,
            y = 77,
            width = 30,
            height = 74
        }, {
            x = 33,
            y = 77,
            width = 30,
            height = 74
        }, {
            x = 65,
            y = 77,
            width = 30,
            height = 74
        }}
    }
    local projectileSheet = graphics.newImageSheet("assets/7effect/bullet_2.png", projectileSheetOptions)
    local projectileSequenceData = {
        name = "projectile",
        start = 1,
        count = 8,
        time = 500,
        loopCount = 0
    }
    local projectileSprite = display.newSprite(projectileSheet, projectileSequenceData)
    projectileSprite.anchorX = 0.5
    projectileSprite.anchorY = 0.5
    projectileSprite.x = startX
    projectileSprite.y = startY
    projectileSprite:scale(3, 3)
    projectileSprite.alpha = 0
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
-- Função principal: senbon.attack
--------------------------------------------------
function senbon.attack(attacker, target, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("senbon.attack: Objeto de display do atacante não encontrado. Aplicando dano sem animação.")
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * 0.50))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback then
            callback()
        end
        return
    end

    cardGroup:toFront()
    print("senbon.attack: Iniciando animação de ação do atacante com zoom.")
    playAttackerAnimation(cardGroup, function() -- Callback para disparar o projetil após o zoom
        print("senbon.attack: Disparando projetil após zoom in/out.")
        playProjectileAnimation(attacker, target, battleFunctions, function()
            print("senbon.attack: Projetil completado.")
            -- Após o término do projetil, identifica o objeto de display do alvo
            local targetGroup
            if target.isOpponent then
                targetGroup = target.group or gridSlotsOpponent[targetSlot] or target
            else
                targetGroup = target.group or gridSlotsPlayer[targetSlot] or _G.playerGridGroup or target
            end
            if targetGroup then
                -- Aplica tremor (shake) no alvo antes de exibir o efeito de hit
                shakeTarget(targetGroup, function()
                    print("senbon.attack: Exibindo efeito de hit no alvo após tremor.")
                    showHitEffect(targetGroup, function()
                        local atkValue = tonumber(attacker.atk) or 0
                        local damage = math.max(1, math.floor(atkValue * 0.50))
                        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                        print("senbon.attack: Efeito de hit concluído; dano de " .. damage .. " aplicado.")
                        if callback then
                            callback()
                        end
                    end)
                end)
            else
                local atkValue = tonumber(attacker.atk) or 0
                local damage = math.max(1, math.floor(atkValue * 0.40))
                battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                print("senbon.attack: Alvo sem objeto de display; dano aplicado sem efeito de hit.")
                if callback then
                    callback()
                end
            end
        end)
    end, function()
        -- Callback final da animação do atacante (opcional para limpeza)
    end)
end

return senbon
