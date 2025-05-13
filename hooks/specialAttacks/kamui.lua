local kamui = {}

-- Configurações de design e escala responsiva
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth

-- Controlador de escala para a up animation
local upAnimScale = 2.0  -- ajuste conforme necessário

--------------------------------------------------
-- Função auxiliar para obter o alvo com a menor porcentagem de vida atual
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
-- Função playUpAnimation com fade in e fade out
--------------------------------------------------
local upSheetOptions = {
    frames = {
        { x = 1208, y = 2, width = 132, height = 124 },
        { x = 1208, y = 136, width = 110, height = 118 },
        { x = 1208, y = 256, width = 100, height = 112 },
        { x = 2, y = 2, width = 400, height = 158 },
        { x = 806, y = 318, width = 400, height = 156 },
        { x = 806, y = 160, width = 400, height = 156 },
        { x = 806, y = 2, width = 400, height = 156 },
        { x = 404, y = 318, width = 400, height = 156 },
        { x = 404, y = 160, width = 400, height = 156 },
        { x = 404, y = 2, width = 400, height = 156 },
        { x = 2, y = 162, width = 400, height = 156 },
        { x = 2, y = 320, width = 400, height = 154 },
        { x = 1320, y = 136, width = 1, height = 1 },
        { x = 1320, y = 136, width = 1, height = 1 },
    }
}
local upSheet = graphics.newImageSheet("assets/7effect/action_39.png", upSheetOptions)
local upSequenceData = {
    name = "upAnim",
    start = 1,
    count = 14,
    time = 1500,
    loopCount = 1
}

local function playUpAnimation(cardGroup, callback)
    local upSprite = display.newSprite(upSheet, upSequenceData)
    upSprite.anchorX = 0.5
    upSprite.anchorY = 0.5
    upSprite.x = cardGroup.x
    upSprite.y = cardGroup.y
    upSprite:scale(upAnimScale * deviceScaleFactor, upAnimScale * deviceScaleFactor)
    cardGroup.parent:insert(upSprite)
    upSprite:toFront()
    
    upSprite.alpha = 0
    transition.to(upSprite, { time = 200, alpha = 1 })
    transition.to(upSprite, { delay = 1500, time = 200, alpha = 0 })
    
    upSprite:play()
    upSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if upSprite.removeSelf then upSprite:removeSelf() end
            if callback then callback() end
        end
    end)
end

--------------------------------------------------
-- Função de tremida contínua (shake) para o alvo
--------------------------------------------------
local continuousShakeHandles = {}

local function startContinuousShake(obj)
    local function shakeCycle()
        local originalX = obj.x
        local shakeAmount = 4  -- intensidade do shake
        local shakeDuration = 50
        local t1 = transition.to(obj, { time = shakeDuration, x = originalX - shakeAmount, transition = easing.inOutSine })
        local t2 = transition.to(obj, { delay = shakeDuration, time = shakeDuration, x = originalX + shakeAmount, transition = easing.inOutSine })
        local t3 = transition.to(obj, { delay = 2 * shakeDuration, time = shakeDuration, x = originalX, transition = easing.inOutSine, onComplete = shakeCycle })
        continuousShakeHandles[obj] = { t1 = t1, t2 = t2, t3 = t3 }
    end
    shakeCycle()
end

local function stopContinuousShake(obj)
    local handles = continuousShakeHandles[obj]
    if handles then
        if handles.t1 then transition.cancel(handles.t1) end
        if handles.t2 then transition.cancel(handles.t2) end
        if handles.t3 then transition.cancel(handles.t3) end
        continuousShakeHandles[obj] = nil
    end
end

