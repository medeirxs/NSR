-- hooks/basicAttacks/naraka.lua

-- Hook de ataque em área: zoom in no atacante, animação de ação contínua,
-- overlay escuro + overlay animado + hit no centro da tela e aplica dano a todos

local naraka = {}

-- Escalas responsivas
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth
local hitEffectScale = 4.0 * deviceScaleFactor
local overlayScale = 2.0 * deviceScaleFactor
local actionScale = 1.5 * deviceScaleFactor

----------------------------------------------------------------------------------------------------
-- Função auxiliar: createActionSprite
-- Exibe uma animação de ação sobre o atacante em loop contínuo
----------------------------------------------------------------------------------------------------
local function createActionSprite(cardGroup)
	local sheetOptions = {
		frames = {
			{ x = 110, y = 1761, width = 106, height = 51 }, -- action_83_1_00.png
			{ x = 2, y = 1640, width = 182, height = 119 }, -- action_83_1_01.png
			{ x = 2, y = 1442, width = 206, height = 123 }, -- action_83_1_02.png
			{ x = 2, y = 877, width = 218, height = 119 }, -- action_83_1_03.png
			{ x = 2, y = 2, width = 218, height = 127 }, -- action_83_1_04.png
			{ x = 2, y = 754, width = 218, height = 121 }, -- action_83_1_05.png
			{ x = 222, y = 1640, width = 196, height = 115 }, -- action_83_1_06.png
			{ x = 222, y = 1442, width = 196, height = 123 }, -- action_83_1_07.png
			{ x = 222, y = 877, width = 206, height = 119 }, -- action_83_1_08.png
			{ x = 222, y = 2, width = 206, height = 127 }, -- action_83_1_09.png
			{ x = 222, y = 754, width = 206, height = 121 }, -- action_83_1_10.png
			{ x = 436, y = 1761, width = 106, height = 51 }, -- action_83_1_11.png
			{ x = 436, y = 1640, width = 182, height = 119 }, -- action_83_1_12.png
			{ x = 436, y = 1442, width = 206, height = 123 }, -- action_83_1_13.png
			{ x = 436, y = 877, width = 218, height = 119 }, -- action_83_1_14.png
			{ x = 436, y = 2, width = 218, height = 127 }, -- action_83_1_15.png
			{ x = 436, y = 754, width = 218, height = 121 }, -- action_83_1_16.png
		},
	}
	local actionSheet = graphics.newImageSheet("assets/7effect/action_83_1.png", sheetOptions)
	local seqData = { name = "action", start = 1, count = 17, time = 1200, loopCount = 1 }
	local sprite = display.newSprite(actionSheet, seqData)

	sprite.anchorX, sprite.anchorY = 0.5, 0.5
	sprite.x, sprite.y = 0, 0.3
	sprite.alpha = 1.5
	sprite:scale(actionScale, actionScale)
	cardGroup:insert(sprite)
	sprite:toFront()
	sprite:play()

	return sprite
end

----------------------------------------------------------------------------------------------------
-- Função auxiliar: showOverlayAnimationAtPosition
-- Exibe overlay animado via spritesheet no centro da tela
----------------------------------------------------------------------------------------------------
local function showOverlayAnimationAtPosition(x, y, callback)
	local sheetOptions = {
		frames = {
			{ x = 1, y = 1, width = 640, height = 360 },
			{ x = 643, y = 1, width = 640, height = 360 },
			{ x = 1, y = 363, width = 640, height = 360 },
			{ x = 643, y = 363, width = 640, height = 360 },
			{ x = 1, y = 725, width = 640, height = 360 },
			{ x = 643, y = 725, width = 640, height = 360 },
			{ x = 1, y = 1087, width = 640, height = 360 },
			{ x = 643, y = 1087, width = 640, height = 360 },
			{ x = 1285, y = 1, width = 640, height = 360 },
			{ x = 1285, y = 363, width = 640, height = 360 },
			{ x = 1285, y = 725, width = 640, height = 360 },
			{ x = 1285, y = 1087, width = 640, height = 360 },
			{ x = 1, y = 1449, width = 640, height = 360 },
		},
	}
	local overlaySheet = graphics.newImageSheet("assets/7effect/action_111.png", sheetOptions)
	local seqData = { name = "overlay", start = 1, count = 13, time = 1500, loopCount = 1 }
	local sprite = display.newSprite(overlaySheet, seqData)

	local totalTime = seqData.time * seqData.loopCount
	local fadeTime = 750

	sprite.alpha = 0
	transition.to(sprite, { alpha = 0.7, time = fadeTime })
	transition.to(sprite, { alpha = 0, time = fadeTime, delay = totalTime - fadeTime })

	sprite.anchorX, sprite.anchorY = 0.5, 0.5
	sprite.x, sprite.y = x, y
	sprite:scale(overlayScale, overlayScale)
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

