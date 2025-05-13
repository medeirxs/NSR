local fliyng_rasengan = {}

local designWidth = 1080
local deviceScaleFactor = (display.actualContentWidth and (display.actualContentWidth / designWidth)) or 1

local animScale = 1.0 
local bulletScale = 2.0
local baseDamageMultiplier = 1.10
local hitAnimScale = 2.0

-- Configuração da spritesheet de hit
local hitSheetOptions = {
    frames = {
        { x = 2,    y = 2,    width = 234, height = 240 },
        { x = 508,  y = 2,    width = 272, height = 230 },
        { x = 1284, y = 2,    width = 276, height = 222 },
        { x = 1562, y = 2,    width = 254, height = 218 },
        { x = 782,  y = 2,    width = 284, height = 226 },
        { x = 244,  y = 2,    width = 262, height = 232 },
        { x = 1068, y = 2,    width = 214, height = 226 },
        { x = 1818, y = 2,    width = 182, height = 214 },
    }
}
local hitSheet = graphics.newImageSheet("assets/7effect/hit_27.png", hitSheetOptions)
local hitSequenceData = {
    name = "hitAnim",
    start = 1,
    count = 8,
    time = 400,
    loopCount = 1
}

-- Spritesheet para a animação extra (extra anim)
local extra2SheetOptions = {
    frames = {
        { x = 277, y = 715, width = 66,  height = 61 },
        { x = 326, y = 844, width = 95,  height = 89 },
        { x = 340, y = 715, width = 135, height = 127 },
        { x = 171, y = 801, width = 158, height = 153 },
        { x = 2,   y = 538, width = 273, height = 261 },
        { x = 2,   y = 275, width = 273, height = 261 },
        { x = 2,   y = 2,   width = 278, height = 271 },
        { x = 277, y = 279, width = 232, height = 228 },
        { x = 282, y = 2,   width = 275, height = 219 },
        { x = 277, y = 513, width = 200, height = 206 },
        { x = 2,   y = 801, width = 167, height = 165 },
    }
}
local extra2Sheet = graphics.newImageSheet("assets/7effect/action_103.png", extra2SheetOptions)
local extra2SequenceData = {
    name = "extra2Anim",
    start = 1,
    count = 11,
    time = 500,
    loopCount = 1
}

--------------------------------------------------
-- Função auxiliar: shakeTarget
--------------------------------------------------
local function shakeTarget(targetGroup, onComplete)
    local origX = targetGroup.x
    local origY = targetGroup.y
    local origRotation = targetGroup.rotation or 0
    local shakeDistance = 5
    local shakeTime = 50

    transition.to(targetGroup, {
        time = shakeTime,
        x = origX + shakeDistance,
        rotation = origRotation,
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
                            if onComplete and type(onComplete) == "function" then onComplete() end
                        end
                    })
                end
            })
        end
    })
end

--------------------------------------------------
-- Função playUpAnimation (animação de zoom in via spritesheet)
--------------------------------------------------
local function playUpAnimation(cardGroup, callback)
    local upSheetOptions = {
        frames = {
            { x = 302, y = 606, width = 144, height = 144 },
            { x = 2,   y = 606, width = 300, height = 298 },
            { x = 2,   y = 304, width = 300, height = 300 },
            { x = 2,   y = 2,   width = 300, height = 300 },
        }
    }
    local upSheet = graphics.newImageSheet("assets/7effect/action_104.png", upSheetOptions)
    local upSequenceData = {
        name = "upAnim",
        start = 1,
        count = 4,
        time = 500,
        loopCount = 1
    }

    local upSprite = display.newSprite(upSheet, upSequenceData)
    upSprite.anchorX = 0.5
    upSprite.anchorY = 0.5
    upSprite.x, upSprite.y = 0, 0
    cardGroup:insert(upSprite)
    upSprite:toFront()

    upSprite.alpha = 0
    transition.to(upSprite, { time = 200, alpha = 1 })
    transition.to(upSprite, { delay = 490, time = 200, alpha = 0 })
    upSprite:play()
    upSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if upSprite.removeSelf then upSprite:removeSelf() end
            if callback and type(callback) == "function" then callback() end
        end
    end)
end

--------------------------------------------------
-- Função auxiliar: getLowestLifeTarget
--------------------------------------------------
local function getLowestLifeTarget(formation)
    if type(formation) ~= "table" then
        print("getLowestLifeTarget: Formação inválida, não é uma tabela.")
        return nil, nil
    end

    print("getLowestLifeTarget: Iniciando varredura da formação...")
    local lowestRatio = math.huge
    local lowestTarget = nil
    local lowestSlot = nil
    for key, card in pairs(formation) do
        if card and type(card) == "table" then
            local currentHp = tonumber(card.hp) or 0
            local maxHp = tonumber(card.maxHp) or tonumber(card.originalHP) or 1
            local ratio = (maxHp > 0) and (currentHp / maxHp) or 1.0
            print("Chave " .. tostring(key) .. ": " .. (card.name or "Sem Nome") ..
                  " | HP: " .. currentHp .. " / " .. maxHp .. " = " .. ratio)
            if ratio < lowestRatio then
                lowestRatio = ratio
                lowestTarget = card
                lowestSlot = key
            end
        else
            print("Chave " .. tostring(key) .. " não possui dados válidos.")
        end
    end

    if lowestTarget then
        print("Alvo selecionado -> Chave " .. tostring(lowestSlot) .. ": " ..
              (lowestTarget.name or "Sem Nome") .. " | Ratio: " .. lowestRatio)
    else
        print("Nenhum alvo válido encontrado na formação.")
    end
    return lowestTarget, lowestSlot
