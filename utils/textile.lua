-- components/textoComContorno.lua (com suporte a anchorX)
local M = {}

function M.new(params)
    local group = params.group or display.currentStage
    local texto = params.texto or "Texto"
    local x, y = params.x or 0, params.y or 0
    local fonte = "assets/7fonts/Textile.ttf"
    local tamanho = params.tamanho or 20
    local corTexto = params.corTexto or {1, 1, 1}
    local corContorno = params.corContorno or {0, 0, 0}
    local espessuraContorno = params.espessuraContorno or 2
    local anchorX = params.anchorX or 0.5
    local anchorY = params.anchorY or 0.5

    local grupoTexto = display.newGroup()
    group:insert(grupoTexto)

    local offsets = {{-espessuraContorno, 0}, {espessuraContorno, 0}, {0, -espessuraContorno}, {0, espessuraContorno},
                     {-espessuraContorno, -espessuraContorno}, {espessuraContorno, -espessuraContorno},
                     {-espessuraContorno, espessuraContorno}, {espessuraContorno, espessuraContorno}}

    local textosContorno = {}

    -- Textos de contorno
    for i = 1, #offsets do
        local offset = offsets[i]
        local textoContorno = display.newText({
            text = texto,
            x = offset[1],
            y = offset[2],
            font = fonte,
            fontSize = tamanho
        })
        textoContorno.anchorX, textoContorno.anchorY = anchorX, anchorY
        textoContorno:setFillColor(unpack(corContorno))
        grupoTexto:insert(textoContorno)
        textosContorno[#textosContorno + 1] = textoContorno
    end

    -- Texto principal
    local textoPrincipal = display.newText({
        text = texto,
        x = 0,
        y = 0,
        font = fonte,
        fontSize = tamanho
    })
    textoPrincipal.anchorX, textoPrincipal.anchorY = anchorX, anchorY
    textoPrincipal:setFillColor(unpack(corTexto))
    grupoTexto:insert(textoPrincipal)

    grupoTexto.x, grupoTexto.y = x, y

    -- Função para atualizar texto
    function grupoTexto:setText(novoTexto)
        textoPrincipal.text = novoTexto
        for i = 1, #textosContorno do
            textosContorno[i].text = novoTexto
        end
    end

    return grupoTexto
end

return M
