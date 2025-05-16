local composer = require("composer")
local widget = require("widget")
local wS = require("journey.winScreen")
local raiseItems = require("components.showRaiseItems")
local CharacterRaiseShow = require("components.characterRaiseShow")
local textile = require("utils.textile")

local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view

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

    local card = require("components.card")
    local cd = card.new({
        x = display.contentCenterX,
        y = display.contentCenterY - 250,
        characterId = "058fab51-e43a-4896-86fe-83f579e701fd",
        stars = 8,
        scaleFactor = 1.17
    })

    local hpText = textile.new({
        group = sceneGroup,
        texto = 7321321 .. " ",
        x = iconHp.x + 221,
        y = iconHp.y + 2,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 100
        
    })
    
    local iconHp = display.newImageRect(sceneGroup, "assets/7icon/icon_hp.png", 48, 48)
    iconHp.x, iconHp.y = display.contentCenterX - 100, display.contentCenterY - 27
    local iconAtk = display.newImageRect(sceneGroup, "assets/7icon/icon_atk.png", 48, 48)
    iconAtk.x, iconAtk.y = display.contentCenterX - 100, display.contentCenterY + 11
    local atkText = textile.new({
        group = sceneGroup,
        texto = 7321321 .. " ",
        x = hpText.x,
        y = hpText.y + 42,
        tamanho = 24,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 100
    })

    local levelText = textile.new({
        group = sceneGroup,
        texto = "Nv" .. 40 .. " ",
        x = display.contentCenterX - 118,
        y = display.contentCenterY - 77,
        tamanho = 21,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local hpText = textile.new({
        group = sceneGroup,
        texto = 0 .. "/" .. 430 .. " ",
        x = display.contentCenterX + 120,
        y = display.contentCenterY - 77,
        tamanho = 21,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 100
    })

    local xpBarBg = display.newImageRect(sceneGroup, "assets/7misc/pb_hp_gray.png", 224 * 1.1, 16 * 1.1)
    xpBarBg.x, xpBarBg.y = display.contentCenterX, display.contentCenterY - 58

    local addButton = display.newGroup()
    sceneGroup:insert(addButton)

    local btnAdd1 = display.newImageRect(addButton, "assets/7button/btn_add.png", 104 * 1.1, 104 * 1.1)
    btnAdd1.x, btnAdd1.y = 100, 135
    local btnAdd2 = display.newImageRect(addButton, "assets/7button/btn_add.png", 104 * 1.1, 104 * 1.1)
    btnAdd2.x, btnAdd2.y = btnAdd1.x, 135 + 158
    local btnAdd3 = display.newImageRect(addButton, "assets/7button/btn_add.png", 104 * 1.1, 104 * 1.1)
    btnAdd3.x, btnAdd3.y = btnAdd1.x, 135 + (158 * 2)

    local btnAdd4 = display.newImageRect(addButton, "assets/7button/btn_add.png", 104 * 1.1, 104 * 1.1)
    btnAdd4.x, btnAdd4.y = display.contentCenterX + 220, 135
    local btnAdd5 = display.newImageRect(addButton, "assets/7button/btn_add.png", 104 * 1.1, 104 * 1.1)
    btnAdd5.x, btnAdd5.y = btnAdd4.x, 135 + 158
    local btnAdd6 = display.newImageRect(addButton, "assets/7button/btn_add.png", 104 * 1.1, 104 * 1.1)
    btnAdd6.x, btnAdd6.y = btnAdd4.x, 135 + (158 * 2)

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

    -- local raiseItems = raiseItems.new({
    --     x = display.contentCenterX,
    --     y = display.contentCenterX,
    --     characterId = "058fab51-e43a-4896-86fe-83f579e701fd",
    --     stars = 6
    -- })

    -- local raiseGroup = CharacterRaiseShow.new({
    --     characterId = "058fab51-e43a-4896-86fe-83f579e701fd",
    --     quantity = 3,
    --     x = display.contentCenterX + 54,
    --     y = display.contentCenterY - 159,
    --     scaleFactor = 0.9
    --     -- stars = 8
    -- })
    -- display.getCurrentStage():insert(raiseGroup)
end

scene:addEventListener("create", scene)
return scene
