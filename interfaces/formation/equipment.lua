-- equipment.lua
local composer = require("composer")
local widget = require("widget")
local supabaseClient = require("api.getCharacters")
local userDataLib = require("lib.userData")
local card = require("components.card")
local EquipmentS = require("components.equipmentS")
local textile = require("utils.textile")
local navBar = require("components.navBar")
local topBack = require("components.backTop")
local cloudOn = require("utils.cloudOn")
local cloudOff = require("utils.cloudOff")

local scene = composer.newScene()

function scene:create(event)
    local group = self.view
    local params = event.params or {}

    local data = userDataLib.load() or {}
    local userId = data.id or 461752844
    local serverId = data.server or 1

    local background = display.newImageRect(group, "assets/7bg/bg_tab_default.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    background.x, background.y = display.contentCenterX, display.contentCenterY

    local dtModal = display.newImageRect(group, "assets/7bg/dt_modal.png", 600 * 1.03, 750 * 1.03)
    dtModal.x, dtModal.y = display.contentCenterX, display.contentCenterY
    local dtModalInside = display.newImageRect(group, "assets/7bg/dtModalInside.png", 450 * 1.31, 500 * 1.48)
    dtModalInside.x, dtModalInside.y = display.contentCenterX, display.contentCenterY

    local emptyCard = display.newImageRect(group, "assets/7card/card_holder_m.png", 400 / 1.4, 460 / 1.4)
    emptyCard.x, emptyCard.y = display.contentCenterX, display.contentCenterY - 170
    local toolEmpty = display.newImageRect(group, "assets/7card/card_holder_s_1.png", 132 * 1.1, 132 * 1.1)
    toolEmpty.x, toolEmpty.y = emptyCard.x - 210, emptyCard.y - 60
    local mantleEmpty = display.newImageRect(group, "assets/7card/card_holder_s_1.png", 132 * 1.1, 132 * 1.1)
    mantleEmpty.x, mantleEmpty.y = emptyCard.x - 210, emptyCard.y + 90
    local toolAcessory = display.newImageRect(group, "assets/7card/card_holder_s_1.png", 132 * 1.1, 132 * 1.1)
    toolAcessory.x, toolAcessory.y = emptyCard.x + 210, emptyCard.y - 60
    local mountEmpty = display.newImageRect(group, "assets/7card/card_holder_s_1.png", 132 * 1.1, 132 * 1.1)
    mountEmpty.x, mountEmpty.y = emptyCard.x + 210, emptyCard.y + 90

    local toolUnlocked = display.newImageRect(group, "assets/7card/card_empty_weapon_s.png", 132 / 1.15, 132 / 1.15)
    toolUnlocked.x, toolUnlocked.y = emptyCard.x - 210, emptyCard.y - 60
    local mantleUnlocked = display.newImageRect(group, "assets/7card/card_empty_equip_s.png", 132 / 1.15, 132 / 1.15)
    mantleUnlocked.x, mantleUnlocked.y = emptyCard.x - 210, emptyCard.y + 90
    local acessoryUnlocked = display.newImageRect(group, "assets/7card/card_empty_neck_s.png", 132 / 1.15, 132 / 1.15)
    acessoryUnlocked.x, acessoryUnlocked.y = emptyCard.x + 210, emptyCard.y - 60
    local mountUnlocked = display.newImageRect(group, "assets/7card/card_empty_mount_s.png", 132 / 1.15, 132 / 1.15)
    mountUnlocked.x, mountUnlocked.y = emptyCard.x + 210, emptyCard.y + 90

    local nameBg = display.newImageRect(group, "assets/7textbg/tbg_blue_s9_11.png", 380 * 1.4, 40)
    nameBg.x, nameBg.y = display.contentCenterX, display.contentCenterY + 20

    local askButton = display.newImageRect(group, "assets/7button/btn_help.png", 96 / 1.1, 96 / 1.1)
    askButton.x, askButton.y = display.contentWidth - 80, display.contentCenterY + 20

    local hpBg = display.newImageRect(group, "assets/7textbg/tbg_blue_s9_11.png", 380 / 1.5, 40 / 1.5)
    hpBg.x, hpBg.y = 55, display.contentCenterY + 70
    hpBg.anchorX = 0
    local hpIcon = display.newImageRect(group, "assets/7icon/icon_hp.png", 48, 48)
    hpIcon.x, hpIcon.y = hpBg.x + 20, hpBg.y

    local atkBg = display.newImageRect(group, "assets/7textbg/tbg_blue_s9_11.png", 380 / 1.5, 40 / 1.5)
    atkBg.x, atkBg.y = display.contentCenterX + 265, display.contentCenterY + 70
    atkBg.anchorX = 100
    local atkIcon = display.newImageRect(group, "assets/7icon/icon_atk.png", 48, 48)
    atkIcon.x, atkIcon.y = atkBg.x - 230, atkBg.y

    local defBg = display.newImageRect(group, "assets/7textbg/tbg_blue_s9_11.png", 380 / 1.5, 40 / 1.5)
    defBg.x, defBg.y = 55, display.contentCenterY + 115
    defBg.anchorX = 0
    local defIcon = display.newImageRect(group, "assets/7icon/icon_armor.png", 48, 48)
    defIcon.x, defIcon.y = defBg.x + 20, defBg.y

    local velBg = display.newImageRect(group, "assets/7textbg/tbg_blue_s9_11.png", 380 / 1.5, 40 / 1.5)
    velBg.x, velBg.y = display.contentCenterX + 265, display.contentCenterY + 115
    velBg.anchorX = 100
    local atkIcon = display.newImageRect(group, "assets/7icon/icon_mount_speed.png", 48, 48)
    atkIcon.x, atkIcon.y = velBg.x - 230, velBg.y

    local criBg = display.newImageRect(group, "assets/7textbg/tbg_blue_s9_11.png", 380 / 1.5, 40 / 1.5)
    criBg.x, criBg.y = 55, display.contentCenterY + 115 + 45
    criBg.anchorX = 0
    local criIcon = display.newImageRect(group, "assets/7icon/icon_crit.png", 48, 48)
    criIcon.x, criIcon.y = criBg.x + 20, criBg.y

    local armBg = display.newImageRect(group, "assets/7textbg/tbg_blue_s9_11.png", 380 / 1.5, 40 / 1.5)
    armBg.x, armBg.y = display.contentCenterX + 265, display.contentCenterY + 115 + 45
    armBg.anchorX = 100
    local armIcon = display.newImageRect(group, "assets/7icon/icon_def.png", 48, 48)
    armIcon.x, armIcon.y = armBg.x - 230, armBg.y

    local precBg = display.newImageRect(group, "assets/7textbg/tbg_blue_s9_11.png", 380 / 1.5, 40 / 1.5)
    precBg.x, precBg.y = 55, display.contentCenterY + 115 + 90
    precBg.anchorX = 0
    local precIcon = display.newImageRect(group, "assets/7icon/icon_hit.png", 48, 48)
    precIcon.x, precIcon.y = precBg.x + 20, precBg.y

    local evaBg = display.newImageRect(group, "assets/7textbg/tbg_blue_s9_11.png", 380 / 1.5, 40 / 1.5)
    evaBg.x, evaBg.y = display.contentCenterX + 265, display.contentCenterY + 115 + 90
    evaBg.anchorX = 100
    local evaIcon = display.newImageRect(group, "assets/7icon/icon_dex.png", 48, 48)
    evaIcon.x, evaIcon.y = evaBg.x - 230, evaBg.y

    local curadoBg = display.newImageRect(group, "assets/7textbg/tbg_blue_s9_11.png", 380 / 1.5, 40 / 1.5)
    curadoBg.x, curadoBg.y = 55, display.contentCenterY + 115 + 90 + 45
    curadoBg.anchorX = 0
    local curadoIcon = display.newImageRect(group, "assets/7icon/icon_heal.png", 48, 48)
    curadoIcon.x, curadoIcon.y = curadoBg.x + 20, curadoBg.y

    local redDanoBg = display.newImageRect(group, "assets/7textbg/tbg_blue_s9_11.png", 380 / 1.5, 40 / 1.5)
    redDanoBg.x, redDanoBg.y = display.contentCenterX + 265, display.contentCenterY + 115 + 90 + 45
    redDanoBg.anchorX = 100
    local redDanoIcon = display.newImageRect(group, "assets/7icon/icon_reduce_damage.png", 48, 48)
    redDanoIcon.x, redDanoIcon.y = redDanoBg.x - 230, redDanoBg.y

    local text = textile.new({
        group = group,
        texto = " HP ",
        x = hpBg.x + 35,
        y = hpBg.y + 2,
        tamanho = 22,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })
    local text = textile.new({
        group = group,
        texto = " PROT ",
        x = hpBg.x + 35,
        y = hpBg.y + 2 + (45),
        tamanho = 22,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })
    local text = textile.new({
        group = group,
        texto = " CRÍ ",
        x = hpBg.x + 35,
        y = hpBg.y + 2 + (45 * 2),
        tamanho = 22,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })
    local text = textile.new({
        group = group,
        texto = " PREC ",
        x = hpBg.x + 35,
        y = hpBg.y + 2 + (45 * 3),
        tamanho = 22,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })
    local text = textile.new({
        group = group,
        texto = " CURADO ",
        x = hpBg.x + 35,
        y = hpBg.y + 2 + (45 * 4),
        tamanho = 22,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local text = textile.new({
        group = group,
        texto = " ATK ",
        x = atkBg.x - 210,
        y = atkBg.y + 2,
        tamanho = 22,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })
    local text = textile.new({
        group = group,
        texto = " VEL ",
        x = atkBg.x - 210,
        y = atkBg.y + 2 + (45),
        tamanho = 22,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })
    local text = textile.new({
        group = group,
        texto = " DUR ",
        x = atkBg.x - 210,
        y = atkBg.y + 2 + (45 * 2),
        tamanho = 22,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })
    local text = textile.new({
        group = group,
        texto = " EVA ",
        x = atkBg.x - 210,
        y = atkBg.y + 2 + (45 * 3),
        tamanho = 22,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })
    local text = textile.new({
        group = group,
        texto = " RED. DANO ",
        x = atkBg.x - 210,
        y = atkBg.y + 2 + (45 * 4),
        tamanho = 22,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    local openBtn = display.newImageRect(group, "assets/7card/card_back_m.png", 400 / 1.55, 460 / 1.55)
    openBtn.x, openBtn.y = display.contentCenterX, display.contentCenterY - 160
    openBtn:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.gotoScene("interfaces.formation.equipmentSelect", {
                params = {
                    userId = self.userId
                }
            })
        end)
        timer.performWithDelay(300, function()
            cloudOff.show({
                group = display.getCurrentStage(),
                time = 600
            })
        end)
    end)
    openBtn.alpha = 0.01

    local text = textile.new({
        group = group,
        texto = "Selec.\numa\ncarta",
        x = openBtn.x,
        y = openBtn.y,
        tamanho = 34,
        corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0, 0.2},
        espessuraContorno = 2
    })

    local myNavBar = navBar.new()
    group:insert(myNavBar)
    local topBack = topBack.new({
        title = ""
    })
    group:insert(topBack)

    local tabEquipmentBg = display.newImageRect(group, "assets/7button/btn_tab_light_s9.png", 236, 82)
    tabEquipmentBg.x, tabEquipmentBg.y = 330, -137
    local changeMemberText = textile.new({
        group = group,
        texto = " Equipamento ",
        x = tabEquipmentBg.x,
        y = tabEquipmentBg.y + 5,
        tamanho = 22,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    local tabFormationBg = display.newImageRect(group, "assets/7button/btn_tab_s9.png", 236, 82)
    tabFormationBg.x, tabFormationBg.y = 110, -137
    local changeMemberText = textile.new({
        group = group,
        texto = " Grupo Pequeno ",
        x = tabFormationBg.x,
        y = tabFormationBg.y + 5,
        tamanho = 22,
        corTexto = {0.6, 0.6, 0.6}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })
    tabFormationBg:addEventListener("tap", function()
        cloudOn.show({
            time = 300
        })
        timer.performWithDelay(300, function()
            composer.removeScene("interfaces.formation.formation")
            composer.gotoScene("interfaces.formation.formation")
        end)
        timer.performWithDelay(300, function()
            cloudOff.show({
                group = display.getCurrentStage(),
                time = 600
            })
        end)
    end)

    self.cardGroup = display.newGroup()
    group:insert(self.cardGroup)
    self.equipGroup = display.newGroup()
    group:insert(self.equipGroup)
end

function scene:show(event)
    local params = event.params or {}
    local data = userDataLib.load() or {}
    local userId = data.id or 461752844
    local serverId = data.server or 1

    if event.phase == "did" then
        if not params.selectedCharacterId then
            return
        end

        -- limpa anteriores
        self.cardGroup:removeSelf();
        self.cardGroup = display.newGroup();
        self.view:insert(self.cardGroup)
        self.equipGroup:removeSelf();
        self.equipGroup = display.newGroup();
        self.view:insert(self.equipGroup)

        -- 1) exibe o card
        local newCard = card.new({
            x = display.contentCenterX,
            y = display.contentCenterY - 150,
            characterId = params.selectedCharacterId,
            stars = params.selectedStars,
            scaleFactor = 1.1
        })
        self.cardGroup:insert(newCard)

        -- 2) busca tool, mantle e accessory na tabela characters
        local endpoint =
            string.format("characters?select=tool,mantle,acessory&uuid=eq.%s", -- note o 'acessory' errado do esquema
            params.selectedCharacterId)
        supabaseClient:request("GET", endpoint, nil, function(event)
            if event.isError or event.status ~= 200 then
                print("Erro ao buscar equipamentos do personagem:", event.response)
                return
            end

            local data = require("json").decode(event.response)
            if not data or #data == 0 then
                print("Personagem não encontrado na tabela characters.")
                return
            end

            local equips = data[1]
            local positions = {{
                x = newCard.x - 220,
                y = newCard.y - 88
            }, {
                x = newCard.x - 220,
                y = newCard.y + 49
            }, {
                x = newCard.x + 162,
                y = newCard.y - 88
            }}
            -- use o nome exato das colunas do seu schema:
            local keys = {"tool", "mantle", "acessory"}

            for i, key in ipairs(keys) do
                local equipId = equips[key]
                if equipId and equipId ~= "" then
                    EquipmentS.new({
                        group = self.equipGroup,
                        x = positions[i].x,
                        y = positions[i].y,
                        equipId = equipId,
                        scaleFactor = 1.10
                    })
                end
            end
        end)

        -- 3) busca dados de user_characters para exibir stats
        local ucEndpoint = string.format("user_characters?userId=eq.%s&characterId=eq.%s&select=...", tostring(userId),
            tostring(params.selectedCharacterId))
        supabaseClient:request("GET", ucEndpoint, nil, function(event)
            if event.isError or event.status ~= 200 then
                print("Erro ao buscar user_characters:", event.response)
                return
            end
            local ucData = require("json").decode(event.response)
            if not ucData or #ucData == 0 then
                return
            end

            local stats = ucData[1]
            local infos = {{
                label = "Nome",
                value = stats.name
            }, {
                label = "Nível",
                value = stats.level
            }, {
                label = "HP",
                value = stats.hp
            }, {
                label = "ATK",
                value = stats.atk
            }, {
                label = "EVA",
                value = stats.eva
            }, {
                label = "PREC",
                value = stats.prec
            }, {
                label = "CRI",
                value = stats.cri
            }, {
                label = "RES",
                value = stats.res
            }, {
                label = "VEL",
                value = stats.vel
            }, {
                label = "ARMOR",
                value = stats.armor
            }}
            local nameText = textile.new({
                group = self.equipGroup,
                texto = " " .. stats.name .. " (Nv" .. stats.level .. ") ",
                x = display.contentCenterX,
                y = display.contentCenterY + 20,
                tamanho = 22,
                corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                corContorno = {0, 0, 0},
                espessuraContorno = 2
            })
            local textHp = textile.new({
                group = self.equipGroup,
                texto = stats.hp .. ' ',
                x = display.contentCenterX - 15,
                y = display.contentCenterY + 72,
                tamanho = 21,
                corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                corContorno = {0, 0, 0},
                espessuraContorno = 2,
                anchorX = 100
            })
            local armorText = textile.new({
                group = self.equipGroup,
                texto = ((stats.armor) * 100) .. '% ',
                x = display.contentCenterX - 15,
                y = display.contentCenterY + 72 + 45,
                tamanho = 21,
                corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                corContorno = {0, 0, 0},
                espessuraContorno = 2,
                anchorX = 100
            })
            local criText = textile.new({
                group = self.equipGroup,
                texto = (stats.cri * 100) .. '% ',
                x = display.contentCenterX - 15,
                y = display.contentCenterY + 72 + 90,
                tamanho = 21,
                corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                corContorno = {0, 0, 0},
                espessuraContorno = 2,
                anchorX = 100
            })
            local prec = textile.new({
                group = self.equipGroup,
                texto = (stats.prec * 100) .. '% ',
                x = display.contentCenterX - 15,
                y = display.contentCenterY + 72 + 90 + 45,
                tamanho = 21,
                corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                corContorno = {0, 0, 0},
                espessuraContorno = 2,
                anchorX = 100
            })
            local curado = textile.new({
                group = self.equipGroup,
                texto = "10000 ",
                x = display.contentCenterX - 15,
                y = display.contentCenterY + 72 + 90 + 90,
                tamanho = 21,
                corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                corContorno = {0, 0, 0},
                espessuraContorno = 2,
                anchorX = 100
            })
            local atkText = textile.new({
                group = self.equipGroup,
                texto = stats.atk .. ' ',
                x = display.contentWidth - 58,
                y = display.contentCenterY + 72,
                tamanho = 21,
                corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                corContorno = {0, 0, 0},
                espessuraContorno = 2,
                anchorX = 100
            })
            local velText = textile.new({
                group = self.equipGroup,
                texto = stats.vel .. ' ',
                x = display.contentWidth - 58,
                y = display.contentCenterY + 72 + 45,
                tamanho = 21,
                corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                corContorno = {0, 0, 0},
                espessuraContorno = 2,
                anchorX = 100
            })
            local resText = textile.new({
                group = self.equipGroup,
                texto = (stats.res * 100) .. '% ',
                x = display.contentWidth - 58,
                y = display.contentCenterY + 72 + 90,
                tamanho = 21,
                corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                corContorno = {0, 0, 0},
                espessuraContorno = 2,
                anchorX = 100
            })
            local evaText = textile.new({
                group = self.equipGroup,
                texto = (stats.eva * 100) .. '% ',
                x = display.contentWidth - 58,
                y = display.contentCenterY + 72 + 90 + 45,
                tamanho = 21,
                corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                corContorno = {0, 0, 0},
                espessuraContorno = 2,
                anchorX = 100
            })
            local evaText = textile.new({
                group = self.equipGroup,
                texto = '0.0% ',
                x = display.contentWidth - 58,
                y = display.contentCenterY + 72 + 90 + 90,
                tamanho = 21,
                corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
                corContorno = {0, 0, 0},
                espessuraContorno = 2,
                anchorX = 100
            })

            -- insere cada texto na tela
            for i, info in ipairs(infos) do
                local txt = display.newText({
                    parent = self.view,
                    text = info.label .. ": " .. tostring(info.value),
                    x = display.contentWidth,
                    y = display.contentCenterY + (i - 1) * 20, -- ajuste o espaçamento conforme precisar
                    font = native.systemFont,
                    fontSize = 16,
                    align = "left"
                })
                txt.anchorX = 0
            end
        end)
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
