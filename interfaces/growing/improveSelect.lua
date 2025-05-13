-- interfaces/growing/improveSelect.lua
local composer = require("composer")
local supa = require("config.supabase")
local json = require("json")
local network = require("network")
local widget = require("widget")
local userDataLib = require("lib.userData")
local cardCell = require("components.cardCell")

local scene = composer.newScene()

function scene:create(event)
    local sceneGroup = self.view
    local data = userDataLib.load() or {}
    local localUserId = tonumber(data.id) or 461752844
    self.userId = (event.params and event.params.userId) or localUserId

    display.newText({
        parent = sceneGroup,
        text = "Selecione o Personagem",
        x = display.contentCenterX,
        y = 40,
        font = native.systemFontBold,
        fontSize = 22
    }):setFillColor(1)

    self.scrollView = widget.newScrollView {
        x = display.contentCenterX,
        y = display.contentCenterY + 20,
        width = display.contentWidth,
        height = display.contentHeight - 80,
        horizontalScrollDisabled = true
    }
    sceneGroup:insert(self.scrollView)

    local headers = {
        ["Content-Type"] = "application/json",
        ["apikey"] = supa.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
    }
    local url = string.format(
        "%s/rest/v1/user_characters?userId=eq.%s&select=id,characterId,name,stars,level,health,attack",
        supa.SUPABASE_URL, tostring(self.userId))
    network.request(url, "GET", function(evt)
        if evt.isError then
            return
        end
        local chars = json.decode(evt.response) or {}
        local padding, cellH, y = 10, 132, 10 + 132 * 0.5
        for _, c in ipairs(chars) do
            local cell = cardCell.new {
                x = display.contentCenterX,
                y = y,
                characterId = c.characterId,
                stars = c.stars,
                level = c.level,
                health = c.health,
                attack = c.attack,
                name = c.name
            }
            function cell:tap()
                _G.chaId = c.id
                composer.gotoScene("interfaces.growing.improve", {
                    effect = "slideRight",
                    time = 300
                })
            end
            cell:addEventListener("tap", cell)
            self.scrollView:insert(cell)
            y = y + cellH + padding
        end
        self.scrollView:setScrollHeight(y)
    end, {
        headers = headers
    })
end

function scene:hide(event)
    if event.phase == "will" then
        composer.removeScene("interfaces.growing.improveSelect")
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("hide", scene)
return scene
