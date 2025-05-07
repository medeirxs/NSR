local json = require("json")
local config = require("config.supabase")

local M = {}

-- 1. Buscar servidor mais recente
function M.getLatestServer(serverCallback)
    local headers = {
        ["apikey"] = config.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY
    }

    local url = config.SUPABASE_URL .. "/rest/v1/servers?select=id&order=id.desc&limit=1"
    local params = {
        headers = headers
    }

    network.request(url, "GET", function(event)
        if not event.isError and event.status == 200 then
            local data = json.decode(event.response)
            if type(data) == "table" and #data > 0 then
                serverCallback(data[1].id, nil)
            else
                serverCallback(nil, "Nenhum servidor encontrado (json vazio)")
            end
        else
            serverCallback(nil, "Erro ao buscar servidor")
        end
    end, params)
end

-- 2. Cadastro (Auth + server)
function M.signUp(email, password, signUpCallback)
    local headers = {
        ["apikey"] = config.SUPABASE_ANON_KEY,
        ["Content-Type"] = "application/json"
    }

    local body = json.encode({
        email = email,
        password = password
    })

    local params = {
        headers = headers,
        body = body
    }

    network.request(config.SUPABASE_URL .. "/auth/v1/signup", "POST", function(event)
        if not event.isError and (event.status == 200 or event.status == 201) then
            local response = json.decode(event.response)
            local user_uuid = response.user and response.user.id

            M.getLatestServer(function(serverId, err)
                if serverId then
                    signUpCallback(user_uuid, serverId, nil)
                else
                    signUpCallback(nil, nil, err)
                end
            end)
        else
            signUpCallback(nil, nil, event.response or "Erro desconhecido")
        end
    end, params)
end

-- 3. Login com email e senha
function M.signIn(email, password, callback)
    local headers = {
        ["apikey"] = config.SUPABASE_ANON_KEY,
        ["Content-Type"] = "application/json"
    }

    local body = json.encode({
        email = email,
        password = password
    })

    local params = {
        headers = headers,
        body = body
    }

    local url = config.SUPABASE_URL .. "/auth/v1/token?grant_type=password"

    network.request(url, "POST", function(event)
        if not event.isError and (event.status == 200 or event.status == 201) then
            local data = json.decode(event.response)
            local user_uuid = data.user and data.user.id
            callback(user_uuid, nil)
        else
            callback(nil, event.response or "Erro ao fazer login")
        end
    end, params)
end

-- 4. Inserir novo personagem na tabela users
function M.insertUser(uuid, serverId, userCallback)
    local headers = {
        ["apikey"] = config.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY,
        ["Content-Type"] = "application/json",
        ["Prefer"] = "return=representation"
    }

    local body = json.encode({
        uuid = uuid,
        name = "Ninja",
        server = serverId
    })

    local params = {
        headers = headers,
        body = body
    }

    local url = config.SUPABASE_URL .. "/rest/v1/users"
    network.request(url, "POST", function(event)
        if not event.isError and event.status == 201 then
            userCallback(true, nil)
        else
            userCallback(false, event.response or "Erro ao inserir usuário")
        end
    end, params)
end

-- 5. Verifica se já existe personagem no servidor
function M.getUserInServer(authUuid, serverId, callback)
    local headers = {
        ["apikey"] = config.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY
    }

    local url = config.SUPABASE_URL .. "/rest/v1/users?select=*&uuid=eq." .. authUuid .. "&server=eq." .. serverId
    local params = {
        headers = headers
    }

    network.request(url, "GET", function(event)
        if not event.isError and event.status == 200 then
            local data = json.decode(event.response)
            if #data > 0 then
                callback(data[1], nil)
            else
                callback(nil, nil)
            end
        else
            callback(nil, "Erro ao buscar conta no servidor")
        end
    end, params)
end

return M