--------------------------------------------------
-- Função de hit com fade in e shake simultâneo
--------------------------------------------------
local function showHitEffect(targetGroup, callback)
    local hitSheetOptions = {
        frames = {
            { x = 1,   y = 1,    width = 466, height = 414 },
            { x = 1,   y = 417,  width = 466, height = 414 },
            { x = 1,   y = 833,  width = 466, height = 414 },
            { x = 1,   y = 1249, width = 466, height = 414 },
            { x = 1,   y = 1665, width = 466, height = 414 },
            { x = 1,   y = 2081, width = 466, height = 414 },
            { x = 1,   y = 2497, width = 466, height = 414 },
            { x = 1,   y = 2913, width = 466, height = 414 },
            { x = 1,   y = 3329, width = 466, height = 414 },
            { x = 1,   y = 3745, width = 466, height = 414 },
            { x = 1,   y = 4161, width = 466, height = 414 },
            { x = 1,   y = 4577, width = 466, height = 414 },
            { x = 1,   y = 4993, width = 466, height = 414 },
            { x = 1,   y = 5409, width = 466, height = 414 },
            { x = 1,   y = 5825, width = 466, height = 414 },
            { x = 1,   y = 6241, width = 466, height = 414 },
            { x = 1,   y = 6657, width = 466, height = 414 },
            { x = 1,   y = 7073, width = 466, height = 414 },
            { x = 1,   y = 7489, width = 466, height = 414 },
            { x = 1,   y = 7905, width = 466, height = 414 },
            { x = 1,   y = 8321, width = 466, height = 414 },
            { x = 1,   y = 8737, width = 466, height = 414 },
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/kamui.png", hitSheetOptions)
    local hitSequenceData = {
        name = "hit",
        start = 1,
        count = 22,
        time = 1000,
        loopCount = 1
    }
    local hitSprite = display.newSprite(hitSheet, hitSequenceData)
    hitSprite.anchorX = 0.5
    hitSprite.anchorY = 0.5
    hitSprite.x = 0
    hitSprite.y = 0
    targetGroup:insert(hitSprite)
    hitSprite:toFront()
    
    -- Inicia com fade in
    hitSprite.alpha = 0
    transition.to(hitSprite, { time = 300, alpha = 1, onComplete = function()
        hitSprite:play()
    end })
    
    -- Inicia o shake contínuo no targetGroup junto com o hit
    startContinuousShake(targetGroup)
    
    hitSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            stopContinuousShake(targetGroup)
            if hitSprite.removeSelf then hitSprite:removeSelf() end
            if callback then callback() end
        end
    end)
end

--------------------------------------------------
-- Função principal: kamui.attack
--------------------------------------------------
function kamui.attack(attacker, target, battleFunctions, targetSlot, callback)
    local animationDuration = 500
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("kamui.attack: Objeto de display do atacante não encontrado. Aplicando dano sem animação.")
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * 0.90))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback then callback() end
        return
    end

    if target and type(target) == "table" and not target[1] then
        local formation = nil
        if battleFunctions.getOpponents then
            formation = battleFunctions.getOpponents(attacker)
        end
        if formation and type(formation) == "table" and #formation > 0 then
            local newTarget, newSlot = getLowestLifeTarget(formation)
            if newTarget then
                print("Debug: Substituindo alvo. Slot antigo: " .. tostring(targetSlot) .. " | Novo slot: " .. tostring(newSlot))
                target = newTarget
                targetSlot = newSlot
            else
                print("Debug: Nenhum novo alvo encontrado na formação.")
            end
        end
    end

    local origX, origY = cardGroup.x, cardGroup.y

    cardGroup:toFront()
    print("kamui.attack: Iniciando animação de zoom. Atacante Atk = " .. tostring(attacker.atk))
    transition.to(cardGroup, {
        time = animationDuration,
        xScale = 1.3,
        yScale = 1.3,
        transition = easing.outQuad,
        onComplete = function()
            playUpAnimation(cardGroup, function()
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
                        print("kamui.attack: Zoom out concluído. Atk = " .. atkValue .. ", Damage = " .. damage)
                        local targetGroup = target.group or target
                        if targetGroup then
                            print("kamui.attack: Aplicando efeito de hit com shake no alvo.")
                            -- Guarda a posição original do targetGroup antes do shake
                            local targetOrigX, targetOrigY = targetGroup.x, targetGroup.y
                            showHitEffect(targetGroup, function()
                                -- Após o efeito, garante que o targetGroup retorne à posição original
                                targetGroup.x = targetOrigX
                                targetGroup.y = targetOrigY
                                battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                                print("kamui.attack: Efeito de hit concluído; dano de " .. damage .. " aplicado.")
                                if callback then callback() end
                            end)
                        else
                            battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                            print("kamui.attack: Alvo sem objeto de display; dano aplicado sem efeito de hit.")
                            if callback then callback() end
                        end
                    end
                })
            end)
        end
    })
end

return kamui
