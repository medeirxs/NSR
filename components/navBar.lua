local composer = require("composer")
local widget = require("widget")
local text = require("utils.textile")
local navBar = {}

function navBar.new(options)
    options = options or {}

    local navBarHeight = options.height or 80
    local bgImageFile = options.bgImage or "assets/7bg/bg_deco_bottom.png" -- imagem de fundo da navBar
    local buttonSize = options.buttonSize or 45 -- largura e altura das imagens dos botões

    -- Dados dos botões: cada item define a imagem, o rótulo, a função onPress e, opcionalmente, a posição individual
    local buttonData = options.buttons or {{
        image = "assets/7button/btn_home.png",
        label = "Tela Inical",
        onPress = function()
            composer.removeScene("router.home") -- Remove a cena para que ela seja recriada
            composer.gotoScene("router.home")
        end,
        buttonX = nil, -- se nil, usará a posição padrão
        buttonY = nil,
        labelX = nil,
        labelY = nil
    }, {
        image = "assets/7button/btn_campaign.png",
        label = "Jornada",
        onPress = function()
            -- composer.removeScene("router.main.campaignMain") -- Remove a cena para que ela seja recriada
            -- composer.gotoScene("router.main.campaignMain")
        end,
        buttonX = 160,
        buttonY = nil,
        labelX = nil,
        labelY = nil
    }, {
        image = "assets/7button/btn_arena.png",
        label = "Desafio",
        onPress = function()
            -- composer.gotoScene("router.main.arenaMain")
        end,
        buttonX = 265,
        buttonY = nil,
        labelX = nil,
        labelY = nil
    }, {
        image = "assets/7button/btn_alter.png",
        label = "Melhorar",
        onPress = function()
            -- composer.removeScene("router.improve.improve") -- Remove a cena para que ela seja recriada
            -- composer.gotoScene("router.improve.improve")
        end,
        buttonX = 372,
        buttonY = nil,
        labelX = nil,
        labelY = nil
    }, {
        image = "assets/7button/btn_shop.png",
        label = "Loja",
        onPress = function()
            composer.gotoScene("router.interfaces.gold")
        end,
        buttonX = 480,
        buttonY = nil,
        labelX = nil,
        labelY = nil
    }, {
        image = "assets/7button/btn_more.png",
        label = "Mais",
        onPress = function()

        end,
        buttonX = 585,
        buttonY = nil,
        labelX = nil,
        labelY = nil
    }}

    local navBarGroup = display.newGroup()

    -- Cria a imagem de fundo da navBar, que ocupará toda a largura da tela
    local background = display.newImageRect(navBarGroup, bgImageFile, display.contentWidth * 1.1, navBarHeight)
    background.anchorX = 0.5
    background.anchorY = 0
    background.x = display.contentCenterX
    background.y = display.contentHeight - (navBarHeight - 214)

    -- Calcula o espaçamento padrão entre os botões
    local numButtons = #buttonData
    local spacing = display.contentWidth / (numButtons + 1)

    -- Cria cada botão com sua imagem e texto
    for i = 1, numButtons do
        -- Posição padrão calculada para o botão
        local defaultButtonX = spacing * i - 38
        local defaultButtonY = background.y - (navBarHeight * 0.25) + 50

        -- Usa valores individuais se fornecidos, senão usa os padrões
        local posX = buttonData[i].buttonX or defaultButtonX
        local posY = buttonData[i].buttonY or defaultButtonY

        -- Cria o botão com widget.newButton
        local button = widget.newButton({
            defaultFile = buttonData[i].image,
            overFile = buttonData[i].image,
            width = buttonSize * 2.2,
            height = buttonSize * 2.2,
            onRelease = buttonData[i].onPress
        })
        button.x = posX
        button.y = posY
        navBarGroup:insert(button)

        -- Posição padrão calculada para o rótulo
        local defaultLabelX = posX
        local defaultLabelY = background.y + (navBarHeight * 0.25)

        -- Usa valores individuais para o texto se fornecidos
        local textX = buttonData[i].labelX or defaultLabelX
        local textY = buttonData[i].labelY or defaultLabelY

        local label = text.new({
            group = navBarGroup,
            texto = buttonData[i].label,
            x = textX,
            y = textY + 43,
            fonte = "assets/7fonts/Textile.ttf",
            tamanho = 18,
            corTexto = {1, 1, 1}, -- branco
            corContorno = {0, 0, 0}, -- preto
            espessuraContorno = 2,
            anchorX = 0.5 -- ajuste feito aqui
        })
    end

    return navBarGroup
end

return navBar
