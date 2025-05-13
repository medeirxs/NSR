-- interfaces/growing/improve.lua
local composer = require("composer")
local Card = require("components.card")
local supa = require("config.supabase")
local json = require("json")
local network = require("network")

local scene = composer.newScene()

-- Níveis que recebem bônus adicional de 10% ao evoluir
local bumpLevels = {
    [20] = true,
    [30] = true,
    [40] = true,
    [60] = true,
    [70] = true,
    [80] = true,
    [100] = true,
    [110] = true,
    [120] = true
}
local MAX_LEVEL = 130

-- Tabela de XP cumulativa necessária para alcançar cada level
local xpThresholds = {
    [1] = 250,
    [2] = 500,
    [3] = 750,
    [4] = 1000,
    [5] = 1250,
    [6] = 1500,
    [7] = 1750,
    [8] = 2000,
    [9] = 2250,
    [10] = 2500,
    [11] = 2750,
    [12] = 3000,
    [13] = 3250,
    [14] = 3500,
    [15] = 3750,
    [16] = 4000,
    [17] = 4250,
    [18] = 4500,
    [19] = 4750,
    [20] = 5000,
    [21] = 5500,
    [22] = 6000,
    [23] = 6500,
    [24] = 7000,
    [25] = 7500,
    [26] = 8000,
    [27] = 8500,
    [28] = 9000,
    [29] = 9500,
    [30] = 10000,
    [31] = 10500,
    [32] = 11000,
    [33] = 11500,
    [34] = 12000,
    [35] = 12500,
    [36] = 13000,
    [37] = 13500,
    [38] = 14000,
    [39] = 14500,
    [40] = 15000,
    [41] = 16250,
    [42] = 17500,
    [43] = 18750,
    [44] = 20000,
    [45] = 21250,
    [46] = 22500,
    [47] = 23750,
    [48] = 25000,
    [49] = 26250,
    [50] = 27500,
    [51] = 28750,
    [52] = 30000,
    [53] = 31250,
    [54] = 32500,
    [55] = 33750,
    [56] = 35000,
    [57] = 36250,
    [58] = 37500,
    [59] = 38750,
    [60] = 40000,
    [61] = 41250,
    [62] = 42500,
    [63] = 43750,
    [64] = 45000,
    [65] = 46250,
    [66] = 47500,
    [67] = 48750,
    [68] = 50000,
    [69] = 51250,
    [70] = 52500,
    [71] = 53750,
    [72] = 55000,
    [73] = 56250,
    [74] = 57500,
    [75] = 58750,
    [76] = 60000,
    [77] = 61250,
    [78] = 62500,
    [79] = 63750,
    [80] = 65000,
    [81] = 67500,
    [82] = 70000,
    [83] = 72500,
    [84] = 75000,
    [85] = 77500,
    [86] = 80000,
    [87] = 82500,
    [88] = 85000,
    [89] = 87500,
    [90] = 90000,
    [91] = 92500,
    [92] = 95000,
    [93] = 97500,
    [94] = 100000,
    [95] = 102500,
    [96] = 105000,
    [97] = 107500,
    [98] = 110000,
    [99] = 112500,
    [100] = 115000,
    [101] = 117500,
    [102] = 120000,
    [103] = 122500,
    [104] = 125000,
    [105] = 127500,
    [106] = 130000,
    [107] = 132500,
    [108] = 135000,
    [109] = 137500,
    [110] = 140000,
    [111] = 142500,
    [112] = 145000,
    [113] = 147500,
    [114] = 150000,
    [115] = 152500,
    [116] = 155000,
    [117] = 157500,
    [118] = 160000,
    [119] = 162500,
    [120] = 165000,
    [121] = 167500,
    [122] = 170000,
    [123] = 172500,
    [124] = 175000,
    [125] = 177500,
    [126] = 180000,
    [127] = 182500,
    [128] = 185000,
    [129] = 187500,
    [130] = 190000
}

--------------------------------------------------------------------------------
function scene:create(event)
    local sceneGroup = self.view
    -- Fundo
    local bg = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth,
        display.contentHeight)
    bg:setFillColor(0.1)
    -- Título
    local title = display.newText({
        parent = sceneGroup,
        text = "Tela de Melhoria",
        x = display.contentCenterX,
        y = 60,
        font = native.systemFontBold,
        fontSize = 24
    })
    title:setFillColor(1)
    -- Botão Selecionar Personagem
    local userDataLib = require("lib.userData")
    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 461752844
    local btnSelect = display.newText({
        parent = sceneGroup,
        text = "Escolher Personagem",
        x = display.contentCenterX,
        y = display.contentHeight - 50,
        font = native.systemFont,
        fontSize = 20
    })
    btnSelect:setFillColor(0.2, 0.6, 1)
    btnSelect:addEventListener("tap", function()
        composer.gotoScene("interfaces.growing.improveSelect", {
            effect = "slideLeft",
            time = 300,
            params = {
                userId = userId
            }
        })
    end)
    -- Grupo dinâmico
    self.cardGroup = display.newGroup()
    sceneGroup:insert(self.cardGroup)
end

