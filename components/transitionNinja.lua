-- transitionNinja.lua
-- Componente para tocar a animação do ninja a partir da spritesheet
local transitionNinja = {}

-- 1) Definição dos frames, conforme seu mapeamento:
local sheetOptions = {
    frames = {{
        x = 1,
        y = 1,
        width = 800,
        height = 600
    }, -- frame 1
    {
        x = 803,
        y = 1,
        width = 800,
        height = 600
    }, -- frame 2
    {
        x = 1,
        y = 603,
        width = 800,
        height = 600
    }, -- frame 3
    {
        x = 803,
        y = 603,
        width = 800,
        height = 600
    }, -- frame 4
    {
        x = 1,
        y = 1205,
        width = 800,
        height = 600
    }, -- frame 5
    {
        x = 803,
        y = 1205,
        width = 800,
        height = 600
    }, -- frame 6
    {
        x = 1605,
        y = 1,
        width = 800,
        height = 600
    }, -- frame 7
    {
        x = 1605,
        y = 603,
        width = 800,
        height = 600
    } -- frame 8
    }
}

-- 2) Carrega a imagem (coloque seu arquivo PNG na pasta assets/ com este nome)
local spriteSheet = graphics.newImageSheet("assets/7effect/spritesheet_5.png", sheetOptions)

-- 3) Configuração padrão da sequência
local defaultSequence = {
    name = "run",
    frames = {1, 2, 3, 4, 5, 6, 7, 8},
    time = 800, -- duração total em ms
    loopCount = 2 -- quantas vezes repete (0 = infinito)
}

function transitionNinja.new(params)
    local group = params.group or display.currentStage
    local x = params.x or display.contentCenterX
    local y = params.y or display.contentCenterY
    local time = params.time or defaultSequence.time
    local loopCount = params.loopCount or defaultSequence.loopCount

    -- monta a própria sequência ajustando time e loopCount
    local sequenceData = {{
        name = defaultSequence.name,
        frames = defaultSequence.frames,
        time = time,
        loopCount = loopCount
    }}

    -- cria o sprite
    local ninja = display.newSprite(group, spriteSheet, sequenceData)
    ninja.x, ninja.y = x, y
    ninja:scale(0.9, 0.9)
    ninja:play()

    local ninjaSound = audio.loadSound("assets/sound/eft_battle_ninja_forward.mp3")
    timer.performWithDelay(0, function()
        audio.play(ninjaSound, {
            channel = 2
        })
    end)
    timer.performWithDelay(300, function()
        audio.play(ninjaSound, {
            channel = 3
        })
    end)
    timer.performWithDelay(600, function()
        audio.play(ninjaSound, {
            channel = 4
        })
    end)

    -- se passar callback, aguarda fase "ended" da animação
    if params.onComplete then
        ninja:addEventListener("sprite", function(event)
            if event.phase == "ended" and event.target == ninja then
                params.onComplete()
            end
        end)
    end

    return ninja
end

return transitionNinja
