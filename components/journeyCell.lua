local json = require("json")
local network = require("network")
local supabase = require("config.supabase")
local textile = require("utils.textile")
local journeyCell = {}

function journeyCell.new(params)
    local group = display.newGroup()
    local x = params.x
    local y = params.y
    local userId = params.userId or 0
    local id = params.id or 1
    local scaleFactor = params.scaleFactor or 1
    local bgImage = params.bg or "assets/7bg/bg_campaign_map_cell_unopen.jpg"
    local chapterText = params.chapter or "Capítulo Indefinido"
    local titleText = params.title or "Título da Missão"
    local onTap = params.onTap

    -- fundo + borda
    local bg = display.newImageRect(group, bgImage, 600 * scaleFactor, 147 * scaleFactor)
    bg.x, bg.y = x, y
    local border = display.newImageRect(group, "assets/7bg/bg_cell_blue_border.png", 610 * scaleFactor,
        172 * scaleFactor)
    border.x, border.y = x, y + (8 * scaleFactor)

    -- textos

    local lblChapter = textile.new({
        group = group,
        texto = " " .. chapterText .. " ",
        x = x,
        y = y + (49 * scaleFactor),
        tamanho = 20,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })
    local lblTitle = textile.new({
        group = group,
        texto = " " .. titleText .. " ",
        x = x,
        y = y + (73 * scaleFactor),
        tamanho = 24,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    -- se não tem userId, já bloqueia
    if userId == 0 then
        bg.fill.effect = "filter.grayscale"
        border.fill.effect = "filter.grayscale"
        local lockImg = display.newImageRect(group, "assets/7misc/misc_campaign_map_cell_lock.png", 588 * scaleFactor,
            180 * scaleFactor)
        lockImg.x, lockImg.y = x, y
        return group
    end

    -- função que aplica lock/unlock/completed
    local function applyState(journeyVal)
        local low = (id - 1) * 10 + 1
        local high = id * 10
        if journeyVal < low then
            -- bloqueado
            bg.fill.effect = "filter.grayscale"
            border.fill.effect = "filter.grayscale"
            local lockImg = display.newImageRect(group, "assets/7misc/misc_campaign_map_cell_lock.png",
                588 * scaleFactor, 180 * scaleFactor)
            lockImg.x, lockImg.y = x, y + 10
        elseif journeyVal > high then
            -- concluído
            local isCompleted = display.newImageRect(group, "assets/7misc/misc_rating_s.png", 140 * scaleFactor,
                140 * scaleFactor)
            isCompleted.x = x + (255 * scaleFactor)
            isCompleted.y = y - (10 * scaleFactor)
            if onTap then
                group:addEventListener("tap", function()
                    onTap()
                    return true
                end)
            end
        else
            -- desbloqueado
            if onTap then
                group:addEventListener("tap", function()
                    onTap()
                    return true
                end)
            end
        end
    end

    -- busca journey e aplica estado
    local headers = {
        ["apikey"] = supabase.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
    }
    local url = string.format("%s/rest/v1/users?select=journey&id=eq.%d", supabase.SUPABASE_URL, userId)
    network.request(url, "GET", function(ev)
        if not ev.isError and ev.status == 200 then
            local t = json.decode(ev.response)
            local val = (t and t[1] and t[1].journey) or 0
            applyState(val)
        else
            print("Erro fetch journey:", ev.status, ev.response)
            applyState(0)
        end
    end, {
        headers = headers
    })

    return group
end

return journeyCell
