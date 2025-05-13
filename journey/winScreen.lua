local composer = require("composer")
local getUsers = require("api.getUsers")
local textile = require("utils.textile")
local cloudOn = require("utils.cloudOn")
local cloudOff = require("utils.cloudOff")
local userDataLib = require("lib.userData")

local data = userDataLib.load() or {}
local userId = tonumber(data.id) or 461752844
local serverId = tonumber(data.server) or 1

local component = {}

local userLevelBar = {}

local getUsers = require("api.getUsers")

local xpThresholds = {
    [1] = 0,
    [2] = 3,
    [3] = 7,
    [4] = 11,
    [5] = 15,
    [6] = 19,
    [7] = 23,
    [8] = 27,
    [9] = 32,
    [10] = 36,
    [11] = 41,
    [12] = 46,
    [13] = 51,
    [14] = 56,
    [15] = 62,
    [16] = 68,
    [17] = 73,
    [18] = 79,
    [19] = 86,
    [20] = 92,
    [21] = 99,
    [22] = 106,
    [23] = 113,
    [24] = 121,
    [25] = 128,
    [26] = 136,
    [27] = 145,
    [28] = 153,
    [29] = 162,
    [30] = 171,
    [31] = 181,
    [32] = 191,
    [33] = 201,
    [34] = 211,
    [35] = 222,
    [36] = 233,
    [37] = 245,
    [38] = 257,
    [39] = 270,
    [40] = 283,
    [41] = 296,
    [42] = 310,
    [43] = 324,
    [44] = 339,
    [45] = 354,
    [46] = 370,
    [47] = 387,
    [48] = 404,
    [49] = 421,
    [50] = 440,
    [51] = 458,
    [52] = 478,
    [53] = 498,
    [54] = 519,
    [55] = 541,
    [56] = 563,
    [57] = 587,
    [58] = 611,
    [59] = 635,
    [60] = 661,
    [61] = 688,
    [62] = 715,
    [63] = 744,
    [64] = 773,
    [65] = 804,
    [66] = 836,
    [67] = 868,
    [68] = 902,
    [69] = 937,
    [70] = 974,
    [71] = 1011,
    [72] = 1050,
    [73] = 1090,
    [74] = 1132,
    [75] = 1175,
    [76] = 1220,
    [77] = 1266,
    [78] = 1314,
    [79] = 1363,
    [80] = 1415,
    [81] = 1468,
    [82] = 1522,
    [83] = 1579,
    [84] = 1638,
    [85] = 1699,
    [86] = 1762,
    [87] = 1827,
    [88] = 1894,
    [89] = 1964,
    [90] = 2036,
    [91] = 2111,
    [92] = 2189,
    [93] = 2269,
    [94] = 2352,
    [95] = 2437,
    [96] = 2526,
    [97] = 2618,
    [98] = 2713,
    [99] = 2812,
    [100] = 2914,
    [101] = 3019,
    [102] = 3128,
    [103] = 3241,
    [104] = 3358,
    [105] = 3479,
    [106] = 3605,
    [107] = 3734,
    [108] = 3868,
    [109] = 4007,
    [110] = 4151,
    [111] = 4300,
    [112] = 4454,
    [113] = 4613,
    [114] = 4778,
    [115] = 4949,
    [116] = 5126,
    [117] = 5309,
    [118] = 5498,
    [119] = 5694,
    [120] = 5897,
    [121] = 6106,
    [122] = 6324,
    [123] = 6548,
    [124] = 6781,
    [125] = 7022,
    [126] = 7271,
    [127] = 7529,
    [128] = 7796,
    [129] = 8073,
    [130] = 8359,
    [131] = 8655,
    [132] = 8961,
    [133] = 9278,
    [134] = 9607,
    [135] = 9946,
    [136] = 10298,
    [137] = 10662,
    [138] = 11039,
    [139] = 11428,
    [140] = 11832,
    [141] = 12249,
    [142] = 12682,
    [143] = 13129,
    [144] = 13592,
    [145] = 14071,
    [146] = 14567,
    [147] = 15081,
    [148] = 15612,
    [149] = 16162,
    [150] = 16731,
    [151] = 17320,
    [152] = 17930,
    [153] = 18561,
    [154] = 19214,
    [155] = 19890,
    [156] = 20590,
    [157] = 21314,
    [158] = 22063,
    [159] = 22839,
    [160] = 23642,
    [161] = 24473,
    [162] = 25333,
    [163] = 26223,
    [164] = 27144,
    [165] = 28098,
    [166] = 29085,
    [167] = 30106,
    [168] = 31164,
    [169] = 32258,
    [170] = 33390,
    [171] = 34562,
    [172] = 35776,
    [173] = 37031,
    [174] = 38331,
    [175] = 39676,
    [176] = 41068,
    [177] = 42509,
    [178] = 44000,
    [179] = 45544
}

