-- interfaces/growing/improve.lua
local composer = require("composer")
local Card = require("components.card")
local supa = require("config.supabase")
local json = require("json")
local network = require("network")
local userDataLib = require("lib.userData")
local textile = require("utils.textile")

local scene = composer.newScene()

local MAX_LEVEL = 130
local starLevelCap = {
    [2] = 20,
    [3] = 30,
    [4] = 40,
    [5] = 60,
    [6] = 70,
    [7] = 80,
    [8] = 100,
    [9] = 110,
    [10] = 120,
    [11] = 130
}

-- XP cumulativo por nível
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
-- UUID do sushi
local SUSHI_UUID = "cd0d2985-9685-46d8-b873-5fa73bfaa5e8"

function scene:create(event)
    local sceneGroup = self.view
    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 0
    self.userId = userId

    local background = display.newImageRect(sceneGroup, "assets/7bg/bg_tab_default.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    background.x, background.y = display.contentCenterX, display.contentCenterY

    local riseGroup = display.newGroup()
    sceneGroup:insert(riseGroup)

    local characterModalL = display.newImageRect(riseGroup, "assets/7bg/improve.png", 400 * 1.5, 595 * 1.5)
    characterModalL.x, characterModalL.y = display.contentCenterX, display.contentCenterY

    local bgSilver = display.newImageRect(riseGroup, "assets/7textbg/tbg_blue_s9_11_l.png", 450 * 1.28, 150 * 1.28)
    bgSilver.x, bgSilver.y = display.contentCenterX, display.contentCenterY + 260

    local advanceButton = display.newImageRect(riseGroup, "assets/7button/btn_common_yellow_s9.png", 244, 76)
    advanceButton.x, advanceButton.y = display.contentCenterX + 150, display.contentCenterY + 400
    local text = textile.new({
        texto = " Elevar ",
        x = advanceButton.x,
        y = advanceButton.y,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })
    riseGroup:insert(text)

    self.btnUpgrade = advanceButton

    local autoSelect = display.newImageRect(riseGroup, "assets/7button/btn_common_blue_s9.png", 244, 76)
    autoSelect.x, autoSelect.y = display.contentCenterX - 150, advanceButton.y
    local text = textile.new({
        texto = " Auto Adicionar ",
        x = autoSelect.x,
        y = autoSelect.y,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })
    riseGroup:insert(text)

    local topBack = require("components.backTop")
    local topBack = topBack.new({
        title = ""
    })
    riseGroup:insert(topBack)
    local navbar = require("components.navBar")
    local navbar = navbar.new()
    riseGroup:insert(navbar)

    local tabEquipmentBg = display.newImageRect(sceneGroup, "assets/7button/btn_tab_s9.png", 236, 82)
    tabEquipmentBg.x, tabEquipmentBg.y = 330, -128
    local changeMemberText = textile.new({
        group = sceneGroup,
        texto = " Elevar Ordem ",
        x = tabEquipmentBg.x,
        y = tabEquipmentBg.y + 5,
        tamanho = 22,
        corTexto = {0.66, 0.66, 0.66}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local tabFormationBg = display.newImageRect(sceneGroup, "assets/7button/btn_tab_light_s9.png", 236, 82)
    tabFormationBg.x, tabFormationBg.y = 110, -128
    local changeMemberText = textile.new({
        group = sceneGroup,
        texto = " Elevar ",
        x = tabFormationBg.x,
        y = tabFormationBg.y + 5,
        tamanho = 22,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local xpBarBg = display.newImageRect(sceneGroup, "assets/7misc/pb_hp_gray.png", 224 * 1.1, 16 * 1.1)
    xpBarBg.x, xpBarBg.y = display.contentCenterX, display.contentCenterY - 58

    local addButton = display.newGroup()
    sceneGroup:insert(addButton)

    local btnAdd1 = display.newImageRect(addButton, "assets/7button/btn_add.png", 104 * 1.1, 104 * 1.1)
    btnAdd1.x, btnAdd1.y = 100, 135
    btnAdd1:addEventListener("tap", function()

        composer.gotoScene("interfaces.growing.improveEvolveSelect", {
            effect = "slideRight",
            time = 300,
            params = {
                recordId = _G.chaId
            }
        })
    end)
    local btnAdd2 = display.newImageRect(addButton, "assets/7button/btn_add.png", 104 * 1.1, 104 * 1.1)
    btnAdd2.x, btnAdd2.y = btnAdd1.x, 135 + 158
    btnAdd2:addEventListener("tap", function()
        composer.gotoScene("interfaces.growing.improveEvolveSelect", {
            effect = "slideRight",
            time = 300,
            params = {
                recordId = _G.chaId
            }
        })
    end)
    local btnAdd3 = display.newImageRect(addButton, "assets/7button/btn_add.png", 104 * 1.1, 104 * 1.1)
    btnAdd3.x, btnAdd3.y = btnAdd1.x, 135 + (158 * 2)
    btnAdd3:addEventListener("tap", function()
        composer.gotoScene("interfaces.growing.improveEvolveSelect", {
            effect = "slideRight",
            time = 300,
            params = {
                recordId = _G.chaId
            }
        })
    end)
    local btnAdd4 = display.newImageRect(addButton, "assets/7button/btn_add.png", 104 * 1.1, 104 * 1.1)
    btnAdd4.x, btnAdd4.y = display.contentCenterX + 220, 135
    btnAdd4:addEventListener("tap", function()
        composer.gotoScene("interfaces.growing.improveEvolveSelect", {
            effect = "slideRight",
            time = 300,
            params = {
                recordId = _G.chaId
            }
        })
    end)
    local btnAdd5 = display.newImageRect(addButton, "assets/7button/btn_add.png", 104 * 1.1, 104 * 1.1)
    btnAdd5.x, btnAdd5.y = btnAdd4.x, 135 + 158
    btnAdd5:addEventListener("tap", function()
        composer.gotoScene("interfaces.growing.improveEvolveSelect", {
            effect = "slideRight",
            time = 300,
            params = {
                recordId = _G.chaId
            }
        })
    end)
    local btnAdd6 = display.newImageRect(addButton, "assets/7button/btn_add.png", 104 * 1.1, 104 * 1.1)
    btnAdd6.x, btnAdd6.y = btnAdd4.x, 135 + (158 * 2)
    btnAdd6:addEventListener("tap", function()
        composer.gotoScene("interfaces.growing.improveEvolveSelect", {
            effect = "slideRight",
            time = 300,
            params = {
                recordId = _G.chaId
            }
        })
    end)

    local function pulse(obj)
        transition.to(obj, {
            time = 1200,
            alpha = 0,
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

    pulse(addButton)

    local card_back_m = display.newImageRect(sceneGroup, "assets/7card/card_back_m.png", 328 / 1.25, 380 / 1.25)
    card_back_m.x, card_back_m.y = display.contentCenterX, display.contentCenterY - 260
    card_back_m.alpha = 0.01
    card_back_m:addEventListener("tap", function()
        composer.gotoScene("interfaces.growing.improveSelect", {
            effect = "slideLeft",
            time = 300,
            params = {
                userId = self.userId
            }
        })
    end)

    local selectText = textile.new({
        texto = "Selec.\numa\ncarta.",
        x = card_back_m.x,
        y = card_back_m.y,
        tamanho = 32,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0, 0.2},
        espessuraContorno = 2
    })
    riseGroup:insert(selectText)
    pulse(selectText)

    -- -- botão escolher sushis
    -- local btnSushi = display.newText({
    --     parent = sceneGroup,
    --     text = "Escolher Sushis",
    --     x = display.contentCenterX,
    --     y = display.contentHeight - 100,
    --     font = native.systemFont,
    --     fontSize = 18
    -- })
    -- btnSushi:setFillColor(1, 0.5, 0)
    -- btnSushi:addEventListener("tap", function()
    --     if not _G.chaId then

    --         return
    --     end
    --     composer.gotoScene("interfaces.growing.improveEvolveSelect", {
    --         effect = "slideRight",
    --         time = 300,
    --         params = {
    --             recordId = _G.chaId
    --         }
    --     })
    -- end)

    -- Dentro de scene:create (immediately after btnSushi), adicione:

    -- Dentro de scene:create (logo após btnUpgrade), adicione:

    local btnAuto = display.newText({
        parent = sceneGroup,
        text = "Auto Selecionar Sushis",
        x = display.contentCenterX,
        y = display.contentHeight - 180, -- ajuste conforme layout
        font = native.systemFontBold,
        fontSize = 16
    })
    btnAuto:setFillColor(0, 0.8, 0)
    btnAuto:addEventListener("tap", function()
        if not _G.chaId then
            native.showAlert("Aviso", "Selecione um personagem primeiro", {"OK"})
            return
        end

        -- busca quantidade de sushi no banco
        local data = userDataLib.load() or {}
        local userId = tonumber(data.id) or 0
        local headers = {
            ["Content-Type"] = "application/json",
            ["apikey"] = supa.SUPABASE_ANON_KEY,
            ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
        }
        local url = string.format("%s/rest/v1/user_items?userId=eq.%s&itemId=eq.%s&select=quantity", supa.SUPABASE_URL,
            userId, "cd0d2985-9685-46d8-b873-5fa73bfaa5e8")
        network.request(url, "GET", function(evt)
            if evt.isError then
                return
            end
            local rec = json.decode(evt.response)[1]
            local qty = (rec and rec.quantity) or 0
            local selectCount = math.min(qty, 6)
            self.selectedSushiCount = selectCount
            -- if self.sushiCountText then
            --     self.sushiCountText.text = "Sushis selecionados: " .. selectCount
            -- end
            -- Remove grid anterior (se existir)
            if self.sushiIconGroup then
                self.sushiIconGroup:removeSelf()
            end
            -- Cria novo grupo de ícones
            self.sushiIconGroup = display.newGroup()
            self.cardGroup:insert(self.sushiIconGroup)

            local centerX = display.contentCenterX
            local startY = 150 -- ajuste a posição vertical inicial
            local offsetX = 100 -- distância horizontal entre colunas
            local offsetY = 120 -- distância vertical entre linhas
            local count = math.min(self.selectedSushiCount, 6)

            for i = 1, count do
                local col = (i > 3) and 2 or 1
                local row = (i > 3) and (i - 3) or i

                local icon = display.newImageRect(self.sushiIconGroup, "assets/7items/sushi.png", 104, 104)
                icon.x = centerX + (col == 1 and -offsetX or offsetX)
                icon.y = startY + (row - 1) * offsetY
            end

        end, {
            headers = headers
        })
    end)

    -- grupo dinâmico
    self.cardGroup = display.newGroup()
    sceneGroup:insert(self.cardGroup)
    self.selectedSushiCount = 0
end

function scene:show(event)
    if event.phase ~= "did" then
        return
    end

    -- traz sushiCount da tela anterior
    if event.params and event.params.sushiCount then
        self.selectedSushiCount = event.params.sushiCount
    end

    -- limpa UI
    if self.cardGroup then
        self.cardGroup:removeSelf()
    end
    self.cardGroup = display.newGroup()
    self.view:insert(self.cardGroup)

    -- exibe contador de sushis
    -- self.sushiCountText = display.newText({
    --     parent = self.cardGroup,
    --     text = "Sushis selecionados: " .. self.selectedSushiCount,
    --     x = display.contentCenterX,
    --     y = 100,
    --     font = native.systemFont,
    --     fontSize = 18
    -- })
    -- self.sushiCountText:setFillColor(1)

    -- verifica personagem
    local recordId = _G.chaId
    if not recordId then
        return
    end

    -- headers para requisições
    local headers = {
        ["Content-Type"] = "application/json",
        ["apikey"] = supa.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
    }

    -- busca dados do personagem
    local url = string.format(
        "%s/rest/v1/user_characters?select=characterId,level,health,attack,stars,xp&limit=1&id=eq.%s",
        supa.SUPABASE_URL, recordId)
    network.request(url, "GET", function(evt)
        if evt.isError then
            return
        end
        local d = json.decode(evt.response)[1]
        self.levelVal, self.healthVal, self.attackVal, self.xpVal = d.level, d.health, d.attack, d.xp or 0

        -- cria campos de texto e guarda em self.*
        local y0 = 130

        local levelText = textile.new({
            parent = self.cardGroup,
            texto = "Nv" .. d.level .. " ",
            x = display.contentCenterX - 118,
            y = display.contentCenterY - 77,
            tamanho = 21,
            corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 0
        })
        self.cardGroup:insert(levelText)

        local iconHp = display.newImageRect(self.cardGroup, "assets/7icon/icon_hp.png", 48, 48)
        iconHp.x, iconHp.y = display.contentCenterX - 100, display.contentCenterY - 27
        local hpText = textile.new({
            parent = self.cardGroup,
            texto = d.health .. " ",
            x = iconHp.x + 221,
            y = iconHp.y + 2,
            tamanho = 24,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100
        })
        self.cardGroup:insert(hpText)

        local iconAtk = display.newImageRect(self.cardGroup, "assets/7icon/icon_atk.png", 48, 48)
        iconAtk.x, iconAtk.y = display.contentCenterX - 100, display.contentCenterY + 11
        local atkText = textile.new({
            parent = self.cardGroup,
            texto = d.attack .. " ",
            x = hpText.x,
            y = hpText.y + 42,
            tamanho = 24,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100
        })
        self.cardGroup:insert(atkText)

        local xpText = textile.new({
            parent = self.cardGroup,
            texto = 0 .. "/" .. "" .. "asdasd ",
            x = display.contentCenterX + 120,
            y = display.contentCenterY - 77,
            tamanho = 21,
            corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 100
        })
        self.cardGroup:insert(xpText)

        local c = Card.new({
            x = display.contentCenterX,
            y = display.contentCenterY - 250,
            characterId = d.characterId,
            scaleFactor = 1.17,
            stars = d.stars
        })
        self.cardGroup:insert(c)

        if d.level == 130 then
            local xpBarBg = display.newImageRect(self.cardGroup, "assets/7misc/pb_green.png", 224 * 1.1, 16 * 1.1)
            xpBarBg.x, xpBarBg.y = display.contentCenterX, display.contentCenterY - 60
        end

        local function onUpgradeTap()
            if not _G.chaId then
                return
            end
            local recordId = _G.chaId

            -- calcula teto de level pelo stars
            local stars = d.stars or 2
            local starLevelCap = {
                [2] = 20,
                [3] = 30,
                [4] = 40,
                [5] = 60,
                [6] = 70,
                [7] = 80,
                [8] = 100,
                [9] = 110,
                [10] = 120,
                [11] = 130
            }
            local levelCap = starLevelCap[stars] or MAX_LEVEL

            -- **VERIFICADOR DE NÍVEL MÁXIMO**
            if d.level >= levelCap then

                return -- sai antes de tentar atualizar textos ou stats
            end

            -- 1) Buscar e consumir sushis no banco
            local fetchItemsUrl = string.format("%s/rest/v1/user_items?userId=eq.%s&itemId=eq.%s&select=id,quantity",
                supa.SUPABASE_URL, tostring(self.userId), "cd0d2985-9685-46d8-b873-5fa73bfaa5e8")
            network.request(fetchItemsUrl, "GET", function(fe)
                if fe.isError then
                    print("Erro ao buscar user_items:", fe.response)
                    return
                end
                local itemRec = json.decode(fe.response)[1]
                if not itemRec then
                    print("Nenhum sushi encontrado para consumir")
                    return
                end

                local newQty = itemRec.quantity - scene.selectedSushiCount
                if newQty < 0 then
                    newQty = 0
                end

                local patchItemUrl = string.format("%s/rest/v1/user_items?id=eq.%s", supa.SUPABASE_URL,
                    tostring(itemRec.id))
                network.request(patchItemUrl, "PATCH", function(pi)
                    if pi.isError then
                        print("Erro ao atualizar user_items:", pi.response)
                    end
                end, {
                    headers = {
                        ["Content-Type"] = "application/json",
                        ["apikey"] = supa.SUPABASE_ANON_KEY,
                        ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
                    },
                    body = json.encode({
                        quantity = newQty
                    })
                })

                -- 2) Buscar dados atuais do personagem
                local fetchCharUrl = string.format(
                    "%s/rest/v1/user_characters?select=level,health,attack,stars,xp&limit=1&id=eq.%s",
                    supa.SUPABASE_URL, tostring(recordId))
                network.request(fetchCharUrl, "GET", function(cf)
                    if cf.isError then
                        print("Erro ao buscar char:", cf.response)
                        return
                    end
                    local charRec = json.decode(cf.response)[1]
                    if not charRec then
                        return
                    end

                    -- 3) Calcular novos valores
                    local baseXP = charRec.xp or 0
                    local baseLevel = charRec.level or 0
                    local baseHP = charRec.health or 0
                    local baseATK = charRec.attack or 0
                    local stars = d.stars or 2
                    local levelCap = starLevelCap[stars] or MAX_LEVEL

                    if self.levelVal >= levelCap then
                        self.btnUpgrade:setFillColor(0.5) -- muda cor para visual “desligado”
                        self.btnUpgrade.alpha = 0.5 -- torna semitransparente
                        self.btnUpgrade:removeEventListener("tap", onUpgradeTap)
                    end

                    -- XP ganho
                    local xpGain = 2500 * scene.selectedSushiCount
                    local newXP = baseXP + xpGain

                    -- Novo level
                    local newLevel = baseLevel
                    for lvl = baseLevel + 1, levelCap do
                        if xpThresholds[lvl] and newXP >= xpThresholds[lvl] then
                            newLevel = lvl
                        else
                            break
                        end
                    end

                    -- calcula newLevel normalmente...
                    local newLevel = baseLevel
                    for lvl = baseLevel + 1, levelCap do
                        if xpThresholds[lvl] and newXP >= xpThresholds[lvl] then
                            newLevel = lvl
                        else
                            break
                        end
                    end

                    local newHP, newATK = baseHP, baseATK
                    for lvlStep = baseLevel, newLevel - 1 do
                        local mult = (lvlStep <= 40 and 1.05) or (lvlStep <= 80 and 1.03) or 1.02
                        newHP = math.floor(newHP * mult)
                        newATK = math.floor(newATK * mult)
                    end

                    -- 4) Persistir no banco user_characters
                    local patchCharUrl2 = string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL,
                        tostring(recordId))
                    local bodyChar = json.encode({
                        xp = newXP,
                        level = newLevel,
                        health = newHP,
                        attack = newATK
                    })
                    network.request(patchCharUrl2, "PATCH", function(pc)
                        if pc.isError then
                            print("Erro ao atualizar char:", pc.response)
                            return
                        end
                        -- 5) Atualizar UI somente aqui
                        scene.xpText.text = "XP: " .. newXP
                        scene.levelText.text = "Level: " .. newLevel
                        scene.healthText.text = "Health: " .. newHP
                        scene.attackText.text = "Attack: " .. newATK
                        -- 5) Após atualizar UI dos stats, limpe os sushis exibidos:
                        if self.sushiIconGroup then
                            self.sushiIconGroup:removeSelf()
                            self.sushiIconGroup = nil
                        end

                        -- 6) Zere o contador e o texto:
                        self.selectedSushiCount = 0
                        -- if self.sushiCountText then
                        --     self.sushiCountText.text = "Sushis selecionados: 0"
                        -- end
                    end, {
                        headers = {
                            ["Content-Type"] = "application/json",
                            ["apikey"] = supa.SUPABASE_ANON_KEY,
                            ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
                        },
                        body = bodyChar
                    })
                end, {
                    headers = {
                        ["Content-Type"] = "application/json",
                        ["apikey"] = supa.SUPABASE_ANON_KEY,
                        ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
                    }
                })
            end, {
                headers = {
                    ["Content-Type"] = "application/json",
                    ["apikey"] = supa.SUPABASE_ANON_KEY,
                    ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
                }
            })

        end

        -- associe o listener ao botão:
        self.btnUpgrade:addEventListener("tap", onUpgradeTap)

    end, {
        headers = headers
    })

    if self.sushiIconGroup then
        self.sushiIconGroup:removeSelf()
    end
    -- cria novo grupo
    self.sushiIconGroup = display.newGroup()
    self.cardGroup:insert(self.sushiIconGroup)

    local centerX = display.contentCenterX
    local startY = 135 -- ajuste a altura inicial
    local offsetX = 220 -- distância horizontal da coluna
    local offsetY = 160 -- distância vertical entre linhas
    local count = math.min(self.selectedSushiCount, 6)

    for i = 1, count do
        local col = (i > 3) and 2 or 1
        local row = (i > 3) and (i - 3) or i

        local icon = display.newImageRect(self.sushiIconGroup, "assets/7items/sushi.png", 104 * 1.15, 104 * 1.15)
        icon.x = centerX + (col == 1 and -offsetX or offsetX)
        icon.y = startY + (row - 1) * offsetY
    end

end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
