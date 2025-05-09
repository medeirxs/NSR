local composer = require("composer")
local widget = require("widget")
local json = require("json")
local network = require("network")
local supabase = require("config.supabase")
local userDataLib = require("lib.userData")

local navBar = require("components.navBar")
local textile = require("utils.textile")
local cardCell = require("components.cardCell")
local itemCell = require("components.itemCell")
local cloudOn = require("utils.cloudOn")
local cloudOff = require("utils.cloudOff")

local scene = composer.newScene()
local tabContents = {
    cards = nil,
    items = nil
}

local currentTab = nil
local selectedTab = nil

local function cards()
    local group = display.newGroup()

    -- dados do usuário
    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 0

    -- scroll view
    local scroll = widget.newScrollView({
        top = -79,
        left = 0,
        width = display.contentWidth,
        height = 1190,
        horizontalScrollDisabled = true,
        hideBackground = true
    })
    group:insert(scroll)

    local navBar = navBar.new()
    group:insert(navBar)

    -- layout constants
    local cardHeight = 132
    local cardSpacing = 20
    local itemHeight = 132 + 10 -- altura do itemCell + espaçamento
    local paddingBottom = 50
    local maxSeparate = 6
    local yPos = 20

    -- mapas locais
    local spriteMap = {
        ["cd0d2985-9685-46d8-b873-5fa73bfaa5e8"] = "assets/7items/sushi.png",
        ["fdb9aa25-777c-4e0e-981e-151a6dc9a7d2"] = "assets/7items/sushi_legendary.png",
        ["83749125-dd27-4c01-93e2-49ae2b5de364"] = "assets/7items/ninja_certificate.png"
    }
    local nameMap = {
        ["cd0d2985-9685-46d8-b873-5fa73bfaa5e8"] = "Sushi",
        ["fdb9aa25-777c-4e0e-981e-151a6dc9a7d2"] = "Sushi Lendário",
        ["83749125-dd27-4c01-93e2-49ae2b5de364"] = "Certificado de Nível"
    }
    local starMap = {
        ["cd0d2985-9685-46d8-b873-5fa73bfaa5e8"] = 5,
        ["fdb9aa25-777c-4e0e-981e-151a6dc9a7d2"] = 6,
        ["83749125-dd27-4c01-93e2-49ae2b5de364"] = 5
    }

    -- função para exibir cartas e depois itens
    local function loadCardsAndItems()
        -- fetch cartas
        local cardsUrl = string.format(
            "%s/rest/v1/user_characters?select=characterId,name,level,stars,hp,atk&userId=eq.%s", supabase.SUPABASE_URL,
            tostring(userId))
        network.request(cardsUrl, "GET", function(evt)
            if evt.isError then
                native.showAlert("Erro", "Falha ao carregar cartas.", {"OK"})
                return
            end
            local cards = json.decode(evt.response) or {}
            -- exibe cada carta
            for _, c in ipairs(cards) do
                local cell = cardCell.new {
                    x = display.contentCenterX,
                    y = yPos + 100,
                    characterId = c.characterId,
                    stars = c.stars,
                    level = c.level,
                    hp = c.hp,
                    atk = c.atk,
                    name = c.name or "Ninja",
                    search = true
                }
                scroll:insert(cell)
                cell.isHitTestable = true
                cell:addEventListener("tap", function()

                    cloudOn.show({
                        time = 300
                    })
                    timer.performWithDelay(300, function()
                        composer.gotoScene("lib.characterInfo", {
                            effect = "fade",
                            time = 0,
                            params = c
                        })
                    end)
                    timer.performWithDelay(300, function()
                        cloudOff.show({
                            group = display.getCurrentStage(),
                            time = 600
                        })
                    end)
                end)
                yPos = yPos + cardHeight + cardSpacing
            end
            -- após cartas, fetch itens
            local itemsUrl = string.format("%s/rest/v1/user_items?select=itemId,quantity&userId=eq.%s",
                supabase.SUPABASE_URL, tostring(userId))
            network.request(itemsUrl, "GET", function(evt2)
                if evt2.isError then
                    native.showAlert("Erro", "Falha ao carregar itens.", {"OK"})
                    return
                end
                local items = json.decode(evt2.response) or {}
                -- ordenar itens por stars e nome
                table.sort(items, function(a, b)
                    local sa = starMap[a.itemId] or 0
                    local sb = starMap[b.itemId] or 0
                    if sa ~= sb then
                        return sa < sb
                    end
                    return (nameMap[a.itemId] or "") < (nameMap[b.itemId] or "")
                end)
                -- exibe itens com agrupamento
                for _, it in ipairs(items) do
                    local qty = tonumber(it.quantity) or 0
                    if qty > maxSeparate then
                        -- mostra maxSeparate unidades x1
                        for i = 1, maxSeparate do
                            scroll:insert(itemCell.new({
                                x = display.contentCenterX,
                                y = yPos + 100,
                                itemId = it.itemId,
                                quantity = 1,
                                name = nameMap[it.itemId],
                                stars = starMap[it.itemId],
                                sprite = spriteMap[it.itemId],
                                search = true
                            }))
                            yPos = yPos + itemHeight + 10
                        end
                        -- exibe o restante agrupado
                        local rem = qty - maxSeparate
                        scroll:insert(itemCell.new({
                            x = display.contentCenterX,
                            y = yPos + 100,
                            itemId = it.itemId,
                            quantity = rem,
                            name = (nameMap[it.itemId] or "Item") .. " x" .. rem,
                            stars = starMap[it.itemId],
                            sprite = spriteMap[it.itemId],
                            search = true
                        }))
                        yPos = yPos + itemHeight + 10
                    else
                        -- mostra cada unidade separada
                        for i = 1, qty do
                            scroll:insert(itemCell.new({
                                x = display.contentCenterX,
                                y = yPos + 100,
                                itemId = it.itemId,
                                quantity = 1,
                                name = nameMap[it.itemId],
                                stars = starMap[it.itemId],
                                sprite = spriteMap[it.itemId],
                                search = true
                            }))
                            yPos = yPos + itemHeight + 10
                        end
                    end
                end
                -- padding final
                scroll:setScrollHeight(yPos + paddingBottom)
            end, {
                headers = {
                    ["apikey"] = supabase.SUPABASE_ANON_KEY,
                    ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
                }
            })
        end, {
            headers = {
                ["apikey"] = supabase.SUPABASE_ANON_KEY,
                ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
            }
        })
    end

    loadCardsAndItems()

    return group
