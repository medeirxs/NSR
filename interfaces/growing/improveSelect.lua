-- interfaces/growing/improveSelect.lua
local composer = require("composer")
local supa = require("config.supabase")
local json = require("json")
local network = require("network")
local widget = require("widget")
local userDataLib = require("lib.userData")
local cardCell = require("components.cardCell")

local scene = composer.newScene()

--------------------------------------------------------------------------------
-- create: inicializa ScrollView e carrega personagens
--------------------------------------------------------------------------------
function scene:create(event)
    local sceneGroup = self.view

    -- Obtém userId do userData ou fallback
    local data = userDataLib.load() or {}
    local localUserId = tonumber(data.id) or 461752844
    self.userId = (event.params and event.params.userId) or localUserId
    print("[improveSelect] userId:", self.userId)

    -- Título
    local title = display.newText({
        parent = sceneGroup,
        text = "Selecione o Personagem",
        x = display.contentCenterX,
        y = 40,
        font = native.systemFontBold,
        fontSize = 22
    })
    title:setFillColor(1)

    -- ScrollView vertical
    self.scrollView = widget.newScrollView({
        x = display.contentCenterX,
        y = display.contentCenterY + 20,
        width = display.contentWidth,
        height = display.contentHeight - 80,
        horizontalScrollDisabled = true
    })
    sceneGroup:insert(self.scrollView)

    -- Requisição Supabase para listar user_characters
    local headers = {
        ["Content-Type"] = "application/json",
        ["apikey"] = supa.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
    }
    local url = string.format("%s/rest/v1/user_characters?userId=eq.%s&select=id,characterId,name,stars,level,hp,atk",
        supa.SUPABASE_URL, tostring(self.userId))
    print("[improveSelect] request URL:", url)

    network.request(url, "GET", function(event)
        if event.isError then
            print("[improveSelect] network error:", event.response)
            return
        end
        local characters = json.decode(event.response) or {}
        print("[improveSelect] total chars:", #characters)

        local padding, cellH, y = 10, 132, 10 + 132 * 0.5
        for i, char in ipairs(characters) do
            print(string.format("[improveSelect] %d: id=%s uuid=%s name=%s", i, char.id, char.characterId, char.name))
            local cell = cardCell.new({
                x = display.contentCenterX,
                y = y,
                characterId = char.characterId,
                stars = char.stars,
                level = char.level,
                hp = char.hp,
                atk = char.atk,
                name = char.name
            })
            -- Ao tocar, salva o recordId global e volta para improve
            function cell:tap()
                _G.chaId = char.id -- salva o ID do registro (ex. 312)
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

--------------------------------------------------------------------------------
-- hide: limpa cena para próxima vez
--------------------------------------------------------------------------------
function scene:hide(event)
    if event.phase == "will" then
        composer.removeScene("interfaces.growing.improveSelect")
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("hide", scene)
return scene