local function getLevelFromXp(xp)
    local lvl = 1
    for level, minXp in pairs(xpThresholds) do
        if xp >= minXp and level > lvl then
            lvl = level
        end
    end
    return lvl
end

-- Retorna nível baseado no XP
local function calculateLevel(xp)
    local level = 1
    for lvl, threshold in ipairs(xpThresholds) do
        if xp >= threshold then
            level = lvl
        else
            break
        end
    end
    return level
end

function userLevelBar.new(params)
    local group = display.newGroup()
    group.x, group.y = params.x or 0, params.y or 0

    local userId = tonumber(data.id)
    local serverId = tonumber(data.server) -- opcional
    local showBar = (params.xpBar ~= false)

    local levelText = textile.new({
        group = group,
        texto = "...",
        x = -105,
        y = 130,
        tamanho = 20,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })
    local xpText = textile.new({
        group = group,
        texto = "...",
        x = -145,
        y = 175,
        tamanho = 22,
        corTexto = {0.29, 0.87, 0.34}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local barWidth, barHeight, barY = params.barWidth or 290, params.barHeight or 8, params.barY or 150
    local bgBar, fillBar
    if showBar then
        bgBar = display.newRoundedRect(group, 0, barY, barWidth, barHeight, barHeight / 2)
        bgBar:setFillColor(0.3)
        fillBar = display.newRoundedRect(group, -barWidth / 2, barY, barWidth, barHeight, barHeight / 2)
        fillBar.anchorX = 0
        fillBar:setFillColor(0, 1, 0)
        fillBar.width = 0
    end
    -- Busca dados do usuário
    getUsers.fetch(userId, serverId, function(data, err)
        if err then
            levelText.text = "Erro"
            xpText.text = ""
            return
        end

        local rawXp = tonumber(data.level) or 0
        local lvl = getLevelFromXp(rawXp)
        local minXp = xpThresholds[lvl]
        local maxXp = xpThresholds[lvl + 1] or rawXp
        local nextXp = xpThresholds[lvl + 1] or rawXp

        levelText.text = "Nv" .. lvl
        xpText:setText("Para elevar, é necessário EXP:" .. nextXp - rawXp .. " ")
        levelText:setText(tostring(lvl) .. " ")

        -- Atualiza barra de XP se existir
        if showBar and fillBar then
            local percent = (rawXp - minXp) / (maxXp - minXp)
            percent = math.max(0, math.min(percent, 1))
            fillBar.width = barWidth * percent
        end
    end)

    return group
end

function component.new(params)
    local group = display.newGroup()

    local silver = params.silver
    local exp = params.exp
    local userId = params.userId
    local title = params.title
    local subtitle = params.subtitle
    local returnTo = params.returnTo
    local params = params.params

    local winnerSound = audio.loadSound("assets/sound/battle_win.mp3")
    timer.performWithDelay(0, function()
        audio.play(winnerSound, {
            channel = 2
        })
    end)

    local blackAlpha = display.newImageRect(group, "assets/7bg/bg_activity_bg.png", 2000, 2000)
    blackAlpha.x, blackAlpha.y = display.contentCenterX, display.contentCenterY
    local blackAlph2 = display.newImageRect(group, "assets/7bg/bg_activity_bg.png", 2000, 2000)
    blackAlph2.x, blackAlph2.y = display.contentCenterX, display.contentCenterY
    blackAlph2.alpha = 0.5
    blackAlpha:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("journey.winScreen")
            group:removeSelf()
            composer.removeScene(returnTo)
            composer.gotoScene(returnTo)
        end)
        timer.performWithDelay(300, function()
            cloudOff.show({
                group = display.getCurrentStage(),
                time = 600
            })
        end)
    end)

    local title = display.newText({
        text = title .. " ",
        x = 30,
        y = -100,
        font = "assets/7fonts/Textile.ttf",
        fontSize = 30
    })
    group:insert(title)
    title.anchorX = 0
    title:setFillColor(0.95, 0.86, 0.31)

    local subtitle = display.newText({
        text = subtitle .. " ",
        x = 30,
        y = -65,
        font = "assets/7fonts/Textile.ttf",
        fontSize = 22
    })
    group:insert(subtitle)
    subtitle.anchorX = 0
    subtitle:setFillColor(0.6, 0.6, 0.6)

    local divider1 = display.newImageRect(group, "assets/7bg/bg_bottom_frame_2.png", 610, 3)
    divider1.x, divider1.y = display.contentCenterX, -35
    divider1.alpha = 0.8

    local miscRatingOuter = display.newImageRect(group, "assets/7misc/misc_rating_outer_bg.png", 300 * 1.1, 300 * 1.1)
    miscRatingOuter.x, miscRatingOuter.y = display.contentWidth - 160, 80

    local function spin(obj)
        transition.to(obj, {
            time = 2000,
            rotation = obj.rotation + 50,
            onComplete = function()
                spin(obj)
            end
        })
    end
    spin(miscRatingOuter)

    local miscRatingInner = display.newImageRect(group, "assets/7misc/misc_rating_inner_bg.png", 300 * 1.1, 300 * 1.1)
    miscRatingInner.x, miscRatingInner.y = display.contentWidth - 160, 80

    local function spin(obj)
        transition.to(obj, {
            time = 2000,
            rotation = obj.rotation - 50,
            onComplete = function()
                spin(obj)
            end
        })
    end
    spin(miscRatingInner)

    local rating = display.newImageRect(group, "assets/7misc/misc_rating_sign_s.png", 300 * 1.1, 300 * 1.1)
    rating.x, rating.y = display.contentWidth - 160, 80

    local iconsGroup = display.newGroup()
    group:insert(iconsGroup)
    iconsGroup.y = 50
    iconsGroup.x = -10

    local silverIcon = display.newImageRect(iconsGroup, "assets/7icon/icon_coin.png", 48 / 1.1, 48 / 1.1)
    silverIcon.x, silverIcon.y = 50, 0
    local silverText = textile.new({
        group = group,
        texto = silver .. " ",
        x = silverIcon.x + 15,
        y = silverIcon.y + 52,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local expIcon = display.newImageRect(iconsGroup, "assets/7icon/icon_friend_point.png", 48 / 1.1, 48 / 1.1)
    expIcon.x, expIcon.y = 50, 50
    local silverText = textile.new({
        group = group,
        texto = "0 ",
        x = expIcon.x + 15,
        y = expIcon.y + 52,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local lvlIcon = display.newImageRect(iconsGroup, "assets/7icon/icon_exp.png", 48 / 1.1, 48 / 1.1)
    lvlIcon.x, lvlIcon.y = 50, 100
    local silverText = textile.new({
        group = group,
        texto = tostring(exp) .. " ",
        x = lvlIcon.x + 15,
        y = lvlIcon.y + 52,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local friendPointIcon = display.newImageRect(iconsGroup, "assets/7icon/icon_level.png", 48 / 1.1, 48 / 1.1)
    friendPointIcon.x, friendPointIcon.y = 50, 150

    local component = userLevelBar.new({
        x = 170,
        y = 75,
        userId = userId,
        xpBar = true
    })
    group:insert(component)

    local title = display.newText({
        text = "Prêmio de Jornada ",
        x = 30,
        y = display.contentCenterY - 155,
        font = "assets/7fonts/Textile.ttf",
        fontSize = 30
    })
    group:insert(title)
    title.anchorX = 0
    title:setFillColor(0.95, 0.86, 0.31)

    local divider2 = display.newImageRect(group, "assets/7bg/bg_bottom_frame_2.png", 610, 3)
    divider2.x, divider2.y = display.contentCenterX, display.contentCenterY - 139
    divider2.alpha = 0.8

    local sprite = display.newImageRect(group, "assets/7items/sushi.png", 104, 104)
    sprite.x, sprite.y = 80, display.contentCenterY - 75
    local sprite = display.newImageRect(group, "assets/7items/sushi.png", 104, 104)
    sprite.x, sprite.y = 192, display.contentCenterY - 75
    local sprite = display.newImageRect(group, "assets/7items/sushi.png", 104, 104)
    sprite.x, sprite.y = 304, display.contentCenterY - 75
    local sprite = display.newImageRect(group, "assets/7items/sushi.png", 104, 104)
    sprite.x, sprite.y = 416, display.contentCenterY - 75
    local sprite = display.newImageRect(group, "assets/7items/sushi.png", 104, 104)
    sprite.x, sprite.y = 528, display.contentCenterY - 75

    local clickToBack = display.newText({
        text = " Clique em qualquer lugar para continuar ",
        x = display.contentCenterX,
        y = display.contentHeight,
        font = "assets/7fonts/Textile.ttf",
        fontSize = 22
    })
    group:insert(clickToBack)
    clickToBack:setFillColor(0.95, 0.86, 0.31)

    local function pulse(obj)
        -- primeiro faz fade out
        transition.to(obj, {
            time = 800,
            alpha = 0.3,
            onComplete = function()
                -- depois faz fade in e reinicia
                transition.to(obj, {
                    time = 800,
                    alpha = 1,
                    onComplete = function()
                        pulse(obj)
                    end
                })
            end
        })
    end

    -- inicia o “pulsar”
    pulse(clickToBack)

    return group
end
return component
