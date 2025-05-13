local senbon = {}

-- Variáveis de controle de escala (ajuste conforme necessário)
local attackerAnimScale = 1.5
local hitEffectScale = 2.9

--------------------------------------------------
-- Fase 3: Efeito de hit com tremor
--------------------------------------------------
local function showHitEffect(targetGroup, callback)
    local hitSheetOptions = {
        frames = {
            { x = 446, y = 88,  width = 1,   height = 1 },
            { x = 328, y = 2,   width = 88,  height = 116 },
            { x = 328, y = 2,   width = 88,  height = 116 },
            { x = 2,   y = 2,   width = 148, height = 90 },
            { x = 2,   y = 2,   width = 148, height = 90 },
            { x = 152, y = 2,   width = 174, height = 88 },
            { x = 446, y = 2,   width = 132, height = 84 },
            { x = 446, y = 2,   width = 132, height = 84 },
            { x = 580, y = 2,   width = 114, height = 84 },
        }
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
            if hitSprite.removeSelf then hitSprite:removeSelf() end
            if callback then callback() end
        end
    end)
end

--------------------------------------------------
-- Fase 1: Animação do atacante (spritesheet de ação com destaque)
-- Recebe dois callbacks – um para disparar o projetil e outro (final) para limpeza.
--------------------------------------------------
local function playAttackerAnimation(cardGroup, projectileCallback, finalCallback)
    local origX, origY = cardGroup.x, cardGroup.y

    cardGroup:toFront()
    print("playAttackerAnimation: Iniciando animação do atacante via spritesheet.")
    local attackerSheetOptions = {
        frames = {
            { x = 0, y = 0, width = 0, height = 0 },
            { x = 2,   y = 482, width = 292, height = 152 },
            { x = 2,   y = 326, width = 300, height = 154 },
            { x = 2,   y = 166, width = 300, height = 158 },
            { x = 304, y = 2,   width = 300, height = 162 },
            { x = 2,   y = 2,   width = 300, height = 162 },
            { x = 304, y = 304, width = 300, height = 156 },
            { x = 2,   y = 636, width = 222, height = 152 },
        }
    }
    local attackerSheet = graphics.newImageSheet("assets/7effect/action_14.png", attackerSheetOptions)
    local attackerSequenceData = {
        name = "attackAnim",
        start = 1,
        count = 1,
        time = 1,
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
    timer.performWithDelay(400, function()
        if projectileCallback then projectileCallback() end
    end)
    attackerSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            print("playAttackerAnimation: Animação do atacante terminou.")
            if attackerSprite.removeSelf then attackerSprite:removeSelf() end
            if finalCallback then finalCallback() end
        end
    end)
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
        if callback then callback() end
        return
    end

    local cardImageAttacker = attackerGroup[1] or attackerGroup
    local startX, startY = cardImageAttacker:localToContent(cardImageAttacker.x, cardImageAttacker.y)

    local cardImageTarget = targetGroup[1] or targetGroup
    local targetX, targetY = cardImageTarget:localToContent(cardImageTarget.x, cardImageTarget.y)

    local projectileSheetOptions = {
        frames = {
            { x = 104, y = 2, width = 18, height = 62 },
            { x = 70,  y = 2, width = 32, height = 74 },
            { x = 36,  y = 2, width = 32, height = 74 },
            { x = 2,   y = 2, width = 32, height = 74 },
            { x = 2,   y = 78, width = 30, height = 74 },
            { x = 2,   y = 78, width = 30, height = 74 },
        }
    }
    local projectileSheet = graphics.newImageSheet("assets/7effect/bullet_2.png", projectileSheetOptions)
    local projectileSequenceData = {
        name = "projectile",
        start = 1,
        count = 6,
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
                        if projectileSprite.removeSelf then projectileSprite:removeSelf() end
                        if callback then callback() end
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
        if callback then callback() end
        return
    end

    cardGroup:toFront()
    print("senbon.attack: Iniciando animação de ação do atacante via spritesheet.")
    playAttackerAnimation(cardGroup,
        function()  -- Callback para disparar o projetil durante a animação
            print("senbon.attack: Disparando projetil durante a animação do atacante.")
            playProjectileAnimation(attacker, target, battleFunctions, function()
                print("senbon.attack: Projetil completado.")
                -- Somente após o término do projetil, dispara o hit effect
                local targetGroup
                if target.isOpponent then
                    targetGroup = target.group or gridSlotsOpponent[targetSlot] or target
                else
                    targetGroup = target.group or gridSlotsPlayer[targetSlot] or _G.playerGridGroup or target
                end
                if targetGroup then
                    print("senbon.attack: Exibindo efeito de hit no alvo.")
                    showHitEffect(targetGroup, function()
                        local atkValue = tonumber(attacker.atk) or 0
                        local damage = math.max(1, math.floor(atkValue * 0.50))
                        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                        print("senbon.attack: Efeito de hit concluído; dano de " .. damage .. " aplicado.")
                        if callback then callback() end
                    end)
                else
                    local atkValue = tonumber(attacker.atk) or 0
                    local damage = math.max(1, math.floor(atkValue * 0.50))
                    battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                    print("senbon.attack: Alvo sem objeto de display; dano aplicado sem efeito de hit.")
                    if callback then callback() end
                end
            end)
        end,
        function()  
            -- Callback final da animação do atacante (opcional para limpeza)
        end
    )
end

return senbon
