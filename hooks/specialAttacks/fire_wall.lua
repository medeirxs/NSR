-- hooks/specialAttacks/fire_wall.lua

local fire_wall   = {}
local designWidth = 1080
local deviceScale = display.actualContentWidth / designWidth
local totalSlots  = 6  -- número de slots por formação

--------------------------------------------------------------------------------
-- Exibe o efeito de hit em coordenadas globais
--------------------------------------------------------------------------------
local function showHitEffect(targetGroup)
    local hitSheetOptions = { frames = {
        { x=318, y=274, width=258, height=258 }, { x=318, y=274, width=258, height=258 },
        { x=636, y=268, width=282, height=258 }, { x=636, y=  2, width=290, height=264 },
        { x=320, y=  2, width=314, height=270 }, { x=  2, y=  2, width=316, height=260 },
        { x=  2, y=264, width=314, height=246 }, { x=  2, y=512, width=170, height=200 },
    }}
    local sheet  = graphics.newImageSheet("assets/7effect/hit_51.png", hitSheetOptions)
    local seq    = { name="hit", start=1, count=8, time=500, loopCount=1 }
    local sprite = display.newSprite(sheet, seq)
    sprite.anchorX, sprite.anchorY = 0.5, 0.5

    local gx, gy = targetGroup.parent:localToContent(targetGroup.x, targetGroup.y)
    sprite.x, sprite.y = gx, gy

    display.getCurrentStage():insert(sprite)
    sprite:toFront()
    sprite:play()
    sprite:addEventListener("sprite", function(evt)
        if evt.phase == "ended" then sprite:removeSelf() end
    end)
end

-- Exporta para global, permitindo uso em applyDamageToFormation em battle.lua
_G.showHitEffect = showHitEffect

--------------------------------------------------------------------------------
-- Animação de ação (dash → zoom → play → zoom out)
--------------------------------------------------------------------------------
local function playActionAnimation(cardGroup, isOpponent, callback)
    local opts = { frames = {
        { x=1336, y=398, width= 66, height= 74 }, { x=1210, y=398, width=124, height= 94 },
        { x=1212, y=  2, width=284, height=174 }, { x=   2, y=254, width=300, height=240 },
        { x= 306, y=  2, width=302, height=250 }, { x= 610, y=  2, width=300, height=250 },
        { x= 912, y=  2, width=298, height=248 }, { x=   2, y=  2, width=302, height=250 },
        { x= 608, y=254, width=298, height=222 }, { x= 304, y=254, width=302, height=220 },
        { x= 912, y=252, width=296, height=220 }, { x=1212, y=178, width=282, height=218 },
    }}
    local sheet  = graphics.newImageSheet("assets/7effect/bullet_11.png", opts)
    local seq    = { name="actionAnim", start=1, count=12, time=900, loopCount=1 }
    local sprite = display.newSprite(sheet, seq)
    sprite.anchorX, sprite.anchorY = 0.5, 1

    if isOpponent then
        local gx, gy = cardGroup.parent:localToContent(cardGroup.x, cardGroup.y)
        sprite.x, sprite.y = gx, gy
        sprite.rotation = 180
        display.getCurrentStage():insert(sprite)
    else
        sprite.x, sprite.y = cardGroup.x, cardGroup.y
        cardGroup.parent:insert(sprite)
    end

    sprite:toFront()
    sprite:scale(4 * deviceScale, 4 * deviceScale)
    sprite:play()
    sprite:addEventListener("sprite", function(evt)
        if evt.phase == "ended" then
            sprite:removeSelf()
            if callback then callback() end
        end
    end)
end

--------------------------------------------------------------------------------
-- Função principal de ataque
--------------------------------------------------------------------------------
function fire_wall.attack(attacker, target, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    local atkVal    = tonumber(attacker.atk) or 0
    local damage    = math.max(1, math.floor(atkVal * 0.45))

    -- Se não houver display, ataca apenas o alvo
    if not cardGroup then
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback then callback() end
        return
    end

    -- Salva posição original e calcula centro da tela
    local origX, origY = cardGroup.x, cardGroup.y
    local parent      = cardGroup.parent or display.getCurrentStage()
    local cx, cy      = parent:contentToLocal(display.contentCenterX, display.contentCenterY)

    -- Sequência de animações
    cardGroup:toFront()
    transition.to(cardGroup, {
        time = 300, x = cx, y = cy, transition = easing.inOutQuad,
        onComplete = function()
            transition.to(cardGroup, {
                time = 200, xScale = 1.3, yScale = 1.3, transition = easing.outQuad,
                onComplete = function()
                    playActionAnimation(cardGroup, attacker.isOpponent, function()
                        transition.to(cardGroup, {
                            time = 100, xScale = 1, yScale = 1,
                            onComplete = function()
                                transition.to(cardGroup, {
                                    time = 300, x = origX, y = origY, transition = easing.inOutQuad,
                                    onComplete = function()
                                        -- Ajuste: usa applyDamageToFormation para múltiplos hits
                                        battleFunctions.applyDamageToFormation(attacker, not attacker.isOpponent, damage, { multiHit = true })

                                        if callback then callback() end
                                    end
                                })
                            end
                        })
                    end)
                end
            })
        end
    })
end

return fire_wall
