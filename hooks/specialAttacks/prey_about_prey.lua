local prey_about_prey = {}

local designWidth       = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth
local hitEffectScale    = 3.0 * deviceScaleFactor
local actionScale       = 3.0 * deviceScaleFactor
local bulletScale       = 3.0 * deviceScaleFactor
--------------------------------------------------
-- Função auxiliar: showActionEffect
-- Exibe uma animação de ação via spritesheet sobre o centro da carta atacante
--------------------------------------------------
local actionSheetOptions = {
    frames = {
        { x=190, y=2,   width= 98, height=36 },  -- action_28_00.png
        { x= 96, y=2,   width= 92, height=42 },  -- action_28_01.png
        { x=  2, y=2,   width= 92, height=42 },  -- action_28_02.png
        { x=290, y=2,   width= 80, height=34 },  -- action_28_03.png
    }
}
local actionSheet = graphics.newImageSheet("assets/7effect/action_28.png", actionSheetOptions)
local actionSequenceData = { name = "action", start = 1, count = 4, time = 400, loopCount = 1 }

local function showActionEffect(cardGroup, callback)
    local sprite = display.newSprite(actionSheet, actionSequenceData)
    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = 0, 0
    sprite:scale(actionScale, actionScale)
    cardGroup:insert(sprite)
    sprite:toFront()
    sprite:play()
    sprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if sprite.removeSelf then sprite:removeSelf() end
            if callback then callback() end
        end
    end)
end

