local composer = require("composer")
local widget = require("widget")
local json = require("json")
local network = require("network")
local config = require("config.supabase")
local getUsers = require("api.getUsers")

local topBack = require("components.backTop")
local navBar = require("components.navBar")

local textile = require("utils.textile")
local getUsers = require("api.getUsers")

local userDataLib = require("lib.userData")

local scene = composer.newScene()

local userNick = {}
function userNick.new(params)
    local group = display.newGroup()
    local x, y = params.x, params.y
    local userId = params.userId
    local serverId = params.serverId

    getUsers.fetch(userId, nil, function(record, err)
        if err then
            native.showAlert("Erro", err, {"OK"})
            return
        end

        local textoCor = record.isKaguyaWinner and {0.95, 0.86, 0.31} or {1, 1, 1}
        local nameX = x

        if record.isBeta then
            local iconBeta = display.newImageRect(group, "assets/7icon/icon_beta.png", 62, 30)
            iconBeta.x, iconBeta.y = x - 50, y - 30
            group:insert(iconBeta)

            textile.new({
                group = group,
                texto = (record.name or "") .. " ",
                x = nameX - 10,
                y = y - 45,
                tamanho = 24,
                corTexto = textoCor,
                corContorno = {0, 0, 0},
                espessuraContorno = 2,
                anchorX = 0,
                anchorY = 0
            })

        else

            textile.new({
                group = group,
                texto = (record.name or "") .. " ",
                x = nameX - 60,
                y = y - 45,
                tamanho = 24,
                corTexto = textoCor,
                corContorno = {0, 0, 0},
                espessuraContorno = 2,
                anchorX = 0,
                anchorY = 0
            })
        end

    end)

    return group
end

local chatBubble = {}

