local composer = require("composer")
local widget = require("widget")
local navBar = require("components.navBar")
local mBTN = require("components.missionButton")
local supabase = require("config.supabase")
local userDataLib = require("lib.userData")
local getUserDataAPI = require("api.getUserData")
local textile = require("utils.textile")
local getUsers = require("api.getUsers")
local topback = require("components.backTop")
local apiEnergy = require("api.energy")
local Critical = require("utils.crticial")
local cloudOn = require("utils.cloudOn")
local cloudOff = require("utils.cloudOff")
local scene = composer.newScene()

local background

function scene:setBackgroundImage(imagePath, originalWidth, originalHeight)
    if background then
        background:removeSelf()
        background = nil
    end

    local screenWidth = display.actualContentWidth
    local screenHeight = display.actualContentHeight

    -- A altura desejada é 1.5 vezes a altura da tela.
    local desiredHeight = 1.5 * screenHeight
    -- Calcula o scaleFactor para que a imagem original alcance a desiredHeight.
    local scaleFactor = desiredHeight / originalHeight
    local newWidth = originalWidth * scaleFactor
    local newHeight = desiredHeight

    background = display.newImageRect(self.view, imagePath, newWidth, newHeight)
    if background then
        -- Centraliza horizontalmente e alinha a parte inferior à base da tela.
        background.anchorX = 0.5
        background.anchorY = 1
        background.x = display.contentCenterX
        background.y = display.contentHeight + 210
    else
        print("Erro ao carregar a imagem:", imagePath)
    end
end

local EnergyBar = {}
function EnergyBar.new(params)
    local group = params.group or display.currentStage
    local x, y = params.x or 0, params.y or 0
    local width, height = params.width or 150, params.height or 5
    local maxEnergy = params.maxEnergy or 120
    local cornerRadius = params.cornerRadius or 100

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
    fillBar:setFillColor(0.996, 0.690, 0.047)

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

