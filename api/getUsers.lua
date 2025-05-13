-- api/getUsers.lua
local json = require("json")
local network = require("network")
local config = require("config.supabase")

local M = {}

function M.fetchAll(callback)
    local headers = {
        ["apikey"] = config.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY
    }
    local url = config.SUPABASE_URL .. "/rest/v1/users?select=*"
    network.request(url, "GET", function(event)
        if event.isError or event.status ~= 200 then
            callback(nil, event.response or "Erro ao listar usuários")
            return
        end
        callback(json.decode(event.response), nil)
    end, {
        headers = headers
    })
end

function M.fetch(userId, serverId, callback)
    local headers = {
        ["apikey"] = config.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY
    }
    -- monta URL base com filtro de userId
    local url = config.SUPABASE_URL ..
                    "/rest/v1/users?select=name,level,silver,energy,gold,isBeta,isKaguyaWinner,server" .. "&id=eq." ..
                    tostring(userId)

    -- adiciona filtro de server se fornecido
    if serverId then
        url = url .. "&server=eq." .. tostring(serverId)
    end

    network.request(url, "GET", function(event)
        if event.isError or event.status ~= 200 then
            callback(nil, event.response or "Erro ao carregar usuário")
            return
        end
        local data = json.decode(event.response)
        if type(data) == "table" and #data > 0 then
            callback(data[1], nil)
        else
            callback(nil, "Usuário não encontrado")
        end
    end, {
        headers = headers
    })
end

function M.fetchFormation(userId, callback)
    local headers = {
        ["apikey"] = config.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY
    }
    local url = config.SUPABASE_URL .. "/rest/v1/user_formation?select=formation&userId=eq." .. tostring(userId)

    network.request(url, "GET", function(event)
        if event.isError or event.status ~= 200 then
            callback(nil, event.response or "Erro ao carregar formação")
            return
        end
        local data = json.decode(event.response)
        if type(data) == "table" and #data > 0 then
            callback(data[1].formation, nil)
        else
            callback(nil, "Formação não encontrada")
        end
    end, {
        headers = headers
    })
end

return M
