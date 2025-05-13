-- hooks/basicAttacks/second_row_attack.lua

-- Hook básico: move o atacante ao centro da tela, faz zoom in, dispara um projétil até o centro da formação inimiga,
-- exibe hit na posição de impacto, aplica dano às cartas da segunda linha (slots 4,5,6), faz zoom out e retorna.

local second_row_attack = {}

-- Escalas responsivas
local designWidth             = 1080
local deviceScaleFactor       = display.actualContentWidth / designWidth
local bulletScale             = 3
local hitEffectScale          = 8.0 * deviceScaleFactor

-- Offset vertical para o projétil e hit (em pixels adaptados)
local formationCenterYOffset  = 200 * deviceScaleFactor
--------------------------------------------------
-- Função auxiliar: playActionAnimation
-- Exibe uma animação de ação no centro do atacante antes do projétil
--------------------------------------------------
local function playActionAnimation(cardGroup, onComplete)
    -- **Atualize estes frames e o caminho conforme seu sprite**
    local sheetOptions = {
        frames = {
            { x = 1,   y = 1,   width = 306, height = 290 },
            { x = 309, y = 1,   width = 306, height = 278 },
            { x = 309, y = 281, width = 308, height = 238 },
            { x = 1,   y = 521, width = 298, height = 230 },
            { x = 301, y = 521, width = 318, height = 200 },
            { x = 617, y = 1,   width = 318, height = 192 },
            { x = 619, y = 195, width = 318, height = 206 },
            { x = 621, y = 403, width = 316, height = 186 },
            { x = 621, y = 591, width = 238, height = 186 },
            { x = 861, y = 591, width = 228, height = 186 }, 
        }
    }
    local actionSheet = graphics.newImageSheet("assets/7effect/action_12.png", sheetOptions)
    local seqData     = { name = "action", start = 1, count = 10, time = 400, loopCount = 1 }
    local sprite      = display.newSprite(actionSheet, seqData)

    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = 0, 0
    sprite:scale(2.0 * deviceScaleFactor, 2.0 * deviceScaleFactor)
    cardGroup:insert(sprite)
    sprite:toFront()
    sprite:play()

    sprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if sprite.removeSelf then sprite:removeSelf() end
            if onComplete then onComplete() end
        end
    end)