function scene:create(event)
    local sceneGroup = self.view

    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 461752844
    local serverId = tonumber(data.server) or 1

    local background = display.newImageRect(sceneGroup, "assets/7bg/bg_yellow_large.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local decoTop2 = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_2.png", display.contentWidth, 60)
    decoTop2.x = display.contentCenterX
    decoTop2.y = -50
    ---- Energy
    local tbg_black_s9_m = display.newImageRect(sceneGroup, "assets/7textbg/tbg_black_s9_m.png", 140 * 1.8, 20 * 1.9)
    tbg_black_s9_m.x = display.contentCenterX
    tbg_black_s9_m.y = decoTop2.y - 3

    local topback = topback.new({
        title = "A Tentação da Comida ",
        func = "interfaces.campaign"
    })
    sceneGroup:insert(topback)

    -- 1) Dois helpers, lá em cima do seu arquivo (fora da scene)
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
        group = sceneGroup,
        x = tbg_black_s9_m.x + 10,
        y = -45,
        width = 195,
        height = 8,
        maxEnergy = 120
    })
    local energyText = textile.new({
        group = sceneGroup,
        texto = " 0/120      00:00 ",
        x = display.contentCenterX - 90,
        y = energyBar.y - 60,
        tamanho = 22,
        corTexto = {1, 1, 1},
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local energyIcon = display.newImageRect(sceneGroup, "assets/7icon/icon_energy.png", 44, 44)
    energyIcon.x, energyIcon.y = energyText.x - 15, energyText.y + 6

    local function updateEnergy()
        getUsers.fetch(userId, serverId, function(record, err)
            if err then
                native.showAlert("Erro", err, {"OK"})
                return
            end
            energy = record.energy or energy
            energyBar:setEnergy(energy)
            -- já atualiza o texto imediato para refletir o novo valor
            -- no updateEnergy, depois de energy = record.energy…
            local secsLeft = (energy >= 120) and (6 * 60) or getTimeToNextCron()
            energyText:setText(string.format("%d/120    %s ", energy, formatMMSS(secsLeft)))

        end)
    end

    updateEnergy()

    timer.performWithDelay(1000, function()
        local secsLeft = (energy >= 120) and (6 * 60) or getTimeToNextCron()
        energyText:setText(string.format("%d/120    %s ", energy, formatMMSS(secsLeft)))
    end, 0)

    local initialDelay = getTimeToNextCron() * 1000
    timer.performWithDelay(initialDelay, function()
        -- faz o primeiro fetch logo que o cron rodar
        updateEnergy()
        -- e agenda fetch a cada 6 minutos eternamente
        timer.performWithDelay(6 * 60 * 1000, updateEnergy, 0)
    end)

    local function goToHome(event)
        if event.phase == "ended" then -- Garante que a ação ocorre apenas quando o toque termina
            composer.removeScene("router.home")
            composer.gotoScene("router.home")
        end
        return true -- Previne a propagação do evento
    end

    ---- MissionButtons
    local scrollView = widget.newScrollView({
        top = -23,
        left = 0,
        width = 640,
        height = 1125,
        scrollWidth = display.contentWidth,
        scrollHeight = 1350,
        horizontalScrollDisabled = true,
        hideBackground = true
    })
    sceneGroup:insert(scrollView)

    local m1 = mBTN.new({
        x = display.contentCenterX,
        y = 90,
        id = 1,
        userId = userId,
        sprite = "assets/7items/onigiri.png",
        stars = 0,
        title = "Comum",
        subtitle = "A tentação da Comida",
        energy = 40,
        onTap = function()
            cloudOn.show({
                time = 300
            })
            timer.performWithDelay(300, function()
                composer.gotoScene("journey.journeyFormation", {
                    params = {
                        op = "journey.specialChapters.specialOpponents.agsq",
                        form = "opponent_", -- opponent_ | boss_,
                        bg = 2,
                        title = "Comum",
                        subtitle = "A Tentação da Comida",
                        userId = userId,
                        needed = 40,
                        returnTo = "journey.specialChapters.a_tentacao_da_comida"
                    }
                })
            end)
            timer.performWithDelay(300, function()
                cloudOff.show({
                    group = display.getCurrentStage(),
                    time = 600
                })
            end)
        end
    })
    scrollView:insert(m1)

    local m2 = mBTN.new({
        x = display.contentCenterX,
        y = 90 + 150,
        id = 41,
        userId = userId,
        sprite = "assets/7items/sushi.png",
        stars = 0,
        title = "Elite",
        subtitle = "A tentação da Comida",
        energy = 60,
        onTap = function()
            cloudOn.show({
                time = 300
            })
            timer.performWithDelay(300, function()
                composer.gotoScene("journey.journeyFormation", {
                    params = {
                        op = "journey.specialChapters.specialOpponents.food_2",
                        form = "opponent_", -- opponent_ | boss_,
                        bg = 2,
                        title = "Elite",
                        subtitle = "A Tentação da Comida",
                        userId = userId,
                        needed = 60,
                        returnTo = "journey.specialChapters.a_tentacao_da_comida"
                    }
                })
            end)
            timer.performWithDelay(300, function()
                cloudOff.show({
                    group = display.getCurrentStage(),
                    time = 600
                })
            end)
        end
    })
    scrollView:insert(m2)

    local m3 = mBTN.new({
        x = display.contentCenterX,
        y = 90 + 300,
        id = 71,
        userId = userId,
        sprite = "assets/7items/sushi.png",
        stars = 0,
        title = "Herói",
        subtitle = "A tentação da Comida",
        energy = 80,
        onTap = function()
            cloudOn.show({
                time = 300
            })
            timer.performWithDelay(300, function()
                composer.gotoScene("journey.journeyFormation", {
                    params = {
                        op = "journey.specialChapters.specialOpponents.food_3",
                        form = "opponent_", -- opponent_ | boss_,
                        bg = 2,
                        title = "Herói",
                        subtitle = "A Tentação da Comida",
                        userId = userId,
                        needed = 80,
                        returnTo = "journey.specialChapters.a_tentacao_da_comida"
                    }
                })
            end)
            timer.performWithDelay(300, function()
                cloudOff.show({
                    group = display.getCurrentStage(),
                    time = 600
                })
            end)
        end
    })
    scrollView:insert(m3)

    local myNavBar = navBar.new()
    sceneGroup:insert(myNavBar)
end

scene:addEventListener("create", scene)
return scene
