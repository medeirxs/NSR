local composer = require("composer")
local userDataLib = require("lib.userData")
local apiUsers = require("api.getUsers")
local supabase = require("config.supabase")
local json = require("json")
local network = require("network")
local cardN = require("components.card")
local topBack = require("components.backTop")
local navBar = require("components.navBar")
local textile = require("utils.textile")

local cloudOn = require("utils.cloudOn")
local cloudOff = require("utils.cloudOff")

local scene = composer.newScene()

-- Guarda o userId atual
debugger = false
local currentUserId, serverId

-- Armazena os IDs originais e os objetos de card/placeholder
local formation = {}
local cardImages = {}
local totalSlots = 6 -- Grid 3x2

-------------------------------------------------
-- Funções de posicionamento (grid 3x2)
-------------------------------------------------
local function getGridStart()
    local cols = 3
    local slotW, slotH = 159, 520
    local gridW = cols * slotW
    local gridH = 2 * slotH
    local startX = display.contentCenterX - gridW * 0.5 + slotW * 0.5
    local startY = display.contentCenterY - gridH * 0.5 + slotH * 0.5
    return startX, startY
end

local function getSlotPosition(i)
    local cols = 3
    local slotW, slotH = 185, 225
    local startX, startY = getGridStart()
    local row = math.floor((i - 1) / cols) -- 0 para linha 1, 1 para linha 2
    local col = ((i - 1) % cols) + 1 -- 1, 2 ou 3

    -- Espaços extras entre colunas:
    local gap12 = 4 -- espaço extra entre colunas 1 e 2 (slots 1↔2 e 4↔5)
    local gap23 = 4 -- espaço extra entre colunas 2 e 3 (slots 2↔3 e 5↔6)

    -- Deslocamento X adicional conforme a coluna
    local extraX = 0
    if col == 2 then
        extraX = gap12
    elseif col == 3 then
        extraX = gap12 + gap23
    end

    -- Calcula X e Y finais
    local x = startX + (col - 1) * slotW + extraX
    local y = startY + row * slotH

    return x, y
end

-------------------------------------------------
-- Placeholder vazio: quadrado verde com 30% de opacidade.
-------------------------------------------------
local function createEmptySlot(x, y)
    local grp = display.newGroup()

    return grp
end

-------------------------------------------------
-- Reposiciona todos os elementos de acordo com slotIndex
-------------------------------------------------
local function repositionCards()
    for i = 1, totalSlots do
        local px, py = getSlotPosition(i)
        if cardImages[i] then
            cardImages[i].x = px - 30
            cardImages[i].y = py - 27
            cardImages[i].slotIndex = i
        end
    end
end

-------------------------------------------------
-- Atualiza a formação no banco via Supabase REST
-------------------------------------------------
local function updateFormationInDB()
    local url = supabase.SUPABASE_URL .. "/rest/v1/user_formation?userId=eq." .. tostring(currentUserId)
    local body = json.encode({
        formation = formation
    })
    local headers = {
        ["apikey"] = supabase.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
        ["Content-Type"] = "application/json"
    }
    network.request(url, "PATCH", function(ev)
        if ev.isError then
            print("Erro ao atualizar formação:", ev.response)
        else
            print("Formação atualizada:", ev.response)
        end
    end, {
        headers = headers,
        body = body
    })
end

-------------------------------------------------
-- Listener para drag & drop
-------------------------------------------------
local function cardTouch(event)
    local t = event.target
    local ph = event.phase

    if ph == "began" then
        display.getCurrentStage():setFocus(t)
        t.isFocus = true
        t.startX, t.startY = t.x, t.y
        t.offsetX = event.x - t.x
        t.offsetY = event.y - t.y
        return true
    elseif ph == "moved" and t.isFocus then
        t.x = event.x - t.offsetX
        t.y = event.y - t.offsetY
        return true
    elseif (ph == "ended" or ph == "cancelled") and t.isFocus then
        display.getCurrentStage():setFocus(nil)
        t.isFocus = false
        local minD, near = math.huge, nil
        for i = 1, totalSlots do
            local sx, sy = getSlotPosition(i)
            local d = ((t.x - sx) ^ 2 + (t.y - sy) ^ 2) ^ 0.5
            if d < minD then
                minD, near = d, i
            end
        end
        if near and t.slotIndex and near ~= t.slotIndex then
            cardImages[t.slotIndex], cardImages[near] = cardImages[near], cardImages[t.slotIndex]
            formation[t.slotIndex], formation[near] = formation[near], formation[t.slotIndex]
        end
        repositionCards()
        updateFormationInDB()
        return true
    end
    return false
end

