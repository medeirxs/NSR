local json = require("json")
local config = require("config.supabase")

local M = {}

function M.fetch(userId, serverId, callback)
    local headers = {
        ["apikey"] = config.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY
    }

    local url = string.format("%s/rest/v1/users?select=name,level,silver,energy,gold&id=eq.%d&server=eq.%d",
        config.SUPABASE_URL, userId, serverId)

    network.request(url, "GET", function(event)
        if event.isError or event.status ~= 200 then
            callback(nil, event.response or "Erro na requisição")
            return
        end

        local list = json.decode(event.response)
        if type(list) == "table" and #list > 0 then
            callback(list[1], nil)
        else
            callback(nil, "Usuário não encontrado")
        end
    end, {
        headers = headers
    })
end

return M