end
--------------------------------------------------
-- Função auxiliar: playProjectileToCenter
-- Dispara um projétil do atacante até o centro da formação inimiga e chama onComplete.
-- isOpponent: boolean indicando se o atacante é do oponente
--------------------------------------------------
local function playProjectileToCenter(attackerGroup, isOpponent, onComplete)
    if not attackerGroup then
        if onComplete then onComplete() end
        return
    end
    local cardImage    = attackerGroup[1] or attackerGroup
    local startX, startY = cardImage:localToContent(cardImage.x, cardImage.y)
    local center       = isOpponent and _G.playerFormationCenter or _G.opponentFormationCenter
    local sign         = isOpponent and  1 or -1
    local targetX      = center.x
    local targetY      = center.y + sign * formationCenterYOffset

    local sheetOptions = {
        frames = {
            { x = 1,   y = 1,   width = 50,  height = 60 },
            { x = 53,  y = 1,   width = 74,  height = 110 },
            { x = 129, y = 1,   width = 102, height = 178 },
            { x = 233, y = 1,   width = 102, height = 178 },
            { x = 1,   y = 181, width = 128, height = 202 },
            { x = 337, y = 1,   width = 148, height = 234 },
            { x = 131, y = 237, width = 150, height = 172 },
            { x = 283, y = 237, width = 82,  height = 120 },
        }
    }
    local projectileSheet = graphics.newImageSheet("assets/7effect/bullet_14_1.png", sheetOptions)
    local seqData         = { name = "projectile", start = 1, count = 8, time = 500, loopCount = 0 }
    local sprite          = display.newSprite(projectileSheet, seqData)

    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = startX, startY
    sprite:scale(bulletScale, bulletScale)
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
-- Função auxiliar: showHitAtPosition
-- Exibe um efeito de hit via spritesheet na posição (x,y) do estágio
--------------------------------------------------
local function showHitAtPosition(x, y, callback)
    local hitSheetOptions = {
        frames = {
            { x = 686, y = 2,   width = 66,  height = 74 },
            { x = 752, y = 2,   width = 70,  height = 60 },
            { x = 556, y = 2,   width = 120, height = 80 },
            { x = 434, y = 2,   width = 120, height = 84 },
            { x = 2,   y = 2,   width = 120, height = 96 },
            { x = 214, y = 2,   width = 114, height = 94 },
            { x = 330, y = 2,   width = 102, height = 88 },
            { x = 124, y = 2,   width = 96,  height = 88 },
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/hit_12.png", hitSheetOptions)
    local seqData  = { name = "hit", start = 1, count = 8, time = 500, loopCount = 1 }
    local sprite   = display.newSprite(hitSheet, seqData)

    sprite.anchorX, sprite.anchorY = 0.5, 0.5
    sprite.x, sprite.y             = x, y
    sprite:scale(hitEffectScale * 1.2, hitEffectScale)
    display.getCurrentStage():insert(sprite)
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
-- Função principal: movimento, zoom, projétil, hit, dano, zoom out e retorno
--------------------------------------------------
function second_row_attack.attack(attacker, dummyTarget, battleFunctions, targetSlot, callback)
    local cardGroup      = attacker.group or attacker
    local enemyFormation = attacker.isOpponent
                             and _G.playerFormationData
                             or _G.opponentFormationData

    -- cálculo do dano
    local atkVal = tonumber(attacker.atk) or 0
    local damage = math.max(1, math.floor(atkVal * 1.0))

    -- sem gráfico: aplica dano direto
    if not cardGroup then
        for _, slot in ipairs({4, 5, 6}) do
            local tgt = enemyFormation[slot]
            if type(tgt) == "table" then
                battleFunctions.applyDamage(attacker, tgt, damage, slot)
            end
        end
        if callback then callback() end
        return
    end

    -- salva posição original e centro da tela
    local origX, origY = cardGroup.x, cardGroup.y
    local parent       = cardGroup.parent or display.getCurrentStage()
    local cx, cy       = parent:contentToLocal(display.contentCenterX, display.contentCenterY)

    -- move ao centro
    cardGroup:toFront()
    transition.to(cardGroup, {
        time       = 300,
        x          = cx,
        y          = cy,
        transition = easing.inOutQuad,
        onComplete = function()
            -- zoom in
            transition.to(cardGroup, {
                time       = 150,
                xScale     = 1.1,
                yScale     = 1.1,
                transition = easing.outQuad,
                onComplete = function()
                    -- animação de ação antes do projétil
                    playActionAnimation(cardGroup, function()
                        -- agora dispara o projétil
                        playProjectileToCenter(cardGroup, attacker.isOpponent, function()
                            -- exibe hit na posição do impacto
                            local center     = attacker.isOpponent
                                                 and _G.playerFormationCenter
                                                 or _G.opponentFormationCenter
                            local sign       = attacker.isOpponent and 1 or -1
                            local hitX, hitY = center.x, center.y + sign * formationCenterYOffset
                            showHitAtPosition(hitX, hitY, function()
                                -- aplica dano à segunda linha
                                for _, slot in ipairs({4, 5, 6}) do
                                    local tgt = enemyFormation[slot]
                                    if type(tgt) == "table" then
                                        battleFunctions.applyDamage(attacker, tgt, damage, slot)
                                    end
                                end
                                -- zoom out e retorno
                                transition.to(cardGroup, {
                                    time       = 150,
                                    xScale     = 1.0,
                                    yScale     = 1.0,
                                    transition = easing.inOutQuad,
                                    onComplete = function()
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
                                })
                            end)  -- fim showHitAtPosition
                        end)  -- fim playProjectileToCenter
                    end)  -- fim playActionAnimation
                end,
            })
        end,
    })  -- fecham transition.to principais
end  -- fecha a função attack

return second_row_attack

