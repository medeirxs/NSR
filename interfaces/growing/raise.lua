-- interfaces/growing/raise.lua
local composer = require("composer")
local Card = require("components.card")
local userDataLib = require("lib.userData")
local supa = require("config.supabase")
local json = require("json")
local network = require("network")
local widget = require("widget")

local scene = composer.newScene()

-- máximo de stars permitidos
local MAX_STARS = 11

-- requisitos de items para evoluir cada star
local starRequirements = {
    [2] = {"fa6a4997-cc7e-4a9e-a977-f08ea4f7ae82", "4a66104b-d370-4582-a583-39750e223e6f",
           "02ea015b-e52c-4a60-89d6-b081048135c1"},
    [3] = {"f76b1b27-6eda-4e0f-b8f5-889d4444a892", "c9938580-3ad2-42c4-b526-3e92f9362367",
           "7b5c85fe-c11d-4e6d-8765-94dc39850e85"},
    [4] = {"2b70ab29-4c4d-4efa-9903-2207fb16a82c", "8bf99e1b-c655-47e4-8b3f-5ef778c995b7",
           "17603f91-cabc-4d09-8430-1b189066e8a6", "3c2b103f-2b41-4347-8ea2-cf79aeef220b",
           "88554fbd-ea57-4909-9c67-b370c6d7fb89"},
    [7] = {"83749125-dd27-4c01-93e2-49ae2b5de364"}

}

local starLevelCap = {
    [2] = 20,
    [3] = 30,
    [4] = 40,
    [5] = 60,
    [6] = 70,
    [7] = 80,
    [8] = 100,
    [9] = 110,
    [10] = 120
}

function scene:create(event)
    local sceneGroup = self.view

    -- background
    display.newRect(sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth,
        display.contentHeight):setFillColor(0.1)

    -- title
    display.newText({
        parent = sceneGroup,
        text = "Tela de Raise",
        x = display.contentCenterX,
        y = 60,
        font = native.systemFontBold,
        fontSize = 24
    }):setFillColor(1)

    -- load userId
    local data = userDataLib.load() or {}
    local userId = tonumber(data.id) or 0
    self.userId = userId

    -- btn Select Character
    local btnSelect = display.newText({
        parent = sceneGroup,
        text = "Escolher Personagem",
        x = display.contentCenterX,
        y = display.contentHeight - 50,
        font = native.systemFont,
        fontSize = 20
    })
    btnSelect:setFillColor(0.2, 0.6, 1)
    btnSelect:addEventListener("tap", function()
        composer.gotoScene("interfaces.growing.raiseSelect", {
            effect = "slideLeft",
            time = 300,
            params = {
                userId = self.userId
            }
        })
    end)

    -- display selected character id
    self.charText = display.newText({
        parent = sceneGroup,
        text = "Personagem: —",
        x = display.contentCenterX,
        y = 120,
        font = native.systemFont,
        fontSize = 18
    })
    self.charText:setFillColor(1)

    -- groups for card and stars
    self.cardGroup = display.newGroup()
    self.starsGroup = display.newGroup()
    sceneGroup:insert(self.cardGroup)
    sceneGroup:insert(self.starsGroup)
end

