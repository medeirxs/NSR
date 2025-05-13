local composer = require("composer")

local userDataLib = require("lib.userData")
local getUsers = require("api.getUsers")
local config = require("config.supabase")
local network = require("network")
local json = require("json")

local userNick = require("utils.userNick")
local userLevelBar = require("utils.userLevelBar")
local textile = require("utils.textile")

local cloudOff = require("utils.cloudOff") -- saida
local cloudOn = require("utils.cloudOn") -- saida

local bv = require("components.bandView")

local scene = composer.newScene()

local EnergyBar = {}
function EnergyBar.new(params)
    local group = params.group or display.currentStage
    local x, y = params.x or 0, params.y or 0
    local width, height = params.width or 150, params.height or 5
    local maxEnergy = params.maxEnergy or 120
    local cornerRadius = params.cornerRadius or 50

    local barGroup = display.newGroup()
    group:insert(barGroup)

    -- Barra cinza (fundo)
    local bgBar = display.newRoundedRect(barGroup, x, y, width, height, cornerRadius)
    bgBar:setFillColor(0.3, 0.3, 0.3)

    -- Container para máscara (barra verde)
    local maskGroup = display.newContainer(barGroup, width, height)
    maskGroup.x, maskGroup.y = x, y

    -- Barra verde dentro do container
    local fillBar = display.newRoundedRect(maskGroup, -width / 2, 0, width, height, cornerRadius)
    fillBar.anchorX = 0
    fillBar:setFillColor(0, 1, 0)

    -- Atualiza preenchimento da barra
    function barGroup:setEnergy(currentEnergy)
        local percent = currentEnergy / maxEnergy
        if percent > 1 then
            percent = 1
        end
        if percent < 0 then
            percent = 0
        end

        fillBar.width = width * percent
    end

    return barGroup
end

local scrollButton = {}
function scrollButton.new(params)
    local group = display.newGroup()

    local x = params.x
    local y = params.y
    local title = params.title or "Vazio"
    local params = params.params

    local image = display.newImageRect(group, "assets/7button/btn_menu_style.png", 266, 63)
    image.x, image.y = x, y

    local text = display.newText({
        text = " " .. title .. " ",
        x = x,
        y = y,
        font = "assets/7fonts/Textile.ttf",
        fontSize = 24
    })
    group:insert(text)
    text:setFillColor(0)

    return group
end

local nameText, energyText, energyBar, silverText, goldText

