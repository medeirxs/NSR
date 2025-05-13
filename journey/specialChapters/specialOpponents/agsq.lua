-- modules/opponents/localOpponent1.lua
local M = {}
M.userId = "opponent_001"
-------------------------------
-- Formação do Oponente 1 
-- (userId: "opponent_001")
-------------------------------
local formation1 = {}

formation1[1] = {
    card_id = 101,
    uuid = "opponent-101",
    atk = 99,
    def = 0.12,
    hp = 643,
    maxHp = 1993,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0.0051,
    card_image = {"assets/7sprites/choji3.png", "assets/7sprites/choji4.png", "assets/7sprites/choji5.png"},
    ab = "shuriken",
    sp = "giant_hand_attack",
    card_type = "def",
    name = "Oponente",
    index = 1,
    stars = 3,
    size = 1,
    isOpponent = true
} --

formation1[2] = nil

formation1[3] = {
    card_id = 101,
    uuid = "opponent-101",
    atk = 99,
    def = 0.12,
    hp = 643,
    maxHp = 1993,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0.0051,
    card_image = {"assets/7sprites/kankuro3.png", "assets/7sprites/kankuro4.png", "assets/7sprites/kakuro5.png"},
    ab = "shuriken",
    sp = "giant_hand_attack",
    card_type = "def",
    name = "Oponente",
    index = 3,
    stars = 3,
    size = 1,
    isOpponent = true
} --

formation1[4] = nil

formation1[5] = {
    card_id = 101,
    uuid = "opponent-101",
    atk = 1599,
    def = 5,
    hp = 345,
    maxHp = 345,
    vel = 1,
    eva = 0,
    prec = 0.009,
    armor = 1,
    cri = 0.0102,
    res = 0,
    card_image = {"assets/7sprites/lee3.png", "assets/7sprites/lee4.png", "assets/7sprites/lee5.png"},
    ab = "explosive_seal",
    sp = "fortune_tiger",
    card_type = "atk",
    name = "Oponente",
    index = 5,
    stars = 3,
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
    atk = 176,
    def = 0.12,
    hp = 667,
    maxHp = 2257,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0.0051,
    card_image = {"assets/7sprites/kankuro3.png", "assets/7sprites/kakuro4.png", "assets/7sprites/kankuro5.png"},
    ab = "shuriken",
    sp = "puppet",
    card_type = "def",
    name = "Oponente",
    index = 1,
    stars = 3,
    size = 1,
    isOpponent = true
} --

formation2[2] = nil

formation2[3] = {
    card_id = 103,
    uuid = "opponent-103",
    atk = 130,
    def = 0.12,
    hp = 667,
    maxHp = 2257,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0.0051,
    card_image = {"assets/7sprites/choji3.png", "assets/7sprites/choji4.png", "assets/7sprites/choji5.png"},
    ab = "shuriken",
    sp = "giant_hand_attack",
    card_type = "def",
    name = "Oponente Card 3",
    index = 3,
    stars = 3,
    size = 1,
    isOpponent = true
} --

formation2[4] = nil

formation2[5] = {
    card_id = 103,
    uuid = "opponent-103",
    atk = 1730,
    def = 5,
    hp = 447,
    maxHp = 485,
    vel = 1,
    eva = 0,
    prec = 0.009,
    armor = 1,
    cri = 0.0102,
    res = 0,
    card_image = {"assets/7sprites/kiba3.png", "assets/7sprites/kiba4.png", "assets/7sprites/kiba5.png"},
    ab = "kunai",
    sp = "prey_about_prey",
    card_type = "atk",
    name = "Oponente Card 3",
    index = 5,
    stars = 3,
    size = 1,
    isOpponent = true
}

formation2[6] = nil

for i, card in ipairs(formation2) do
    if card then
        card.cardData = card
    end
end

-------------------------------
-- Formação do Oponente 3 
-- (userId: "opponent_003")
-- Descrita completamente, similar às formações 1 e 2
-------------------------------
local formation3 = {}

formation3[1] = nil

formation3[2] = {
    card_id = 102,
    uuid = "opponent-102",
    atk = 741,
    def = 0.12,
    hp = 552,
    maxHp = 2902,
    vel = 1,
    eva = 0,
    prec = 0,
    armor = 1,
    cri = 0,
    res = 0.0051,
    card_image = {"assets/7sprites/choji3.png", "assets/7sprites/choji4.png", "assets/7sprites/choji5.png"},
    ab = "shuriken",
    sp = "giant_hand_attack",
    card_type = "def",
    isRevive = true,
    name = "Oponente Card 2",
    index = 2,
    stars = 3,
    size = 1.5,
    isOpponent = true
}

formation3[3] = nil

formation3[4] = {
    card_id = 102,
    uuid = "opponent-102",
    atk = 1871,
    def = 0.12,
    hp = 387,
    maxHp = 627,
    vel = 1,
    eva = 0,
    prec = 0.009,
    armor = 1,
    cri = 0.0102,
    res = 0.0051,
    card_image = {"assets/7sprites/naruto3.png", "assets/7sprites/naruto4.png", "assets/7sprites/naruto5.png"},
    ab = "fire_liberation",
    sp = "fire_sage_phoneix_technique",
    card_type = "atk",
    isRevive = true,
    name = "Oponente Card 2",
    index = 2,
    stars = 3,
    size = 1.5,
    isOpponent = true
}

formation3[5] = nil

formation3[6] = {
    card_id = 102,
    uuid = "opponent-102",
    atk = 1869,
    def = 0.12,
    hp = 552,
    maxHp = 623,
    vel = 1,
    eva = 0,
    prec = 0.009,
    armor = 1,
    cri = 0.0102,
    res = 0.0051,
    card_image = {"assets/7sprites/sasuke3.png", "assets/7sprites/sasuke4.png", "assets/7sprites/sasuke5.png.png"},
    ab = "fire_liberation",
    sp = "fire_sage_phoneix_technique",
    card_type = "atk",
    isRevive = true,
    name = "Oponente Card 2",
    index = 2,
    stars = 3,
    size = 1.5,
    isOpponent = true
}

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
