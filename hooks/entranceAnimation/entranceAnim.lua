local entranceAnim = {}

-- Tempo da animação em milissegundos (ajuste conforme necessário)
local animTime = 1000  
-- Controle de escala (1.0 = tamanho normal)
local animScale = 3.0  

function entranceAnim.play(x, y, width, height, parentGroup, callback)
    local sheetOptions = {
        frames = {
            { x = 1,    y = 1,    width = 56,  height = 52,  sourceX = 60, sourceY = 74, sourceWidth = 200, sourceHeight = 200 },
            { x = 59,   y = 1,    width = 126, height = 118, sourceX = 25, sourceY = 41, sourceWidth = 200, sourceHeight = 200 },
            { x = 187,  y = 1,    width = 116, height = 108, sourceX = 30, sourceY = 46, sourceWidth = 200, sourceHeight = 200 },
            { x = 305,  y = 1,    width = 114, height = 98,  sourceX = 31, sourceY = 51, sourceWidth = 200, sourceHeight = 200 },
            { x = 421,  y = 1,    width = 114, height = 92,  sourceX = 31, sourceY = 54, sourceWidth = 200, sourceHeight = 200 },
            { x = 537,  y = 1,    width = 114, height = 86,  sourceX = 31, sourceY = 57, sourceWidth = 200, sourceHeight = 200 },
            { x = 653,  y = 1,    width = 116, height = 78,  sourceX = 30, sourceY = 61, sourceWidth = 200, sourceHeight = 200 },
            { x = 653,  y = 81,   width = 114, height = 78,  sourceX = 31, sourceY = 61, sourceWidth = 200, sourceHeight = 200 },
            { x = 769,  y = 81,   width = 114, height = 102, sourceX = 31, sourceY = 49, sourceWidth = 200, sourceHeight = 200 },
            { x = 1,    y = 185,  width = 114, height = 112, sourceX = 31, sourceY = 44, sourceWidth = 200, sourceHeight = 200 },
            { x = 117,  y = 185,  width = 132, height = 108, sourceX = 22, sourceY = 46, sourceWidth = 200, sourceHeight = 200 },
            { x = 251,  y = 185,  width = 140, height = 98,  sourceX = 18, sourceY = 51, sourceWidth = 200, sourceHeight = 200 },
            { x = 393,  y = 185,  width = 146, height = 104, sourceX = 15, sourceY = 48, sourceWidth = 200, sourceHeight = 200 },
            { x = 541,  y = 185,  width = 168, height = 110, sourceX = 4,  sourceY = 45, sourceWidth = 200, sourceHeight = 200 },
            { x = 711,  y = 185,  width = 156, height = 112, sourceX = 10, sourceY = 44, sourceWidth = 200, sourceHeight = 200 },
            { x = 1,    y = 299,  width = 160, height = 98,  sourceX = 8,  sourceY = 51, sourceWidth = 200, sourceHeight = 200 },
            { x = 163,  y = 299,  width = 160, height = 98,  sourceX = 8,  sourceY = 51, sourceWidth = 200, sourceHeight = 200 },
            { x = 325,  y = 299,  width = 158, height = 100, sourceX = 9,  sourceY = 50, sourceWidth = 200, sourceHeight = 200 },
            { x = 485,  y = 299,  width = 158, height = 100, sourceX = 9,  sourceY = 50, sourceWidth = 200, sourceHeight = 200 },
            { x = 645,  y = 299,  width = 154, height = 98,  sourceX = 11, sourceY = 51, sourceWidth = 200, sourceHeight = 200 },
            { x = 1,    y = 399,  width = 154, height = 122, sourceX = 11, sourceY = 39, sourceWidth = 200, sourceHeight = 200 },
            { x = 157,  y = 399,  width = 150, height = 118, sourceX = 13, sourceY = 41, sourceWidth = 200, sourceHeight = 200 },
            { x = 645,  y = 399,  width = 150, height = 118, sourceX = 13, sourceY = 41, sourceWidth = 200, sourceHeight = 200 },
            { x = 157,  y = 519,  width = 100, height = 118, sourceX = 38, sourceY = 41, sourceWidth = 200, sourceHeight = 200 },
            { x = 259,  y = 519,  width = 100, height = 120, sourceX = 38, sourceY = 40, sourceWidth = 200, sourceHeight = 200 },
            { x = 361,  y = 519,  width = 98,  height = 96,  sourceX = 39, sourceY = 52, sourceWidth = 200, sourceHeight = 200 },
            { x = 461,  y = 519,  width = 98,  height = 96,  sourceX = 39, sourceY = 52, sourceWidth = 200, sourceHeight = 200 },
            { x = 561,  y = 519,  width = 100, height = 96,  sourceX = 38, sourceY = 52, sourceWidth = 200, sourceHeight = 200 },
            { x = 663,  y = 519,  width = 100, height = 104, sourceX = 38, sourceY = 48, sourceWidth = 200, sourceHeight = 200 },
            { x = 801,  y = 299,  width = 82,  height = 116, sourceX = 47, sourceY = 42, sourceWidth = 200, sourceHeight = 200 },
            { x = 797,  y = 417,  width = 82,  height = 122, sourceX = 47, sourceY = 39, sourceWidth = 200, sourceHeight = 200 },
            { x = 1,    y = 541,  width = 82,  height = 124, sourceX = 47, sourceY = 38, sourceWidth = 200, sourceHeight = 200 },
            { x = 765,  y = 541,  width = 104, height = 174, sourceX = 36, sourceY = 13, sourceWidth = 200, sourceHeight = 200 },
            { x = 885,  y = 1,    width = 108, height = 174, sourceX = 34, sourceY = 13, sourceWidth = 200, sourceHeight = 200 },
            { x = 1,    y = 717,  width = 126, height = 200, sourceX = 25, sourceY = 0,  sourceWidth = 200, sourceHeight = 200 },
            { x = 129,  y = 717,  width = 128, height = 188, sourceX = 24, sourceY = 6,  sourceWidth = 200, sourceHeight = 200 },
            { x = 259,  y = 717,  width = 126, height = 188, sourceX = 25, sourceY = 6,  sourceWidth = 200, sourceHeight = 200 },
            { x = 871,  y = 541,  width = 118, height = 188, sourceX = 29, sourceY = 6,  sourceWidth = 200, sourceHeight = 200 },
            { x = 885,  y = 177,  width = 104, height = 188, sourceX = 36, sourceY = 6,  sourceWidth = 200, sourceHeight = 200 },
            { x = 387,  y = 731,  width = 98,  height = 196, sourceX = 39, sourceY = 2,  sourceWidth = 200, sourceHeight = 200 },
            { x = 487,  y = 731,  width = 86,  height = 200, sourceX = 45, sourceY = 0,  sourceWidth = 200, sourceHeight = 200 },
            { x = 575,  y = 731,  width = 88,  height = 200, sourceX = 44, sourceY = 0,  sourceWidth = 200, sourceHeight = 200 },
            { x = 665,  y = 731,  width = 88,  height = 200, sourceX = 44, sourceY = 0,  sourceWidth = 200, sourceHeight = 200 },
            { x = 755,  y = 731,  width = 88,  height = 200, sourceX = 44, sourceY = 0,  sourceWidth = 200, sourceHeight = 200 },
            { x = 995,  y = 1,    width = 176, height = 200, sourceX = 0,  sourceY = 0,  sourceWidth = 200, sourceHeight = 200 },
            { x = 991,  y = 203,  width = 82,  height = 174, sourceX = 47, sourceY = 13, sourceWidth = 200, sourceHeight = 200 },
            { x = 991,  y = 379,  width = 124, height = 180, sourceX = 26, sourceY = 10, sourceWidth = 200, sourceHeight = 200 },
            { x = 991,  y = 561,  width = 136, height = 130, sourceX = 20, sourceY = 35, sourceWidth = 200, sourceHeight = 200 },
            { x = 991,  y = 693,  width = 114, height = 110, sourceX = 31, sourceY = 45, sourceWidth = 200, sourceHeight = 200 },
            { x = 771,  y = 1,    width = 76,  height = 72,  sourceX = 50, sourceY = 64, sourceWidth = 200, sourceHeight = 200 },
        }
    }
    local imageSheet = graphics.newImageSheet("assets/7effect/edo_anim.png", sheetOptions)
    local sequenceData = {
        name = "entrance",
        start = 1,
        count = 49,
        time = 2000,
        loopCount = 1
    }
    local animSprite = display.newSprite(imageSheet, sequenceData)
    animSprite.anchorX = 0.5
    animSprite.anchorY = 0.5
    animSprite.x = x * 1.5
    animSprite.y = y
    animSprite.rotation = 180
    animSprite:scale(animScale, animScale)
    if parentGroup then
        parentGroup:insert(animSprite)
    else
        display.getCurrentStage():insert(animSprite)
    end
    animSprite:toFront()
    animSprite:play()
    animSprite:addEventListener("sprite", function(event)
        if event.phase == "ended" then
            if animSprite.removeSelf then animSprite:removeSelf() end
            if callback then callback() end
        end
    end)
end

return entranceAnim
