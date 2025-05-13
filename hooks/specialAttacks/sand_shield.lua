-- hooks/specialAttacks/healTechnique.lua
local healTechnique = {}

local healEffectScale = 1.8 -- Escala do efeito de cura (visuais)
local actionScale = 2 -- Escala da animação de ação
local overlayScale = 3.5 -- Escala da animação overlay

--------------------------------------------------
-- Auxiliar: getDamagePosition
-- Retorna coordenadas centrais de um target (carta/grupo)
--------------------------------------------------
local function getDamagePosition(target)
    if target and target.cardCenterX and target.cardCenterY then
        return target.cardCenterX, target.cardCenterY
    elseif target and target.index and _G.cardSlotPositions then
        local pos = _G.cardSlotPositions[target.index]
        return pos.x, pos.y
    elseif target and target.x and target.y then
        return target.x, target.y
    elseif target and target.getContentBounds then
        local b = target:getContentBounds()
        return (b.xMin + b.xMax) / 2, (b.yMin + b.yMax) / 2
    end
    return display.contentCenterX, display.contentCenterY
end

--------------------------------------------------
-- Função auxiliar: showHit
-- Exibe o valor do hit (cura ou dano)
--------------------------------------------------
local function showHit(target, value, hitType)
    if value == nil then
        value = 0
    end
    local textValue = hitType == "heal" and ("+" .. tostring(value)) or ("-" .. tostring(value))
    local fontSize = hitType == "heal" and 0
    local x, y = getDamagePosition(target)
    local hitText = display.newText({
        text = textValue,
        x = x,
        y = y - 20,
        font = "assets/7fonts/Icarus.ttf",
        fontSize = fontSize,
        align = "center"
    })
    if hitType == "heal" then
        hitText:setFillColor(0, 1, 0)
    else
        hitText:setFillColor(1, 0, 0)
    end
    (target.parent or display.getCurrentStage()):insert(hitText)
    hitText:toFront()
    transition.to(hitText, {
        time = 1,
        y = hitText.y - 300,
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
-- Efeito de cura via spritesheet no alvo
--------------------------------------------------
local function showHealEffect(targetGroup, callback)
    local sheetOptions = {
        frames = {{
            x = 1734,
            y = 2,
            width = 148,
            height = 74
        }, -- hit_84_00.png
        {
            x = 1450,
            y = 2,
            width = 170,
            height = 90
        }, -- hit_84_01.png
        {
            x = 1272,
            y = 2,
            width = 176,
            height = 106
        }, -- hit_84_02.png
        {
            x = 362,
            y = 2,
            width = 178,
            height = 148
        }, -- hit_84_03.png
        {
            x = 182,
            y = 2,
            width = 178,
            height = 164
        }, -- hit_84_04.png
        {
            x = 2,
            y = 2,
            width = 178,
            height = 164
        }, -- hit_84_05.png
        {
            x = 542,
            y = 2,
            width = 158,
            height = 162
        }, -- hit_84_06.png
        {
            x = 1622,
            y = 2,
            width = 110,
            height = 136
        }, -- hit_84_07.png
        {
            x = 1134,
            y = 2,
            width = 136,
            height = 144
        }, -- hit_84_08.png
        {
            x = 990,
            y = 2,
            width = 142,
            height = 148
        }, -- hit_84_09.png
        {
            x = 846,
            y = 2,
            width = 142,
            height = 148
        }, -- hit_84_10.png
        {
            x = 702,
            y = 2,
            width = 142,
            height = 148
        }, -- hit_84_11.png
        {
            x = 1734,
            y = 78,
            width = 82,
            height = 88
        } -- hit_84_12.png
        }
    }
    local sheet = graphics.newImageSheet("assets/7effect/hit_84.png", sheetOptions)
    local seq = {
        name = "heal",
        start = 1,
        count = 13,
        time = 800,
        loopCount = 1
    }
    local sprite = display.newSprite(sheet, seq)
    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite:scale(healEffectScale, healEffectScale)
    targetGroup:insert(sprite)
    sprite:toFront()
    sprite:play()
    sprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if sprite.removeSelf then
                sprite:removeSelf()
            end
            if callback then
                callback()
            end
        end
    end)
end

--------------------------------------------------
-- Função: showOverlay
-- Efeito overlay no centro da formação
--------------------------------------------------
local function showOverlay(attacker, callback)
    local sheetOptions = {
        frames = {{
            x = 1,
            y = 1,
            width = 278,
            height = 204
        }, {
            x = 281,
            y = 1,
            width = 278,
            height = 210
        }, {
            x = 561,
            y = 1,
            width = 282,
            height = 222
        }, {
            x = 1,
            y = 225,
            width = 284,
            height = 228
        }, {
            x = 287,
            y = 225,
            width = 284,
            height = 222
        }, {
            x = 573,
            y = 225,
            width = 286,
            height = 222
        }, {
            x = 287,
            y = 449,
            width = 286,
            height = 222
        }, {
            x = 575,
            y = 449,
            width = 284,
            height = 226
        }, {
            x = 1,
            y = 677,
            width = 276,
            height = 228
        }, {
            x = 279,
            y = 677,
            width = 272,
            height = 220
        }, {
            x = 553,
            y = 677,
            width = 274,
            height = 220
        }, {
            x = 845,
            y = 1,
            width = 278,
            height = 220
        }, {
            x = 861,
            y = 223,
            width = 282,
            height = 204
        }, {
            x = 861,
            y = 429,
            width = 170,
            height = 152
        }}
    }
    local sheet = graphics.newImageSheet("assets/7effect/bullet_84.png", sheetOptions)
    local seq = {
        name = "healAction",
        start = 1,
        count = 14,
        time = 900,
        loopCount = 1
    }
    local sprite = display.newSprite(sheet, seq)
    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite:scale(overlayScale, overlayScale)
    local center = attacker.isOpponent and _G.opponentFormationCenter or _G.playerFormationCenter
    if center then
        sprite.x, sprite.y = center.x, center.y
    else
        sprite.x, sprite.y = display.contentCenterX, display.contentCenterY
    end
    display.getCurrentStage():insert(sprite)
    sprite:toFront()
    sprite:play()
    sprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if sprite.removeSelf then
                sprite:removeSelf()
            end
            if callback then
                callback()
            end
        end
    end)
