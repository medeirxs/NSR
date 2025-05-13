local healTechnique = {}

local healEffectScale = 2.5 -- Controle de tamanho da animação do efeito de cura (hit effect)

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
    if value == nil then
        value = 0
    end

    local textValue = ""
    local fontSize = 100 -- Tamanho padrão para dano
    if hitType == "heal" then
        textValue = "+" .. tostring(value)
        fontSize = 50 -- Ajuste se necessário
    else
        textValue = "-" .. tostring(value)
    end

    local x, y = getDamagePosition(target)
    local posY = y - 20 -- Posiciona o texto um pouco acima

    print("showHit: hitType = " .. hitType .. " | value = " .. tostring(value) .. " | pos = (" .. x .. ", " .. posY ..
              ")")

    local Critical = require("utils.crticial")
    local hueAngle
    if hitType == "heal" then
        hueAngle = 270
    else
    end
    local hitText = Critical.new({
        texto = textValue,
        x = x,
        y = posY,
        spacing = -6,
        scaleFactor = 0.65,
        hueAngle = hueAngle
    })

    if target.parent then
        target.parent:insert(hitText)
    else
        display.getCurrentStage():insert(hitText)
    end
    hitText:toFront()

    transition.to(hitText, {
        time = 1000,
        y = posY - 50,
        alpha = 0,
        onComplete = function()
            if hitText.removeSelf then
                hitText:removeSelf()
            end
        end
    })
end

--------------------------------------------------
-- Função: showHealEffect
--------------------------------------------------
local function showHealEffect(targetGroup, callback)
    local healSheetOptions = {
        frames = {{
            x = 1214,
            y = 2,
            width = 112,
            height = 112
        }, {
            x = 402,
            y = 2,
            width = 120,
            height = 114
        }, {
            x = 794,
            y = 2,
            width = 140,
            height = 114
        }, {
            x = 1410,
            y = 2,
            width = 144,
            height = 110
        }, {
            x = 1556,
            y = 2,
            width = 138,
            height = 108
        }, {
            x = 936,
            y = 2,
            width = 138,
            height = 114
        }, {
            x = 1076,
            y = 2,
            width = 136,
            height = 114
        }, {
            x = 656,
            y = 2,
            width = 136,
            height = 116
        }, {
            x = 518,
            y = 2,
            width = 136,
            height = 116
        }, {
            x = 266,
            y = 2,
            width = 134,
            height = 120
        }, {
            x = 134,
            y = 2,
            width = 130,
            height = 122
        }, {
            x = 2,
            y = 2,
            width = 130,
            height = 122
        }, {
            x = 1696,
            y = 2,
            width = 130,
            height = 102
        }}
    }
    local healSheet = graphics.newImageSheet("assets/7effect/hit_10.png", healSheetOptions)
    local healSequenceData = {
        name = "heal",
        start = 1,
        count = 14,
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
            if healSprite.removeSelf then
                healSprite:removeSelf()
            end
            if callback then
                callback()
            end
        end
    end)
end

--------------------------------------------------
-- Função auxiliar: findValidAllyForHealing
-- Retorna o aliado com a menor razão HP/maxHP dentre os aliados vivos.
--------------------------------------------------
local function findValidAllyForHealing(attacker, allies)
    local lowestRatio = 2 -- Inicializa com valor maior que 1
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
-- Função: healTechnique.attack
-- Executa uma animação de cura utilizando um efeito de ação (fade in/out do PNG "curinha.png").
-- Após o efeito, busca os aliados via battleFunctions.getAllies, seleciona o aliado com menor vida
-- usando findValidAllyForHealing e aplica a cura, exibindo o hit de cura com showHit.
--------------------------------------------------
function healTechnique.attack(attacker, dummyTarget, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("healTechnique: Objeto de display do curador não encontrado. Pulando animação.")
        if callback then
            callback()
        end
        return
    end

    cardGroup:toFront()
    print("healTechnique: Iniciando animação de cura. Curador Atk = " .. tostring(attacker.atk))

    -- Efeito de ação: PNG que aparece com fade in e depois fade out.
    local effectWidth = cardGroup.contentWidth or 100
    local effectHeight = cardGroup.contentHeight or 100
    local actionEffect = display.newImageRect(cardGroup, "assets/7effect/curinha.png", effectWidth, effectHeight)
    actionEffect.anchorX = 0.5
    actionEffect.anchorY = 0.5
    actionEffect.alpha = 0 -- inicia transparente

    -- Posiciona o efeito exatamente no centro da carta (usando o primeiro filho como referência)
    local cardImage = cardGroup[1]
    if cardImage and cardImage.getContentBounds then
        local bounds = cardImage:getContentBounds()
        local globalCenterX = (bounds.xMin + bounds.xMax) * 1
        local globalCenterY = (bounds.yMin + bounds.yMax) * 1
        local localCenterX, localCenterY = cardGroup:contentToLocal(globalCenterX, globalCenterY)
        actionEffect.x = localCenterX
        actionEffect.y = localCenterY
    else
        actionEffect.x = cardGroup.contentWidth * 0
        actionEffect.y = cardGroup.contentHeight * 0
    end

    transition.to(actionEffect, {
        time = 300,
        alpha = 1,
        onComplete = function()
            transition.to(actionEffect, {
                time = 300,
                alpha = 0,
                onComplete = function()
                    if actionEffect.removeSelf then
                        actionEffect:removeSelf()
                    end
                    local atkValue = tonumber(attacker.atk) or 0
                    local healAmount = math.max(1, math.floor(atkValue * 0.30))
                    print("healTechnique: Cura calculada = " .. healAmount)
                    local allies = {}
                    if battleFunctions.getAllies then
                        allies = battleFunctions.getAllies(attacker)
                    end
                    local targetAlly = findValidAllyForHealing(attacker, allies)
                    if targetAlly then
                        print("healTechnique: Alvo para cura encontrado: " .. (targetAlly.name or "sem nome"))
                        local maxHP = tonumber(targetAlly.maxHp) or tonumber(targetAlly.originalHP) or 100
                        local newHp = math.min(maxHP, tonumber(targetAlly.hp) + healAmount)
                        targetAlly.hp = newHp
                        if battleFunctions.updateHealthBar then
                            battleFunctions.updateHealthBar(targetAlly)
                        else
                            print("healTechnique: updateHealthBar não disponível para " ..
                                      (targetAlly.name or "sem nome"))
                        end
                        print("healTechnique: Cura aplicada. Nova vida: " .. targetAlly.hp)
                        if targetAlly.group then
                            showHealEffect(targetAlly.group, function()
                                print("healTechnique: Efeito de cura concluído para " ..
                                          (targetAlly.name or "sem nome"))
                                -- Exibe o hit de cura usando showHit (definido localmente neste módulo)
                                showHit(targetAlly.group, healAmount, "heal")
                                if callback then
                                    callback()
                                end
                            end)
                        else
                            print("healTechnique: Alvo sem objeto de display; nenhum efeito exibido.")
                            if callback then
                                callback()
                            end
                        end
                    else
                        print("healTechnique: Nenhum aliado válido para curar encontrado.")
                        if callback then
                            callback()
                        end
                    end
                end
            })
        end
    })
end

return healTechnique
