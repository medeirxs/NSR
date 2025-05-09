<!-- Import userId and serverId -->

local userDataLib = require("lib.userData")
local data = userDataLib.load() or {}
local userId = tonumber(data.id) or 461752844
local serverId = tonumber(data.server) or 1

<!-- Import an image and text to scene -->

local image = display.newImageRect(group, "assets/7icon/icon_vip.png", 62, 30)
image.x, image.y = 0, 0 --display.contentWidth, display.contentHeight \* 1.44

local text = display.newText({
text = "Texto",
x = display.contentCenterX,
y = 50,
font = native.systemFontBold,
fontSize = 28
})
group:insert(text)

<!-- Create a text with black stroke -->

local textile = require("utils.textile")
local text = textile.new({
group = group,
texto = "Registrar ",
x = 0,
y = 0,
tamanho = 24,
corTexto = {1, 1, 1}, -- Amarelo {0.95, 0.86, 0.31}
corContorno = {0, 0, 0},
espessuraContorno = 2,
anchorX = 0,
anchorY = 0
})

<!-- Add Event Listener with Transition -->

btnDt:addEventListener("tap", function()
cloudOn.show({
time = 300
})
timer.performWithDelay(300, function()
composer.removeScene("interfaces.btnKaguya")
composer.gotoScene("interfaces.btnKaguya")
end)
timer.performWithDelay(300, function()
cloudOff.show({
group = display.getCurrentStage(),
time = 600
})
end)
end)
input:removeSelf()

<!-- Create a group view in scene -->

local bandViewGrouo = display.newGroup()
sceneGroup:insert(bandViewGrouo)

<!-- Create a scrollView for scene -->

local scrollView = widget.newScrollView({
top = -5, -- posição vertical do scroll view na tela
left = 0,
width = 640,
height = 1100, -- área visível; ajuste conforme necessário
scrollWidth = display.contentWidth,
scrollHeight = 1350, -- altura total do conteúdo (deve ser maior que 'height' para permitir scroll)
horizontalScrollDisabled = true,
hideBackground = true
})
group:insert(scrollView)

<!-- Create an empty component -->

local component = {}
function component.new(params)
local group = display.newGroup()

    local x = params.x
    local y = params.y
    local params = params.params

    return group

end
return component

<!-- Create an empty page -->

local composer = require("composer")
local widget = require("widget")

local scene = composer.newScene()

function scene:create(event)
local group = self.view

end

scene:addEventListener("create", scene)
return scene

<!-- Transitions -->

local cloudOn = require("utils.cloudOn")
local cloudOff = require("utils.cloudOff")

cloudOn.show({
time = 600
})

cloudOff.show({
time = 600
})
