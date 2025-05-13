local testPassive = {}

-- Parâmetros de design
local designWidth = 1080
local deviceScaleFactor = display.actualContentWidth / designWidth

-- Configuração da spritesheet para o efeito passivo
local spriteSheetOptions = {
    frames = {
        { x = 1208, y = 2, width = 132, height = 124 },
        { x = 1208, y = 136, width = 110, height = 118 },
        { x = 1208, y = 256, width = 100, height = 112 },
        { x = 2, y = 2, width = 400, height = 158 },
        { x = 806, y = 318, width = 400, height = 156 },
        { x = 806, y = 160, width = 400, height = 156 },
        { x = 806, y = 2, width = 400, height = 156 },
        { x = 404, y = 318, width = 400, height = 156 },
        { x = 404, y = 160, width = 400, height = 156 },
        { x = 404, y = 2, width = 400, height = 156 },
        { x = 2, y = 162, width = 400, height = 156 },
        { x = 2, y = 320, width = 400, height = 154 },
        { x = 1320, y = 136, width = 1, height = 1 },
        { x = 1320, y = 136, width = 1, height = 1 },
    }
}
local passiveSheet = graphics.newImageSheet("assets/7effect/action_39.png", spriteSheetOptions)
local sequenceData = {
    name = "passiveAnim",
    start = 1,
    count = 14,
    time = 800,      -- tempo total da animação
    loopCount = 0    -- 0 para looping infinito
}

-- Função principal do hook: executa a animação e ativa a passiva por 2 rounds
function testPassive.attack(attacker, target, battleFunctions, targetSlot, callback)
    local cardGroup = attacker.group or attacker
    if not cardGroup then
        print("testPassive: Objeto de display do atacante não encontrado. Abortando a animação passiva.")
        if callback then callback() end
        return
    end

    cardGroup:toFront()
    print("testPassive: Iniciando animação passiva na carta " .. (attacker.name or "Sem Nome"))

    -- Cria o sprite da animação passiva e posiciona no centro do cardGroup
    local passiveSprite = display.newSprite(passiveSheet, sequenceData)
    passiveSprite.anchorX = 0.5
    passiveSprite.anchorY = 0.5
    passiveSprite.x = cardGroup.x
    passiveSprite.y = cardGroup.y
    passiveSprite:scale(deviceScaleFactor, deviceScaleFactor)
    
    -- Insere o sprite no mesmo grupo que a carta para garantir que fique visível
    if cardGroup.parent then
        cardGroup.parent:insert(passiveSprite)
        passiveSprite:toFront()
    end

    passiveSprite:play()

    -- Ativa a passiva na carta: ela ficará ativa por 2 rounds
    attacker.passiveActive = true
    attacker.passiveRoundsLeft = 2
    attacker.passiveEffectSprite = passiveSprite

    print("testPassive: Passiva ativada na carta por 2 rounds.")
    if callback then callback() end
end

return testPassive
