local composer = require("composer")
local widget = require("widget")
local network = require("network")
local json = require("json")
local supabase = require("config.supabase")
local navBar = require("components.navBar")
local getUsers = require("api.getUsers")
local textile = require("utils.textile")
local userDataLib = require("lib.userData")
local gM = require("api.getMissions")
local journeyCell = require("components.journeyCell")

local cloudOn = require("utils.cloudOn")
local cloudOff = require("utils.cloudOff")

local specialCell = {}

function specialCell.new(params)
    local group = display.newGroup()
    local x = params.x
    local y = params.y
    local userId = params.userId or 0
    local id = params.id or 1
    local scaleFactor = params.scaleFactor or 1
    local bgImage = params.bg or "assets/7bg/bg_campaign_map_cell_unopen.jpg"
    local chapterText = params.chapter or "Capítulo Indefinido"
    local titleText = params.title or "Título da Missão"
    local onTap = params.onTap

    -- fundo + borda
    local bg = display.newImageRect(group, bgImage, 600 * scaleFactor, 147 * scaleFactor)
    bg.x, bg.y = x, y
    local border = display.newImageRect(group, "assets/7bg/bg_cell_blue_border.png", 610 * scaleFactor,
        172 * scaleFactor)
    border.x, border.y = x, y + (8 * scaleFactor)

    -- textos

    local lblChapter = textile.new({
        group = group,
        texto = " " .. chapterText .. " ",
        x = x,
        y = y + (49 * scaleFactor),
        tamanho = 20,
        corTexto = {0.95, 0.86, 0.31}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })
    local lblTitle = textile.new({
        group = group,
        texto = " " .. titleText .. " ",
        x = x,
        y = y + (73 * scaleFactor),
        tamanho = 24,
        corTexto = {1}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    -- se não tem userId, já bloqueia
    if userId == 0 then
        bg.fill.effect = "filter.grayscale"
        border.fill.effect = "filter.grayscale"
        local lockImg = display.newImageRect(group, "assets/7misc/misc_campaign_map_cell_lock.png", 588 * scaleFactor,
            180 * scaleFactor)
        lockImg.x, lockImg.y = x, y
        return group
    end

    -- função que aplica lock/unlock/completed
    local function applyState(journeyVal)
        local low = (id - 1) * 10 + 1
        local high = id * 10
        if journeyVal < low then
            -- bloqueado
            bg.fill.effect = "filter.grayscale"
            border.fill.effect = "filter.grayscale"
            local lockImg = display.newImageRect(group, "assets/7misc/misc_campaign_map_cell_lock.png",
                588 * scaleFactor, 180 * scaleFactor)
            lockImg.x, lockImg.y = x, y + 10
        elseif journeyVal > high then

            if onTap then
                group:addEventListener("tap", function()
                    onTap()
                    return true
                end)
            end
        else
            -- desbloqueado
            if onTap then
                group:addEventListener("tap", function()
                    onTap()
                    return true
                end)
            end
        end
    end

    -- busca journey e aplica estado
    local headers = {
        ["apikey"] = supabase.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supabase.SUPABASE_ANON_KEY
    }
    local url = string.format("%s/rest/v1/users?select=journey&id=eq.%d", supabase.SUPABASE_URL, userId)
    network.request(url, "GET", function(ev)
        if not ev.isError and ev.status == 200 then
            local t = json.decode(ev.response)
            local val = (t and t[1] and t[1].journey) or 0
            applyState(val)
        else
            print("Erro fetch journey:", ev.status, ev.response)
            applyState(0)
        end
    end, {
        headers = headers
    })

    return group
end

local scene = composer.newScene()
local tabContents = {
    synthesize = nil,
    decompose = nil
}

local data = userDataLib.load() or {}
local userId = tonumber(data.id) or 461752844
local serverId = tonumber(data.server) or 1

local currentTab = nil
local selectedTab = nil

local EnergyBar = {}
function EnergyBar.new(params)
    local group = params.group or display.currentStage
    local x, y = params.x or 0, params.y or 0
    local width, height = params.width or 150, params.height or 5
    local maxEnergy = params.maxEnergy or 120
    local cornerRadius = params.cornerRadius or 100

    local barGroup = display.newGroup()
    group:insert(barGroup)

    -- Barra cinza (fundo)
    local bgBar = display.newRoundedRect(barGroup, x, y, width, height, cornerRadius)
    bgBar:setFillColor(0.3, 0.3, 0.3)

    -- Container para máscara (barra verde)
    local maskGroup = display.newContainer(barGroup, width, height)
    maskGroup.x, maskGroup.y = x, y

    -- Barra verde dentro do container
    local fillBar = display.newRoundedRect(maskGroup, -width / 2, 0, width, height, cornerRadius)
    fillBar.anchorX = 0
    fillBar:setFillColor(0.996, 0.690, 0.047)

    -- Atualiza preenchimento da barra
    function barGroup:setEnergy(currentEnergy)
        local percent = currentEnergy / maxEnergy
        if percent > 1 then
            percent = 1
        end
        if percent < 0 then
            percent = 0
        end

        fillBar.width = width * percent
    end

    return barGroup
end

local function synthesize()
    local group = display.newGroup()

    local itemCount = 26
    local verticalStep = 180
    local bottomMargin = 130 -- margem extra em pixels

    local scrollHeight = (itemCount * verticalStep) + bottomMargin

    local scrollView = widget.newScrollView({
        top = -28, -- posição vertical do scroll view na tela
        left = 0,
        width = 640,
        height = 1150, -- área visível; ajuste conforme necessário
        scrollWidth = display.contentWidth,
        scrollHeight = 1350, -- altura total do conteúdo (deve ser maior que 'height' para permitir scroll)
        horizontalScrollDisabled = true,
        hideBackground = true
    })
    group:insert(scrollView)

    local map1 = journeyCell.new({
        x = display.contentCenterX,
        y = 120,
        userId = userId,
        id = 1,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_1.jpg",
        chapter = "Primeiro Capítulo",
        title = "Naruto Uzumaki Chegando",
        onTap = function()
            composer.removeScene("journey.chapters.naruto_uzumaki_chegando")
            composer.gotoScene("journey.chapters.naruto_uzumaki_chegando")
        end
    })
    scrollView:insert(map1)

    local map2 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180,
        userId = userId,
        id = 2,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_2.jpg",
        chapter = "Segundo Capítulo",
        title = "Aventura no País das Ondas",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map2)

    local map3 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 2,
        userId = userId,
        id = 3,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_3.jpg",
        chapter = "Terceiro Capítulo",
        title = "O Exame Chunin",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map3)

    local map4 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 3,
        userId = userId,
        id = 4,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_4.jpg",
        chapter = "Quarto Capítulo",
        title = "Preliminares",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map4)

    local map5 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 4,
        userId = userId,
        id = 5,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_5.jpg",
        chapter = "Quinto Capítulo",
        title = "Segunda Fase do Exame Chunin",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map5)

    local map6 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 5,
        userId = userId,
        id = 6,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_6.jpg",
        chapter = "Sexto Capítulo",
        title = "Esmagamento de Konoha",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map6)

    local map7 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 6,
        userId = userId,
        id = 7,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_7.jpg",
        chapter = "Sétimo Capítulo",
        title = "Akatsuki Chegando",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map7)

    local map8 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 7,
        userId = userId,
        id = 8,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_8.jpg",
        chapter = "Oitavo Capítulo",
        title = "Busca por Tsunade",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map8)

    local map9 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 8,
        userId = userId,
        id = 9,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_9.jpg",
        chapter = "Nono Capítulo",
        title = "Missão Recuperação de Sasuke",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map9)

    local map10 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 9,
        userId = userId,
        id = 10,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_10.jpg",
        chapter = "Décimo Capítulo",
        title = "Encontro no Vale do Fim",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map10)

    local map11 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 10,
        userId = userId,
        id = 11,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_11.jpg",
        chapter = "Décimo Primeiro Capítulo",
        title = "Missão de Resgate do Kazekage",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map11)

    local map12 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 11,
        userId = userId,
        id = 12,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_12.jpg",
        chapter = "Décimo Segundo Capítulo",
        title = "Há Quanto Tempo!",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map12)

    local map13 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 12,
        userId = userId,
        id = 13,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_13.jpg",
        chapter = "Décimo Terceiro Capítulo",
        title = "Imortais Devastadores",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map13)

    local map14 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 13,
        userId = userId,
        id = 14,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_14.jpg",
        chapter = "Décimo Quarto Capítulo",
        title = "Time Taka",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map14)

    local map15 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 14,
        userId = userId,
        id = 15,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_15.jpg",
        chapter = "Décimo Quinto Capítulo",
        title = "Capitulo da Vingança",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map15)

    local map16 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 15,
        userId = userId,
        id = 16,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_16.jpg",
        chapter = "Décimo Sexto Capítulo",
        title = "Ataque de Pain",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map16)

    local map17 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 16,
        userId = userId,
        id = 17,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_17.jpg",
        chapter = "Décimo Sétimo Capítulo",
        title = "Reunião dos Kage",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map17)

    local map18 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 17,
        userId = userId,
        id = 18,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_18.jpg",
        chapter = "Décimo Oitavo Capítulo",
        title = "Ilha do Paraíso",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map18)

    local map19 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 18,
        userId = userId,
        id = 19,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_19.jpg",
        chapter = "Décimo Nono Capítulo",
        title = "Quarta Guerra Mundial Ninja",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map19)

    local map20 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 19,
        userId = userId,
        id = 20,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_20.jpg",
        chapter = "Vigésimo Capítulo",
        title = "Ressucitados",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map20)

    local map21 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 20,
        userId = userId,
        id = 21,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_21.jpg",
        chapter = "Vigésimo Primeiro Capítulo",
        title = "Fantasmas do Passado",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map21)

    local map22 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 21,
        userId = userId,
        id = 22,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_22.jpg",
        chapter = "Vigésimo Segundo Capítulo",
        title = "Regresso dos Jinchuriki",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map22)

    local map23 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 22,
        userId = userId,
        id = 23,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_23.jpg",
        chapter = "Vigésimo Terceiro Capítulo",
        title = "Previsão da Vitória",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map23)

    local map24 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 23,
        userId = userId,
        id = 24,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_24.jpg",
        chapter = "Vigésimo Quarto Capítulo",
        title = "O Encontro Com o Sábio",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map24)

    local map25 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 24,
        userId = userId,
        id = 25,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_25.jpg",
        chapter = "Vigésimo Quinto Capítulo",
        title = "Kaguya Otsutsuki",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map25)

    local map26 = journeyCell.new({
        x = display.contentCenterX,
        y = 120 + 180 * 25,
        userId = userId,
        id = 26,
        scaleFactor = 1,
        bg = "assets/7bg/bg_campaign_map_26.jpg",
        chapter = "Capítulo Final",
        title = "Naruto Vs Sasuke",
        onTap = function()
            composer.gotoScene("router.main")
        end
    })
    scrollView:insert(map26)

    local spacer = display.newRect(0, 0, 1, bottomMargin)
    spacer.anchorY = 0
    spacer.x = display.contentCenterX
    spacer.y = (itemCount * verticalStep) + (120 * 0) -- 120 porque o primeiro botão está em y=120
    spacer.isVisible = false
    scrollView:insert(spacer)

    local myNavBar = navBar.new()
    group:insert(myNavBar)
    return group
