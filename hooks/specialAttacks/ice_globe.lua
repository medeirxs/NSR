-- hooks/specialAttacks/ice_globe.lua
local ice_globe = {}

local healEffectScale = 1 -- Controle de tamanho da animação do efeito de cura (hit effect)

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
    local fontSize = 0 -- Tamanho padrão
    if hitType == "heal" then
        textValue = "+" .. tostring(value)
        fontSize = 0
    else
        textValue = "-" .. tostring(value)
    end

    local x, y = getDamagePosition(target)
    local posY = y - 20

    local hitText = display.newText({
        text = textValue,
        x = x,
        y = posY,
        font = "assets/7fonts/Icarus.ttf",
        fontSize = fontSize,
        align = "center"
    })

    if hitType == "heal" then
        hitText:setFillColor(0, 1, 0)
    else
        hitText:setFillColor(1, 0, 0)
    end

    if target.parent then
        target.parent:insert(hitText)
    else
        display.getCurrentStage():insert(hitText)
    end
    hitText:toFront()

    transition.to(hitText, {
        time = 100,
        y = posY - 1,
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
-- Animação de cura via spritesheet
--------------------------------------------------
local function showHealEffect(targetGroup, callback)
    local healSheetOptions = {
        frames = {{
            x = 1,
            y = 1,
            width = 290,
            height = 311
        }, {
            x = 293,
            y = 1,
            width = 290,
            height = 311
        }, {
            x = 585,
            y = 1,
            width = 290,
            height = 311
        }, {
            x = 1,
            y = 314,
            width = 290,
            height = 311
        }, {
            x = 293,
            y = 314,
            width = 290,
            height = 311
        }, {
            x = 585,
            y = 314,
            width = 290,
            height = 311
        }, {
            x = 1,
            y = 627,
            width = 290,
            height = 311
        }, {
            x = 293,
            y = 627,
            width = 290,
            height = 311
        }, {
            x = 585,
            y = 627,
            width = 290,
            height = 311
        }, {
            x = 877,
            y = 1,
            width = 290,
            height = 311
        }, {
            x = 877,
            y = 314,
            width = 290,
            height = 311
        }, {
            x = 877,
            y = 627,
            width = 290,
            height = 311
        }, {
            x = 1,
            y = 940,
            width = 290,
            height = 311
        }, {
            x = 293,
            y = 940,
            width = 290,
            height = 311
        }}
    }
    local sheet = graphics.newImageSheet("assets/7effect/bullet_114.png", healSheetOptions)
    local seqData = {
        name = "heal",
        start = 1,
        count = 14,
        time = 1100,
        loopCount = 1
    }
    local healSprite = display.newSprite(sheet, seqData)
    healSprite.anchorX, healSprite.anchorY = 0.5, 0.5
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
    local lowestRatio, targetAlly = 2, nil
    for _, ally in ipairs(allies) do
        if ally then
            local curHp = tonumber(ally.hp) or 0
            local maxHp = tonumber(ally.maxHp) or tonumber(ally.originalHP) or 1
            local ratio = (maxHp > 0) and (curHp / maxHp) or 1
            if not targetAlly or ratio < lowestRatio then
                lowestRatio, targetAlly = ratio, ally
            end
        end
    end
    return targetAlly
end

--------------------------------------------------
-- Função principal: ice_globe.attack
-- Executa animação de cura e aplica shield via manageCardTurn
--------------------------------------------------
function ice_globe.attack(attacker, dummyTarget, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("ice_globe: display do curador não encontrado. Pulando animação.")
        if callback then
            callback()
        end
        return
    end

    cardGroup:toFront()
    print("ice_globe: Iniciando animação de cura. Curador Atk = " .. tostring(attacker.atk))

    -- Efeito de ação (curinha.png com fade)
    local w, h = cardGroup.contentWidth or 100, cardGroup.contentHeight or 100
    local actionEffect = display.newImageRect(cardGroup, "assets/7effect/gelin.png", w, h)
    actionEffect.anchorX, actionEffect.anchorY, actionEffect.alpha = 0.5, 0.5, 0
    local img = cardGroup[1]
    if img and img.getContentBounds then
        local b = img:getContentBounds()
        local gx, gy = (b.xMin + b.xMax) / 2, (b.yMin + b.yMax) / 2
        actionEffect.x, actionEffect.y = cardGroup:contentToLocal(gx, gy)
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

                    -- Cálculo da cura
                    local atkValue = tonumber(attacker.atk) or 0
                    local healAmount = math.max(1, math.floor(atkValue * 0))
                    print("ice_globe: Cura calculada = " .. healAmount)

                    -- Busca aliados e escolhe alvo
                    local allies = battleFunctions.getAllies and battleFunctions.getAllies(attacker) or {}
                    local targetAlly = findValidAllyForHealing(attacker, allies)

                    if targetAlly then
                        -- Aplica a cura e atualiza barra
                        local maxHP = tonumber(targetAlly.maxHp) or tonumber(targetAlly.originalHP) or 100
                        targetAlly.hp = math.min(maxHP, (tonumber(targetAlly.hp) or 0) + healAmount)
                        if battleFunctions.updateHealthBar then
                            battleFunctions.updateHealthBar(targetAlly)
                        end
                        print("ice_globe: Cura aplicada. Nova vida = " .. targetAlly.hp)

                        -- Efeito de cura e hit
                        showHealEffect(targetAlly.group, function()
                            showHit(targetAlly.group, healAmount, "heal")
                            -- Ativa escudo até ser atacada
                            local manage = battleFunctions.manageCardTurn or _G.manageCardTurn
                            if manage then
                                manage(targetAlly, "shield", 20)
                            end
                            -- Garante persistência caso seja removido por attackPerformed
                            targetAlly.shieldActive = false
                            if targetAlly.group and not targetAlly.defenseIcon then
                                local shieldImg = display.newImageRect("assets/7battle/icon_buffer_2.png", 60, 60)
                                shieldImg.anchorX, shieldImg.anchorY = 0.5, 0.5
                                shieldImg.x = -targetAlly.group.contentWidth * 0.5 + 65 * 3.8
                                shieldImg.y = targetAlly.group.contentHeight * 0.5 - 65 * 1.2
                                targetAlly.defenseIcon = shieldImg
                                targetAlly.group:insert(shieldImg)
                            end
                            if callback then
                                callback()
                            end
                        end)
                    else
                        print("ice_globe: Nenhum aliado válido para curar.")
                        if callback then
                            callback()
                        end
                    end
                end
            })
        end
    })
end

return ice_globe
