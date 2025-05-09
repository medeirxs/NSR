-- events.lua
local composer = require("composer")
local widget = require("widget")
local navBar = require("components.navBar")

local scene = composer.newScene()

local tabContents = {
    daily = nil,
    accumulatedGold = nil,
    consumeGold = nil,
    trade = nil,
    reedem = nil
}

local currentTab = nil
local selectedTab = nil

local function daily()
    local group = display.newGroup()
    local title = display.newText({
        text = "Sintetizar",
        x = display.contentCenterX,
        y = display.contentCenterY,
        font = native.systemFontBold,
        fontSize = 28
    })
    group:insert(title)
    group:insert(navBar.new())
    return group
end

local function accumulatedGold()
    local group = display.newGroup()
    local title = display.newText({
        text = "Decompor",
        x = display.contentCenterX,
        y = display.contentCenterY,
        font = native.systemFontBold,
        fontSize = 28
    })
    group:insert(title)
    group:insert(navBar.new())
    return group
end

local function consumeGold()
    local group = display.newGroup()
    local title = display.newText({
        text = "Decompor",
        x = display.contentCenterX,
        y = display.contentCenterY,
        font = native.systemFontBold,
        fontSize = 28
    })
    group:insert(title)
    group:insert(navBar.new())
    return group
end

local function trade()
    local group = display.newGroup()
    local title = display.newText({
        text = "Decompor",
        x = display.contentCenterX,
        y = display.contentCenterY,
        font = native.systemFontBold,
        fontSize = 28
    })
    group:insert(title)
    group:insert(navBar.new())
    return group
end

local function reedem()
    local group = display.newGroup()

    group:insert(navBar.new())
    return group
end

-- Esconde todas as abas e exibe apenas a solicitada
local function updateTabContent(tabName)
    for _, grp in pairs(tabContents) do
        if grp then
            grp.isVisible = false
        end
    end

    if not tabContents[tabName] then
        if tabName == "daily" then
            tabContents[tabName] = daily()
        elseif tabName == "accumulatedGold" then
            tabContents[tabName] = accumulatedGold()
        elseif tabName == "consumeGold" then
            tabContents[tabName] = consumeGold()
        elseif tabName == "trade" then
            tabContents[tabName] = trade()
        elseif tabName == "reedem" then
            tabContents[tabName] = reedem()
        end
        scene.view:insert(tabContents[tabName])
    end

    tabContents[tabName].isVisible = true
    currentTab = tabName
end

-- Cria os botões de aba usando imagens ao invés de texto
local function createTabs()
    local tabGroup = display.newGroup()
    scene.view:insert(tabGroup)

    local tabNames = {"daily", "accumulatedGold", "consumeGold", "trade", "reedem"}
    -- ajuste estes caminhos para suas próprias imagens de ícone
    local tabIcons = {"assets/7button/btn_act_buy_item.png", "assets/7button/btn_act_buy_item.png",
                      "assets/7button/btn_act_buy_item.png", "assets/7button/btn_act_buy_item.png",
                      "assets/7button/reedem_code.png"}

    local scrollView = widget.newScrollView({
        x = 218,
        y = -129,
        width = 447,
        height = 90,
        anchorX = 0,
        horizontalScrollDisabled = false,
        verticalScrollDisabled = true,
        scrollWidth = #tabNames * 200,
        isBounceEnabled = true,
        hideBackground = true
    })
    scene.view:insert(scrollView)

    local startX, spacing = 70, 130
    local tabs = {}

    for i, name in ipairs(tabNames) do
        local tab = display.newGroup()
        scrollView:insert(tab)

        -- fundo do botão
        local bg = display.newImageRect(tab, "assets/7button/btn_tab_s9_s.png", 132, 82)
        bg.x, bg.y = startX + (i - 1) * spacing, 45
        tab:insert(bg)
        tab.bg = bg

        -- ícone centralizado
        local iconSize = 48
        local icon = display.newImageRect(tab, tabIcons[i], 105, 79)
        icon.x, icon.y = bg.x, bg.y
        tab:insert(icon)

        tabs[i] = tab

        function tab:tap()
            -- resetar aba anterior
            if selectedTab then
                selectedTab.bg.fill = {
                    type = "image",
                    filename = "assets/7button/btn_tab_s9_s.png"
                }
            end
            -- destacar esta aba
            bg.fill = {
                type = "image",
                filename = "assets/7button/btn_tab_light_s9_s.png"
            }
            selectedTab = tab
            updateTabContent(name)
            return true
        end
        tab:addEventListener("tap", tab)
    end

    return tabGroup, tabs
end

local function setInitialActiveTab(tabs)
    if not selectedTab and tabs[1] then
        selectedTab = tabs[1]
        selectedTab.bg.fill = {
            type = "image",
            filename = "assets/7button/btn_tab_light_s9_s.png"
        }
    end
end

-- montagem da cena
function scene:create(event)
    local sceneGroup = self.view

    -- fundos e decoração
    local background = display.newImageRect(sceneGroup, "assets/7bg/bg_yellow_large.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    background.x, background.y = display.contentCenterX, display.contentCenterY

    local bgDecoTop = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_1.png", 640, 128)
    bgDecoTop.x, bgDecoTop.y = display.contentCenterX, -142

    local backBg = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_3.png", 128, 128)
    backBg.x, backBg.y = display.contentCenterX + 170, bgDecoTop.y

    local btnFilter = display.newImageRect(sceneGroup, "assets/7button/btn_help.png", 96, 96)
    btnFilter.x, btnFilter.y = display.contentCenterX + 180, bgDecoTop.y + 10

    local btnBack = display.newImageRect(sceneGroup, "assets/7button/btn_close.png", 96, 96)
    btnBack.x, btnBack.y = display.contentCenterX + 270, bgDecoTop.y + 10

    local function goToHome(event)
        if event.phase == "ended" then
            composer.removeScene("router.home")
            composer.gotoScene("router.home")
        end
        return true
    end
    btnBack:addEventListener("touch", goToHome)

    -- tabs
    local tabGroup, tabs = createTabs()
    setInitialActiveTab(tabs)
    updateTabContent("reedem")
end

scene:addEventListener("create", scene)
return scene