----------------------------------------------------------------------------------------------------
-- Função auxiliar: showHitAtPosition
-- Exibe hit via spritesheet em (x,y)
----------------------------------------------------------------------------------------------------
local function showHitAtPosition(x, y, callback)
	local sheetOptions = {
		frames = {
			{ x = 1, y = 1, width = 215, height = 242 },
			{ x = 218, y = 1, width = 215, height = 242 },
			{ x = 435, y = 1, width = 215, height = 242 },
			{ x = 1, y = 245, width = 215, height = 242 },
			{ x = 218, y = 245, width = 215, height = 242 },
			{ x = 435, y = 245, width = 215, height = 242 },
			{ x = 1, y = 489, width = 215, height = 242 },
			{ x = 218, y = 489, width = 215, height = 242 },
			{ x = 435, y = 489, width = 215, height = 242 },
			{ x = 652, y = 1, width = 232, height = 276 },
			{ x = 652, y = 279, width = 215, height = 242 },
			{ x = 652, y = 523, width = 215, height = 242 },
			{ x = 1, y = 767, width = 215, height = 242 },
		},
	}
	local hitSheet = graphics.newImageSheet("assets/7effect/bullet_116.png", sheetOptions)
	local seqData = { name = "hit", start = 1, count = 13, time = 1400, loopCount = 1 }
	local sprite = display.newSprite(hitSheet, seqData)

	sprite.anchorX, sprite.anchorY = 0.5, 0.5
	sprite.x, sprite.y = x, y
	sprite:scale(1.1 * hitEffectScale, hitEffectScale)
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

----------------------------------------------------------------------------------------------------
-- Função auxiliar: shakeTarget
----------------------------------------------------------------------------------------------------
local function shakeTarget(targetGroup)
	local origX, origY = targetGroup.x, targetGroup.y
	local shakeDist = 5
	local shakeTime = 50

	transition.to(targetGroup, {
		time = shakeTime,
		x = origX + shakeDist,
		onComplete = function()
			transition.to(targetGroup, {
				time = shakeTime,
				x = origX - shakeDist,
				onComplete = function()
					transition.to(targetGroup, {
						time = shakeTime,
						x = origX,
					})
				end,
			})
		end,
	})
end

--------------------------------------------------
-- Função principal: zoom in, ação contínua,
-- overlay escuro com fade, overlay animado no centro da tela,
-- hit, limpa e zoom out
--------------------------------------------------
function naraka.attack(attacker, dummyTarget, battleFunctions, targetSlot, callback)
	local cardGroup = attacker.group or attacker
	local enemyFormation = attacker.isOpponent and _G.playerFormationData or _G.opponentFormationData
	local center = attacker.isOpponent and _G.playerFormationCenter or _G.opponentFormationCenter
	local atkVal = tonumber(attacker.atk) or 0
	local damage = math.max(1, math.floor(atkVal * 0.45))

	local function getEnemyFormation()
		return attacker.isOpponent and _G.playerFormationData or _G.opponentFormationData
	end

	local function getFormationCenter()
		return attacker.isOpponent and _G.playerFormationCenter or _G.opponentFormationCenter
	end

	-- 1) Sem gráfico: aplica dano direto e shareVision e sai
	if not cardGroup then
		for slot = 1, 6 do
			local tgt = enemyFormation[slot]
			if type(tgt) == "table" then
				battleFunctions.applyDamage(attacker, tgt, damage, slot)
				if tgt.group then
					shakeTarget(tgt.group)
				end
			end
		end

		-- dá 4 cargas de shareVision ao atacante
		_G.manageCardTurn(attacker.cardData or attacker, "shareVision", 4)

		local healAmount = math.max(1, math.floor(atkVal * 0.45))
		battleFunctions.applyHealing(attacker, attacker, healAmount)

		if callback then
			callback()
		end
		return
	end

	-- 2) Zoom in no atacante
	transition.to(cardGroup, {
		time = 150,
		xScale = 1.2,
		yScale = 1.2,
		transition = easing.outQuad,
		onComplete = function()
			-- 3) Overlay preto semi-transparente
			local overlayRect = display.newRect(
				display.contentCenterX,
				display.contentCenterY,
				display.actualContentWidth,
				display.actualContentHeight
			)
			overlayRect:setFillColor(0)
			overlayRect.alpha = 0
			display.getCurrentStage():insert(overlayRect)

			local overlayLoops = 6
			local overlayFadeTime = 500
			local overlayTotalTime = overlayLoops * overlayFadeTime
			transition.to(overlayRect, { alpha = 0.8, time = overlayFadeTime })
			transition.to(
				overlayRect,
				{ alpha = 0, time = overlayFadeTime, delay = overlayTotalTime - overlayFadeTime }
			)

			-- 4) Ação contínua
			local actionSprite = createActionSprite(cardGroup)

			-- 5) Overlay animado no centro da tela
			showOverlayAnimationAtPosition(display.contentCenterX, display.contentCenterY, function()
				-- 6) Hit animado no centro da formação
				showHitAtPosition(center.x, center.y, function()
					-- limpa sprites e recorta overlay
					if actionSprite and actionSprite.removeSelf then
						actionSprite:removeSelf()
					end
					if overlayRect and overlayRect.removeSelf then
						overlayRect:removeSelf()
					end

					-- 7) Aplica dano e tremor em cada carta
					local enemyFormation = getEnemyFormation()
					for slot = 1, 6 do
						local tgt = enemyFormation[slot]
						if type(tgt) == "table" then
							battleFunctions.applyDamage(attacker, tgt, damage, slot)
							if tgt.group then
								shakeTarget(tgt.group)
							end
							if math.random() < 0.0 then
								_G.manageCardTurn(tgt, "block", 1)
							end
						end
					end

					local healAmount = math.max(1, math.floor(atkVal * 0.45))
					battleFunctions.applyHealing(attacker, attacker, healAmount)

					-- 8) Dá 4 cargas de shareVision ao atacante
					_G.manageCardTurn(attacker.cardData or attacker, "shareVision", 4)

					-- 9) Zoom out no atacante e callback final
					transition.to(cardGroup, {
						time = 150,
						xScale = 1.0,
						yScale = 1.0,
						transition = easing.inOutQuad,
						onComplete = function()
							if callback then
								callback()
							end
						end,
					})
				end)
			end)
		end,
	})
end

return naraka
