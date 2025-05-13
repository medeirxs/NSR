local rasengan = {}

-- Configurações de design e escala
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth and (display.actualContentWidth / designWidth) or 1

-- Controlador global de escala para as animações
local animScale = 1
local bulletScale = 1
-- Parâmetros do ataque (ajuste conforme necessário)
local baseDamageMultiplier = 1.10

-- Controle de escala para a animação de hit (já considerando o global)
local hitAnimScale = 1.7 -- ajuste conforme necessário

-- Configuração da spritesheet de hit
local hitSheetOptions = {
    frames = {{
        x = 124,
        y = 106,
        width = 18,
        height = 18
    }, {
        x = 714,
        y = 70,
        width = 54,
        height = 54
    }, {
        x = 456,
        y = 2,
        width = 92,
        height = 96
    }, {
        x = 714,
        y = 2,
        width = 66,
        height = 82
    }, {
        x = 630,
        y = 2,
        width = 86,
        height = 82
    }, {
        x = 278,
        y = 2,
        width = 80,
        height = 100
    }, {
        x = 202,
        y = 2,
        width = 74,
        height = 102
    }, {
        x = 550,
        y = 2,
        width = 78,
        height = 90
    }, {
        x = 124,
        y = 2,
        width = 76,
        height = 102
    }, {
        x = 360,
        y = 2,
        width = 94,
        height = 98
    }, {
        x = 2,
        y = 2,
        width = 120,
        height = 120
    }, {
        x = 770,
        y = 70,
        width = 46,
        height = 46
    }}
}
local hitSheet = graphics.newImageSheet("assets/7effect/action_25.png", hitSheetOptions)
local hitSequenceData = {
    name = "hitAnim",
    start = 1,
    count = 11,
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
        x = 643,
        y = 1,
        width = 640,
        height = 360
    }, -- chidori1-_1_
    {
        x = 1,
        y = 363,
        width = 640,
        height = 360
    }, -- chidori1-_2_
    {
        x = 643,
        y = 363,
        width = 640,
        height = 360
    }, -- chidori1-_3_
    {
        x = 1,
        y = 725,
        width = 640,
        height = 360
    }, -- chidori1-_4_
    {
        x = 643,
        y = 725,
        width = 640,
        height = 360
    }, -- chidori1-_5_
    {
        x = 1,
        y = 1087,
        width = 640,
        height = 360
    }, -- chidori1-_6_
    {
        x = 643,
        y = 1087,
        width = 640,
        height = 360
    }, -- chidori1-_7_
    {
        x = 1285,
        y = 1,
        width = 640,
        height = 360
    }, -- chidori1-_8_
    {
        x = 1285,
        y = 363,
        width = 640,
        height = 360
    }, -- chidori1-_9_
    {
        x = 1,
        y = 1,
        width = 640,
        height = 360
    } -- chidori1-_10_
    }
}
local upSheet = graphics.newImageSheet("assets/7effect/bullet_118.png", upSheetOptions)
local upSequenceData = {
    name = "upAnim",
    start = 1,
    count = 10,
    time = 1000,
    loopCount = 1
}

--------------------------------------------------
-- Configuração da spritesheet para a animação extra
--------------------------------------------------
local extra2SheetOptions = {
    frames = {{
        x = 643,
        y = 1087,
        width = 640,
        height = 360
    }, -- chidori2-_1_
    {
        x = 1285,
        y = 1087,
        width = 640,
        height = 360
    }, -- chidori2-_2_
    {
        x = 1,
        y = 1449,
        width = 640,
        height = 360
    }, -- chidori2-_3_
    {
        x = 643,
        y = 1449,
        width = 640,
        height = 360
    }, -- chidori2-_4_
    {
        x = 1285,
        y = 1449,
        width = 640,
        height = 360
    }, -- chidori2-_5_
    {
        x = 1927,
        y = 1,
        width = 640,
        height = 360
    }, -- chidori2-_6_
    {
        x = 1927,
        y = 363,
        width = 640,
        height = 360
    }, -- chidori2-_7_
    {
        x = 1927,
        y = 725,
        width = 640,
        height = 360
    }, -- chidori2-_8_
    {
        x = 1927,
        y = 1087,
        width = 640,
        height = 360
    }, -- chidori2-_9_
    {
        x = 1,
        y = 1,
        width = 640,
        height = 360
    }, -- chidori2-_10_
    {
        x = 643,
        y = 1,
        width = 640,
        height = 360
    }, -- chidori2-_11_
    {
        x = 1285,
        y = 1,
        width = 640,
        height = 360
    }, -- chidori2-_12_
    {
        x = 1,
        y = 363,
        width = 640,
        height = 360
    }, -- chidori2-_13_
    {
        x = 643,
        y = 363,
        width = 640,
        height = 360
    }, -- chidori2-_14_
    {
        x = 1285,
        y = 363,
        width = 640,
        height = 360
    }, -- chidori2-_15_
    {
        x = 1,
        y = 725,
        width = 640,
        height = 360
    }, -- chidori2-_16_
    {
        x = 643,
        y = 725,
        width = 640,
        height = 360
    }, -- chidori2-_17_
    {
        x = 1285,
        y = 725,
        width = 640,
        height = 360
    }, -- chidori2-_18_
    {
        x = 1,
        y = 1087,
        width = 640,
        height = 360
    } -- chidori2-_19_
    }
}
local extra2Sheet = graphics.newImageSheet("assets/7effect/bullet_119.png", extra2SheetOptions)
local extra2SequenceData = {
    name = "extra2Anim",
    start = 1,
    count = 19,
    time = 500,
    loopCount = 0
}

--------------------------------------------------
-- Função playUpAnimation (animação de zoom in via spritesheet)
-- O upSprite é criado como filho do cardGroup e acompanha a carta durante o zoom in.
--------------------------------------------------
local function playUpAnimation(cardGroup, callback)
    local upSprite = display.newSprite(upSheet, upSequenceData)
    upSprite.anchorX = 0.5
    upSprite.anchorY = 0.6
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
    })
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
        cardGroup.extraSprite2.anchorY = 0.7
        cardGroup.extraSprite2.x, cardGroup.extraSprite2.y = 0, 0
        cardGroup:insert(cardGroup.extraSprite2)
        cardGroup.extraSprite2:toFront()
        cardGroup.extraSprite2:scale(bulletScale, bulletScale)
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
        xScale = origScaleX * 1.1,
        yScale = origScaleY * 1.1,
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
                                    xScale = origScaleX,
                                    yScale = origScaleY,
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
