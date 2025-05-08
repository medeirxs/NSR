-- interfaces/runes.lua
local composer = require("composer")
local display = display
local supabase = require("config.supabase")
local network = require("network")
local json = require("json")

local scene = composer.newScene()

-- Busca o array de rune UUIDs do user_characters
local function getCharacterRunes(characterId, callback)
    local headers = {
        ["apikey"] = supabase.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
    }
    -- Supondo que characterId identifica unicamente a linha em user_characters
    local url = string.format("%s/rest/v1/user_characters?select=runes&characterId=eq.%s", supabase.SUPABASE_URL,
        characterId)
    network.request(url, "GET", function(ev)
        if ev.isError or ev.status ~= 200 then
            print("Erro ao buscar runes do character:", ev.response)
            callback(nil)
            return
        end
        local data = json.decode(ev.response)
        if data and data[1] and type(data[1].runes) == "string" then
            callback(json.decode(data[1].runes))
        elseif data and data[1] and type(data[1].runes) == "table" then
            callback(data[1].runes)
        else
            callback({})
        end
    end, {
        headers = headers
    })
end

-- Busca metadados dos runes (nome, image, description, etc)
local function getRunesData(runeIds, callback)
    if #runeIds == 0 then
        callback({})
        return
    end

    local headers = {
        ["apikey"] = supabase.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
    }
    -- monta lista para IN(...)
    local list = table.concat(runeIds, ",")
    local url = string.format("%s/rest/v1/runes?select=uuid,name,runetype,atribute,image&uuid=in.(%s)",
        supabase.SUPABASE_URL, list)
    network.request(url, "GET", function(ev)
        if ev.isError or ev.status ~= 200 then
            print("Erro ao buscar dados de runes:", ev.response)
            callback({})
            return
        end
        callback(json.decode(ev.response))
    end, {
        headers = headers
    })
end

function scene:create(event)
    local group = self.view
    local params = event.params or {}
    local characterId = 461752844

    -- background simples
    local bg = display.newRect(group, display.contentCenterX, display.contentCenterY, display.contentWidth,
        display.contentHeight)
    bg:setFillColor(0.1, 0.1, 0.1)

    -- título
    local title = display.newText({
        parent = group,
        text = "Runes do Personagem",
        x = display.contentCenterX,
        y = 50,
        fontSize = 24,
        align = "center"
    })
    title:setFillColor(1, 1, 1)

    -- container para os ícones
    local iconsGroup = display.newGroup()
    group:insert(iconsGroup)

    -- fetch e exibição
    if characterId then
        getCharacterRunes(characterId, function(runeIds)
            getRunesData(runeIds, function(runes)
                -- layout em grid: 4 colunas
                local cols = 4
                local padding = 16
                local iconSize = 64
                for i, rune in ipairs(runes) do
                    local col = (i - 1) % cols
                    local row = math.floor((i - 1) / cols)
                    local x = display.contentCenterX - ((cols - 1) * (iconSize + padding)) / 2 + col *
                                  (iconSize + padding)
                    local y = 100 + row * (iconSize + padding)

                    -- ícone
                    local imgPath = rune.image or "assets/7runes/default.png"
                    local icon = display.newImageRect(iconsGroup, imgPath, iconSize, iconSize)
                    icon.x, icon.y = x, y

                    -- nome abaixo do ícone
                    local lbl = display.newText({
                        parent = iconsGroup,
                        text = rune.name or "",
                        x = x,
                        y = y + iconSize / 2 + 12,
                        fontSize = 14,
                        align = "center"
                    })
                    lbl:setFillColor(1, 1, 1)
                end
            end)
        end)
    else
        local err = display.newText({
            parent = group,
            text = "characterId não fornecido",
            x = display.contentCenterX,
            y = display.contentCenterY,
            fontSize = 18
        })
        err:setFillColor(1, 0, 0)
    end
end

function scene:show(event)
    if event.phase == "did" then
        -- se quiser animação ou reload, faz aqui
    end
end

function scene:hide(event)
    if event.phase == "will" then
        composer.removeScene(self.sceneName)
    end
end

scene:addEventListener("create")
scene:addEventListener("show")
scene:addEventListener("hide")

return scene
