local json = require("json")
local network = require("network")
local userDataLib = require("lib.userData")
local supabase = require("config.supabase")
local card_s = require("components.cardS")

local CharacterRaiseShow = {}
CharacterRaiseShow.__index = CharacterRaiseShow

--- Componente que exibe todos os cards do usuário filtrados por stars, omitindo o último
-- @param params.table
--   characterId (string, opcional): filtra por tipo de personagem
--   stars (number, opcional): filtra por quantidade de stars (stars.eq)
--   x, y (number, opcionais): posição central do grupo
--   scaleFactor (number, opcional): escala dos cards
--   spacing (number, opcional): espaço entre cards
function CharacterRaiseShow.new(params)
    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 461752844
    local characterId = params.characterId
    local starsFilter = params.stars
    local x = params.x or display.contentCenterX
    local y = params.y or display.contentCenterY
    local scaleFactor = params.scaleFactor or 1
    local spacing = params.spacing or (150 * scaleFactor)

    local group = display.newGroup()
    group.x, group.y = x, y

    local headers = {
        ["apikey"] = supabase.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY,
        ["Content-Type"] = "application/json"
    }

    -- Monta query: filtra por userId, opcional characterId e stars, ordena por level.asc
    local queryParts = {string.format("userId=eq.%d", userId)}
    if characterId then
        table.insert(queryParts, string.format("characterId=eq.%s", characterId))
    end
    if starsFilter then
        table.insert(queryParts, string.format("stars=eq.%d", starsFilter))
    end
    table.insert(queryParts, "order=level.asc,stars.asc")
    local query = "?" .. table.concat(queryParts, "&")

    local url = supabase.SUPABASE_URL .. "/rest/v1/user_characters" .. query

    -- Listener da requisição
    local function listener(event)
        if event.isError then
            print("Erro ao buscar personagens:", event.response)
            return
        end
        local result = json.decode(event.response) or {}

        -- Remove o último personagem (mais forte dentro do filtro)
        if #result > 0 then
            table.remove(result, #result)
        end

        -- Exibe os cards restantes
        for i, row in ipairs(result) do
            local card = card_s.new({
                characterId = row.characterId,
                stars = row.stars,
                x = (i - 1) * spacing,
                y = 0,
                scaleFactor = scaleFactor
            })
            group:insert(card)
        end
    end

    network.request(url, "GET", listener, {
        headers = headers
    })
    return group
end

return CharacterRaiseShow
