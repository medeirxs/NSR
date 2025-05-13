local noturne_guy = {}

-- Configurações de design e escala
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth and (display.actualContentWidth / designWidth) or 1

-- Controlador global de escala para as animações
local animScale = 1.0
local bulletScale = 5.0
-- Parâmetros do ataque (ajuste conforme necessário)
local baseDamageMultiplier = 0.9 -- Valor base atualizado para 0.9

-- Controle de escala para a animação de hit (já considerando o global)
local hitAnimScale = 1.0 -- ajuste conforme necessário

-- Controle de escala específica para a animação de zoom in (upAnim)
local upAnimScale = 3.0 -- ajuste conforme necessário

-- Configuração da spritesheet de hit
local hitSheetOptions = {
    frames = {{
        x = 1,
        y = 1,
        width = 1280,
        height = 720
    }, {
        x = 1,
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
        y = 1,
        width = 1280,
        height = 720
    }, {
        x = 1283,
        y = 723,
        width = 1280,
        height = 720
    }, {
        x = 1283,
        y = 1445,
        width = 1280,
        height = 720
    }}
}
local hitSheet = graphics.newImageSheet("assets/7effect/hit_100.png", hitSheetOptions)
local hitSequenceData = {
    name = "hitAnim",
    start = 1,
    count = 6,
    time = 400,
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
        x = 2,
        y = 2,
        width = 134,
        height = 164
    }, {
        x = 1074,
        y = 2,
        width = 132,
        height = 162
    }, {
        x = 674,
        y = 2,
        width = 130,
        height = 164
    }, {
        x = 540,
        y = 2,
        width = 132,
        height = 164
    }, {
        x = 940,
        y = 2,
        width = 132,
        height = 162
    }, {
        x = 806,
        y = 2,
        width = 132,
        height = 162
    }, {
        x = 1472,
        y = 2,
        width = 130,
        height = 162
    }, {
        x = 1340,
        y = 2,
        width = 130,
        height = 162
    }, {
        x = 406,
        y = 2,
        width = 132,
        height = 164
    }, {
        x = 1208,
        y = 2,
        width = 130,
        height = 162
    }, {
        x = 272,
        y = 2,
        width = 132,
        height = 164
    }, {
        x = 138,
        y = 2,
        width = 132,
        height = 164
    }}
}
local upSheet = graphics.newImageSheet("assets/7effect/noturne_guy_action.png", upSheetOptions)
local upSequenceData = {
    name = "upAnim",
    start = 1,
    count = 12,
    time = 500,
    loopCount = 0
}

--------------------------------------------------
-- Extra Animation: será um PNG
--------------------------------------------------
local extraImagePath = "assets/7effect/noturne_guy.png" -- Certifique-se de que esse arquivo exista
local extraImageWidth = 700 -- Ajuste conforme necessário
local extraImageHeight = 700

--------------------------------------------------
-- Função playUpAnimation
-- Agora recebe targetGlobalX e targetGlobalY para calcular a rotação.
--------------------------------------------------
local function playUpAnimation(cardGroup, callback, targetGlobalX, targetGlobalY)
    -- Inicia o upSprite imediatamente junto com o zoom in
    local upSprite = display.newSprite(upSheet, upSequenceData)
    upSprite.anchorX = 0.5
    upSprite.anchorY = 0.5
    upSprite.x, upSprite.y = 0, 0 -- centralizado no cardGroup
    cardGroup:insert(upSprite)
    upSprite:toBack()

    upSprite.alpha = 0
    transition.to(upSprite, {
        time = 200,
        alpha = 1
    })
    upSprite:play()
    upSprite:scale(upAnimScale, upAnimScale)
    cardGroup.upSprite = upSprite -- Armazena para remoção no final

    -- Inicia a extra animation (PNG) 100 ms após o início do zoom in
    timer.performWithDelay(100, function()
        cardGroup.extraSprite2 = display.newImageRect(cardGroup, extraImagePath, extraImageWidth, extraImageHeight)
        cardGroup.extraSprite2.anchorX = 0.5
        cardGroup.extraSprite2.anchorY = 0.5
        cardGroup.extraSprite2.x, cardGroup.extraSprite2.y = 0, 0 -- centralizado no cardGroup

        -- Se as coordenadas do alvo foram informadas, calcula a rotação para que o topo da imagem aponte para o alvo.
        if targetGlobalX and targetGlobalY then
            local cx, cy = cardGroup:localToContent(0, 0)
            local angle = math.deg(math.atan2(targetGlobalY - cy, targetGlobalX - cx)) + 90
            cardGroup.extraSprite2.rotation = angle
        end

        cardGroup.extraSprite2.alpha = 0
        transition.to(cardGroup.extraSprite2, {
            time = 400,
            alpha = 0.6,
            onComplete = function()
                timer.performWithDelay(400, function()
                    if callback then
                        callback()
                    end
                end)
            end
        })
    end)