--------------------------------------------------------------------------------
function scene:show(event)
    if event.phase ~= "did" then
        return
    end
    -- Limpa UI
    if self.cardGroup and self.cardGroup.removeSelf then
        self.cardGroup:removeSelf()
    end
    self.cardGroup = display.newGroup();
    self.view:insert(self.cardGroup)
    local recordId = _G.chaId;
    if not recordId then
        return
    end

    -- Exibe Registro ID
    local idText = display.newText({
        text = "Registro ID:" .. recordId,
        x = display.contentCenterX,
        y = 40,
        font = native.systemFontBold,
        fontSize = 22
    })
    idText:setFillColor(1);
    self.cardGroup:insert(idText)

    -- Fetch dados iniciais
    local headers = {
        ["Content-Type"] = "application/json",
        ["apikey"] = supa.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
    }
    local url = string.format("%s/rest/v1/user_characters?select=characterId,level,health,attack,xp&limit=1&id=eq.%s",
        supa.SUPABASE_URL, recordId)

    network.request(url, "GET", function(evt)
        if evt.isError then
            return
        end
        local d = json.decode(evt.response)[1]
        local charId, lvl, hp, atk, xp = d.characterId, d.level, d.health, d.attack, d.xp or 0
        self.levelVal, self.healthVal, self.attackVal, self.xpVal = lvl, hp, atk, xp

        -- Exibe textos
        local lvlTxt = display.newText({
            text = "Level:" .. lvl,
            x = display.contentCenterX,
            y = 70,
            font = native.systemFont,
            fontSize = 20
        })
        lvlTxt:setFillColor(1, 1, 0);
        self.cardGroup:insert(lvlTxt);
        self.levelText = lvlTxt

        local y0 = 100
        local hpTxt = display.newText({
            text = "Health:" .. hp,
            x = display.contentCenterX,
            y = y0,
            font = native.systemFont,
            fontSize = 18
        })
        hpTxt:setFillColor(0, 1, 0);
        self.cardGroup:insert(hpTxt);
        self.healthText = hpTxt

        local atkTxt = display.newText({
            text = "Attack:" .. atk,
            x = display.contentCenterX,
            y = y0 + 30,
            font = native.systemFont,
            fontSize = 18
        })
        atkTxt:setFillColor(1, 0, 0);
        self.cardGroup:insert(atkTxt);
        self.attackText = atkTxt

        local xpTxt = display.newText({
            text = "XP:" .. xp,
            x = display.contentCenterX,
            y = y0 + 60,
            font = native.systemFont,
            fontSize = 18
        })
        xpTxt:setFillColor(0.5, 0.5, 1);
        self.cardGroup:insert(xpTxt);
        self.xpText = xpTxt

        -- Exibe card
        local c = Card.new({
            x = display.contentCenterX,
            y = display.contentCenterY + 40,
            characterId = charId,
            scaleFactor = 1
        })
        self.cardGroup:insert(c);
        self.card = c

        -- Botão adicionar XP
        local btn = display.newText({
            text = "+2500 XP",
            x = display.contentCenterX,
            y = display.contentHeight - 80,
            font = native.systemFontBold,
            fontSize = 18
        })
        btn:setFillColor(0.2, 0.8, 1);
        self.cardGroup:insert(btn)

        btn:addEventListener("tap", function()
            -- Se já no nível máximo
            if self.levelVal >= MAX_LEVEL then
                native.showAlert("Aviso", "Nível máximo: " .. MAX_LEVEL, {"OK"})
                return
            end
            -- Adiciona XP
            self.xpVal = self.xpVal + 2500
            -- Calcula novo level (sem consumir XP)
            local newLevel = self.levelVal
            for lvlStep = self.levelVal + 1, MAX_LEVEL do
                if xpThresholds[lvlStep] and self.xpVal >= xpThresholds[lvlStep] then
                    newLevel = lvlStep
                else
                    break
                end
            end
            -- Calcula ganhos de health e attack baseado em níveis ganhos
            local hpVal, atkVal = self.healthVal, self.attackVal
            for lvlStep = self.levelVal, newLevel - 1 do
                local mult = (lvlStep <= 40 and 1.05) or (lvlStep <= 80 and 1.03) or 1.02
                if bumpLevels[lvlStep] then
                    mult = mult * 1.10
                end
                hpVal = math.floor(hpVal * mult)
                atkVal = math.floor(atkVal * mult)
            end
            -- Atualiza valores locais
            self.levelVal, self.healthVal, self.attackVal = newLevel, hpVal, atkVal
            -- PATCH atualiza xp e level, health e attack
            local body = json.encode({
                xp = self.xpVal,
                level = newLevel,
                health = hpVal,
                attack = atkVal
            })
            local pUrl = string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL, recordId)
            network.request(pUrl, "PATCH", function(pe)
                if pe.isError then
                    return
                end
                -- Atualiza UI
                self.xpText.text = "XP:" .. self.xpVal
                self.levelText.text = "Level:" .. self.levelVal
                self.healthText.text = "Health:" .. self.healthVal
                self.attackText.text = "Attack:" .. self.attackVal
            end, {
                headers = headers,
                body = body
            })
        end)
    end, {
        headers = headers
    })
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