--------------------------------------------------
-- Função auxiliar: showHitEffect
-- Exibe um efeito de hit via spritesheet sobre o centro da carta acertada
--------------------------------------------------
local function showHitEffect(targetGroup, callback)
    if not targetGroup then
        if callback then callback() end
        return
    end

    local hitSheetOptions = {
        frames = {
            { x=   2, y= 124, width=120, height=120 },  -- hit_28_00.png
            { x=   2, y=   2, width=120, height=120 },  -- hit_28_01.png
            { x=   2, y=   2, width=120, height=120 },  -- hit_28_02.png
            { x=   2, y= 246, width=118, height= 98 },  -- hit_28_03.png
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/hit_28.png", hitSheetOptions)
    local hitSequenceData = {
        name = "hit",
        start = 1,
        count = 4,
        time = 300,
        loopCount = 1
    }

    local hitSprite = display.newSprite(hitSheet, hitSequenceData)
    hitSprite.anchorX, hitSprite.anchorY = 0.5, 0.5
    hitSprite.x, hitSprite.y             = 0, 0
    hitSprite:scale(hitEffectScale, hitEffectScale)
    targetGroup:insert(hitSprite)
    hitSprite:toFront()
    hitSprite:play()

    hitSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if hitSprite.removeSelf then hitSprite:removeSelf() end
            if callback then callback() end
        end
    end)
end

--------------------------------------------------
-- Função auxiliar: playProjectileAnimation
-- Dispara um projétil do atacante para o alvo e chama callback.
--------------------------------------------------
local function playProjectileAnimation(attackerGroup, targetGroup, onComplete)
    if not attackerGroup or not targetGroup then
        if onComplete then onComplete() end
        return
    end

    local cardImageAttacker = attackerGroup[1] or attackerGroup
    local startX, startY    = cardImageAttacker:localToContent(cardImageAttacker.x, cardImageAttacker.y)
    local cardImageTarget   = targetGroup[1] or targetGroup
    local targetX, targetY  = cardImageTarget:localToContent(cardImageTarget.x, cardImageTarget.y)

    local sheetOptions = {
        frames = {
            { x=   1, y=   1, width=118, height=126 },
            { x= 121, y=   1, width=118, height=132 },
            { x= 241, y=   1, width=114, height=140 },
            { x= 357, y=   1, width=114, height=130 },
            { x=   1, y= 133, width=102, height=144 },
            { x= 357, y= 133, width=114, height=164 },
            { x=   1, y= 299, width=100, height=158 },
            { x= 103, y= 299, width= 96, height=150 },
            { x= 201, y= 299, width= 94, height=166 },
            { x= 297, y= 299, width= 96, height=172 },
            { x= 473, y=   1, width= 92, height=150 },
            { x= 395, y= 299, width= 96, height=160 },
            { x= 567, y=   1, width= 98, height=174 },
            { x= 493, y= 177, width= 92, height=156 },
        }
    }
    local projectileSheet = graphics.newImageSheet("assets/7effect/bullet_28.png", sheetOptions)
    local seqData         = { name = "projectile", start = 1, count = 14, time = 500, loopCount = 0 }
    local sprite          = display.newSprite(projectileSheet, seqData)

    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = startX, startY
    sprite:scale(bulletScale , bulletScale)
    sprite.alpha = 0
    sprite:play()

    transition.to(sprite, {
        alpha = 1, time = 0,
        onComplete = function()
            local dx = targetX - startX
            local dy = targetY - startY
            sprite.rotation = math.deg(math.atan2(dy, dx)) + 90
            transition.to(sprite, {
                time       = 400,
                x          = targetX,
                y          = targetY,
                transition = easing.linear,
                onComplete = function()
                    if sprite.removeSelf then sprite:removeSelf() end
                    if onComplete then onComplete() end
                end
            })
        end
    })
end

--------------------------------------------------
-- Função principal: ataque em coluna com prioridade de colunas,
-- movimento, animação de ação, projétil, hit visual em cada carta e retorno
--------------------------------------------------
function prey_about_prey.attack(attacker, dummyTarget, battleFunctions, targetSlot, callback)
    local cardGroup      = attacker.group or attacker
    local myFormation    = attacker.isOpponent and _G.opponentFormationData or _G.playerFormationData
    local enemyFormation = attacker.isOpponent and _G.playerFormationData or _G.opponentFormationData

    -- 1) Descobre slot do atacante
    local attackerSlot
    for i = 1, 6 do
        if myFormation[i] == attacker then attackerSlot = i; break end
    end

    -- 2) Coluna do atacante (1, 2 ou 3)
    local colIndex = ((attackerSlot or targetSlot) - 1) % 3 + 1

    -- 3) Prioridade de colunas
    local priorities = (colIndex == 1) and {1,2,3}
                     or (colIndex == 2) and {2,1,3}
                     or {3,2,1}

    local function findTargetColumn()
        for _, c in ipairs(priorities) do
            if enemyFormation[c] or enemyFormation[c+3] then
                return c
            end
        end
        return nil
    end

    -- 5) Sem gráfico: aplica direto
    if not cardGroup then
        local atkVal, dmg = tonumber(attacker.atk) or 0, 0
        dmg = math.max(1, math.floor(atkVal * 1.0))
        local c = findTargetColumn()
        if c then
            for _, s in ipairs({c, c+3}) do
                local tgt = enemyFormation[s]
                if type(tgt) == "table" then
                    battleFunctions.applyDamage(attacker, tgt, dmg, s)
                end
            end
        end
        if callback then callback() end
        return
    end

    -- 6) Posição e centro
    local origX, origY = cardGroup.x, cardGroup.y
    local parent       = cardGroup.parent or display.getCurrentStage()
    local cx, cy       = parent:contentToLocal(display.contentCenterX, display.contentCenterY)

    -- 7) Coluna alvo
    local targetCol = findTargetColumn()
    if not targetCol then
        if callback then callback() end
        return
    end

    -- 8) Move à coluna
    local moveX = (targetCol == 1) and (cx - 335)
                or (targetCol == 3) and (cx + 335)
                or cx

    cardGroup:toFront()
    transition.to(cardGroup, {
        time       = 300,
        x          = moveX,
        y          = cy,
        transition = easing.inOutQuad,
        onComplete = function()
            -- 9) Zoom in
            transition.to(cardGroup, {
                time       = 150,
                xScale     = 1.1,
                yScale     = 1.1,
                transition = easing.outQuad,
                onComplete = function()
                    -- 10) Animação de ação antes do projétil
                    showActionEffect(cardGroup, function()
                        -- 11) Delay + projétil
                        timer.performWithDelay(200, function()
                            local lowerSlot = targetCol + 3
                            local upperSlot = targetCol
                            local lower     = enemyFormation[lowerSlot]
                            local upper     = enemyFormation[upperSlot]
                            local projGrp   = (type(lower) == "table" and lower.group)
                                             or (type(upper) == "table" and upper.group)

                            local function afterProjectile()
                                for _, s in ipairs({targetCol, targetCol+3}) do
                                    local tgt = enemyFormation[s]
                                    if type(tgt) == "table" and tgt.group then
                                        showHitEffect(tgt.group)
                                    end
                                end
                                
                                local atkVal, dmg = tonumber(attacker.atk) or 0, 0
                                dmg = math.max(1, math.floor(atkVal * 1.0))
                                for _, s in ipairs({targetCol, targetCol+3}) do
                                    local tgt = enemyFormation[s]
                                    if type(tgt) == "table" then
                                        battleFunctions.applyDamage(attacker, tgt, dmg, s)
                                    end
                                end
                                -- Zoom out e retorno
                                transition.to(cardGroup, { time=300, xScale=1, yScale=1, transition=easing.inOutQuad })
                                transition.to(cardGroup, {
                                    time       = 300,
                                    x          = origX,
                                    y          = origY,
                                    transition = easing.inOutQuad,
                                    onComplete = function()
                                        if callback then callback() end
                                    end
                                })
                            end

                            if projGrp then
                                playProjectileAnimation(cardGroup, projGrp, afterProjectile)
                            else
                                afterProjectile()
                            end
                        end)
                    end)
                end
            })
        end
    })
end

return prey_about_prey