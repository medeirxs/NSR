local component = {}
function component.new(params)
    local group = display.newGroup()

    local x = params.x
    local y = params.y
    local params = params.params

    return group

end
return component
