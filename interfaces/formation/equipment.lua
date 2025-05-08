-- equipment.lua
local composer = require("composer")
local widget = require("widget")
local supabaseClient = require("api.getCharacters")
local card = require("components.card")

local scene = composer.newScene()

-- Cria a cena de equipment, recebe params via event.params
function scene:create(event)
    local group = self.view
    local params = event.params or {}
    self.userId = params.userId or 461752844

    -- Fundo e layout aqui...

    -- Botão "Selecionar"
    local selecionarBtn = widget.newButton({
        label = "Selecionar",
        onRelease = function()
            composer.gotoScene("interfaces.formation.equipmentSelect", {
                params = {
                    userId = self.userId
                }
            })
        end
    })
    selecionarBtn.x, selecionarBtn.y = display.contentCenterX, display.contentHeight - 100
    group:insert(selecionarBtn)

    -- Grupo para exibir o card selecionado
    self.cardGroup = display.newGroup()
    group:insert(self.cardGroup)
end

-- Exibe o card selecionado quando a cena está visível
function scene:show(event)
    if event.phase == "did" then
        local params = event.params or {}
        if params.selectedCharacterId then
            -- Remove card anterior, se existir
            if self.cardGroup then
                self.cardGroup:removeSelf()
            end
            self.cardGroup = display.newGroup()
            self.view:insert(self.cardGroup)

            -- Cria e insere componente card
            local newCard = card.new({
                x = display.contentCenterX,
                y = display.contentCenterY,
                characterId = params.selectedCharacterId,
                stars = params.selectedStars,
                scaleFactor = 1
            })
            self.cardGroup:insert(newCard)
        end
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)

return scene