local cloudOff = require("utils.cloudOff") -- saida
-------------------------------------------------
-- Monta a cena
-------------------------------------------------
function scene:create(e)
    cloudOff.show({
        time = 600
    })
    local grp = self.view
    local data = userDataLib.load() or {}
    currentUserId = data.id or 461752844
    serverId = data.server or 1

    local bg = display.newImageRect(grp, "assets/7bg/bg_tab_default.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    bg.x, bg.y = display.contentCenterX, display.contentCenterY

    local modal = display.newImageRect(grp, "assets/7bg/formation_modal.png", 400 * 1.55, 530 * 1.55)
    modal.x, modal.y = display.contentCenterX, display.contentCenterY

    local cardPlaceholder = display.newImageRect(grp, "assets/7card/card_holder_m.png", 400 / 2.05, 460 / 2.05)
    cardPlaceholder.x, cardPlaceholder.y = 130, display.contentCenterY - 280

    local cardPlaceholder1 = display.newImageRect(grp, "assets/7card/card_holder_m.png", 400 / 2.05, 460 / 2.05)
    cardPlaceholder1.x, cardPlaceholder1.y = cardPlaceholder.x + 190, cardPlaceholder.y
    local cardPlaceholder2 = display.newImageRect(grp, "assets/7card/card_holder_m.png", 400 / 2.05, 460 / 2.05)
    cardPlaceholder2.x, cardPlaceholder2.y = cardPlaceholder1.x + 190, cardPlaceholder1.y

    local cardPlaceholder3 = display.newImageRect(grp, "assets/7card/card_holder_m.png", 400 / 2.05, 460 / 2.05)
    cardPlaceholder3.x, cardPlaceholder3.y = 130, display.contentCenterY - 55
    local cardPlaceholder4 = display.newImageRect(grp, "assets/7card/card_holder_m.png", 400 / 2.05, 460 / 2.05)
    cardPlaceholder4.x, cardPlaceholder4.y = cardPlaceholder3.x + 190, cardPlaceholder3.y
    local cardPlaceholder5 = display.newImageRect(grp, "assets/7card/card_holder_m.png", 400 / 2.05, 460 / 2.05)
    cardPlaceholder5.x, cardPlaceholder5.y = cardPlaceholder4.x + 190, cardPlaceholder4.y

    apiUsers.fetchFormation(currentUserId, function(f, err)
        if err then
            native.showAlert("Erro", err, {"OK"})
            return
        end
        formation = (type(f) == "string") and json.decode(f) or f
        totalSlots = math.max(#formation, totalSlots)

        for i = 1, totalSlots do
            local x, y = getSlotPosition(i)
            if formation[i] then
                local url = string.format("%s/rest/v1/user_characters?select=characterId,stars,level&id=eq.%s",
                    supabase.SUPABASE_URL, tostring(formation[i]))
                local h = {
                    ["apikey"] = supabase.SUPABASE_ANON_KEY,
                    ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
                }
                network.request(url, "GET", function(ev2)
                    if ev2.isError then
                        return
                    end
                    local rec = json.decode(ev2.response)
                    if #rec > 0 then
                        local cu, st = rec[1].characterId, rec[1].stars or 2
                        local lvl = rec[1].level or 1
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

                        local card = cardN.new({
                            x = x - 30,
                            y = y,
                            characterId = cu,
                            stars = st,
                            scaleFactor = 0.8
                        })
                        card.slotIndex = i;
                        card:addEventListener("touch", cardTouch)
                        grp:insert(card);
                        cardImages[i] = card
                        card:addEventListener("tap", function()
                            cloudOn.show({
                                time = 300
                            })
                            timer.performWithDelay(300, function()
                                composer.removeScene("interfaces.formation.formationSelect")
                                composer.gotoScene("interfaces.formation.formationSelect")
                            end)
                        end)

                        local rect = display.newRoundedRect(card, 0, -- centro X do card
                        110, -- Y relativo ao card
                        150, 24, 4)
                        rect:setFillColor(unpack(bgColor))

                        -- texto de nível também dentro do group do card
                        local levelText = textile.new({
                            group = card,
                            texto = "Nv" .. lvl,
                            x = 0,
                            y = 110,
                            tamanho = 20,
                            corTexto = {1, 1, 1},
                            corContorno = {0, 0, 0},
                            espessuraContorno = 2,
                            anchorX = 0.5
                        })

                    else
                        local ph = createEmptySlot(x, y, 185, 225)
                        ph.slotIndex = i;
                        ph:addEventListener("touch", cardTouch)
                        grp:insert(ph);
                        cardImages[i] = ph
                    end
                end, {
                    headers = h
                })
            else
                local ph = createEmptySlot(x, y, 185, 225)
                ph.slotIndex = i;
                ph:addEventListener("touch", cardTouch)
                grp:insert(ph);
                cardImages[i] = ph
            end
        end

    end)

    local costBg = display.newImageRect(grp, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
    costBg.x, costBg.y = display.contentCenterX - 150, display.contentCenterY + 130
    local costIcon = display.newImageRect(grp, "assets/7icon/icon_cost.png", 48, 48)
    costIcon.x, costIcon.y = costBg.x - 90, costBg.y - 10
    local costText = textile.new({
        group = grp,
        texto = "0/210 ",
        x = costBg.x,
        y = costBg.y - 4,
        tamanho = 24,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local powerBg = display.newImageRect(grp, "assets/7textbg/tbg_blue_s9_4.png", 239, 15)
    powerBg.x, powerBg.y = display.contentCenterX + 150, display.contentCenterY + 130
    local powerIcon = display.newImageRect(grp, "assets/7icon/icon_battle_ability.png", 72, 72)
    powerIcon.x, powerIcon.y = powerBg.x - 90, powerBg.y - 10

    local powerText = textile.new({
        group = grp,
        texto = 0,
        x = powerBg.x - 60,
        y = powerBg.y - 4,
        tamanho = 25,
        corTexto = {1},
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local leaderAbility = display.newImageRect(grp, "assets/7textbg/tbg_blue_s9_11.png", 380 * 1.4, 50 * 1.4)
    leaderAbility.x, leaderAbility.y = display.contentCenterX, display.contentCenterY + 185

    local changeAbilityButton = display.newImageRect(grp, "assets/7button/btn_refresh.png", 96 * 1.15, 96 * 1.15)
    changeAbilityButton.x, changeAbilityButton.y = display.contentCenterX + 230, display.contentCenterY + 183

    local chooseLeader = display.newImageRect(grp, "assets/7button/btn_common_yellow_s9.png", 244, 66)
    chooseLeader.x, chooseLeader.y = display.contentCenterX - 135, display.contentCenterY + 275
    chooseLeader.fill.effect = "filter.grayscale"
    local chooseLeaderText = textile.new({
        group = grp,
        texto = "Definir Líder ",
        x = chooseLeader.x,
        y = chooseLeader.y,
        tamanho = 23,
        corTexto = {0.7, 0.7, 0.7}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local advanceNinja = display.newImageRect(grp, "assets/7button/btn_common_yellow_s9.png", 244, 66)
    advanceNinja.x, advanceNinja.y = chooseLeader.x + 270, chooseLeader.y
    advanceNinja.fill.effect = "filter.grayscale"
    local advanceNinjaText = textile.new({
        group = grp,
        texto = "Avançar ",
        x = advanceNinja.x,
        y = advanceNinja.y,
        tamanho = 23,
        corTexto = {0.7, 0.7, 0.7},
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local changeMember = display.newImageRect(grp, "assets/7button/btn_common_blue_s9_l.png", 280 * 1.7, 40 * 1.7)
    changeMember.x, changeMember.y = display.contentCenterX, display.contentCenterY + 358
    local changeMemberText = textile.new({
        group = grp,
        texto = "Trocar Membro ",
        x = changeMember.x,
        y = changeMember.y,
        tamanho = 23,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })
    changeMember:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("interfaces.formation.formationSelect")
            composer.gotoScene("interfaces.formation.formationSelect")
        end)
    end)

    local myNavBar = navBar.new()
    grp:insert(myNavBar)
    local topBack = topBack.new({
        title = ""
    })
    grp:insert(topBack)

    local tabEquipmentBg = display.newImageRect(grp, "assets/7button/btn_tab_s9.png", 236, 82)
    tabEquipmentBg.x, tabEquipmentBg.y = 330, -137
    local changeMemberText = textile.new({
        group = grp,
        texto = " Equipamento ",
        x = tabEquipmentBg.x,
        y = tabEquipmentBg.y + 5,
        tamanho = 22,
        corTexto = {0.6, 0.6, 0.6}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })
    tabEquipmentBg:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("interfaces.formation.equipment")
            composer.gotoScene("interfaces.formation.equipment")
        end)
        timer.performWithDelay(300, function()
            cloudOff.show({
                group = display.getCurrentStage(),
                time = 600
            })
        end)

    end)

    local tabFormationBg = display.newImageRect(grp, "assets/7button/btn_tab_light_s9.png", 236, 82)
    tabFormationBg.x, tabFormationBg.y = 110, -137
    local changeMemberText = textile.new({
        group = grp,
        texto = " Grupo Pequeno ",
        x = tabFormationBg.x,
        y = tabFormationBg.y + 5,
        tamanho = 22,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

end

scene:addEventListener("create", scene)
return scene
