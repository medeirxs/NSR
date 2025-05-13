-- components/missionButton.lua
local json = require("json")
local network = require("network")
local supabase = require("config.supabase")
local textile = require("utils.textile")

local missionButton = {}

local journeyState = nil
local pendingCbs = {}

local function notifyAll()
    for _, cb in ipairs(pendingCbs) do
        cb(journeyState)
    end
    pendingCbs = {}
end

local function fetchUserJourney(userId)
    if journeyState ~= nil then
        return
    end
    local headers = {
        ["apikey"] = supabase.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
    }
    local url = string.format("%s/rest/v1/users?select=journey&id=eq.%d", supabase.SUPABASE_URL, userId)
    network.request(url, "GET", function(ev)
        if not ev.isError and ev.status == 200 then
            local t = json.decode(ev.response)
            journeyState = tonumber((t and t[1] and t[1].journey) or 0)
        else
            print("[missionButton] erro ao buscar journey:", ev.status, ev.response)
            journeyState = 0
        end
        notifyAll()
    end, {
        headers = headers
    })
end

function missionButton.new(params)
    local group = display.newGroup()
    local x = params.x
    local y = params.y
    local sprite = params.sprite or "assets/7card/card_sketch_s.png"
    local stars = params.stars or 0
    local titleText = params.title or "asd"
    local subtitle = params.subtitle or "asd"
    local energy = params.energy or 0
    local id = params.id or 1
    local userId = params.userId or 0
    local onTap = params.onTap
    local scaleFactor = params.scaleFactor or 1

    -- fundo
    local bg = display.newImageRect(group, "assets/7bg/bg_cell_rank_1.png", 584 * scaleFactor, 136 * scaleFactor)
    bg.x, bg.y = x, y

    -- aplica filtro inicial se passado
    if params.filter then
        bg.fill.effect = params.filter
    end

    -- sprite e background de estrela
    local function getCardBg(s)
        if s == 0 then
            return "assets/empty.png"
        elseif s == 2 then
            return "assets/7card/empty_white_s.png"
        elseif s <= 4 then
            return "assets/7card/empty_green_s.png"
        elseif s <= 7 then
            return "assets/7card/empty_blue_s.png"
        else
            return "assets/7card/empty_purple_s.png"
        end
    end
    local spriteBg = display.newImageRect(group, getCardBg(stars), 104 * scaleFactor, 104 * scaleFactor)
    spriteBg.x, spriteBg.y = x - 227 * scaleFactor, y - 2 * scaleFactor
    local spt = display.newImageRect(group, sprite, 104 * scaleFactor, 104 * scaleFactor)
    spt.x, spt.y = spriteBg.x, spriteBg.y

    -- ícone de detalhes
    local infoIcon = display.newImageRect(group, "assets/7button/btn_detail.png", 61 * scaleFactor, 103 * scaleFactor)
    infoIcon.x, infoIcon.y = spriteBg.x + 476 * scaleFactor, spriteBg.y

    -- textos

    local titleLabel = textile.new({
        group = group,
        texto = titleText .. " ",
        x = x - 160 * scaleFactor,
        y = y - 40 * scaleFactor,
        tamanho = 18,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local subtitleLabel = textile.new({
        group = group,
        texto = subtitle .. " ",
        x = titleLabel.x,
        y = titleLabel.y + 35 * scaleFactor,
        tamanho = 20,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    -- energia
    local energyIcon = display.newImageRect(group, "assets/7icon/icon_energy.png", 44 / 1.1 * scaleFactor,
        44 / 1.1 * scaleFactor)
    energyIcon.x, energyIcon.y = subtitleLabel.x + 10 * scaleFactor, subtitleLabel.y + 40 * scaleFactor

    local energyText = textile.new({
        group = group,
        texto = tostring(energy) .. " ",
        x = energyIcon.x + 20 * scaleFactor,
        y = energyIcon.y,
        tamanho = 22,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    -- callback local que aplica lock/unlock
    local function applyState(journey)
        local unlocked = (journey >= id)
        if unlocked then
            if onTap then
                group:addEventListener("tap", function()
                    onTap()
                    return true
                end)
            end
        else
            infoIcon.fill.effect = "filter.grayscale"
            spriteBg.fill.effect = "filter.grayscale"
            spt.fill.effect = "filter.grayscale"
            bg.fill.effect = "filter.grayscale"
            local lockImg = display.newImageRect(group, "assets/7misc/misc_campaign_map_cell_lock.png",
                (578) * scaleFactor, (160 / 1.1) * scaleFactor)
            lockImg.x, lockImg.y = x, y + 10
        end
    end

    -- agenda callback e dispara fetch
    table.insert(pendingCbs, applyState)
    fetchUserJourney(userId)

    return group
end

return missionButton
