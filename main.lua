local composer = require("composer")
local userData = require("lib.userData")

display.setStatusBar(display.HiddenStatusBar)

native.setProperty("androidSystemUiVisibility", "immersiveSticky")
if (system.getInfo("platformName") == "Android") then
    local androidVersion = string.sub(system.getInfo("platformVersion"), 1, 3)
    if (androidVersion and tonumber(androidVersion) >= 4.4) then
        native.setProperty("androidSystemUiVisibility", "immersiveSticky")
    elseif (androidVersion) then
        native.setProperty("androidSystemUiVisibility", "lowProfile")
    end
end

local data = userData.load()

if data and data.id and data.server then
    -- composer.gotoScene("router.home", {
    composer.gotoScene("router.home", {
        --     effect = "fade",
        time = 1
    })
else
    composer.gotoScene("router.auth", {
        effect = "fade",
        time = 1
    })
end
