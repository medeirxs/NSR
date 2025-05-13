-- hooks/specialAttacks/giant_rasengan.lua

local giant_rasengan = {}
local designWidth    = 1080
local deviceScale    = display.actualContentWidth / designWidth
local totalSlots     = 6   -- número de slots por formação

--------------------------------------------------------------------------------
-- Exibe o efeito de hit em coordenadas globais
--------------------------------------------------------------------------------
local function showHitEffect(targetGroup)
    local hitSheetOptions = { frames = {
        { x = 2,    y = 2,    width = 234, height = 240 },
        { x = 508,  y = 2,    width = 272, height = 230 },
        { x = 1284, y = 2,    width = 276, height = 222 },
        { x = 1562, y = 2,    width = 254, height = 218 },
        { x = 782,  y = 2,    width = 284, height = 226 },
        { x = 244,  y = 2,    width = 262, height = 232 },
        { x = 1068, y = 2,    width = 214, height = 226 },
        { x = 1818, y = 2,    width = 182, height = 214 },
    }}
    local sheet = graphics.newImageSheet("assets/7effect/hit_27.png", hitSheetOptions)
    local seq   = { name="hit", start=1, count=8, time=500, loopCount=1 }
    local sprite = display.newSprite(sheet, seq)
    sprite.anchorX, sprite.anchorY = 0.5, 0.5

    local gx, gy = targetGroup.parent:localToContent(targetGroup.x, targetGroup.y)
    sprite.x, sprite.y = gx, gy

    display.getCurrentStage():insert(sprite)
    sprite:toFront()
    sprite:play()
    sprite:scale(5, 5)
    sprite:addEventListener("sprite", function(evt)
        if evt.phase == "ended" then sprite:removeSelf() end
    end)
end

--------------------------------------------------------------------------------
-- Função principal de ataque
--------------------------------------------------------------------------------
function giant_rasengan.attack(attacker, target, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    local atkVal    = tonumber(attacker.atk) or 0
    local damage    = math.max(1, math.floor(atkVal * 0.45))

    if not cardGroup then
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback then callback() end
        return
    end

    -- 0) guarda referências antes de subir ao stage
    local origParent   = cardGroup.parent
    local origX, origY = cardGroup.x, cardGroup.y
    local origScaleX   = cardGroup.xScale or 1
    local origScaleY   = cardGroup.yScale or 1

    -- reposiciona no stage, mantendo posição global
    local gx, gy = origParent:localToContent(origX, origY)
    local stage  = display.getCurrentStage()
    stage:insert(cardGroup)
    local lx, ly = stage:contentToLocal(gx, gy)
    cardGroup.x, cardGroup.y = lx, ly

    -- calcula centros
    local screenCX, screenCY = cardGroup.parent:contentToLocal(
        display.contentCenterX, display.contentCenterY
    )
    local formationCenter = attacker.isOpponent
        and _G.playerFormationCenter
        or _G.opponentFormationCenter
    local formCX, formCY        = formationCenter.x, formationCenter.y
    local localFormCX, localFormCY = cardGroup.parent:contentToLocal(formCX, formCY)

    --------------------------------------------------------------------------------
    -- 1) Move a carta até o centro da tela
    --------------------------------------------------------------------------------
    cardGroup:toFront()
    transition.to(cardGroup, {
        time       = 300,
        x          = screenCX,
        y          = screenCY,
        transition = easing.inOutQuad,
        onComplete = function()

            --------------------------------------------------------------------------------
            -- 2) Zoom in no centro da tela e inicia followSprite
            --------------------------------------------------------------------------------
            local followOpts = { frames = {
                { x=1,    y=1,    width=960, height=540 },
                { x=963,  y=1,    width=960, height=540 },
                { x=1,    y=543,  width=960, height=540 },
                { x=963,  y=543,  width=960, height=540 },
                { x=1,    y=1085, width=960, height=540 },
                { x=963,  y=1085, width=960, height=540 },
                { x=1,    y=1627, width=960, height=540 },
                { x=963,  y=1627, width=960, height=540 },
                { x=1925, y=1,    width=960, height=540 },
                { x=1925, y=543,  width=960, height=540 },
                { x=1925, y=1085, width=960, height=540 },
                { x=1925, y=1627, width=960, height=540 },
            }}
            local followSheet  = graphics.newImageSheet("assets/7effect/bullet_110.png", followOpts)
            local followSeq    = { name="follow", start=1, count=12, time=600, loopCount=0 }
            local followSprite = display.newSprite(followSheet, followSeq)
            followSprite.anchorX, followSprite.anchorY = 0.5, 0.6
            followSprite.alpha = 0
            cardGroup:insert(followSprite)
            followSprite:play()
            transition.to(followSprite, { time=600, alpha=0.95 })

            -- agora faz o zoom in
            transition.to(cardGroup, {
                time       = 900,
                xScale     = origScaleX * 1.2 * deviceScale,
                yScale     = origScaleY * 1.2 * deviceScale,
                transition = easing.outQuad,
                onComplete = function()

                    --------------------------------------------------------------------------------
                    -- 3) Zoom out em direção ao centro da formação inimiga/jogador
                    --------------------------------------------------------------------------------
                    transition.to(cardGroup, {
                        time       = 500,
                        x          = localFormCX,
                        y          = localFormCY,
                        xScale     = origScaleX,
                        yScale     = origScaleY,
                        transition = easing.inOutQuad,
                        onComplete = function()

                            -- remove followSprite
                            if followSprite and followSprite.removeSelf then
                                followSprite:removeSelf()
                            end

                            --------------------------------------------------------------------------------
                            -- 4) Aplica dano, efeito de hit, bleed e block
                            --------------------------------------------------------------------------------
                            battleFunctions.applyDamageToFormation(
                                attacker,
                                not attacker.isOpponent,
                                damage
                            )
                            local dummyGroup = display.newGroup()
                            dummyGroup.x, dummyGroup.y = formCX, formCY
                            showHitEffect(dummyGroup)

                            local targetFormation = not attacker.isOpponent
                                and opponentFormationData
                                or playerFormationData
                            for slot = 1, totalSlots do
                                local tgtData = targetFormation[slot]
                                if tgtData and type(tgtData) == "table" and tonumber(tgtData.hp or 0) > 0 then
                                    -- aplica bleed
                                    local bleedParams = { percent = 0, rounds = 0 }
                                    _G.manageCardTurn(tgtData, "applyBleed", bleedParams)
                                    -- 10% de chance de block
                                    if math.random() < 0 then
                                        _G.manageCardTurn(tgtData, "block", 1)
                                    end
                                end
                            end

                            --------------------------------------------------------------------------------
                            -- 5) Retorna e finaliza
                            --------------------------------------------------------------------------------
                            transition.to(cardGroup, {
                                time       = 300,
                                x          = screenCX,
                                y          = screenCY,
                                transition = easing.inOutQuad,
                                onComplete = function()
                                    local gx2, gy2 = stage:localToContent(cardGroup.x, cardGroup.y)
                                    origParent:insert(cardGroup)
                                    local lx2, ly2 = origParent:contentToLocal(gx2, gy2)
                                    cardGroup.x, cardGroup.y = lx2, ly2

                                    transition.to(cardGroup, {
                                        time       = 300,
                                        x          = origX,
                                        y          = origY,
                                        xScale     = origScaleX,
                                        yScale     = origScaleY,
                                        transition = easing.outQuad,
                                        onComplete = function()
                                            if callback then callback() end
                                        end
                                    })
                                end
                            })
                        end
                    })
                end
            })
        end
    })
end

return giant_rasengan
