local json = require("json")
local network = require("network")
local supa = require("config.supabase")

local defaultHeaders = {
    ["Content-Type"] = "application/json",
    ["apikey"] = supa.SUPABASE_ANON_KEY,
    ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
}

local function consumeEnergy(userId, amount, onComplete)
    local url = supa.SUPABASE_URL .. "/rest/v1/rpc/consume_energy"
    local body = json.encode({
        p_user_id = userId,
        p_amount = amount
    })

    network.request(url, "POST", function(event)
        if event.isError then
            -- requisição falhou (timeout, DNS etc)
            print("❌ Erro de rede ao consumir energia:", event.response)
        else
            local status = event.status
            if status == 400 and event.response:find("Not enough energy") then
                -- falta de energia
                print("⛔ Você não tem energia suficiente!")
            elseif status >= 200 and status < 300 then
                -- sucesso
                print("✅ Energia consumida com sucesso!")
            else
                -- outro erro de API
                print(("❌ Erro ao consumir energia (HTTP %d): %s"):format(status, event.response))
            end
        end
        if onComplete then
            onComplete(event)
        end
    end, {
        headers = defaultHeaders,
        body = body
    })
end

return {
    consumeEnergy = consumeEnergy
}
