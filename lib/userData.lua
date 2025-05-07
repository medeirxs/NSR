-- 📁 lib/userData.lua

local json = require("json")
local M = {}

local function getFilePath()
    return system.pathForFile("userData.json", system.DocumentsDirectory)
end

-- Salva a tabela `data` em JSON
function M.save(data)
    local path = getFilePath()
    local file = io.open(path, "w")
    if file then
        file:write(json.encode(data))
        io.close(file)
    else
        print("Erro ao abrir userData.json para escrita")
    end
end

-- Carrega e retorna a tabela do JSON, ou nil se não existir
function M.load()
    local path = getFilePath()
    local file = io.open(path, "r")
    if file then
        local contents = file:read("*a")
        io.close(file)
        return json.decode(contents)
    end
    return nil
end

-- Remove o arquivo `userData.json`
function M.clear()
    local path = getFilePath()
    os.remove(path)
end

return M
