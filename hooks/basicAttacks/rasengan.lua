local rasengan = {}

-- Configurações de design e escala
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth and (display.actualContentWidth / designWidth) or 1

-- Controlador global de escala para as animações
local animScale = 1.0
local bulletScale = 0.7
-- Parâmetros do ataque (ajuste conforme necessário)
local baseDamageMultiplier = 1.10

-- Controle de escala para a animação de hit (já considerando o global)
local hitAnimScale = 1.7 -- ajuste conforme necessário

-- Configuração da spritesheet de hit
local hitSheetOptions = {
    frames = {{
        x = 1,
        y = 1,
        width = 237,
        height = 193
    }, {
        x = 240,
        y = 1,
        width = 235,
        height = 197
    }, {
        x = 477,
        y = 1,
        width = 231,
        height = 197
    }, {
        x = 710,
        y = 1,
        width = 237,
        height = 197
    }, {
        x = 1,
        y = 200,
        width = 237,
        height = 197
    }, {
        x = 240,
        y = 200,
        width = 239,
        height = 197
    }, {
        x = 481,
        y = 200,
        width = 243,
        height = 197
    }, {
        x = 726,
        y = 200,
        width = 239,
        height = 197
    }, {
        x = 1,
        y = 399,
        width = 241,
        height = 197
    }, {
        x = 244,
        y = 399,
        width = 239,
        height = 197
    }, {
        x = 485,
        y = 399,
        width = 245,
        height = 197
    }, {
        x = 732,
        y = 399,
        width = 239,
        height = 197
    }, {
        x = 1,
        y = 598,
        width = 241,
        height = 197
    }, {
        x = 244,
        y = 598,
        width = 237,
        height = 197
    }, {
        x = 483,
        y = 598,
        width = 241,
        height = 197
    }, {
        x = 726,
        y = 598,
        width = 241,
        height = 197
    }, {
        x = 949,
        y = 1,
        width = 241,
        height = 193
    }, {
        x = 967,
        y = 196,
        width = 239,
        height = 195
    }, {
        x = 973,
        y = 393,
        width = 239,
        height = 193
    }, {
        x = 973,
        y = 588,
        width = 243,
        height = 197
    }}
}
local hitSheet = graphics.newImageSheet("assets/7effect/hit_102.png", hitSheetOptions)
local hitSequenceData = {
    name = "hitAnim",
    start = 1,
    count = 20,
    time = 500, -- tempo da animação de hit
    loopCount = 1
}

--------------------------------------------------------------------------------
-- Função auxiliar: safeManageCardTurn (já definida acima)
--------------------------------------------------------------------------------
local function safeManageCardTurn(cardData, action, value)
    if battleFunctions and battleFunctions.manageCardTurn then
        battleFunctions.manageCardTurn(cardData, action, value)
    elseif _G.manageCardTurn then
        _G.manageCardTurn(cardData, action, value)
    else
        print("manageCardTurn function not defined, skipping block action.")
    end
end

--------------------------------------------------
-- Configuração da spritesheet para a animação de zoom in (up)
--------------------------------------------------
local upSheetOptions = {
    frames = {{
        x = 277,
        y = 715,
        width = 66,
        height = 61
    }, {
        x = 326,
        y = 844,
        width = 95,
        height = 89
    }, {
        x = 340,
        y = 715,
        width = 135,
        height = 127
    }, {
        x = 171,
        y = 801,
        width = 158,
        height = 153
    }, {
        x = 2,
        y = 538,
        width = 273,
        height = 261
    }, {
        x = 2,
        y = 275,
        width = 273,
        height = 261
    }, {
        x = 2,
        y = 2,
        width = 278,
        height = 271
    }}
}
local upSheet = graphics.newImageSheet("assets/7effect/action_103.png", upSheetOptions)
local upSequenceData = {
    name = "upAnim",
    start = 1,
    count = 7,
    time = 500,
    loopCount = 1
}

--------------------------------------------------
-- Configuração da spritesheet para a animação extra
--------------------------------------------------
local extra2SheetOptions = {
    frames = {{
        x = 1,
        y = 1,
        width = 960,
        height = 540
    }, {
        x = 963,
        y = 1,
        width = 960,
        height = 540
    }, {
        x = 1,
        y = 543,
        width = 960,
        height = 540
    }, {
        x = 963,
        y = 543,
        width = 960,
        height = 540
    }, {
        x = 1,
        y = 1085,
        width = 960,
        height = 540
    }, {
        x = 963,
        y = 1085,
        width = 960,
        height = 540
    }, {
        x = 1,
        y = 1627,
        width = 960,
        height = 540
    }, {
        x = 963,
        y = 1627,
        width = 960,
        height = 540
    }, {
        x = 1925,
        y = 1,
        width = 960,
        height = 540
    }, {
        x = 1925,
        y = 543,
        width = 960,
        height = 540
    }, {
        x = 1925,
        y = 1085,
        width = 960,
        height = 540
    }, {
        x = 1925,
        y = 1627,
        width = 960,
        height = 540
    }}
}
local extra2Sheet = graphics.newImageSheet("assets/7effect/bullet_110.png", extra2SheetOptions)
local extra2SequenceData = {
    name = "extra2Anim",
    start = 1,
    count = 12,
    time = 400,
    loopCount = 0
}