end

--------------------------------------------------
-- Configuração da animação de ação de cura
--------------------------------------------------
local healActionSheetOptions = {
    frames = {{
        x = 2,
        y = 2,
        width = 226,
        height = 150
    }, -- action_84_00.png
    {
        x = 2,
        y = 154,
        width = 224,
        height = 136
    }, -- action_84_01.png
    {
        x = 2,
        y = 292,
        width = 210,
        height = 156
    }, -- action_84_02.png
    {
        x = 2,
        y = 450,
        width = 208,
        height = 166
    }, -- action_84_03.png
    {
        x = 2,
        y = 1068,
        width = 178,
        height = 178
    }, -- action_84_04.png
    {
        x = 2,
        y = 700,
        width = 198,
        height = 186
    }, -- action_84_06.png
    {
        x = 2,
        y = 1248,
        width = 156,
        height = 86
    }, -- action_84_07.png
    {
        x = 2,
        y = 618,
        width = 202,
        height = 80
    } -- action_84_08.png
    }
};
local healActionSheet = graphics.newImageSheet("assets/7effect/action_84.png", healActionSheetOptions)
local healActionSequenceData = {
    name = "healAction",
    start = 1,
    count = 9,
    time = 500,
    loopCount = 1
}

--------------------------------------------------
-- Função principal: healTechnique.attack
--------------------------------------------------
function healTechnique.attack(attacker, dummyTarget, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        if callback then
            callback()
        end
        return
    end
    cardGroup:toFront()

    -- 1) Animação na carta
    local actionSprite = display.newSprite(healActionSheet, healActionSequenceData)
    actionSprite.anchorX, actionSprite.anchorY = 0.5, 0.5
    actionSprite:scale(actionScale, actionScale)
    local img = cardGroup[1]
    if img and img.getContentBounds then
        local b = img:getContentBounds()
        actionSprite.x, actionSprite.y = cardGroup:contentToLocal((b.xMin + b.xMax) / 2, (b.yMin + b.yMax) / 2)
    else
        actionSprite.x, actionSprite.y = 0, 0
    end
    cardGroup:insert(actionSprite)
    actionSprite:toFront()
    actionSprite:play()

    actionSprite:addEventListener("sprite", function(ev)
        if ev.phase == "ended" then
            if actionSprite.removeSelf then
                actionSprite:removeSelf()
            end
            -- 2) Overlay no centro da formação
            showOverlay(attacker, function()
                -- 3) Ciclo de cura + shield em aliados
                local atkValue = tonumber(attacker.atk) or 0
                local healAmount = math.max(1, math.floor(atkValue * 0.0))
                local allies = battleFunctions.getAllies and battleFunctions.getAllies(attacker) or {}
                for i = 1, 6 do
                    local ally = allies[i]
                    if ally then
                        local maxHP = tonumber(ally.maxHp) or tonumber(ally.originalHP) or 100
                        ally.hp = math.min(maxHP, (tonumber(ally.hp) or 0) + healAmount)
                        if battleFunctions.updateHealthBar then
                            battleFunctions.updateHealthBar(ally)
                        end
                        if ally.group then
                            showHealEffect(ally.group, function()
                                showHit(ally.group, healAmount, "heal")
                                local m = battleFunctions.manageCardTurn or _G.manageCardTurn
                                if m then
                                    m(ally, "shield", 1)
                                end
                            end)
                        else
                            local m = battleFunctions.manageCardTurn or _G.manageCardTurn
                            if m then
                                m(ally, "shield", 1)
                            end
                        end
                    end
                end
                if callback then
                    callback()
                end
            end)
        end
    end)
end

return healTechnique
