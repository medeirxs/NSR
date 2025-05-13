local eletric_jiongu = {}

-- Defina a largura de referência e calcule o fator responsivo
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth

-- Variáveis de controle de escala responsivas
local attackerAnimScale = 1.0 * deviceScaleFactor
local hitEffectScale = 3.0 * deviceScaleFactor

--------------------------------------------------
-- Função auxiliar: shakeTarget
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
                rotation = origRotation,
                transition = easing.linear,
                onComplete = function()
                    transition.to(targetGroup, {
                        time = shakeTime,
                        x = origX,
                        rotation = origRotation,
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
-- Função auxiliar: showHitEffect
--------------------------------------------------
local function showHitEffect(targetGroup, callback)
    local hitSheetOptions = {
        frames = {
            { x = 124, y = 106, width = 18,  height = 18 },
            { x = 714, y = 70,  width = 54,  height = 54 },
            { x = 456, y = 2,   width = 92,  height = 96 },
            { x = 714, y = 2,   width = 66,  height = 82 },
            { x = 630, y = 2,   width = 86,  height = 82 },
            { x = 278, y = 2,   width = 80,  height = 100 },
            { x = 202, y = 2,   width = 74,  height = 102 },
            { x = 550, y = 2,   width = 78,  height = 90 },
            { x = 124, y = 2,   width = 76,  height = 102 },
            { x = 360, y = 2,   width = 94,  height = 98 },
            { x = 2,   y = 2,   width = 120, height = 120 },
            { x = 770, y = 70,  width = 46,  height = 46 },
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/action_102.png", hitSheetOptions)
    local hitSequenceData = {
        name = "hit",
        start = 1,
        count = 12,
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
-- Função principal: playAttackerAnimation com efeito de zoom in/out
--------------------------------------------------
local function playAttackerAnimation(cardGroup, projectileCallback, finalCallback)
    -- Armazena os valores originais de escala
    local origScaleX = cardGroup.xScale or 1
    local origScaleY = cardGroup.yScale or 1

    -- Zoom in: aumenta a escala em 20%
    transition.to(cardGroup, {
        time = 100,
        xScale = origScaleX * 1.2,
        yScale = origScaleY * 1.2,
        onComplete = function()
            -- Após o zoom in, inicia a animação do atacante
            cardGroup:toFront()
            print("playAttackerAnimation: Iniciando animação do atacante via spritesheet com zoom.")
            local attackerSheetOptions = {
                frames = {
                    { x = 1,    y = 1,    width = 500, height = 500 },
                    { x = 503,  y = 1,    width = 500, height = 500 },
                    { x = 1005, y = 1,    width = 500, height = 500 },
                    { x = 1,    y = 503,  width = 500, height = 500 },
                    { x = 503,  y = 503,  width = 500, height = 500 },
                    { x = 1005, y = 503,  width = 500, height = 500 },
                    { x = 1,    y = 1005, width = 500, height = 500 },
                    { x = 503,  y = 1005, width = 500, height = 500 },
                    { x = 1005, y = 1005, width = 500, height = 500 },
                    { x = 1005, y = 1005, width = 500, height = 500 },
                    { x = 1005, y = 1005, width = 500, height = 500 },
                    { x = 1005, y = 1005, width = 500, height = 500 },
                    { x = 1005, y = 1005, width = 500, height = 500 },
                    { x = 1005, y = 1005, width = 500, height = 500 },
                }
            }
            local attackerSheet = graphics.newImageSheet("assets/7effect/bullet_107.png", attackerSheetOptions)
            local attackerSequenceData = {
                name = "attackAnim",
                start = 1,
                count = 15,
                time = 800,
                loopCount = 1
            }
            local attackerSprite = display.newSprite(attackerSheet, attackerSequenceData)
            attackerSprite.anchorX = 0.5
            attackerSprite.anchorY = 0.5
            attackerSprite.x = cardGroup.x
            attackerSprite.y = cardGroup.y
            attackerSprite:scale(attackerAnimScale, attackerAnimScale)
            cardGroup.parent:insert(attackerSprite)
            attackerSprite:toFront()
            attackerSprite:play()
            -- Chama o callback para disparar o projetil 400 ms antes do final
            timer.performWithDelay(400, function()
                if projectileCallback then projectileCallback() end
            end)
            attackerSprite:addEventListener("sprite", function(event)
                if event.phase == "ended" then
                    print("playAttackerAnimation: Animação do atacante terminou.")
                    if attackerSprite.removeSelf then attackerSprite:removeSelf() end
                    -- Zoom out: retorna à escala original com um breve transition
                    transition.to(cardGroup, {
                        time = 200,
                        xScale = origScaleX,
                        yScale = origScaleY,
                        onComplete = function()
                            if finalCallback then finalCallback() end
                        end
                    })
                end
            end)
        end
    })
end

--------------------------------------------------
-- Função auxiliar: playProjectileAnimation
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
            { x = 1,    y = 1,    width = 386, height = 626 },
            { x = 389,  y = 1,    width = 386, height = 626 },
            { x = 777,  y = 1,    width = 386, height = 626 },
            { x = 1,    y = 629,  width = 386, height = 626 },
            { x = 389,  y = 629,  width = 386, height = 626 },
            { x = 777,  y = 629,  width = 386, height = 626 },
            { x = 1165, y = 1,    width = 386, height = 626 },
            { x = 1165, y = 629,  width = 386, height = 626 },
        }
    }
    local projectileSheet = graphics.newImageSheet("assets/7effect/bullet_109.png", projectileSheetOptions)
    local projectileSequenceData = {
        name = "projectile",
        start = 1,
        count = 8,
        time = 600,
        loopCount = 0
    }
    local projectileSprite = display.newSprite(projectileSheet, projectileSequenceData)
    projectileSprite.anchorX = 0.5
    projectileSprite.anchorY = 0.5
    projectileSprite.x = startX
    projectileSprite.y = startY
    projectileSprite:scale(1.0 * deviceScaleFactor, 1.0 * deviceScaleFactor)
    projectileSprite.alpha = 0  -- Inicia invisível para efeito de fade in
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
                        if projectileSprite.removeSelf then projectileSprite:removeSelf() end
                        if callback then callback() end
                    end
                })
            end)
        end
    })
