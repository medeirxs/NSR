local healTechnique = {}

local healEffectScale = 3.5  -- Controle de tamanho da animação do efeito de cura (hit effect)
local actionScale = 3.5
--------------------------------------------------
-- Função auxiliar: getDamagePosition
-- Retorna as coordenadas do centro exato da carta, utilizando propriedades registradas ou fallback.
--------------------------------------------------
local function getDamagePosition(target)
    if target and target.cardCenterX and target.cardCenterY then
        return target.cardCenterX, target.cardCenterY
    elseif target and target.index and _G.cardSlotPositions and _G.cardSlotPositions[target.index] then
        local pos = _G.cardSlotPositions[target.index]
        return pos.x, pos.y
    elseif target and target.x and target.y then
        return target.x, target.y
    elseif target and target.getContentBounds then
        local bounds = target:getContentBounds()
        return (bounds.xMin + bounds.xMax) / 2, (bounds.yMin + bounds.yMax) / 2
    end
    return display.contentCenterX, display.contentCenterY
end

--------------------------------------------------
-- Função auxiliar: showHit
-- Exibe o valor do hit (dano ou cura) na posição da carta.
-- hitType: "damage" exibe com "-" (vermelho) e "heal" com "+" (verde).
--------------------------------------------------
local function showHit(target, value, hitType)
    if value == nil then value = 0 end

    local textValue = ""
    local fontSize = 100  -- Tamanho padrão para dano
    if hitType == "heal" then
        textValue = "+" .. tostring(value)
        fontSize = 50  -- Ajuste se necessário
    else
        textValue = "-" .. tostring(value)
    end

    local x, y = getDamagePosition(target)
    local posY = y - 20  -- Posiciona o texto um pouco acima

    print("showHit: hitType = " .. hitType .. " | value = " .. tostring(value) .. " | pos = (" .. x .. ", " .. posY .. ")")

    local hitText = display.newText({
        text = textValue,
        x = x,
        y = posY,
        font = "assets/7fonts/Icarus.ttf",
        fontSize = fontSize,
        align = "center"
    })

    if hitType == "heal" then
        hitText:setFillColor(0, 1, 0)  -- Verde para cura
    else
        hitText:setFillColor(1, 0, 0)  -- Vermelho para dano
    end

    if target.parent then
        target.parent:insert(hitText)
    else
        display.getCurrentStage():insert(hitText)
    end
    hitText:toFront()

    transition.to(hitText, {
        time = 1000,
        y = posY - 300,
        alpha = 0,
        onComplete = function()
            if hitText.removeSelf then hitText:removeSelf() end
        end
    })
end

--------------------------------------------------
-- Função: showHealEffect
--------------------------------------------------
local function showHealEffect(targetGroup, callback)
    local healSheetOptions = {
        frames = {
            { x = 686, y = 2,   width = 66, height = 74 },
            { x = 190, y = 2,   width = 78, height = 84 },
            { x = 2,   y = 2,   width = 78, height = 98 },
            { x = 334, y = 2,   width = 76, height = 96 },
            { x = 102, y = 2,   width = 78, height = 86 },
            { x = 432, y = 2,   width = 76, height = 84 },
            { x = 602, y = 2,   width = 76, height = 82 },
            { x = 518, y = 2,   width = 76, height = 82 },
            { x = 276, y = 2,   width = 56, height = 78 },
            { x = 754, y = 2,   width = 54, height = 40 },
            { x = 754, y = 44,  width = 52, height = 36 },            
        }
    }
    local healSheet = graphics.newImageSheet("assets/7effect/hit_8_1.png", healSheetOptions)
    local healSequenceData = {
        name = "heal",
        start = 1,
        count = 11,
        time = 800,
        loopCount = 1
    }
    local healSprite = display.newSprite(healSheet, healSequenceData)
    healSprite.anchorX = 0.5
    healSprite.anchorY = 0.5
    healSprite.x = 0
    healSprite.y = 0
    healSprite:scale(healEffectScale, healEffectScale)
    targetGroup:insert(healSprite)
    healSprite:toFront()
    healSprite:play()
    healSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if healSprite.removeSelf then healSprite:removeSelf() end
            if callback then callback() end
        end
    end)
end

