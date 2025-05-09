local json = require("json")
local network = require("network")
local supabase = require("config.supabase")

local cardS = require("components.cardS")
local textile = require("utils.textile")

local cardCell = {}

local CharacterType = {}
local function getCardTypeImage(t)
    if t == "atk" then
        return "assets/7card/prof_attack.png"
    elseif t == "cr" then
        return "assets/7card/prof_heal.png"
    elseif t == "bal" then
        return "assets/7card/prof_balance.png"
    elseif t == "def" then
        return "assets/7card/prof_defense.png"
    end
    return nil
end
function CharacterType.new(params)
    local group = display.newGroup()
    group.x = params.x or display.contentCenterX
    group.y = params.y or display.contentCenterY

    local iconSize = params.size or 32
    local headers = {
        ["apikey"] = supabase.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
    }
    local url = string.format("%s/rest/v1/characters?select=card_type&uuid=eq.%s", supabase.SUPABASE_URL,
        tostring(params.characterId))

    local function networkListener(event)
        if event.isError then
            print("Erro ao buscar tipo de carta:", event.response)
            if params.callback then
                params.callback(nil)
            end
            return
        end
        local data = json.decode(event.response)
        if data and #data > 0 and data[1].card_type then
            local imgPath = getCardTypeImage(data[1].card_type)
            if imgPath then
                local icon = display.newImageRect(group, imgPath, iconSize, iconSize)
                icon.x, icon.y = 0, 0
                if params.callback then
                    params.callback(icon)
                end
            else
                if params.callback then
                    params.callback(nil)
                end
            end
        else
            if params.callback then
                params.callback(nil)
            end
        end
    end

    network.request(url, "GET", networkListener, {
        headers = headers
    })
    return group
end

function cardCell.new(params)
    local group = display.newGroup()

    local x = params.x
    local y = params.y
    local characterId = params.characterId or 0
    local stars = params.stars or 0
    local level = params.level or 1
    local hp = params.hp or 1
    local atk = params.atk or 1
    local name = params.name or "Ninja"
    local search = params.search or false
    local searchFunc = params.searchFunc or ""
    local params = params.params

    local bgCell = display.newImageRect(group, "assets/7bg/bg_cell_brown_2.png", 584, 132)
    bgCell.x, bgCell.y = x, y

    local cardS = cardS.new({
        x = bgCell.x - 220,
        y = bgCell.y - 25,
        characterId = characterId,
        stars = stars,
        scaleFactor = 0.95
    })
    group:insert(cardS)

    local st = stars or 2
    local lvl = level or 1
    local bgColor
    if st == 2 then
        bgColor = {0.5, 0.5, 0.5} -- cinza
    elseif st <= 4 then
        bgColor = {0, 1, 0} -- verde
    elseif st <= 7 then
        bgColor = {0, 0, 1} -- azul
    elseif st <= 11 then
        bgColor = {0.5, 0, 0.5} -- roxo
    else
        bgColor = {1, 1, 1} -- branco padrão
    end
    local rect = display.newRoundedRect(group, cardS.x, cardS.y + 69, 105, 24, 20)
    rect:setFillColor(unpack(bgColor))

    local text = textile.new({
        group = group,
        texto = " Nv" .. level .. " ",
        x = rect.x,
        y = rect.y,
        tamanho = 18,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local typeIconGroup = CharacterType.new {
        x = cardS.x + 85,
        y = y - 40,
        characterId = characterId,
        size = 42,
        callback = function(icon)
        end
    }
    group:insert(typeIconGroup)

    local text = textile.new({
        group = group,
        texto = name .. " ",
        x = typeIconGroup.x + 30,
        y = typeIconGroup.y,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local hpIcon = display.newImageRect(group, "assets/7icon/icon_hp.png", 48, 48)
    hpIcon.x, hpIcon.y = typeIconGroup.x, typeIconGroup.y + 40

    local hpText = textile.new({
        group = group,
        texto = hp .. " ",
        x = hpIcon.x + 25,
        y = hpIcon.y + 1,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local atkIcon = display.newImageRect(group, "assets/7icon/icon_atk.png", 48, 48)
    atkIcon.x, atkIcon.y = typeIconGroup.x + 190, typeIconGroup.y + 40

    local atkText = textile.new({
        group = group,
        texto = atk .. " ",
        x = atkIcon.x + 25,
        y = atkIcon.y + 1,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local function calcularEstrelasVisuais(stars)
        if stars <= 2 then
            return 2
        elseif stars <= 4 then
            return 3
        elseif stars <= 7 then
            return 4
        elseif stars <= 11 then
            return 5
        else
            return 5 -- valor máximo, caso ultrapasse
        end
    end

    local starsCount = calcularEstrelasVisuais(stars)
    for i = 1, starsCount do
        local star = display.newImageRect(group, "assets/7misc/misc_star_on.png", 64, 64)
        star.x = 186 + (i - 1) * 35
        star.y = bgCell.y + 35
    end

    local lockIcon = display.newImageRect(group, "assets/7icon/icon_status_lock_gray.png", 34, 34)
    lockIcon.x, lockIcon.y = bgCell.x + 90, bgCell.y - 70

    local flagIcon = display.newImageRect(group, "assets/7icon/icon_status_inband_gray.png", 34, 34)
    flagIcon.x, flagIcon.y = lockIcon.x + (30), lockIcon.y
    local toolIcon = display.newImageRect(group, "assets/7icon/icon_status_weapon_gray.png", 34, 34)
    toolIcon.x, toolIcon.y = lockIcon.x + (30 * 2), lockIcon.y
    local mantleIcon = display.newImageRect(group, "assets/7icon/icon_status_armor_gray.png", 34, 34)
    mantleIcon.x, mantleIcon.y = lockIcon.x + (30 * 3), lockIcon.y
    local acessoryIcon = display.newImageRect(group, "assets/7icon/icon_status_necklace_gray.png", 34, 34)
    acessoryIcon.x, acessoryIcon.y = lockIcon.x + (30 * 4), lockIcon.y
    local mountIcon = display.newImageRect(group, "assets/7icon/icon_status_mount_gray.png", 34, 34)
    mountIcon.x, mountIcon.y = lockIcon.x + (30 * 5), lockIcon.y

    if search then
        local btnAdd = display.newImageRect(group, "assets/7button/btn_search.png", 34 * 2.7, 34 * 2.7)
        btnAdd.x, btnAdd.y = bgCell.x + 235, bgCell.y
        group:insert(btnAdd)

    end

    return group
end
return cardCell
