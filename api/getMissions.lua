-- utils/api.lua
local json = require("json")
local network = require("network")
local supa = require("config.supabase")

local getMissions = {}

--- Busca todas as missions no Supabase
-- @param callback function(missionsTable, errorMessage)
function getMissions.getMissions(callback)
    local url = supa.SUPABASE_URL .. "/rest/v1/mission?select=*" -- buscar todos os campos
    local headers = {
        ["Content-Type"] = "application/json",
        ["apikey"] = supa.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
    }

    network.request(url, "GET", function(event)
        if event.isError then
            callback(nil, "Erro na requisição: " .. (event.response or "unknown"))
            return
        end
        if event.status ~= 200 then
            callback(nil, "Status " .. event.status .. " ao buscar missions")
            return
        end

        local data = json.decode(event.response)
        callback(data, nil)
    end, {
        headers = headers
    })
end

return getMissions
