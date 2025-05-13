local json = require("json")
local network = require("network")
local supa = require("config.supabase")

-- headers comuns a todas as requisições Supabase
local defaultHeaders = {
    ["Content-Type"] = "application/json",
    ["apikey"] = supa.SUPABASE_ANON_KEY,
    ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
}

-- função que envia o prêmio de silver e level
local function rewardPlayer(userId, silverAmount, levelAmount, onComplete)
    local url = supa.SUPABASE_URL .. "/rest/v1/rpc/reward_user"
    local body = json.encode({
        p_user_id = userId,
        p_silver = silverAmount,
        p_level = levelAmount
    })

    network.request(url, "POST", function(event)
        if event.isError then
            print("❌ Erro ao enviar prêmio:", event.response)
        else
            print("✅ Prêmio enviado com sucesso!")
        end
        if onComplete then
            onComplete(event)
        end
    end, {
        headers = defaultHeaders,
        body = body
    })
end