end

local function decompose()
    local group = display.newGroup()

    local itemsChapters = display.newGroup()
    group:insert(itemsChapters)

    gM.getMissions(function(missions, err)
        if err then
            print("Erro ao carregar missions:", err)
            return
        end

        -- encontra a mission de id 2
        local mission2
        for _, m in ipairs(missions) do
            if m.id == 2 then
                mission2 = m
                break
            end
        end

        local special = mission2 and mission2.isActive
        local frogId, foodId

        if special == true then
            frogId = 999999999
            foodId = 1
        elseif special == false then
            frogId = 1
            foodId = 999999999
        else
            -- quando isActive vier nil
            frogId = 1
            foodId = 1
        end

        -- instancia frog
        local frog = specialCell.new({
            x = display.contentCenterX,
            userId = userId,
            y = 75,
            id = frogId,
            bg = "assets/7bg/bg_campaign_map_201.jpg",
            chapter = "Capítulo Especial",
            title = "Monte Kiyama de Treino",
            onTap = function()
                cloudOn.show({
                    time = 300
                })
                timer.performWithDelay(300, function()

                    composer.removeScene("journey.specialChapters.monte_kiyama_de_treino")
                    composer.gotoScene("journey.specialChapters.monte_kiyama_de_treino")
                end)
                timer.performWithDelay(300, function()
                    cloudOff.show({
                        group = display.getCurrentStage(),
                        time = 600
                    })
                end)
            end
        })
        itemsChapters:insert(frog)

        -- instancia food
        local food = specialCell.new({
            x = display.contentCenterX,
            userId = userId,
            y = 260,
            id = foodId,
            bg = "assets/7bg/bg_campaign_map_202.jpg",
            chapter = "Capítulo Especial",
            title = "A Tentação da Comida",
            onTap = function()
                cloudOn.show({
                    time = 300
                })
                timer.performWithDelay(300, function()
                    composer.removeScene("journey.specialChapters.a_tentacao_da_comida")
                    composer.gotoScene("journey.specialChapters.a_tentacao_da_comida")
                end)
                timer.performWithDelay(300, function()
                    cloudOff.show({
                        group = display.getCurrentStage(),
                        time = 600
                    })
                end)
            end
        })
        itemsChapters:insert(food)
    end)

    local charactersChapters = display.newGroup()
    group:insert(charactersChapters)

    local boys1 = specialCell.new({
        x = display.contentCenterX,
        userId = userId,
        y = 75,
        id = 1,
        bg = "assets/7bg/bg_campaign_map_204.jpg",
        chapter = "Capítulo Especial",
        title = "Arco Garotos de Sangue Quente",
        onTap = function()
            composer.gotoScene("router.main.campaignRouter.specialChapters.arco_dos_garotos_de_sangue_quente")
        end
    })
    charactersChapters:insert(boys1)

    local boys2 = specialCell.new({
        x = display.contentCenterX,
        userId = userId,
        y = 260,
        id = 1,
        bg = "assets/7bg/bg_campaign_map_205.jpg",
        chapter = "Capítulo Especial",
        title = "Arco Garotos de Sangue Quente",
        onTap = function()
            composer.gotoScene("router.main.campaignRouter.specialChapters.arco_dos_garotos_sabios")
        end
    })
    charactersChapters:insert(boys2)

    local girls1 = specialCell.new({
        x = display.contentCenterX,
        userId = userId,
        y = 445,
        id = 1,
        bg = "assets/7bg/bg_campaign_map_206.jpg",
        chapter = "Capítulo Especial",
        title = "Arco das Garotas",
        onTap = function()
            composer.gotoScene("router.main.campaignRouter.specialChapters.arco_das_garotas")
        end
    })
    charactersChapters:insert(girls1)

    charactersChapters.x = 0 -- tela visível
    charactersChapters.x = display.contentWidth -- fora da tela, à direita

    local currentPage = 1 -- página atual

    -- Função que realiza o slide para a página desejada
    local function slideJourney(page)
        local targetX = -display.contentWidth * (page - 1)
        transition.to(itemsChapters, {
            time = 500,
            x = targetX,
            onComplete = function()
                updateButtons()
            end
        })
        transition.to(charactersChapters, {
            time = 500,
            x = targetX + display.contentWidth
        })
    end

    -- Funções para navegar entre as páginas
    local function goNextPage()
        if currentPage < 2 then
            currentPage = currentPage + 1
            slideJourney(currentPage)
        end
    end

    local function goPreviousPage()
        if currentPage > 1 then
            currentPage = currentPage - 1
            slideJourney(currentPage)
        end
    end

    local prevBtn = display.newImageRect("assets/7button/btn_arrow_2.png", 85, 73)
    prevBtn.x = 50
    prevBtn.y = display.contentCenterY + 100
    prevBtn.rotation = 180
    group:insert(prevBtn)

    -- Criação do botão para avançar (imagem "next.png")
    local nextBtn = display.newImageRect("assets/7button/btn_arrow_2.png", 85, 73)
    nextBtn.x = display.contentWidth - 50
    nextBtn.y = display.contentCenterY + 100
    group:insert(nextBtn)

    function updateButtons()
        if currentPage == 1 then
            prevBtn.isVisible = false
            nextBtn.isVisible = true
        elseif currentPage == 2 then
            prevBtn.isVisible = true
            nextBtn.isVisible = false
        end
    end

    -- Inicializa os botões de acordo com a página inicial
    updateButtons()

    -- Adiciona os listeners para os botões
    prevBtn:addEventListener("tap", goPreviousPage)
    nextBtn:addEventListener("tap", goNextPage)

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
        if tabName == "synthesize" then
            tabContents[tabName] = synthesize() -- Chama a função e atribui o grupo retornado
        elseif tabName == "decompose" then
            tabContents[tabName] = decompose() -- Chama a função e atribui o grupo retornado
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

    local tabNames = {"synthesize", "decompose"}
    local labels = {"Comum", "Especial"}
    local startX = 115
    local spacing = 150

    for i, name in ipairs(tabNames) do
        local tab = display.newGroup()
        tabGroup:insert(tab)

        local bg = display.newImageRect(tab, "assets/7button/btn_tab_journey.png", 80 * 2, 48 * 1.7)
        bg.x, bg.y = startX + (i - 1) * spacing - 30, -128
        tab:insert(bg)

        local label = textile.new({
            label = tab,
            texto = " " .. labels[i] .. " ",
            x = bg.x,
            y = bg.y + 5,
            tamanho = 21,
            corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
            corContorno = {0, 0, 0},
            espessuraContorno = 2

        })
        tab:insert(label)

        tab.bg = bg -- Atribuir a referência ao campo `bg`

        -- Definir a função de toque
        function tab:tap()
            if selectedTab then
                selectedTab.bg.fill = {
                    type = "image",
                    filename = "assets/7button/btn_tab_journey.png"
                }
            end

            -- Alterar o fundo da aba clicada para o estado ativo
            bg.fill = {
                type = "image",
                filename = "assets/7button/btn_tab_journey_light.png"
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
            filename = "assets/7button/btn_tab_journey_light.png"
        }
    end