function scene:create(event)
    local group = self.view

    cloudOff.show({
        time = 600
    })

    local saved = userDataLib.load() or {}
    local userId = tonumber(saved.id) or error("Usuário não logado")
    local serverId = tonumber(saved.server) or error("Servidor não definido")

    local background = display.newImageRect(group, "assets/7bg/bg_home.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    background.x, background.y = display.contentCenterX, display.contentCenterY

    ----- Main User Info
    local bgMainUserInfo = display.newImageRect(group, "assets/7bg/bg_main_user_info.png", 640, 141)
    bgMainUserInfo.x, bgMainUserInfo.y = display.contentCenterX, -142

    local levelBg = display.newImageRect(group, "assets/7icon/icon_home_lv_bg.png", 63, 62)
    levelBg.x, levelBg.y = 30, bgMainUserInfo.y - 5

    nameText = userNick.new({
        group = group,
        userId = userId,
        serverId = serverId,
        x = levelBg.x + 35,
        y = levelBg.y - 18
    })
    group:insert(nameText)

    local component = userLevelBar.new({
        x = display.contentCenterX - 163,
        y = -157,
        userId = userId,
        xpBar = true
    })
    group:insert(component)

    local energyBg = display.newImageRect(group, "assets/7icon/icon_energy.png", 63 / 1.35, 62 / 1.35)
    energyBg.x, energyBg.y = 30, bgMainUserInfo.y + 40
    -- energyBar = EnergyBar.new({
    --     group = group,
    --     x = nameText.x + 157, -- ajuste conforme precisar
    --     y = bgMainUserInfo.y + 48, -- ajuste conforme precisar
    --     width = 195,
    --     height = 8,
    --     maxEnergy = 120
    -- })
    -- energyText = textile.new({
    --     group = group,
    --     texto = "",
    --     x = nameText.x + 60,
    --     y = bgMainUserInfo.y + 20,
    --     tamanho = 20,
    --     corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
    --     corContorno = {0, 0, 0},
    --     espessuraContorno = 2,
    --     anchorX = 0,
    --     anchorY = 0
    -- })

    local function getTimeToNextCron()
        local now = os.date("*t")
        -- próxima “janela” de 6 em 6 minutos
        local nextInterval = math.floor(now.min / 6) + 1
        local nextMinuteMark = nextInterval * 6
        -- quantos minutos faltam
        local deltaMin = nextMinuteMark - now.min
        -- segundos restantes
        local secs = deltaMin * 60 - now.sec
        if secs < 0 then
            secs = 0
        end
        return secs
    end

    local function formatMMSS(secs)
        local m = math.floor(secs / 60)
        local s = secs % 60
        return string.format("%02d:%02d", m, s)
    end

    local energy = 0

    local energyBar = EnergyBar.new({
        group = group,
        x = nameText.x + 157,
        y = bgMainUserInfo.y + 48,
        width = 195,
        height = 8,
        maxEnergy = 120
    })
    local energyText = textile.new({
        group = group,
        texto = "0/120    00:00",
        x = nameText.x + 60,
        y = bgMainUserInfo.y + 20,
        tamanho = 20,
        corTexto = {1, 1, 1},
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0,
        anchorY = 0
    })

    local function updateEnergy()
        getUsers.fetch(userId, serverId, function(record, err)
            if err then
                native.showAlert("Erro", err, {"OK"})
                return
            end
            energy = record.energy or energy
            energyBar:setEnergy(energy)
            -- já atualiza o texto imediato para refletir o novo valor
            local secsLeft = getTimeToNextCron()
            energyText:setText(string.format("%d/120      %s ", energy, formatMMSS(secsLeft)))
        end)
    end

    updateEnergy()

    timer.performWithDelay(1000, function()
        local secsLeft = getTimeToNextCron()
        energyText:setText(string.format("%d/120      %s ", energy, formatMMSS(secsLeft)))
    end, 0)

    local initialDelay = getTimeToNextCron() * 1000
    timer.performWithDelay(initialDelay, function()
        -- faz o primeiro fetch logo que o cron rodar
        updateEnergy()
        -- e agenda fetch a cada 6 minutos eternamente
        timer.performWithDelay(6 * 60 * 1000, updateEnergy, 0)
    end)

    local silverBg = display.newImageRect(group, "assets/7icon/icon_coin.png", 42 * 1.15, 42 * 1.15)
    silverBg.x, silverBg.y = display.contentWidth - 230, bgMainUserInfo.y + 35
    silverText = textile.new({
        group = group,
        texto = "",
        x = silverBg.x + 30,
        y = silverBg.y - 14,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0,
        anchorY = 0
    })

    local goldBg = display.newImageRect(group, "assets/7icon/icon_cash.png", 42 * 1.15, 42 * 1.15)
    goldBg.x, goldBg.y = display.contentWidth - 230, bgMainUserInfo.y - 3
    goldText = textile.new({
        group = group,
        texto = "",
        x = goldBg.x + 30,
        y = goldBg.y - 16,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0,
        anchorY = 0
    })
    local btnAdd = display.newImageRect(group, "assets/7button/btn_add.png", 96 / 2, 96 / 2)
    btnAdd.x, btnAdd.y = goldText.x + 175, goldText.y + 15
    btnAdd:addEventListener("tap", function()
        composer.removeScene("interfaces.shop")
        composer.gotoScene("interfaces.shop")
    end)

    local vipButton = display.newImageRect(group, "assets/7button/btn_vip.png", 146, 134)
    vipButton.x, vipButton.y = display.contentCenterX + 3, -135
    vipButton:addEventListener("tap", function()
        composer.removeScene("interfaces.home.vip")
        composer.gotoScene("interfaces.home.vip")
    end)

    ----- homeWidgets --------------------------------------------------------------------------------------------------
    local homeWidget = display.newGroup()
    group:insert(homeWidget)
    homeWidget.x = display.contentWidth - 50
    homeWidget.y = -10

    local btnMessage = display.newImageRect(homeWidget, "assets/7button/btn_home_chat.png", 82, 63)
    btnMessage.x, btnMessage.y = 0, 0
    btnMessage:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("interfaces.btnChat")
            composer.gotoScene("interfaces.btnChat")
        end)
        timer.performWithDelay(300, function()
            cloudOff.show({
                group = display.getCurrentStage(),
                time = 600
            })
        end)
    end)

    local btnMail = display.newImageRect(homeWidget, "assets/7button/btn_mail.png", 78, 76)
    btnMail.x, btnMail.y = -95, 0
    btnMail.fill.effect = "filter.grayscale"
    btnMail:addEventListener("tap", function()
    end)

    local btnDt = display.newImageRect(homeWidget, "assets/7button/btn_dt.png", 104, 114)
    btnDt.x, btnDt.y = btnMail.x - 100, 0
    btnDt:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("interfaces.btnKaguya")
            composer.gotoScene("interfaces.btnKaguya")
        end)
        timer.performWithDelay(300, function()
            cloudOff.show({
                group = display.getCurrentStage(),
                time = 600
            })
        end)
    end)

    local btnPvp = display.newImageRect(homeWidget, "assets/7button/btn_pvp.png", 71, 75)
    btnPvp.x, btnPvp.y = btnDt.x - 90, 0
    btnPvp.fill.effect = "filter.grayscale"
    btnPvp:addEventListener("tap", function()
    end)

    local spriteBg = display.newImageRect(homeWidget, "assets/7card/empty_purple_s.png", 104 / 1.4, 104 / 1.4)
    spriteBg.x, spriteBg.y = btnPvp.x - 90, 0
    spriteBg.fill.effect = "filter.grayscale"
    local spriteBg = display.newImageRect(homeWidget, "assets/7sprites/icon/deidara.png", 104 / 1.43, 104 / 1.43)
    spriteBg.x, spriteBg.y = btnPvp.x - 90, 0
    spriteBg.fill.effect = "filter.grayscale"

    ----- BandView -----------------------------------------------------------------------------------------------------
    local view = bv.new {
        x = display.contentCenterX,
        y = display.contentCenterY - 300,
        userId = 461752844,
        serverId = 1, -- opcional
        offsetX = 110, -- ajuste horizontal
        offsetY = 0, -- ajuste vertical
        scaleFactor = 0.8, -- escala dos cards
        offsetList = {
            [1] = {
                x = 0,
                y = 0
            },
            [2] = {
                x = 6,
                y = 0
            }, -- desloca o 2º cartão
            [3] = {
                x = 12,
                y = 0
            },
            [4] = {
                x = 18,
                y = 0
            },
            [5] = {
                x = 24,
                y = 0
            }
        }
    }
    group:insert(view)

    ----- scrollButtons ------------------------------------------------------------------------------------------------
    local equipment = scrollButton.new({
        x = display.contentCenterX + 140,
        y = display.contentCenterY - 110,
        title = "Equipamento"
    })
    group:insert(equipment)
    equipment:addEventListener("tap", function()
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

    local backpack = scrollButton.new({
        x = display.contentCenterX - 150,
        y = display.contentCenterY - 110,
        title = "Mochila"
    })
    group:insert(backpack)
    backpack:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("interfaces.backpack")
            composer.gotoScene("interfaces.backpack")
        end)
        timer.performWithDelay(300, function()
            cloudOff.show({
                group = display.getCurrentStage(),
                time = 600
            })
        end)
    end)
    ----- renameModal --------------------------------------------------------------------------------------------------
    local function showRenameModal()
        local overlay = display.newGroup()
        group:insert(overlay)

        local bg = display.newRect(overlay, display.contentCenterX, display.contentCenterY, display.contentWidth,
            display.contentHeight * 1.44)
        bg:setFillColor(0, 0, 0, 0.5)

        local bgModal = display.newImageRect(overlay, "assets/7bg/rename_modal.png", 360 * 1.6, 220 * 1.6)
        bgModal.x, bgModal.y = display.contentCenterX, display.contentCenterY

        local input = display.newImageRect(overlay, "assets/7textbg/tbg_black_s9_l.png", 300 * 1.5, 30 * 1.5)
        input.x, input.y = display.contentCenterX, display.contentCenterY - 50
        local text = textile.new({
            group = overlay,
            texto = "Insira seu Apelido",
            x = input.x - 110,
            y = input.y - 38,
            tamanho = 24,
            corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2
        })

        local textField = native.newTextField(display.contentCenterX, display.contentCenterY - 50, 300 * 1.5, 30 * 1.5)
        textField.placeholder = "Insira seu Apelido"
        textField.hasBackground = false
        textField.fontSize = 12
        overlay:insert(textField)
        textField:toFront()

        local confirmBtnBg = display.newImageRect(overlay, "assets/7textbg/tbg_blue_s9_11.png", 280 * 1.6, 40 * 2)
        confirmBtnBg.x, confirmBtnBg.y = display.contentCenterX, display.contentCenterY + 80
        local confirmBtn = display.newImageRect(overlay, "assets/7button/btn_common_yellow_s9_l.png", 280 * 1.4,
            40 * 1.5)
        confirmBtn.x, confirmBtn.y = display.contentCenterX, display.contentCenterY + 80
        confirmBtn:addEventListener("tap", function()
            local newName = textField.text or ""
            if newName:match("%S") then
                textField:removeSelf()
                textField = nil
                local headers = {
                    ["apikey"] = config.SUPABASE_ANON_KEY,
                    ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY,
                    ["Content-Type"] = "application/json"
                }
                local url = string.format("%s/rest/v1/users?id=eq.%d", config.SUPABASE_URL, userId)
                network.request(url, "PATCH", function(ev)
                    if not ev.isError and ev.status == 204 then
                        nameText.text = newName
                        overlay:removeSelf()
                    else
                        native.showAlert("Erro", "Não foi possível atualizar seu nome.", {"OK"})
                    end
                end, {
                    headers = headers,
                    body = json.encode({
                        name = newName
                    })
                })
            else
                native.showAlert("Atenção", "Nome inválido.", {"OK"})
            end
            return true
        end)

        local confirm = textile.new({
            group = overlay,
            texto = "Confirmar",
            x = confirmBtn.x,
            y = confirmBtn.y,
            tamanho = 22,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2

        })
    end

    getUsers.fetch(userId, serverId, function(record, err)
        if err then
            native.showAlert("Erro", err, {"OK"})
            return
        end

        -- nameText:setText(record.name .. " " or "")
        -- levelText:setText(tostring(record.level))
        -- energyText:setText(tostring(record.energy) .. "/120 ")
        -- energyBar:setEnergy(record.energy or 0)
        silverText:setText(tostring(record.silver) .. " ")
        goldText:setText(tostring(record.gold) .. " ")

        if record.name == "Ninja" then
            showRenameModal()
        end

    end)
end

function scene:show(event)

end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
