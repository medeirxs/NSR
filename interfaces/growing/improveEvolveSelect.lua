-- interfaces/growing/improveEvolveSelect.lua
local composer = require("composer")
local supa = require("config.supabase")
local json = require("json")
local network = require("network")
local widget = require("widget")
local userDataLib = require("lib.userData")

local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view
    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 461752844
    local itemId = "cd0d2985-9685-46d8-b873-5fa73bfaa5e8"
    local headers = {
        ["Content-Type"] = "application/json",
        ["apikey"] = supa.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
    }

    -- Fetch quantidade total de sushis
    local url = string.format("%s/rest/v1/user_items?userId=eq.%s&itemId=eq.%s&select=quantity", supa.SUPABASE_URL,
        userId, itemId)
    network.request(url, "GET", function(evt)
        if evt.isError then
            return
        end
        local items = json.decode(evt.response) or {}
        local totalQty = items[1] and items[1].quantity or 0
        local maxUnits = math.min(totalQty, 6)
        local rest = totalQty - maxUnits

        -- Título
        display.newText({
            parent = sceneGroup,
            text = "Selecione até " .. maxUnits .. " sushis",
            x = display.contentCenterX,
            y = 40,
            font = native.systemFontBold,
            fontSize = 20
        }):setFillColor(1)

        -- ScrollView vertical
        local scrollView = widget.newScrollView {
            x = display.contentCenterX,
            y = display.contentCenterY,
            width = display.contentWidth * 0.9,
            height = display.contentHeight * 0.7,
            scrollWidth = display.contentWidth * 0.9,
            scrollHeight = 0,
            horizontalScrollDisabled = true
        }
        sceneGroup:insert(scrollView)

        self.selectedCount = 0
        self.sushiCheckboxs = {}

        local yOff = 50
        for i = 1, maxUnits do
            local row = display.newGroup()
            row.y = yOff
            scrollView:insert(row)

            local icon = display.newImageRect(row, "assets/7items/sushi.png", 48, 48)
            icon.x, icon.y = 40, 0

            display.newText({
                parent = row,
                text = "Sushi " .. i,
                x = 100,
                y = 0,
                font = native.systemFont,
                fontSize = 18,
                anchorX = 0
            }):setFillColor(1)

            local chk = widget.newSwitch {
                style = "checkbox",
                id = "chk" .. i,
                x = scrollView.width - 40,
                y = 0,
                initialSwitchState = false,
                onPress = function(ev)
                    if ev.target.isOn then
                        if self.selectedCount < maxUnits then
                            self.selectedCount = self.selectedCount + 1
                        else
                            ev.target:setState{
                                isOn = false
                            }
                            native.showAlert("Aviso", "Máximo selecionável: " .. maxUnits, {"OK"})
                        end
                    else
                        self.selectedCount = self.selectedCount - 1
                    end
                    self.countText.text = "Selecionados: " .. self.selectedCount
                end
            }
            row:insert(chk)
            self.sushiCheckboxs[#self.sushiCheckboxs + 1] = chk

            yOff = yOff + 60
        end

        -- Linha Restantes
        if rest > 0 then
            local row = display.newGroup()
            row.y = yOff
            scrollView:insert(row)
            display.newText({
                parent = row,
                text = "Restantes: " .. rest,
                x = display.contentCenterX,
                y = 0,
                font = native.systemFont,
                fontSize = 18
            }):setFillColor(1)
            yOff = yOff + 60
        end

        scrollView:setScrollHeight(yOff)

        -- Contador
        self.countText = display.newText({
            parent = sceneGroup,
            text = "Selecionados: 0",
            x = display.contentCenterX,
            y = scrollView.y + scrollView.height / 2 + 20,
            font = native.systemFont,
            fontSize = 18
        })
        self.countText:setFillColor(1)

        -- Continuar
        local btnCont = display.newText({
            parent = sceneGroup,
            text = "Continuar",
            x = display.contentCenterX,
            y = self.countText.y + 40,
            font = native.systemFontBold,
            fontSize = 20
        })
        btnCont:setFillColor(0.2, 0.8, 1)
        btnCont:addEventListener("tap", function()

            composer.gotoScene("interfaces.growing.improve", {
                effect = "slideRight",
                time = 300,
                params = {
                    sushiCount = self.selectedCount
                }
            })
        end)
    end, {
        headers = headers
    })
end

function scene:hide(event)
    if event.phase == "will" then
        composer.removeScene("interfaces.growing.improveEvolveSelect")
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("hide", scene)
return scene
