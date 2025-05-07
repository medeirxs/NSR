local M = {}

function M.show(params)
    local group = params.group or display.currentStage
    local x = params.x or display.contentCenterX
    local y = params.y or display.contentCenterY
    local width = params.width or 200
    local height = params.height or 200
    local time = params.time or 500

    -- Cria a nuvem começando no tamanho cheio e opaca
    local cloud = display.newImageRect(group, "assets/other/cloud.png", 2048, 1136)
    cloud.x, cloud.y = x, y
    cloud.xScale, cloud.yScale = 1.5, 1.5
    cloud.alpha = 1

    -- Anima fade out e scale down
    transition.to(cloud, {
        time = time,
        xScale = 2,
        yScale = 2,
        alpha = 0.2,
        onComplete = function()
            if params.onComplete then
                params.onComplete()
            end
            cloud:removeSelf()
        end
    })
end

return M