end

-- Criar a cena
function scene:create(event)
    local sceneGroup = self.view

    local background = display.newImageRect(sceneGroup, "assets/7bg/bg_tab_default.jpg", display.contentWidth,
        display.contentHeight * 1.44)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local bgDecoTop = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_1.png", 640, 128)
    bgDecoTop.x = display.contentCenterX
    bgDecoTop.y = -142

    local backBg = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_3.png", 128, 128)
    backBg.x = display.contentCenterX + 260
    backBg.y = -142

    local bgD3 = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_2.png", 640, 60)
    bgD3.x = display.contentCenterX
    bgD3.y = -50
    local bgD3s = display.newImageRect(sceneGroup, "assets/7bg/bg_deco_top_2_seperator.png", 54, 52)
    bgD3s.x = display.contentCenterX
    bgD3s.y = -54

    local energyBg = display.newImageRect(sceneGroup, "assets/7textbg/tbg_black_s9_m.png", 140 * 1.8, 20 * 1.8)
    energyBg.x = 150
    energyBg.y = -54

    local btnBack = display.newImageRect(sceneGroup, "assets/7button/btn_close.png", 96, 96)
    btnBack.x = display.contentCenterX + 270
    btnBack.y = -133

    local bg = display.newImageRect(sceneGroup, "assets/7button/btn_tab_journey.png", 80 * 2, 48 * 1.7)
    bg.x, bg.y = 385, -128
    bg.fill.effect = "filter.grayscale"
    local text = textile.new({
        group = sceneGroup,
        texto = "Herói",
        x = bg.x,
        y = bg.y + 5,
        tamanho = 21,
        corTexto = {0.6, 0.6, 0.6}, -- Amarelo {0.95, 0.86, 0.31}
        corContorno = {0, 0, 0},
        espessuraContorno = 2
    })

    -- 1) Dois helpers, lá em cima do seu arquivo (fora da scene)
    local function getTimeToNextCron()
        local now = os.date("*t")
        -- próxima “janela” de 6 em 6 minutos
        local nextInterval = math.floor(now.min / 6) + 1
        local nextMinuteMark = nextInterval * 6
        -- quantos minutos faltam
        local deltaMin = nextMinuteMark - now.min
        -- segundos restantes
        local secs = deltaMin * 60 - now.sec
        if secs < 0 then
            secs = 0
        end
        return secs
    end

    local function formatMMSS(secs)
        local m = math.floor(secs / 60)
        local s = secs % 60
        return string.format("%02d:%02d", m, s)
    end

    local energy = 0

    local energyBar = EnergyBar.new({
        group = sceneGroup,
        x = 157 + 10,
        y = -47,
        width = 195,
        height = 8,
        maxEnergy = 120
    })
    local energyText = textile.new({
        group = sceneGroup,
        texto = "0/120    00:00",
        x = 60 + 10,
        y = energyBar.y - 77,
        tamanho = 20,
        corTexto = {1, 1, 1},
        corContorno = {0, 0, 0},
        espessuraContorno = 2,
        anchorX = 0,
        anchorY = 0
    })

    local energyIcon = display.newImageRect(sceneGroup, "assets/7icon/icon_energy.png", 44, 44)
    energyIcon.x, energyIcon.y = energyText.x - 20, energyText.y + 21

    local function updateEnergy()
        getUsers.fetch(userId, serverId, function(record, err)
            if err then
                native.showAlert("Erro", err, {"OK"})
                return
            end
            energy = record.energy or energy
            energyBar:setEnergy(energy)
            -- já atualiza o texto imediato para refletir o novo valor
            -- no updateEnergy, depois de energy = record.energy…
            local secsLeft = (energy >= 120) and (6 * 60) or getTimeToNextCron()
            energyText:setText(string.format("%d/120      %s ", energy, formatMMSS(secsLeft)))

        end)
    end

    updateEnergy()

    timer.performWithDelay(1000, function()
        local secsLeft = (energy >= 120) and (6 * 60) or getTimeToNextCron()
        energyText:setText(string.format("%d/120      %s ", energy, formatMMSS(secsLeft)))
    end, 0)

    local initialDelay = getTimeToNextCron() * 1000
    timer.performWithDelay(initialDelay, function()
        -- faz o primeiro fetch logo que o cron rodar
        updateEnergy()
        -- e agenda fetch a cada 6 minutos eternamente
        timer.performWithDelay(6 * 60 * 1000, updateEnergy, 0)
    end)

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
    updateTabContent("decompose")
end

scene:addEventListener("create", scene)
return scene
