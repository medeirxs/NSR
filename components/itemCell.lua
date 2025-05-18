-- components/itemCell.lua
local textile = require("utils.textile")

local itemCell = {}

function itemCell.new(params)
	local group = display.newGroup()

	local x = params.x or display.contentCenterX
	local y = params.y or display.contentCenterY
	local sprite = params.sprite or "assets/empty.png"
	local name = params.name or "Ite"
	local stars = params.stars or 5
	local search = params.search or false
	local extraParams = params.params

	-- fundo da célula
	local bgCell = display.newImageRect(group, "assets/7bg/bg_cell_brown_2.png", 584, 132)
	bgCell.x, bgCell.y = x, y

	-- tenta carregar a sprite; se falhar, usa placeholder
	local image
	local ok, result = pcall(function()
		return display.newImageRect(group, sprite, 104, 104)
	end)
	if ok and result then
		image = result
	else
		image = display.newImageRect(group, "assets/empty.png", 104, 104)
	end
	image.x, image.y = bgCell.x - 220, bgCell.y - 25

	-- barra colorida de acordo com stars
	local bgColor
	if stars == 2 then
		bgColor = { 0.5, 0.5, 0.5 }
	elseif stars == 4 then
		bgColor = { 0, 0, 1 }
	elseif stars == 5 then
		bgColor = { 0.5, 0, 0.5 }
	elseif stars == 6 then
		bgColor = { 0.992, 0.4627, 0.0 }
	else
		bgColor = { 1, 1, 1 }
	end
	local rect = display.newRoundedRect(group, image.x, image.y + 69, 105, 24, 20)
	rect:setFillColor(unpack(bgColor))

	-- texto de nível
	textile.new({
		group = group,
		texto = " Nv" .. 1 .. " ",
		x = image.x,
		y = image.y + 69,
		tamanho = 18,
		corTexto = { 1, 1, 1 },
		corContorno = { 0, 0, 0 },
		espessuraContorno = 2,
	})

	-- ícone e nome
	local cardType = display.newImageRect(group, "assets/7card/prof_balance.png", 104 / 2.5, 104 / 2.5)
	cardType.x, cardType.y = image.x + 85, y - 40

	textile.new({
		group = group,
		texto = name .. " ",
		x = cardType.x + 30,
		y = cardType.y,
		tamanho = 24,
		corTexto = { 1, 1, 1 },
		corContorno = { 0, 0, 0 },
		espessuraContorno = 2,
		anchorX = 0,
	})

	-- HP
	local hpIcon = display.newImageRect(group, "assets/7icon/icon_hp.png", 48, 48)
	hpIcon.x, hpIcon.y = cardType.x, cardType.y + 40
	textile.new({
		group = group,
		texto = 300 .. " ",
		x = hpIcon.x + 25,
		y = hpIcon.y + 1,
		tamanho = 24,
		corTexto = { 1, 1, 1 },
		corContorno = { 0, 0, 0 },
		espessuraContorno = 2,
		anchorX = 0,
	})

	-- ATK
	local atkIcon = display.newImageRect(group, "assets/7icon/icon_atk.png", 48, 48)
	atkIcon.x, atkIcon.y = cardType.x + 190, cardType.y + 40
	textile.new({
		group = group,
		texto = 300 .. " ",
		x = atkIcon.x + 25,
		y = atkIcon.y + 1,
		tamanho = 24,
		corTexto = { 1, 1, 1 },
		corContorno = { 0, 0, 0 },
		espessuraContorno = 2,
		anchorX = 0,
	})

	-- estrelas
	for i = 1, stars do
		local star = display.newImageRect(group, "assets/7misc/misc_star_on.png", 64, 64)
		star.x = cardType.x + (i - 1) * 35
		star.y = cardType.y + 75
	end

	-- ícones de status
	local lockIcon = display.newImageRect(group, "assets/7icon/icon_status_lock_gray.png", 34, 34)
	lockIcon.x, lockIcon.y = bgCell.x + 90, bgCell.y - 70
	local flagIcon = display.newImageRect(group, "assets/7icon/icon_status_inband_gray.png", 34, 34)
	flagIcon.x, flagIcon.y = lockIcon.x + 30, lockIcon.y
	local toolIcon = display.newImageRect(group, "assets/7icon/icon_status_weapon_gray.png", 34, 34)
	toolIcon.x, toolIcon.y = lockIcon.x + 60, lockIcon.y
	local mantleIcon = display.newImageRect(group, "assets/7icon/icon_status_armor_gray.png", 34, 34)
	mantleIcon.x, mantleIcon.y = lockIcon.x + 90, lockIcon.y
	local accessoryIcon = display.newImageRect(group, "assets/7icon/icon_status_necklace_gray.png", 34, 34)
	accessoryIcon.x, accessoryIcon.y = lockIcon.x + 120, lockIcon.y
	local mountIcon = display.newImageRect(group, "assets/7icon/icon_status_mount_gray.png", 34, 34)
	mountIcon.x, mountIcon.y = lockIcon.x + 150, lockIcon.y

	-- botão de busca
	if search then
		local btnAdd = display.newImageRect(group, "assets/7button/btn_search.png", 34 * 2.7, 34 * 2.7)
		btnAdd.x, btnAdd.y = bgCell.x + 235, bgCell.y
		group:insert(btnAdd)
	end

	return group
end

return itemCell
