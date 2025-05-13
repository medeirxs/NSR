-- interfaces/growing/improve.lua
local composer = require("composer")
local Card = require("components.card")
local supa = require("config.supabase")
local json = require("json")
local network = require("network")

local scene = composer.newScene()

--------------------------------------------------------------------------------
-- create: configura cena com título, botão e container de card
--------------------------------------------------------------------------------
function scene:create(event)
    local sceneGroup = self.view

    -- Fundo
    local bg = display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth,
        display.contentHeight)
    bg:setFillColor(0.1)

    -- Título
    local title = display.newText({
        parent = sceneGroup,
        text = "Tela de Melhoria",
        x = display.contentCenterX,
        y = 60,
        font = native.systemFontBold,
        fontSize = 24
    })
    title:setFillColor(1)

    -- Botão para selecionar personagem
    local userDataLib = require("lib.userData")
    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 461752844
    local btnSelect = display.newText({
        parent = sceneGroup,
        text = "Escolher Personagem",
        x = display.contentCenterX,
        y = display.contentHeight - 50,
        font = native.systemFont,
        fontSize = 20
    })
    btnSelect:setFillColor(0.2, 0.6, 1)
    btnSelect:addEventListener("tap", function()
        composer.gotoScene("interfaces.growing.improveSelect", {
            effect = "slideLeft",
            time = 300,
            params = {
                userId = userId
            }
        })
    end)

    -- Grupo para exibir card e textos
    self.cardGroup = display.newGroup()
    sceneGroup:insert(self.cardGroup)
end

--------------------------------------------------------------------------------
-- show: busca characterId pelo ID de registro global e exibe card e ID
--------------------------------------------------------------------------------
function scene:show(event)
    if event.phase == "did" then
        -- Limpa elementos anteriores
        if self.cardGroup then
            self.cardGroup:removeSelf()
        end
        self.cardGroup = display.newGroup()
        self.view:insert(self.cardGroup)

        -- Obtém ID de registro selecionado
        local recordId = _G.chaId
        print("[improve] recordId global chaId:", recordId)
        if not recordId then
            return
        end

        -- Exibe texto com o ID da carta
        local idText = display.newText({
            text = "ID do Registro: " .. tostring(recordId),
            x = display.contentCenterX,
            y = 50,
            font = native.systemFontBold,
            fontSize = 28
        })
        idText:setFillColor(1)
        self.cardGroup:insert(idText)

        -- Requisição para obter o characterId real
        local headers = {
            ["Content-Type"] = "application/json",
            ["apikey"] = supa.SUPABASE_ANON_KEY,
            ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
        }
        local url = string.format("%s/rest/v1/user_characters?select=characterId&limit=1&id=eq.%s", supa.SUPABASE_URL,
            tostring(recordId))
        print("[improve] fetch URL:", url)

        network.request(url, "GET", function(evt)
            if evt.isError then
                print("[improve] network error:", evt.response)
                return
            end
            local data = json.decode(evt.response)
            if data and data[1] and data[1].characterId then
                local charId = data[1].characterId
                print("[improve] fetched characterId:", charId)
                -- Exibe o card do personagem
                local c = Card.new({
                    x = display.contentCenterX,
                    y = display.contentCenterY,
                    characterId = charId,
                    scaleFactor = 1
                })
                self.card = c
                self.cardGroup:insert(c)
            else
                print("[improve] registro não encontrado")
            end
        end, {
            headers = headers
        })
    end
end

--------------------------------------------------------------------------------
-- Listeners
--------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
