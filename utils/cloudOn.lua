local M = {}

function M.show(params)
    local group = params.group or display.currentStage
    local x = params.x or display.contentCenterX
    local y = params.y or display.contentCenterY
    local width = params.width or 200
    local height = params.height or 200
    local time = params.time or 500

    -- Cria a nuvem começando pequena e invisível
    local cloud = display.newImageRect(group, "assets/other/cloud.png", 2048, 1136)
    cloud.x, cloud.y = x, y
    cloud.xScale, cloud.yScale = 0.5, 0.5
    cloud.alpha = 0

    -- Anima fade in e scale up
    transition.to(cloud, {
        time = time,
        xScale = 1.5,
        yScale = 1.5,
        alpha = 1,
        onComplete = function()
            if params.onComplete then
                params.onComplete()
            end
            -- Remove a nuvem após a animação
            cloud:removeSelf()
        end
    })
end

return M
