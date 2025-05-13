-- modules/opponents/localOpponent1.lua
local M = {}

M.userId = "opponent_001"

local formation1 = {}

formation1[1] = {
    card_id = 101,
    uuid = "opponent-101",
    atk = 6240,
    def = 0,
    hp = 23191,
    maxHp = 23191,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0,
    card_image = {"assets/7sprites/journey/food_ninja.png", "assets/7sprites/journey/food_ninja.png",
                  "assets/7sprites/journey/food_ninja.png"},
    ab = "fire_liberation",
    sp = "fire_sage_phoenix_technique",
    card_type = "bal",
    name = "Oponente",
    index = 1,
    stars = 5,
    size = 1,
    isOpponent = true
} --

formation1[2] = nil

formation1[3] = {
    card_id = 102,
    uuid = "opponent-102",
    atk = 6240,
    def = 0,
    hp = 23191,
    maxHp = 23191,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0,
    card_image = {"assets/7sprites/journey/food_ninja.png", "assets/7sprites/journey/food_ninja.png",
                  "assets/7sprites/journey/food_ninja.png"},
    ab = "fire_liberation",
    sp = "fire_sage_phoenix_technique",
    card_type = "bal",
    name = "Oponente",
    index = 1,
    stars = 5,
    size = 1,
    isOpponent = true
} --
formation1[4] = nil

formation1[5] = {
    card_id = 103,
    uuid = "opponent-103",
    atk = 6240,
    def = 0,
    hp = 23191,
    maxHp = 23191,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0,
    card_image = {"assets/7sprites/journey/food_ninja.png", "assets/7sprites/journey/food_ninja.png",
                  "assets/7sprites/journey/food_ninja.png"},
    ab = "fire_liberation",
    sp = "fire_sage_phoenix_technique",
    card_type = "bal",
    name = "Oponente",
    index = 1,
    stars = 5,
    size = 1,
    isOpponent = true
} --

formation1[6] = nil

for i, card in ipairs(formation1) do
    if card then
        card.cardData = card
    end
end

-------------------------------
-- Formação do Oponente 2 
-- (userId: "opponent_002")
-------------------------------
local formation2 = {}

formation2[1] = {
    card_id = 101,
    uuid = "opponent-101",
    atk = 6340,
    def = 0,
    hp = 23391,
    maxHp = 23391,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0,
    card_image = {"assets/7sprites/journey/food_ninja.png", "assets/7sprites/journey/food_ninja.png",
                  "assets/7sprites/journey/food_ninja.png"},
    ab = "fire_liberation",
    sp = "fire_sage_phoenix_technique",
    card_type = "bal",
    name = "Oponente",
    index = 1,
    stars = 5,
    size = 1,
    isOpponent = true
} --

formation2[2] = nil

formation2[3] = {
    card_id = 102,
    uuid = "opponent-102",
    atk = 6340,
    def = 0,
    hp = 23391,
    maxHp = 23391,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0,
    card_image = {"assets/7sprites/journey/food_ninja.png", "assets/7sprites/journey/food_ninja.png",
                  "assets/7sprites/journey/food_ninja.png"},
    ab = "fire_liberation",
    sp = "fire_sage_phoenix_technique",
    card_type = "bal",
    name = "Oponente",
    index = 1,
    stars = 5,
    size = 1,
    isOpponent = true
} --

formation2[4] = nil

formation2[5] = {
    card_id = 103,
    uuid = "opponent-103",
    atk = 6340,
    def = 0,
    hp = 23391,
    maxHp = 23391,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0,
    card_image = {"assets/7sprites/journey/food_ninja.png", "assets/7sprites/journey/food_ninja.png",
                  "assets/7sprites/journey/food_ninja.png"},
    ab = "fire_liberation",
    sp = "fire_sage_phoenix_technique",
    card_type = "bal",
    name = "Oponente",
    index = 1,
    stars = 5,
    size = 1,
    isOpponent = true
} --

formation2[6] = nil

for i, card in ipairs(formation2) do
    if card then
        card.cardData = card
    end
end

local formation3 = {}

formation3[1] = nil

formation3[2] = {
    card_id = 102,
    uuid = "opponent-102",
    atk = 6940,
    def = 0,
    hp = 24591,
    maxHp = 24591,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0,
    card_image = {"assets/7sprites/journey/food_ninja.png", "assets/7sprites/journey/food_ninja.png",
                  "assets/7sprites/journey/food_ninja.png"},
    ab = "fire_liberation",
    sp = "fire_sage_phoenix_technique",
    card_type = "bal",
    name = "Oponente",
    index = 1,
    stars = 5,
    size = 1.3,
    isOpponent = true
} --

formation3[3] = nil

formation3[4] = {
    card_id = 104,
    uuid = "opponent-104",
    atk = 6440,
    def = 0,
    hp = 23791,
    maxHp = 23791,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0,
    card_image = {"assets/7sprites/journey/food_ninja.png", "assets/7sprites/journey/food_ninja.png",
                  "assets/7sprites/journey/food_ninja.png"},
    ab = "fire_liberation",
    sp = "fire_sage_phoenix_technique",
    card_type = "bal",
    name = "Oponente",
    index = 1,
    stars = 5,
    size = 1,
    isOpponent = true
} --

formation3[5] = nil

formation3[6] = {
    card_id = 106,
    uuid = "opponent-106",
    atk = 6440,
    def = 0,
    hp = 23791,
    maxHp = 23791,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0,
    card_image = {"assets/7sprites/journey/food_ninja.png", "assets/7sprites/journey/food_ninja.png",
                  "assets/7sprites/journey/food_ninja.png"},
    ab = "fire_liberation",
    sp = "fire_sage_phoenix_technique",
    card_type = "bal",
    name = "Oponente",
    index = 1,
    stars = 5,
    size = 1,
    isOpponent = true
} --

for i, card in ipairs(formation3) do
    if card then
        card.cardData = card
    end
end

-------------------------------
-- Armazena as formações em uma tabela
-------------------------------
M.formations = {
    ["opponent_001"] = formation1,
    ["opponent_002"] = formation2,
    ["opponent_003"] = formation3
}

function M.fetchFormationData(userId, callback)
    if type(callback) ~= "function" then
        error("fetchFormationData: callback must be a function, got " .. type(callback))
    end
    timer.performWithDelay(1, function()
        local formation = M.formations[userId]
        if formation then
            -- Se for formação de oponente, atribua a _G.opponentFormationData
            if userId:find("opponent") then
                _G.opponentFormationData = formation
            end
            callback(formation, nil)
        else
            callback(nil, "Formation not found for userId " .. tostring(userId))
        end
    end)
end

return M
