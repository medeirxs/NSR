local composer = require("composer")
local json = require("json")

local text = require("utils.textile")
local auth = require("api.getAuth")

local scene = composer.newScene()

local emailInput, passwordInput, statusText

function scene:create(event)
    local sceneGroup = self.view

    local background = display.newImageRect(sceneGroup, "assets/7bg/bg_loading.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    background.x, background.y = display.contentCenterX, display.contentCenterY

    local bg_mopup4 = display.newImageRect(sceneGroup, "assets/7bg/bg_mopup4.png", 616, 614)
    bg_mopup4.x, bg_mopup4.y = display.contentCenterX, display.contentCenterY

    local logo = display.newImageRect(sceneGroup, "assets/7text/misc_logo.png", 672 / 1.5, 388 / 1.5)
    logo.x, logo.y = bg_mopup4.x, bg_mopup4.y - 325

    -- desenha um retângulo transparente (ou da cor do seu layout) POR TRÁS do campo
    local bgRect = display.newRect(sceneGroup, display.contentCenterX, 280 + 30, 440, 60)
    bgRect:setFillColor(1, 1, 1, 0) -- transparente

    local scrollBtnEmail =
        display.newImageRect(sceneGroup, "assets/7button/btn_menu_style_l.png", 280 * 1.95, 40 * 1.95)
    scrollBtnEmail.x, scrollBtnEmail.y = display.contentCenterX, 283 + 30

    emailInput = native.newTextField(display.contentCenterX, 284 + 30, 440, 60)
    emailInput.placeholder = "Email"
    emailInput.hasBackground = false -- desliga o chrome nativo
    emailInput.size = 28
    sceneGroup:insert(emailInput)
    emailInput:toFront()

    local bgRect2 = display.newRect(sceneGroup, display.contentCenterX, 380 + 30, 440, 60)
    bgRect2:setFillColor(1, 1, 1, 0)

    local scrollBtnPassword = display.newImageRect(sceneGroup, "assets/7button/btn_menu_style_l.png", 280 * 1.95,
        40 * 1.95)
    scrollBtnPassword.x, scrollBtnPassword.y = display.contentCenterX, 382 + 30

    passwordInput = native.newTextField(display.contentCenterX, 383 + 30, 440, 60)
    passwordInput.placeholder = "Senha"
    passwordInput.isSecure = true
    passwordInput.hasBackground = false -- desliga o chrome nativo
    passwordInput.size = 28
    sceneGroup:insert(passwordInput)
    passwordInput:toFront()

    -- Texto de status
    statusText = display.newText({
        parent = sceneGroup,
        text = "",
        x = display.contentCenterX,
        y = display.contentCenterY + 220,
        font = "assets/7fonts/Textile.ttf",
        fontSize = 12
    })
    statusText:setFillColor(0, 0, 0)

    -- Botão Registrar (usando tap)
    local registerBtn = display.newImageRect(sceneGroup, "assets/7button/btn_common_yellow_s9.png", 244, 76)
    registerBtn.x, registerBtn.y = display.contentCenterX, display.contentCenterY + 120
    registerBtn:addEventListener("tap", function()
        native.setKeyboardFocus(nil)

        local email = (emailInput.text or ""):match("%S+") and emailInput.text or ""
        local password = (passwordInput.text or ""):match("%S+") and passwordInput.text or ""
        if email == "" or password == "" then
            statusText.text = "Preencha email e senha."
            return true
        end

        statusText.text = "Cadastrando..."
        auth.signUp(email, password, function(user_uuid, serverId, err)
            if err then
                -- extrai somente a mensagem interna
                local msg
                if type(err) == "table" then
                    msg = err.msg or err.message or tostring(err)
                else
                    local ok, parsed = pcall(json.decode, err)
                    if ok and type(parsed) == "table" and parsed.msg then
                        msg = parsed.msg
                    else
                        msg = tostring(err)
                    end
                end
                statusText.text = "Erro no cadastro: " .. msg
                return
            end

            -- tudo ok: salve o UUID e passe o serverId adiante
            system.setPreferences("app", {
                user_uuid = user_uuid
            })
            statusText.text = "Cadastro OK!"
            timer.performWithDelay(800, function()
                composer.gotoScene("router.servers", {
                    params = {
                        serverId = serverId
                    }
                })
            end)
        end)

        return true
    end)

    local registerText = text.new({
        group = sceneGroup, -- ou qualquer outro grupo que você esteja usando
        texto = "Registrar ",
        x = registerBtn.x + 5,
        y = registerBtn.y,

        tamanho = 24,
        corTexto = {1, 1, 1}, -- Branco
        corContorno = {0, 0, 0}, -- Preto
        espessuraContorno = 2
    })

    -- Botão Login
    local loginBtn = display.newImageRect(sceneGroup, "assets/7button/btn_common_blue_s9_l.png", 280 * 1.8, 40 * 2)
    loginBtn.x, loginBtn.y = display.contentCenterX, display.contentCenterY + 30
    loginBtn:addEventListener("tap", function()
        local email = emailInput.text or ""
        local password = passwordInput.text or ""

        statusText.text = "Entrando..."

        auth.signIn(email, password, function(uuid, err)
            if err then
                -- tenta extrair a mensagem de erro
                local msg

                if type(err) == "table" then
                    -- se já for tabela, pega err.msg
                    msg = err.msg or err.message or tostring(err)
                else
                    -- se for string, tenta decodificar JSON
                    local ok, parsed = pcall(json.decode, err)
                    if ok and type(parsed) == "table" and parsed.msg then
                        msg = parsed.msg
                    else
                        msg = tostring(err)
                    end
                end

                statusText.text = "Erro no login: " .. msg
                return
            end

            -- sucesso
            system.setPreferences("app", {
                user_uuid = uuid
            })
            statusText.text = "Login OK!"
            timer.performWithDelay(500, function()
                composer.gotoScene("router.servers")
            end)
        end)

        return true
    end)

    local registerText = text.new({
        group = sceneGroup, -- ou qualquer outro grupo que você esteja usando
        texto = "Login ",
        x = loginBtn.x + 5,
        y = loginBtn.y,

        tamanho = 24,
        corTexto = {1, 1, 1}, -- Branco
        corContorno = {0, 0, 0}, -- Preto
        espessuraContorno = 2
    })
end

function scene:hide(event)
    if event.phase == "will" then
        if emailInput then
            emailInput:removeSelf();
            emailInput = nil
        end
        if passwordInput then
            passwordInput:removeSelf();
            passwordInput = nil
        end
    end
end

scene:addEventListener("create", scene)
scene:addEventListener("hide", scene)
return scene
