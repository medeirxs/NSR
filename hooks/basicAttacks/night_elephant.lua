local night_elephant = {}

local hitScale = 0.9
--------------------------------------------------------------------------------
-- Spritesheet da ponte
--------------------------------------------------------------------------------
local bridgeSheetOptions = {
    frames = {
        { x = 1,    y = 1,    width = 720, height = 1280 },
        { x = 723,  y = 1,    width = 720, height = 1280 },
        { x = 1445, y = 1,    width = 720, height = 1280 },
        { x = 2167, y = 1,    width = 720, height = 1280 },
        { x = 1,    y = 1283, width = 720, height = 1280 },
        { x = 723,  y = 1283, width = 720, height = 1280 },
        { x = 1445, y = 1283, width = 720, height = 1280 },
        { x = 2167, y = 1283, width = 720, height = 1280 },
        { x = 2889, y = 1,    width = 720, height = 1280 },
        { x = 2889, y = 1283, width = 720, height = 1280 },
    }
}
local bridgeSheet = graphics.newImageSheet("assets/7effect/bullet_101.png", bridgeSheetOptions)
local bridgeSequenceData = {
    name = "bridge",
    start = 1,
    count = 10,
    time = 900,  -- duração da animação
    loopCount = 1
}

--------------------------------------------------------------------------------
-- Função auxiliar: getGlobalCenter
--------------------------------------------------------------------------------
local function getGlobalCenter(obj)
    if obj and obj.localToContent then
        return obj:localToContent(0, 0)
    else
        return obj.x or 0, obj.y or 0
    end
end

--------------------------------------------------------------------------------
-- Função: showHitEffect
--------------------------------------------------------------------------------
local function showHitEffect(targetGroup, callback)
    local hitSheetOptions = {
        frames = {
          { x = 1,    y = 1,    width = 1280, height = 720 },
          { x = 1,    y = 723,  width = 1280, height = 720 },
          { x = 1,    y = 1445, width = 1280, height = 720 },
          { x = 1283, y = 1,    width = 1280, height = 720 },
          { x = 1283, y = 723,  width = 1280, height = 720 },
          { x = 1283, y = 1445, width = 1280, height = 720 },    
        }
    }
    local hitSheet = graphics.newImageSheet("assets/7effect/hit_101.png", hitSheetOptions)
    local hitSequenceData = {
        name = "hit",
        start = 1,
        count = 6,
        time = 400,
        loopCount = 1
    }
    local hitSprite = display.newSprite(hitSheet, hitSequenceData)
    hitSprite.anchorX = 0.5
    hitSprite.anchorY = 0.5
    hitSprite.x = 0
    hitSprite.y = 0
    targetGroup:insert(hitSprite)
    hitSprite:toFront()
    hitSprite:play()
    hitSprite:addEventListener("sprite", function(event)
    hitSprite:scale(hitScale, hitScale)
        if event.phase == "ended" then
            hitSprite:removeSelf()
            if callback then callback() end
        end
    end)
end

--------------------------------------------------------------------------------
-- Função: shake
--------------------------------------------------------------------------------
local function shake(obj, duration, amplitude)
    local originalX, originalY = obj.x, obj.y
    local iterations = math.floor(duration / 50)
    local function doShake(i)
        if i > iterations then
            obj.x = originalX
            obj.y = originalY
            return
        end
        local offsetX = math.random(-amplitude, amplitude)
        local offsetY = math.random(-amplitude, amplitude)
        transition.to(obj, { time = 50, x = originalX + offsetX, y = originalY + offsetY,
            onComplete = function() doShake(i + 1) end })
    end
    doShake(1)
end

