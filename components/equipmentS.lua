local json = require("json")
local network = require("network")
local config = require("config.supabase")

local EquipmentS = {}

function EquipmentS.new(params)
    assert(params.equipId, "Parâmetro equipId é obrigatório")
    local group = params.group or display.currentStage
    local x = params.x or display.contentCenterX
    local y = params.y or display.contentCenterY
    local w = params.width or 64
    local h = params.height or 64
    local scaleFactor = params.scaleFactor or 1

    local url = string.format("%s/rest/v1/equipments?select=image&uuid=eq.%s", config.SUPABASE_URL, params.equipId)

    local headers = {
        ["apikey"] = config.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY
    }

    network.request(url, "GET", function(event)
        if event.isError then
            print("[EquipmentS] Erro de rede:", event.response)
            return
        end
        if event.status ~= 200 then
            print(string.format("[EquipmentS] Status inesperado %d: %s", event.status, event.response))
            return
        end

        local list = json.decode(event.response)
        if type(list) == "table" and #list > 0 then
            local entry = list[1]

            local bgImage = display.newImageRect(group, "assets/7card/empty_white_s.png", 104 * scaleFactor,
                104 * scaleFactor)
            bgImage.x, bgImage.y = x * scaleFactor, y * scaleFactor

            local imgPath = entry.image or "assets/7equip/tool/kunai.png"
            local img = display.newImageRect(group, imgPath, (w * 1.3) * scaleFactor, (h * 1.3) * scaleFactor)
            img.x, img.y = bgImage.x, bgImage.y

            if params.onComplete then
                params.onComplete(img, entry)
            end
        else
            print("[EquipmentS] Nenhum equipamento encontrado para equipId=" .. params.equipId)
        end
    end, {
        headers = headers
    })

    return group
end

return EquipmentS
