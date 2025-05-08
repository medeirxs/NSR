-- equipmentSelect.lua
local composer = require("composer")
local widget = require("widget")
local supabaseClient = require("api.getCharacters")
local json = require("json")

local scene = composer.newScene()
local scrollView, params

-- Função para popular a lista
local function populateList()
    scrollView:removeSelf()
    scrollView = widget.newScrollView({
        top = 50,
        left = 0,
        width = display.contentWidth,
        height = display.contentHeight - 100,
        scrollWidth = display.contentWidth,
        scrollHeight = 0,
        hideScrollBar = false,
        hideBackground = true
    })
    scene.view:insert(scrollView)

    print("Fetch de user_characters para userId:", params.userId)
    supabaseClient:request("GET", string.format("user_characters?userId=eq.%d&order=stars.desc,name", params.userId),
        nil, function(event)
            if event.isError then
                print("Erro na requisição:", event.response)
                return
            end

            print("Resposta bruta:", event.response)
            local data = json.decode(event.response) or {}
            if #data == 0 then
                print("Nenhum personagem retornado")
            end

            for i, char in ipairs(data) do
                local yPos = (i - 1) * 60 + 30
                local label = char.name or ("Personagem " .. char.id)
                print(string.format("Item %d: %s (charId=%s)", i, label, char.characterId))
                local btn = widget.newButton({
                    label = label,
                    onRelease = function()
                        composer.gotoScene("interfaces.formation.equipment", {
                            params = {
                                userId = params.userId,
                                selectedCharacterId = char.characterId,
                                selectedStars = char.stars
                            }
                        })
                    end
                })
                btn.x, btn.y = display.contentCenterX, yPos
                scrollView:insert(btn)
            end
        end)
end

function scene:create(event)
    params = event.params or {}
    if not params.userId then
        error("userId não informado")
    end

    scrollView = widget.newScrollView({
        top = 50,
        left = 0,
        width = display.contentWidth,
        height = display.contentHeight - 100,
        scrollWidth = display.contentWidth,
        scrollHeight = 0,
        hideScrollBar = false
    })
    self.view:insert(scrollView)
end

function scene:show(event)
    if event.phase == "did" then
        populateList()
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