function scene:show(event)
    if event.phase ~= "did" then
        return
    end

    local recordId = _G.chaId
    if not recordId then
        return
    end

    -- update charText
    self.charText.text = "Personagem ID: " .. tostring(recordId)

    -- clear previous
    self.cardGroup:removeSelf()
    self.cardGroup = display.newGroup()
    self.starsGroup:removeSelf()
    self.starsGroup = display.newGroup()
    self.view:insert(self.cardGroup)
    self.view:insert(self.starsGroup)

    -- headers
    local headers = {
        ["Content-Type"] = "application/json",
        ["apikey"] = supa.SUPABASE_ANON_KEY,
        ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
    }

    -- fetch characterId and stars
    local url = string.format("%s/rest/v1/user_characters?select=characterId,stars&limit=1&id=eq.%s", supa.SUPABASE_URL,
        recordId)
    network.request(url, "GET", function(evt)
        if evt.isError then
            print("Erro ao buscar character:", evt.response)
            return
        end
        local d = json.decode(evt.response)[1]
        if not d then
            return
        end

        -- show card
        local card = Card.new({
            x = display.contentCenterX,
            y = display.contentCenterY + 40,
            characterId = d.characterId,
            scaleFactor = 1,
            stars = d.stars
        })
        self.cardGroup:insert(card)

        -- display stars
        local spacing = 40
        local yStars = display.contentCenterY + 160
        for i = 1, MAX_STARS do
            local img = (i <= d.stars) and "assets/7misc/misc_star_on.png" or "assets/7misc/misc_star_off.png"
            local star = display.newImageRect(self.starsGroup, img, 32, 32)
            star.x = display.contentCenterX + (i - (MAX_STARS + 1) / 2) * spacing
            star.y = yStars
        end

        -- raise button
        local btnRaise = display.newText({
            parent = self.starsGroup,
            text = "↑ Star",
            x = display.contentCenterX,
            y = yStars + 50,
            font = native.systemFontBold,
            fontSize = 18
        })
        btnRaise:setFillColor(0.8, 0.2, 0)
        if d.stars >= MAX_STARS then
            btnRaise.alpha = 0.5
        end

        -- raise handler
        local function onRaiseTap()
            -- 1) Verifica seleção
            if not _G.chaId then
                native.showAlert("Aviso", "Selecione um personagem primeiro", {"OK"})
                return
            end
            local recordId = _G.chaId

            -- cabeçalhos Supabase
            local headers = {
                ["Content-Type"] = "application/json",
                ["apikey"] = supa.SUPABASE_ANON_KEY,
                ["Authorization"] = "Bearer " .. supa.SUPABASE_ANON_KEY
            }

            -- 2) Busca characterId e stars atuais
            local getCharUrl = string.format(
                "%s/rest/v1/user_characters?select=characterId,stars,level&limit=1&id=eq.%s", supa.SUPABASE_URL,
                recordId)
            network.request(getCharUrl, "GET", function(evt)
                if evt.isError then
                    native.showAlert("Erro", "Não foi possível ler personagem", {"OK"})
                    return
                end
                local d = json.decode(evt.response)[1]
                if not d then
                    native.showAlert("Erro", "Personagem não encontrado", {"OK"})
                    return
                end

                local currentStars = d.stars or 0
                local currentLevel = d.level or 0
                local charUuid = d.characterId

                local requiredLevel = starLevelCap[currentStars]
                if requiredLevel and currentLevel < requiredLevel then
                    native.showAlert("Aviso", "Para evoluir de " .. currentStars .. "→" .. (currentStars + 1) ..
                        " stars, o personagem deve estar pelo menos no nível " .. requiredLevel, {"OK"})
                    return
                end

                -- CASE 1: Stars 2→3, 3→4, 4→5 via itens
                if currentStars >= 2 and currentStars < 8 then
                    local req = starRequirements[currentStars]
                    -- 3) Busca inventário do usuário
                    local fetchItemsUrl = string.format("%s/rest/v1/user_items?userId=eq.%s&select=itemId,quantity,id",
                        supa.SUPABASE_URL, scene.userId)
                    network.request(fetchItemsUrl, "GET", function(fe)
                        if fe.isError then
                            native.showAlert("Erro", "Não foi possível ler inventário", {"OK"})
                            return
                        end
                        local allItems = json.decode(fe.response) or {}
                        local map = {}
                        for _, r in ipairs(allItems) do
                            map[r.itemId] = r
                        end

                        -- 4) Verifica requisitos
                        for _, needed in ipairs(req) do
                            local rec = map[needed]
                            if not rec or rec.quantity < 1 then
                                native.showAlert("Aviso", "Faltam itens para evoluir stars", {"OK"})
                                return
                            end
                        end

                        -- 5) Consome itens
                        local pending = #req
                        for _, needed in ipairs(req) do
                            local rec = map[needed]
                            network.request(string.format("%s/rest/v1/user_items?id=eq.%s", supa.SUPABASE_URL, rec.id),
                                "PATCH", function(pi)
                                    pending = pending - 1
                                    if pending == 0 then
                                        -- 6) Evolui stars
                                        network.request(string.format("%s/rest/v1/user_characters?id=eq.%s",
                                            supa.SUPABASE_URL, recordId), "PATCH", function(pc)
                                            if pc.isError then
                                                native.showAlert("Erro", "Falha ao evoluir stars", {"OK"})
                                                return
                                            end
                                            native.showAlert("Sucesso", "Stars evoluídas!", {"OK"})
                                            composer.reloadScene()
                                        end, {
                                            headers = headers,
                                            body = json.encode({
                                                stars = currentStars + 1
                                            })
                                        })
                                    end
                                end, {
                                    headers = headers,
                                    body = json.encode({
                                        quantity = rec.quantity - 1
                                    })
                                })
                        end
                    end, {
                        headers = headers
                    })

                    -- CASE 2: Stars 5→6 via consumo de 1 personagem stars=5
                elseif currentStars == 5 then
                    local fetchUrl = string.format(
                        "%s/rest/v1/user_characters?select=id&characterId=eq.%s&stars=eq.5&id=neq.%s",
                        supa.SUPABASE_URL, charUuid, recordId)
                    network.request(fetchUrl, "GET", function(fe)
                        if fe.isError then
                            native.showAlert("Erro", "Não foi possível ler personagens", {"OK"})
                            return
                        end
                        local recs = json.decode(fe.response) or {}
                        if #recs < 1 then
                            native.showAlert("Aviso", "Você precisa de mais 1 personagem Stars 5", {"OK"})
                            return
                        end
                        -- 4) Deleta 1 personagem
                        local otherId = recs[1].id
                        network.request(
                            string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL, otherId), "DELETE",
                            function(pd)
                                if pd.isError then
                                    native.showAlert("Erro", "Falha ao consumir personagem", {"OK"})
                                    return
                                end
                                -- 5) Evolui o selecionado
                                network.request(string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL,
                                    recordId), "PATCH", function(pp)
                                    if pp.isError then
                                        native.showAlert("Erro", "Falha ao evoluir stars", {"OK"})
                                        return
                                    end
                                    native.showAlert("Sucesso", "Stars evoluídas para 6!", {"OK"})
                                    composer.reloadScene()
                                end, {
                                    headers = headers,
                                    body = json.encode({
                                        stars = 6
                                    })
                                })
                            end, {
                                headers = headers
                            })
                    end, {
                        headers = headers
                    })

                    -- CASE 3: Stars 6→7 via consumo de 2 personagens stars=5
                elseif currentStars == 6 then
                    local fetchUrl = string.format(
                        "%s/rest/v1/user_characters?select=id&characterId=eq.%s&stars=eq.5&id=neq.%s",
                        supa.SUPABASE_URL, charUuid, recordId)
                    network.request(fetchUrl, "GET", function(fe)
                        if fe.isError then
                            native.showAlert("Erro", "Não foi possível ler personagens", {"OK"})
                            return
                        end
                        local recs = json.decode(fe.response) or {}
                        if #recs < 2 then
                            native.showAlert("Aviso", "Você precisa de 2 personagens Stars 5", {"OK"})
                            return
                        end
                        -- 4) Deleta os dois primeiros
                        local deleted = 0
                        for i = 1, 2 do
                            local otherId = recs[i].id
                            network.request(string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL,
                                otherId), "DELETE", function(pd)
                                deleted = deleted + 1
                                if deleted == 2 then
                                    -- 5) Evolui o selecionado
                                    network.request(string.format("%s/rest/v1/user_characters?id=eq.%s",
                                        supa.SUPABASE_URL, recordId), "PATCH", function(pp)
                                        if pp.isError then
                                            native.showAlert("Erro", "Falha ao evoluir stars", {"OK"})
                                            return
                                        end
                                        native.showAlert("Sucesso", "Stars evoluídas para 7!", {"OK"})
                                        composer.reloadScene()
                                    end, {
                                        headers = headers,
                                        body = json.encode({
                                            stars = 7
                                        })
                                    })
                                end
                            end, {
                                headers = headers
                            })
                        end
                    end, {
                        headers = headers
                    })
                    -- Stars 8→9: consome 1 outro personagem stars=8
                elseif currentStars == 8 then
                    local fetchUrl = string.format(
                        "%s/rest/v1/user_characters?select=id&characterId=eq.%s&stars=eq.8&id=neq.%s",
                        supa.SUPABASE_URL, charUuid, recordId)
                    network.request(fetchUrl, "GET", function(fe)
                        local recs = json.decode(fe.response) or {}
                        if #recs < 1 then
                            native.showAlert("Aviso", "Precisa de 1 personagem Stars 8", {"OK"})
                            return
                        end
                        local otherId = recs[1].id
                        network.request(
                            string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL, otherId), "DELETE",
                            function(pd)
                                if pd.isError then
                                    return
                                end
                                -- evolui para 9
                                network.request(string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL,
                                    recordId), "PATCH", function(pp)
                                    composer.reloadScene()
                                end, {
                                    headers = headers,
                                    body = json.encode({
                                        stars = 9
                                    })
                                })
                            end, {
                                headers = headers
                            })
                    end, {
                        headers = headers
                    })

                    -- Stars 9→10: consome 2 personagens stars=8
                elseif currentStars == 9 then
                    local fetchUrl = string.format(
                        "%s/rest/v1/user_characters?select=id&characterId=eq.%s&stars=eq.8&id=neq.%s",
                        supa.SUPABASE_URL, charUuid, recordId)
                    network.request(fetchUrl, "GET", function(fe)
                        local recs = json.decode(fe.response) or {}
                        if #recs < 2 then
                            native.showAlert("Aviso", "Precisa de 2 personagens Stars 8", {"OK"})
                            return
                        end
                        local toDelete = {recs[1].id, recs[2].id}
                        local done = 0
                        for _, otherId in ipairs(toDelete) do
                            network.request(string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL,
                                otherId), "DELETE", function(pd)
                                done = done + 1
                                if done == 2 then
                                    network.request(string.format("%s/rest/v1/user_characters?id=eq.%s",
                                        supa.SUPABASE_URL, recordId), "PATCH", function(pp)
                                        composer.reloadScene()
                                    end, {
                                        headers = headers,
                                        body = json.encode({
                                            stars = 10
                                        })
                                    })
                                end
                            end, {
                                headers = headers
                            })
                        end
                    end, {
                        headers = headers
                    })

                    -- Stars 10→11: consome 1 personagem stars=9
                elseif currentStars == 10 then
                    local fetchUrl = string.format(
                        "%s/rest/v1/user_characters?select=id&characterId=eq.%s&stars=eq.9&id=neq.%s",
                        supa.SUPABASE_URL, charUuid, recordId)
                    network.request(fetchUrl, "GET", function(fe)
                        local recs = json.decode(fe.response) or {}
                        if #recs < 1 then
                            native.showAlert("Aviso", "Precisa de 1 personagem Stars 9", {"OK"})
                            return
                        end
                        local otherId = recs[1].id
                        network.request(
                            string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL, otherId), "DELETE",
                            function(pd)
                                if pd.isError then
                                    return
                                end
                                network.request(string.format("%s/rest/v1/user_characters?id=eq.%s", supa.SUPABASE_URL,
                                    recordId), "PATCH", function(pp)
                                    composer.reloadScene()
                                end, {
                                    headers = headers,
                                    body = json.encode({
                                        stars = 11
                                    })
                                })
                            end, {
                                headers = headers
                            })
                    end, {
                        headers = headers
                    })

                else
                    native.showAlert("Aviso", "Evolução de Stars " .. currentStars .. " não implementada", {"OK"})
                end
            end, {
                headers = headers
            })
        end

        btnRaise:addEventListener("tap", onRaiseTap)
    end, {
        headers = headers
    })
end

scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
return scene
