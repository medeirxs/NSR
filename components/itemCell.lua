local textile = require("utils.textile")

local itemCell = {}

function itemCell.new(params)
    local group = display.newGroup()

    local x = params.x or display.contentCenterX
    local y = params.y or display.contentCenterY
    local sprite = params.sprite
    local name = params.name
    local stars = params.stars or 5
    local params = params.params

    local bgCell = display.newImageRect(group, "assets/7bg/bg_cell_brown_2.png", 584, 132)
    bgCell.x, bgCell.y = x, y

    local image = display.newImageRect(group, sprite, 104, 104)
    image.x, image.y = bgCell.x - 220, bgCell.y - 25

    local rect = display.newRoundedRect(group, image.x, image.y + 69, 105, 24, 20)
    rect:setFillColor(0.5, 0, 0.5)

    local text = textile.new({
        group = group,
        texto = " Nv" .. 1 .. " ",
        x = image.x,
        y = image.y + 69,
        tamanho = 18,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local cardType = display.newImageRect(group, "assets/7card/prof_balance.png", 104 / 2.5, 104 / 2.5)
    cardType.x, cardType.y = image.x + 85, y - 40

    local text = textile.new({
        group = group,
        texto = name .. " ",
        x = cardType.x + 30,
        y = cardType.y,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local hpIcon = display.newImageRect(group, "assets/7icon/icon_hp.png", 48, 48)
    hpIcon.x, hpIcon.y = cardType.x, cardType.y + 40

    local hpText = textile.new({
        group = group,
        texto = 300 .. " ",
        x = hpIcon.x + 25,
        y = hpIcon.y + 1,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local atkIcon = display.newImageRect(group, "assets/7icon/icon_atk.png", 48, 48)
    atkIcon.x, atkIcon.y = cardType.x + 190, cardType.y + 40

    local atkText = textile.new({
        group = group,
        texto = 300 .. " ",
        x = atkIcon.x + 25,
        y = atkIcon.y + 1,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    for i = 1, stars do
        local star = display.newImageRect(group, "assets/7misc/misc_star_on.png", 64, 64)
        star.x = cardType.x + (i - 1) * 35
        star.y = cardType.y + 75
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

    return group

end
return itemCell
