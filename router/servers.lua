local composer = require("composer")
local scene = composer.newScene()
local json = require("json")
local config = require("config.supabase")
local auth = require("api.auth")
local userData = require("lib.userData")
local text = require("utils.textile")
local widget = require("widget")

-- Recupera UUID do Supabase Auth
local authUUID = system.getPreference("app", "user_uuid")

local function goHome(userRecord)
    -- Salva id e servidor no arquivo userData.json
    userData.save({
        id = userRecord.id,
        server = userRecord.server
    })
    -- Aguarda 1 frame antes de trocar de cena para evitar conflito interno do Composer
    timer.performWithDelay(500, function()
        composer.gotoScene("router.home", {
            params = {
                user = userRecord
            }
        })
    end)
end

function scene:create(event)
    local sceneGroup = self.view

    local cloudOff = require("utils.cloudOff") -- saida
    cloudOff.show({
        time = 600
    })

    local image = display.newImageRect(sceneGroup, "assets/7bg/bg_intro.jpg", display.contentWidth,
        display.contentHeight * 1.44) -- 
    image.x = display.contentCenterX
    image.y = display.contentCenterY

    local modalTop = display.newImageRect(sceneGroup, "assets/7bg/bg_sociaty_1.png", 252 * 2.3, 244 * 2.3)
    modalTop.x, modalTop.y = display.contentCenterX, display.contentCenterY - 100

    local modalBottom = display.newImageRect(sceneGroup, "assets/7bg/bg_sociaty_1.png", 252 * 2.3, 244 * 2.3)
    modalBottom.x, modalBottom.y = modalTop.x, modalTop.y + 220
    modalBottom.rotation = 180

    local landingD = display.newImageRect(sceneGroup, "assets/7bg/landing_default.png", 547, 557)
    landingD.x, landingD.y = display.contentCenterX, display.contentCenterY - 80

    local landingD = display.newImageRect(sceneGroup, "assets/7sprites/kakuzu_jiongu.png", 664 / 1.37, 843 / 1.37)
    landingD.x, landingD.y = display.contentCenterX, display.contentCenterY - 80

    local landingD = display.newImageRect(sceneGroup, "assets/7textbg/tbg_blood.png", 420 * 1.6, 136 * 1.6)
    landingD.x, landingD.y = display.contentCenterX, display.contentCenterY + 130
    local landingD = display.newImageRect(sceneGroup, "assets/7text/kakuzu_jiongu.png", 1600 / 2.9, 500 / 2.9)
    landingD.x, landingD.y = display.contentCenterX, display.contentCenterY + 130

    local ninjaLogo = display.newImageRect(sceneGroup, "assets/7text/misc_logo.png", 672 / 1.8, 388 / 1.8)
    ninjaLogo.x, ninjaLogo.y = display.contentCenterX, display.contentCenterY - 380

    -- Cria o ScrollView
    local margin = 20
    local scrollW = display.contentWidth - 2 * margin
    local scrollH = display.contentHeight - 300 -- ajuste conforme seu layout
    local scrollTop = 500 -- ponto onde começa o scroll

    local scrollView = widget.newScrollView({
        top = scrollTop + 180,
        left = margin,
        width = scrollW,
        height = 190,
        scrollWidth = scrollW,
        scrollHeight = 0, -- vamos calcular depois
        horizontalScrollDisabled = true,
        hideBackground = true
    })
    sceneGroup:insert(scrollView)

    if not authUUID then
        display.newText({
            parent = sceneGroup,
            text = "Usuário não logado",
            x = display.contentCenterX,
            y = display.contentCenterY,
            font = native.systemFontBold,
            fontSize = 18
        })
        return
    end

    -- Requisição para listar servidores
    local headers = {
        ["apikey"] = config.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. config.SUPABASE_ANON_KEY
    }
    local url = config.SUPABASE_URL .. "/rest/v1/servers?select=id,name&order=id.asc"

    network.request(url, "GET", function(event)
        if event.isError or event.status ~= 200 then
            print("Erro ao carregar servidores:", event.response)
            return
        end
        local servers = json.decode(event.response)

        -- configura scrolling de acordo com quantos itens teremos
        local rowH = 70
        scrollView:setScrollHeight(#servers * rowH + 20)

        for i, server in ipairs(servers) do
            local yPos = 10 + (i - 1) * rowH

            auth.getUserInServer(authUUID, server.id, function(existing)
                -- monta o label
                local labelText = existing and
                                      string.format("S%d %s | Nv%d %s", server.id, server.name, existing.level,
                        existing.name) or string.format("S%d %s", server.id, server.name)

                -- botão de fundo
                local btnBg = display.newImageRect("assets/7button/btn_common_yellow_s9_l.png", scrollW - 90, 70)
                btnBg.x = scrollW / 2
                btnBg.y = yPos + 30
                scrollView:insert(btnBg)

                btnBg:addEventListener("tap", function()
                    if existing then
                        goHome(existing)
                    else
                        auth.insertUser(authUUID, server.id, function(success)
                            if success then
                                auth.getUserInServer(authUUID, server.id, goHome)
                            end
                        end)
                    end
                    return true
                end)

                -- texto por cima do botão
                local btnTxt = text.new({
                    group = scrollView,
                    texto = labelText,
                    x = scrollW / 2,
                    y = yPos + 30,
                    tamanho = 24,
                    corTexto = {1, 1, 1},
                    corContorno = {0, 0, 0},
                    espessuraContorno = 2
                })
            end)
        end
    end, {
        headers = headers
    })

end

scene:addEventListener("create", scene)
return scene
