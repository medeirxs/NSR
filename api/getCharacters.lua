-- supabaseClient.lua
local json = require("json")
local network = require("network")
local config = require("config.supabase")

local client = {}
client.headers = {
    ["apikey"] = config.SUPABASE_ANON_KEY,
    ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY,
    ["Content-Type"] = "application/json"
}

--- Faz uma requisição REST ao Supabase
-- @param method   "GET"/"POST"/"PATCH"/"DELETE"
-- @param endpoint nome da tabela ou RPC (ex: "user_characters?userId=eq.1")
-- @param body     tabela Lua que será JSON-serializada, ou nil
-- @param callback function(event) → usa event.response / event.isError
function client:request(method, endpoint, body, callback)
    local url = config.SUPABASE_URL .. "/rest/v1/" .. endpoint

    -- define o listener que repassa para o callback do usuário
    local function networkListener(event)
        if callback then
            callback(event)
        end
    end

    -- paramsTable: onde vão headers e (opcionalmente) body
    local params = {
        headers = self.headers
    }
    if body then
        params.body = json.encode(body)
    end

    -- CHAMADA CORRETA:
    network.request(url, method, networkListener, params)
end

-- Helpers opcionais:
function client:getUserCharacters(userId, callback)
    local ep = string.format("user_characters?userId=eq.%d&order=stars.desc,name", userId)
    self:request("GET", ep, nil, callback)
end

function client:insertUserCharacter(body, callback)
    self:request("POST", "user_characters", body, callback)
end

return client