end

--------------------------------------------------------------------------------
-- Função principal: noturne_guy.attack
--------------------------------------------------------------------------------
function noturne_guy.attack(attacker, target, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * baseDamageMultiplier))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        -- Atualiza o multiplicador (aumenta 10% do valor atual, limitado a 1.6)
        baseDamageMultiplier = baseDamageMultiplier * 1.1
        if baseDamageMultiplier > 1.6 then
            baseDamageMultiplier = 1.6
        end
        if callback then
            callback()
        end
        return
    end

    local parent = cardGroup.parent
    local origX, origY = cardGroup.x, cardGroup.y
    local origScaleX, origScaleY = cardGroup.xScale or 1, cardGroup.yScale or 1

    cardGroup:toFront()
    print("noturne_guy.attack: Iniciando zoom in. Atacante Atk = " .. tostring(attacker.atk))
    transition.to(cardGroup, {
        time = 800,
        xScale = origScaleX * 1.4 * animScale,
        yScale = origScaleY * 1.4 * animScale,
        transition = easing.outQuad,
        onComplete = function()
            local targetGroup = target.group or target
            local targetGlobalX, targetGlobalY
            if targetGroup then
                local bounds = targetGroup.contentBounds
                targetGlobalX = (bounds.xMin + bounds.xMax) * 0.5
                targetGlobalY = (bounds.yMin + bounds.yMax) * 0.5
            end

            playUpAnimation(cardGroup, function()
                if not targetGroup then
                    local atkValue = tonumber(attacker.atk) or 0
                    local damage = math.max(1, math.floor(atkValue * baseDamageMultiplier))
                    battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                    -- Atualiza o multiplicador após o ataque
                    baseDamageMultiplier = baseDamageMultiplier * 1.1
                    if baseDamageMultiplier > 1.6 then
                        baseDamageMultiplier = 1.6
                    end
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
                    time = 400,
                    x = localTargetX,
                    y = localTargetY + offsetY,
                    transition = easing.linear,
                    onComplete = function()
                        timer.performWithDelay(10, function()
                            if cardGroup.extraSprite2 and cardGroup.extraSprite2.removeSelf then
                                transition.to(cardGroup.extraSprite2, {
                                    time = 200,
                                    alpha = 0,
                                    onComplete = function()
                                        cardGroup.extraSprite2:removeSelf()
                                        cardGroup.extraSprite2 = nil
                                    end
                                })
                            end
                        end)
                        local hitSprite = display.newSprite(hitSheet, hitSequenceData)
                        hitSprite.anchorX = targetGroup.anchorX or 0.5
                        hitSprite.anchorY = targetGroup.anchorY or 0.5
                        local globalPosX, globalPosY = parent:localToContent(localTargetX, localTargetY)
                        hitSprite.x = globalPosX
                        hitSprite.y = globalPosY
                        display.getCurrentStage():insert(hitSprite)
                        hitSprite:toFront()
                        hitSprite:scale((hitAnimScale or 1) * animScale, (hitAnimScale or 1) * animScale)
                        hitSprite:play()
                        hitSprite:addEventListener("sprite", function(event)
                            if event.phase == "ended" then
                                hitSprite:removeSelf()
                                local atkValue = tonumber(attacker.atk) or 0
                                local damage = math.max(1, math.floor(atkValue * baseDamageMultiplier))
                                battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                                -- Atualiza o multiplicador após o ataque
                                baseDamageMultiplier = baseDamageMultiplier * 1.1
                                if baseDamageMultiplier > 1.6 then
                                    baseDamageMultiplier = 1.6
                                end
                                transition.to(cardGroup, {
                                    time = 500,
                                    x = origX,
                                    y = origY,
                                    xScale = origScaleX * animScale,
                                    yScale = origScaleY * animScale,
                                    transition = easing.inQuad,
                                    onComplete = function()
                                        if cardGroup.upSprite and cardGroup.upSprite.removeSelf then
                                            cardGroup.upSprite:removeSelf()
                                            cardGroup.upSprite = nil
                                        end
                                        if callback then
                                            callback()
                                        end
                                    end
                                })
                            end
                        end)
                    end
                })
            end, targetGlobalX, targetGlobalY)
        end
    })
end

return noturne_guy