function chatBubble.new(params)
    local group = display.newGroup()
    local x, y = params.x, params.y
    local userId = params.userId
    local msg = params.msg or ""
    local time = params.time or "2025-01-01 00:00:00"

    -- fundo da bolha
    local image = display.newImageRect(group, "assets/7bg/bg_chat_cell_other.png", 512, 52 * 1.7)
    image.x, image.y = x, y

    -- nome do usuário (apenas uma vez)
    local nickGroup = userNick.new({
        x = x - image.width / 2 + 65,
        y = y - image.height / 2 + 17,
        userId = userId,
        serverId = serverId
    })
    group:insert(nickGroup)

    -- função para quebrar texto em linhas
    local function wrapText(str, maxChars)
        local wrapped, line = "", ""
        for word in str:gmatch("%S+") do
            if #line + #word + 1 > maxChars then
                wrapped = wrapped .. line .. "\n"
                line = word
            else
                line = (line == "" and word) or (line .. " " .. word)
            end
        end
        return wrapped .. line
    end

    local wrapped = wrapText(msg, 45)

    -- texto da mensagem (apenas uma vez)
    textile.new({
        group = group,
        texto = wrapped,
        x = x - 215,
        y = y,
        tamanho = 19,
        corTexto = {0.404, 0.271, 0.090},
        corContorno = {0, 0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0
    })

    -- timestamp (apenas uma vez)
    local function toBrasilia(iso)
        -- extrai data, hora e offset
        local y, mo, d, h, mi, s, z = iso:match("^(%d+)%-(%d+)%-(%d+)T(%d+):(%d+):(%d+)(.*)$")
        if not y then
            return iso
        end
        local year, month, day = tonumber(y), tonumber(mo), tonumber(d)
        local hour, min, sec = tonumber(h), tonumber(mi), tonumber(s)
        -- parse do offset (ex: "+00:00" ou "-03:00")
        local sign, oh, om = z:match("^([%+%-])(%d%d):(%d%d)$")
        local tzOff = 0
        if sign then
            local offH, offM = tonumber(oh), tonumber(om)
            tzOff = (offH * 3600 + offM * 60) * (sign == "+" and 1 or -1)
        end
        -- epoch local para a data bruta
        local t = {
            year = year,
            month = month,
            day = day,
            hour = hour,
            min = min,
            sec = sec
        }
        local epochLocal = os.time(t)
        -- converte para UTC
        local epochUTC = epochLocal - os.difftime(epochLocal, os.time(os.date("!*t", epochLocal)))
        -- aplica offset de Brasília (UTC-3)
        local epochBR = epochUTC - 9 * 3600
        return os.date("!%Y-%m-%d %H:%M:%S", epochBR)
    end
    local formatted = toBrasilia(time)
    textile.new({
        group = group,
        texto = formatted,
        x = x + 250,
        y = y - 50,
        tamanho = 16,
        corTexto = {1, 0.878, 0.756},
        corContorno = {0, 0, 0, 0},
        espessuraContorno = 2,
        anchorX = 100
    })
    return group
end

function scene:create(event)

    local sceneGroup = self.view

    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 461752844
    local serverId = tonumber(data.server) or 1

    local background = display.newImageRect(sceneGroup, "assets/7bg/bg_yellow_large.jpg", display.contentWidth,
        display.contentHeight * 1.44) -- 
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local bg_chat = display.newImageRect(sceneGroup, "assets/7bg/bg_chat.png", 640 * 1.02, 954 * 1.23) -- 
    bg_chat.x = display.contentCenterX
    bg_chat.y = display.contentCenterY - 80

    local bg_chat_edit = display.newImageRect(sceneGroup, "assets/7bg/bg_chat_edit.png", display.contentWidth * 1.03,
        134 * 1.23) -- 
    bg_chat_edit.x = display.contentCenterX + 2
    bg_chat_edit.y = display.contentCenterY + 550

    local rowHeight = 52 * 1.7
    local spacing = 10
    local offsetY = rowHeight * 0.5 + spacing
    local serverId -- vai ser definido no fetch abaixo

    -- cria o scrollView
    local scrollView = widget.newScrollView({
        top = -58,
        left = 0,
        width = display.contentWidth,
        height = display.contentHeight + 25,
        scrollWidth = display.contentWidth,
        scrollHeight = display.contentHeight,
        horizontalScrollDisabled = true,
        hideBackground = true
    })
    sceneGroup:insert(scrollView)

    local input = native.newTextField(display.contentCenterX - 50, display.contentHeight + 65, 505, 110)
    input.placeholder = "Sua mensagem (Max. 81 Caracteres)"
    input.hasBackground = false
    input.size = 28
    sceneGroup:insert(input)

    -- função que dispara o POST e atualiza a última mensagem
    local function sendMessage()
        local text = input.text
        if not text or text == "" then
            return
        end

        -- headers padrão Supabase
        local headers = {
            ["apikey"] = config.SUPABASE_ANON_KEY,
            ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY,
            ["Content-Type"] = "application/json"
        }

        -- monta o JSON de inserção
        local body = json.encode({{
            userId = userId,
            message = text
        }})

        network.request(config.SUPABASE_URL .. "/rest/v1/chat", "POST", function(evt)
            if evt.isError or (evt.status < 200 or evt.status >= 300) then
                native.showAlert("Erro", "Falha ao enviar mensagem", {"OK"})
                return
            end
            -- limpa o input
            input.text = ""

            local current = composer.getSceneName("current")
            composer.removeScene(current)
            composer.gotoScene(current)
        end, {
            headers = headers,
            body = body
        })
    end

    local btnSend = display.newImageRect(sceneGroup, "assets/7button/btn_send_l.png", 56 * 1.7, 65 * 1.7)
    btnSend.x, btnSend.y = display.contentWidth - 65, input.y
    btnSend:addEventListener("tap", function()
        sendMessage()
    end)

    -- primeiro busca server do usuário
    getUsers.fetch(userId, nil, function(record, err)
        if err then
            native.showAlert("Erro", err, {"OK"})
            return
        end

        local serverId = record.server or 1

        -- busca últimas 20 mensagens do chat
        local headers = {
            ["apikey"] = config.SUPABASE_ANON_KEY,
            ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY
        }
        local url = string.format("%s/rest/v1/chat?select=userId,message,created_at&order=created_at.desc&limit=20",
            config.SUPABASE_URL)

        network.request(url, "GET", function(evt)
            if evt.isError or evt.status ~= 200 then
                native.showAlert("Erro", "Falha ao carregar chat", {"OK"})
                return
            end

            local messages = json.decode(evt.response)
            -- em test.lua, dentro do network.request que monta as bolhas:

            local rowHeight = 90 -- altura base de cada bolha
            local extraSpacing = 50 -- margem extra entre bolhas
            local offsetY = rowHeight * 0.5
            offsetY = rowHeight * 0.5 + 120

            for i = 1, #messages do
                local m = messages[i]
                local bubble = chatBubble.new({
                    x = display.contentCenterX,
                    y = offsetY - 70,
                    userId = m.userId,
                    serverId = serverId,
                    msg = m.message,
                    time = m.created_at
                })
                scrollView:insert(bubble)

                -- aqui definimos o pulo vertical para a próxima bolha
                offsetY = offsetY + rowHeight + extraSpacing
            end

            scrollView:setScrollHeight(offsetY)

        end, {
            headers = headers
        })
    end)

    local myNavBar = navBar.new()
    sceneGroup:insert(myNavBar)
    local topBack = topBack.new({
        title = "Chat"
    })
    sceneGroup:insert(topBack)
    topBack:addEventListener("tap", function()
        input:removeSelf()
    end)
end

scene:addEventListener("create", scene)
return scene