--------------------------------------------------------------------------------
-- Função: showBridgeAnimation
--------------------------------------------------------------------------------
local function showBridgeAnimation(attackerDisplay, targetDisplay, widthScale, callback)
    if not widthScale then widthScale = 1.0 end

    local ax, ay = getGlobalCenter(attackerDisplay)
    local tx, ty = getGlobalCenter(targetDisplay)
    print("BridgeAnimation - Attacker center:", ax, ay, "Target center:", tx, ty)
    
    local midX = (ax + tx) * 0.5
    local midY = (ay + ty) * 0.5

    local dx = tx - ax
    local dy = ty - ay
    local distance = math.sqrt(dx * dx + dy * dy * 1.5)
    
    local angle = math.deg(math.atan2(dy, dx)) + 90

    local bridgeSprite = display.newSprite(bridgeSheet, bridgeSequenceData)
    bridgeSprite.anchorX = 0.5
    bridgeSprite.anchorY = 0.5
    bridgeSprite.x = midX
    bridgeSprite.y = midY
    bridgeSprite.rotation = angle
    local scaleY = distance / bridgeSprite.contentHeight
    bridgeSprite:scale(widthScale, scaleY)
    
    bridgeSprite.alpha = 0
    display.getCurrentStage():insert(bridgeSprite)
    bridgeSprite:play()
    
    transition.to(bridgeSprite, {
        time = 300,
        alpha = 1,
        transition = easing.inOutQuad,
        onComplete = function()
            transition.to(bridgeSprite, {
                delay = 400,
                time = 300,
                alpha = 0,
                transition = easing.inOutQuad,
                onComplete = function()
                    if bridgeSprite.removeSelf then
                        bridgeSprite:removeSelf()
                    end
                    if callback then callback() end
                end
            })
        end
    })
end

--------------------------------------------------------------------------------
-- Função principal: night_elephant.attack
--------------------------------------------------------------------------------
function night_elephant.attack(attacker, target, battleFunctions, targetSlot, callback)
    local zoomDuration = 500  -- duração aumentada para transição suave
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("night_elephant.attack: Attacker display not found. Applying damage without animation.")
        local atkValue = tonumber(attacker.atk) or 0
        local damage = math.max(1, math.floor(atkValue * 0.50))
        battleFunctions.applyDamage(attacker, target, damage, targetSlot)
        if callback then callback() end
        return
    end

    local origX, origY = cardGroup.x, cardGroup.y
    cardGroup:toFront()
    print("night_elephant.attack: Starting zoom in. Attacker Atk = " .. tostring(attacker.atk))
    
    transition.to(cardGroup, {
        time = zoomDuration,
        xScale = 1.3,
        yScale = 1.3,
        transition = easing.inOutQuad,
        onComplete = function()
            -- Mantém o atacante ampliado enquanto a ponte e o hit ocorrem
            local atkValue = tonumber(attacker.atk) or 0
            local damage = math.max(1, math.floor(atkValue * 0.50))
            print("night_elephant.attack: Zoom in completed. Attacker Atk = " .. atkValue .. ", Damage = " .. damage)
            
            local targetDisplay = target.group or target
            if targetDisplay then
                print("night_elephant.attack: Displaying bridge animation feedback.")
                local widthScale = 0.6  -- ajuste conforme necessário
                -- Aplica o shake na carta atacada (targetDisplay) enquanto a ponte é exibida
                shake(targetDisplay, 1300, 5)
                showBridgeAnimation(cardGroup, targetDisplay, widthScale, function()
                    print("night_elephant.attack: Bridge animation finished; showing hit effect.")
                    showHitEffect(targetDisplay, function()
                        -- Após o hit, executa o zoom out do atacante
                        transition.to(cardGroup, {
                            time = zoomDuration,
                            xScale = 1.0,
                            yScale = 1.0,
                            transition = easing.inOutQuad,
                            onComplete = function()
                                battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                                print("night_elephant.attack: Hit effect finished; damage applied.")
                                if callback then callback() end
                            end
                        })
                    end)
                end)
            else
                battleFunctions.applyDamage(attacker, target, damage, targetSlot)
                print("night_elephant.attack: Target display not found; damage applied without visual feedback.")
                if callback then callback() end
            end
        end
    })
end

return night_elephant