end

--------------------------------------------------
-- Função auxiliar: safeManageCardTurn (já definida acima)
--------------------------------------------------
local function safeManageCardTurn(cardData, action, value)
    if battleFunctions and battleFunctions.manageCardTurn then
        battleFunctions.manageCardTurn(cardData, action, value)
    elseif _G.manageCardTurn then
        _G.manageCardTurn(cardData, action, value)
    else
        print("manageCardTurn function not defined, skipping block action.")
    end
end

------------------------------------------------------------------
-- Função principal: fliyng_rasengan.attack
------------------------------------------------------------------
function fliyng_rasengan.attack(attacker, target, battleFunctions, targetSlot, callback)
    -- Seleciona o alvo com menor vida da formação inimiga, se disponível.
    local enemyFormation = nil
    if attacker.isOpponent then
        enemyFormation = _G.playerFormationData
    else
        enemyFormation = _G.opponentFormationData
    end
    
    if enemyFormation then
        print("fliyng_rasengan.attack: Formação inimiga encontrada.")
        local lowestTarget, lowestTargetSlot = getLowestLifeTarget(enemyFormation)
        if lowestTarget then
            target = lowestTarget
            targetSlot = lowestTargetSlot
        else
            print("fliyng_rasengan.attack: Nenhum alvo com menor vida encontrado; utilizando target original.")
        end
    else
        print("fliyng_rasengan.attack: Formação inimiga inexistente; utilizando target original.")
    end

    local cardGroup = attacker.group or attacker
    if not cardGroup then
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * baseDamageMultiplier))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback and type(callback) == "function" then
            callback()
        end
        return
    end

    local parent = cardGroup.parent
    local origX, origY = cardGroup.x, cardGroup.y
    local origScaleX, origScaleY = cardGroup.xScale or 1, cardGroup.yScale or 1

    cardGroup:toFront()
    print("fliyng_rasengan.attack: Iniciando zoom in. Atacante Atk = " .. tostring(attacker.atk))
    transition.to(cardGroup, {
        time = 200,
        xScale = origScaleX * 1.2 * animScale,
        yScale = origScaleY * 1.2 * animScale,
        transition = easing.outQuad,
        onComplete = function()
            playUpAnimation(cardGroup, function()
                local targetGroup = target.group or target
                if not targetGroup then
                    local atkValue = tonumber(attacker.atk) or 0
                    local damage = math.max(1, math.floor(atkValue * 1.0))
                    battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                    if callback and type(callback) == "function" then callback() end
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
                    time = 50,
                    alpha = 0,
                    transition = easing.linear,
                    onComplete = function()
                        timer.performWithDelay(150, function()
                            cardGroup.x = localTargetX
                            cardGroup.y = localTargetY + offsetY
                            transition.to(cardGroup, {
                                time = 50,
                                alpha = 1,
                                onComplete = function()
                                    transition.to(cardGroup, {
                                        time = 0,
                                        xScale = origScaleX * 1.3,
                                        yScale = origScaleY * 1.3,
                                        transition = easing.outQuad,
                                        onComplete = function()
                                            transition.to(cardGroup, {
                                                time = 100,
                                                xScale = origScaleX,
                                                yScale = origScaleY,
                                                transition = easing.inQuad,
                                                onComplete = function()
                                                    local extraSprite = display.newSprite(extra2Sheet, extra2SequenceData)
                                                    extraSprite.anchorX = 0.5
                                                    extraSprite.anchorY = 0.5
                                                    extraSprite.x, extraSprite.y = 0, 0
                                                    cardGroup:insert(extraSprite)
                                                    extraSprite:toFront()
                                                    extraSprite:scale(bulletScale, bulletScale)
                                                    extraSprite:play()
                                                    extraSprite:addEventListener("sprite", function(event)
                                                        if event.phase == "ended" then
                                                            if extraSprite.removeSelf then extraSprite:removeSelf() end
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
                                                                    transition.to(cardGroup, {
                                                                        time = 400,
                                                                        x = origX,
                                                                        y = origY,
                                                                        xScale = origScaleX * animScale,
                                                                        yScale = origScaleY * animScale,
                                                                        transition = easing.inQuad,
                                                                        onComplete = function()
                                                                            if callback and type(callback) == "function" then callback() end
                                                                        end
                                                                    })
                                                                end
                                                            end)
                                                        end
                                                    end)
                                                end
                                            })
                                        end
                                    })
                                end
                            })
                        end)
                    end
                })
            end)
        end
    })
end

return fliyng_rasengan
