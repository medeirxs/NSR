-- userNick.lua
local textile = require("utils.textile")
local getUsers = require("api.getUsers")

local component = {}

function component.new(params)
    local group = display.newGroup()
    local x = params.x
    local y = params.y
    local userId = params.userId
    local serverId = params.serverId

    -- buscamos os dados primeiro para criar o texto com a cor correta
    getUsers.fetch(userId, serverId, function(record, err)
        if err then
            native.showAlert("Erro", err, {"OK"})
            return
        end

        -- escolhe a cor de texto: dourado se ganhou Kaguya, branco caso contrário
        local textoCor = record.isKaguyaWinner and {0.95, 0.86, 0.31} or {1, 1, 1}

        -- cria o texto com a cor adequada
        local nameText = textile.new({
            group = group,
            texto = (record.name or "") .. " ",
            x = x,
            y = y,
            tamanho = 24,
            corTexto = textoCor,
            corContorno = {0, 0, 0},
            espessuraContorno = 2,
            anchorX = 0,
            anchorY = 0
        })

        -- se for beta, exibe o ícone
        -- if record.isBeta then
        --     local iconBeta = display.newImageRect(group, "assets/7icon/icon_beta.png", 62 / 1.5, 30 / 1.5)
        --     iconBeta.x = nameText.x - 35
        --     iconBeta.y = nameText.y + 40
        --     group:insert(iconBeta)
        -- end
    end)

    return group
end

return component