--------------------------------------------------
-- Função auxiliar: findValidAllyForHealing
-- Retorna o aliado com a menor razão HP/maxHP dentre os aliados vivos.
--------------------------------------------------
local function findValidAllyForHealing(attacker, allies)
    local lowestRatio = 2  -- Inicializa com valor maior que 1
    local targetAlly = nil
    for _, ally in ipairs(allies) do
        if ally then
            local currentHp = tonumber(ally.hp) or 0
            local maxHp = tonumber(ally.maxHp) or tonumber(ally.originalHP) or 1
            local ratio = currentHp / maxHp
            if ratio < lowestRatio then
                lowestRatio = ratio
                targetAlly = ally
            end
        end
    end
    return targetAlly
end

--------------------------------------------------
-- Configuração da spritesheet para a animação de ação de cura (substituindo PNG)
--------------------------------------------------
local healActionSheetOptions = {
    frames = {
        { x = 816, y = 2,   width = 126, height = 66 },
        { x = 394, y = 2,   width = 132, height = 102 },
        { x = 528, y = 2,   width = 142, height = 100 },
        { x = 672, y = 2,   width = 142, height = 92 },
        { x = 144, y = 2,   width = 138, height = 112 },
        { x = 2,   y = 2,   width = 140, height = 112 },
        { x = 284, y = 2,   width = 112, height = 108 },
        { x = 816, y = 70,  width = 68,  height = 48 },        
    }
}
local healActionSheet = graphics.newImageSheet("assets/7effect/action_100.png", healActionSheetOptions)
local healActionSequenceData = {
    name = "healAction",
    start = 1,
    count = 8,
    time = 500,
    loopCount = 1
}

--------------------------------------------------
-- Função: healTechnique.attack
-- Aplica a cura a todos os aliados, com índices de 1 a 6.
--------------------------------------------------
function healTechnique.attack(attacker, dummyTarget, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("healTechnique: Objeto de display do curador não encontrado. Pulando animação.")
        if callback then callback() end
        return
    end

    cardGroup:toFront()
    print("healTechnique: Iniciando animação de cura. Curador Atk = " .. tostring(attacker.atk))
    
    -- Efeito de ação: animação de cura usando spritesheet
    local actionSprite = display.newSprite(healActionSheet, healActionSequenceData)
    actionSprite.anchorX = 0.5
    actionSprite.anchorY = 0.5
    actionSprite.alpha = 1  -- opacidade definida imediatamente
    -- Posiciona a animação no centro do cardGroup
    local cardImage = cardGroup[1]
    if cardImage and cardImage.getContentBounds then
        local bounds = cardImage:getContentBounds()
        local localCenterX, localCenterY = cardGroup:contentToLocal((bounds.xMin + bounds.xMax)/2, (bounds.yMin + bounds.yMax)/2)
        actionSprite.x = localCenterX
        actionSprite.y = localCenterY
    else
        actionSprite.x = 0
        actionSprite.y = 0
    end
    cardGroup:insert(actionSprite)
    actionSprite:toFront()
    actionSprite:scale(actionScale, actionScale)
    actionSprite:play()
    actionSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if actionSprite.removeSelf then actionSprite:removeSelf() end
            local atkValue = tonumber(attacker.atk) or 0
            local healAmount = math.max(1, math.floor(atkValue * 0.22))
            print("healTechnique: Cura calculada = " .. healAmount)
            local allies = {}
            if battleFunctions.getAllies then
                allies = battleFunctions.getAllies(attacker)
            end
            -- Aplica a cura a todos os aliados com índices de 1 a 6
            for i = 1, 6 do
                local ally = allies[i]
                if ally then
                    print("healTechnique: Aplicando cura para aliado de index " .. i .. " (" .. (ally.name or "sem nome") .. ")")
                    local maxHP = tonumber(ally.maxHp) or tonumber(ally.originalHP) or 100
                    local newHp = math.min(maxHP, tonumber(ally.hp) + healAmount)
                    ally.hp = newHp
                    if battleFunctions.updateHealthBar then
                        battleFunctions.updateHealthBar(ally)
                    else
                        print("healTechnique: updateHealthBar não disponível para " .. (ally.name or "sem nome"))
                    end
                    print("healTechnique: Aliado de index " .. i .. " curado. Nova vida: " .. ally.hp)
                    if ally.group then
                        showHealEffect(ally.group, function()
                            print("healTechnique: Efeito de cura concluído para aliado de index " .. i)
                            showHit(ally.group, healAmount, "heal")
                        end)
                    else
                        print("healTechnique: Aliado de index " .. i .. " sem objeto de display; nenhum efeito exibido.")
                    end
                end
            end
            if callback then callback() end
        end
    end)
end

return healTechnique