end

local function items()
    local group = display.newGroup()

    local title = display.newText({
        text = "Proxima coisa a ser feita",
        x = display.contentCenterX,
        y = display.contentCenterY,
        font = native.systemFontBold,
        fontSize = 28
    })
    group:insert(title)

    local myNavBar = navBar.new()
    group:insert(myNavBar)
    return group
end

-- Atualizar o conteúdo da aba selecionada
local function updateTabContent(tabName)
    -- Oculta todas as abas antes de exibir a nova
    for _, group in pairs(tabContents) do
        if group then
            group.isVisible = false
        end
    end

    -- Se a aba ainda não foi criada, cria agora
    if not tabContents[tabName] then
        if tabName == "cards" then
            tabContents[tabName] = cards() -- Chama a função e atribui o grupo retornado
        elseif tabName == "items" then
            tabContents[tabName] = items() -- Chama a função e atribui o grupo retornado
        end

        scene.view:insert(tabContents[tabName]) -- Insere na cena corretamente
    end

    -- Exibe a aba escolhida
    tabContents[tabName].isVisible = true
    currentTab = tabName
end

-- Criar os botões das abas
local function createTabs()
    local tabGroup = display.newGroup()
    scene.view:insert(tabGroup)

    local tabNames = {"cards", "items"}
    local labels = {"Carta", "Acessório"}
    local startX = 115
    local spacing = 210

    for i, name in ipairs(tabNames) do
        local tab = display.newGroup()
        tabGroup:insert(tab)

        local bg = display.newImageRect(tab, "assets/7button/btn_tab_s9.png", 236, 82)
        bg.x, bg.y = startX + (i - 1) * spacing, -128
        tab:insert(bg)

        local text = textile.new({
            group = tab,
            texto = " " .. labels[i] .. " ",
            x = bg.x,
            y = bg.y + 5,
            tamanho = 22,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2
        })
        tab:insert(text)

        tab.bg = bg -- Atribuir a referência ao campo `bg`

        -- Definir a função de toque
        function tab:tap()
            if selectedTab then
                selectedTab.bg.fill = {
                    type = "image",
                    filename = "assets/7button/btn_tab_s9.png"
                }
            end

            -- Alterar o fundo da aba clicada para o estado ativo
            bg.fill = {
                type = "image",
                filename = "assets/7button/btn_tab_light_s9.png"
            }

            -- Atualiza a variável de aba selecionada
            selectedTab = tab

            -- Atualiza o conteúdo da aba
            updateTabContent(name)
            return true
        end
        tab:addEventListener("tap", tab)
    end

    -- Retorna o grupo de abas para ser usado em outro lugar
    return tabGroup
end

-- Função para setar a aba inicial como ativa
local function setInitialActiveTab(tabGroup)
    -- A aba 'cards' deve ser marcada como ativa na criação
    if not selectedTab then
        -- Seleciona a aba 'cards' (primeira aba)
        selectedTab = tabGroup[1]
        -- Modifica o fundo da aba 'cards' para indicar que está ativa
        selectedTab.bg.fill = {
            type = "image",
            filename = "assets/7button/btn_tab_light_s9.png"
        }
    end
end

-- Criar a cena
function scene:create(event)
    local sceneGroup = self.view

    local background = display.newImageRect(sceneGroup, "assets/7bg/bg_yellow_large.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local bgDecoTop = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_1.png", 640, 128)
    bgDecoTop.x = display.contentCenterX
    bgDecoTop.y = -142

    local backBg = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_3.png", 128, 128)
    backBg.x = display.contentCenterX + 170
    backBg.y = -142

    local btnFilter = display.newImageRect(sceneGroup, "assets/7button/btn_help.png", 96, 96)
    btnFilter.x = display.contentCenterX + 180
    btnFilter.y = -133

    local btnBack = display.newImageRect(sceneGroup, "assets/7button/btn_close.png", 96, 96)
    btnBack.x = display.contentCenterX + 270
    btnBack.y = -133

    local function goToHome(event)
        if event.phase == "ended" then -- Garante que a ação ocorre apenas quando o toque termina
            composer.removeScene("router.home")
            composer.gotoScene("router.home")
        end
        return true -- Previne a propagação do evento
    end

    -- Adiciona o evento ao botão
    btnBack:addEventListener("touch", goToHome)

    -- Criar as abas
    local tabGroup = createTabs()

    -- Define a aba 'cards' como ativa ao iniciar
    setInitialActiveTab(tabGroup)

    -- Atualiza o conteúdo da aba inicial
    updateTabContent("cards")
end

scene:addEventListener("create", scene)
return scene
