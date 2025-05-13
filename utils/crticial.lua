-- components/critical.lua
local Critical = {}

-- params:
--   group       : display group (default = display.currentStage)
--   x, y        : posição de centro do texto
--   texto       : string só com [0–9,+,-]
--   spacing     : espaço extra entre caracteres (default = 0)
--   scaleFactor : escala uniforme (default = 1)
--   hueAngle    : ângulo de hue em radianos (p.ex. math.pi para 180°) – opcional
function Critical.new(params)
    local parent = params.group or display.currentStage
    local x0 = params.x or 0
    local y0 = params.y or 0
    local texto = tostring(params.texto or "")
    local spacing = params.spacing or 0
    local scaleFactor = params.scaleFactor or 1
    local hueAngle = params.hueAngle -- se nil, sem mudança de cor

    -- 1) medir larguras
    local widths, totalW = {}, 0
    for i = 1, #texto do
        local c = texto:sub(i, i)
        local file = "assets/7fonts/critical/" .. c .. ".png"
        local tmp = display.newImage(file)
        if tmp then
            widths[i] = tmp.contentWidth
            totalW = totalW + widths[i]
            tmp:removeSelf()
        else
            widths[i] = 0
            print("critical.lua: não encontrou →", file)
        end
        if i < #texto then
            totalW = totalW + spacing
        end
    end

    -- 2) criar grupo centralizado
    local textGroup = display.newGroup()
    parent:insert(textGroup)
    textGroup.x, textGroup.y = x0 - (totalW * scaleFactor) / 2, y0
    textGroup.xScale, textGroup.yScale = scaleFactor, scaleFactor

    -- 3) renderizar cada caractere
    local offsetX = 0
    for i = 1, #texto do
        local c = texto:sub(i, i)
        local file = "assets/7fonts/critical/" .. c .. ".png"
        local charImg = display.newImage(textGroup, file)
        if charImg then
            charImg.anchorX, charImg.anchorY = 0, 0
            charImg.x, charImg.y = offsetX, 0
            -- aplica hue, se solicitado
            if hueAngle then
                charImg.fill.effect = "filter.hue"
                charImg.fill.effect.angle = hueAngle
            end
            offsetX = offsetX + widths[i] + spacing
        end
    end

    return textGroup
end

return Critical