end

--------------------------------------------------
-- Função principal: eletric_jiongu.attack
--------------------------------------------------
function eletric_jiongu.attack(attacker, target, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("eletric_jiongu.attack: Objeto de display do atacante não encontrado. Aplicando dano sem animação.")
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * 0.50))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback then callback() end
        return
    end

    cardGroup:toFront()
    print("eletric_jiongu.attack: Iniciando animação de ação do atacante com zoom.")
    playAttackerAnimation(cardGroup,
        function()  -- Callback para disparar o projetil durante a animação do atacante
            print("eletric_jiongu.attack: Disparando projetil durante a animação do atacante.")
            playProjectileAnimation(attacker, target, battleFunctions, function()
                print("eletric_jiongu.attack: Projetil completado.")
            end)
        end,
        function()  -- Callback final após a animação do atacante e zoom out
            local targetGroup = target.group or target
            if targetGroup then
                print("eletric_jiongu.attack: Aplicando tremor no alvo.")
                shakeTarget(targetGroup, function()
                    print("eletric_jiongu.attack: Tremor concluído; exibindo efeito de hit no alvo.")
                    showHitEffect(targetGroup, function()
                        local atkValue = tonumber(attacker.atk) or 0
                        local damage = math.max(1, math.floor(atkValue * 0.50))
                        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                        print("eletric_jiongu.attack: Efeito de hit concluído; dano de " .. damage .. " aplicado.")
                        if callback then callback() end
                    end)
                end)
            else
                local atkValue = tonumber(attacker.atk) or 0
                local damage = math.max(1, math.floor(atkValue * 0.50))
                battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                print("eletric_jiongu.attack: Alvo sem objeto de display; dano aplicado sem efeito de hit.")
                if callback then callback() end
            end
        end
    )
end

return eletric_jiongu
