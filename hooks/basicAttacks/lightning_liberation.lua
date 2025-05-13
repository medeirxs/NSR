local senbon = {}

local function showHitEffect(targetGroup, callback)
    local hitSheetOptions = {
        frames = {
            { x = 316, y = 324, width = 312, height = 320 },
            { x = 316, y = 2,   width = 312, height = 320 },
            { x = 2,   y = 646, width = 312, height = 320 },
            { x = 2,   y = 324, width = 312, height = 320 },
            { x = 2,   y = 2,   width = 312, height = 320 },
            { x = 630, y = 2,   width = 256, height = 268 },
            { x = 316, y = 646, width = 320, height = 302 },
            { x = 620, y = 646, width = 296, height = 284 },
            { x = 630, y = 272, width = 240, height = 232 },
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/hit_UNIVERSAL.png", hitSheetOptions)
    local hitSequenceData = {
        name = "hit",
        start = 1,
        count = 9,
        time = 600,
        loopCount = 1
    }
    local hitSprite = display.newSprite(hitSheet, hitSequenceData)
    hitSprite.anchorX = 0.5
    hitSprite.anchorY = 0.5
    hitSprite.x = 0
    hitSprite.y = 0
    targetGroup:insert(hitSprite)
    hitSprite:toFront()
    hitSprite:play()
    hitSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            hitSprite:removeSelf()
            if callback then callback() end
        end
    end)
end

function senbon.attack(attacker, target, battleFunctions, targetSlot, callback)
    local animationDuration = 200
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("senbon.attack: Objeto de display do atacante não encontrado. Aplicando dano sem animação.")
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * 0.50))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback then callback() end
        return
    end

    local origX, origY = cardGroup.x, cardGroup.y

    cardGroup:toFront()
    print("senbon.attack: Iniciando animação de zoom. Atacante Atk = " .. tostring(attacker.atk))
    transition.to(cardGroup, {
        time = animationDuration,
        xScale = 1.3,
        yScale = 1.3,
        transition = easing.outQuad,
        onComplete = function()
            transition.to(cardGroup, {
                time = animationDuration,
                xScale = 1.0,
                yScale = 1.0,
                transition = easing.inQuad,
                onComplete = function()
                    cardGroup.x = origX
                    cardGroup.y = origY
                    local atkValue = tonumber(attacker.atk) or 0
                    local damage = math.max(1, math.floor(atkValue * 0.50))
                    print("senbon.attack: Zoom out concluído. Atk = " .. atkValue .. ", Damage calculado = " .. damage)
                    local targetGroup = target.group or target
                    if targetGroup then
                        print("senbon.attack: Exibindo efeito de hit no alvo.")
                        showHitEffect(targetGroup, function()
                            battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                            print("senbon.attack: Efeito de hit concluído; dano de " .. damage .. " aplicado.")
                            if callback then callback() end
                        end)
                    else
                        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                        print("senbon.attack: Alvo sem objeto de display; dano aplicado sem efeito de hit.")
                        if callback then callback() end
                    end
                end
            })
        end
    })
end

return senbon