--------------------------------------------------
-- Função playUpAnimation (animação de zoom in via spritesheet)
-- O upSprite é criado como filho do cardGroup e acompanha a carta durante o zoom in.
--------------------------------------------------
local function playUpAnimation(cardGroup, callback)
    local upSprite = display.newSprite(upSheet, upSequenceData)
    upSprite.anchorX = 0.5
    upSprite.anchorY = 0.5
    upSprite.x, upSprite.y = 0, 0 -- centralizado no cardGroup
    cardGroup:insert(upSprite)
    upSprite:toFront()

    upSprite.alpha = 0
    transition.to(upSprite, {
        time = 200,
        alpha = 1
    })
    transition.to(upSprite, {
        delay = 500 - 10,
        time = 200,
        alpha = 0
    }) -- fade out inicia 10 ms antes do fim
    upSprite:play()
    upSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if upSprite.removeSelf then
                upSprite:removeSelf()
            end
            if callback then
                callback()
            end
        end
    end)

    -- Inicia a animação extra 10 ms antes do término do up animation
    timer.performWithDelay(500 - 30, function()
        cardGroup.extraSprite2 = display.newSprite(extra2Sheet, extra2SequenceData)
        cardGroup.extraSprite2.anchorX = 0.5
        cardGroup.extraSprite2.anchorY = 0.5
        cardGroup.extraSprite2.x, cardGroup.extraSprite2.y = 0, 0 -- centralizado em cardGroup
        cardGroup:insert(cardGroup.extraSprite2)
        cardGroup.extraSprite2:toFront()
        cardGroup.extraSprite2:scale(bulletScale, bulletScale) -- aplica o controlador de escala extra (pode ser ajustado)
        cardGroup.extraSprite2:play()
    end)
end

--------------------------------------------------------------------------------
-- Função principal: rasengan.attack
--------------------------------------------------------------------------------
function rasengan.attack(attacker, target, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * baseDamageMultiplier))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback then
            callback()
        end
        return
    end

    local parent = cardGroup.parent
    local origX, origY = cardGroup.x, cardGroup.y
    local origScaleX, origScaleY = cardGroup.xScale or 1, cardGroup.yScale or 1

    cardGroup:toFront()
    print("rasengan.attack: Iniciando zoom in. Atacante Atk = " .. tostring(attacker.atk))
    -- Zoom in: aumenta a escala da carta (controlado pelo animScale)
    transition.to(cardGroup, {
        time = 250,
        xScale = origScaleX * 1.1 * animScale,
        yScale = origScaleY * 1.1 * animScale,
        transition = easing.outQuad,
        onComplete = function()
            playUpAnimation(cardGroup, function()
                -- Após o up animation, move a carta para o centro do alvo
                local targetGroup = target.group or target
                if not targetGroup then
                    local atkValue = tonumber(attacker.atk) or 0
                    local damage = math.max(1, math.floor(atkValue * baseDamageMultiplier))
                    battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                    if callback then
                        callback()
                    end
                    return
                end
                local bounds = targetGroup.contentBounds
                local globalTargetX = (bounds.xMin + bounds.xMax) * 0.5
                local globalTargetY = (bounds.yMin + bounds.yMax) * 0.5
                local localTargetX, localTargetY = parent:contentToLocal(globalTargetX, globalTargetY)
                local offsetY = 120
                if attacker.isOpponent then
                    offsetY = -120
                end
                transition.to(cardGroup, {
                    time = 500,
                    x = localTargetX,
                    y = localTargetY + offsetY,
                    transition = easing.linear,
                    onComplete = function()
                        timer.performWithDelay(10, function()
                            if cardGroup.extraSprite2 and cardGroup.extraSprite2.removeSelf then
                                cardGroup.extraSprite2:removeSelf()
                                cardGroup.extraSprite2 = nil
                            end
                        end)
                        -- Cria a animação de hit sobre o alvo usando coordenadas globais convertidas
                        local hitSprite = display.newSprite(hitSheet, hitSequenceData)
                        hitSprite.anchorX = targetGroup.anchorX or 0.5
                        hitSprite.anchorY = targetGroup.anchorY or 0.5
                        local globalPosX, globalPosY = parent:localToContent(localTargetX, localTargetY)
                        hitSprite.x = globalPosX
                        hitSprite.y = globalPosY
                        display.getCurrentStage():insert(hitSprite)
                        hitSprite:toFront()
                        hitSprite.alpha = 0
                        transition.to(hitSprite, {
                            time = 300,
                            alpha = 0.8
                        })
                        hitSprite:scale((hitAnimScale or 1) * animScale, (hitAnimScale or 1) * animScale)
                        hitSprite:play()
                        hitSprite:addEventListener("sprite", function(event)
                            if event.phase == "ended" then
                                hitSprite:removeSelf()
                                local atkValue = tonumber(attacker.atk) or 0
                                local damage = math.max(1, math.floor(atkValue * baseDamageMultiplier))
                                battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                                transition.to(cardGroup, {
                                    time = 400,
                                    x = origX,
                                    y = origY,
                                    xScale = origScaleX * animScale,
                                    yScale = origScaleY * animScale,
                                    transition = easing.inQuad,
                                    onComplete = function()
                                        if callback then
                                            callback()
                                        end
                                    end
                                })
                            end
                        end)
                    end
                })
            end)
        end
    })
end

return rasengan

