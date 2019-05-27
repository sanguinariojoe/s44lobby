function widget:GetInfo()
    return {
        name     = 'notAchili Framework',
        desc     = 'Phony widget to disable the original one without affecting real game options',
        author   = 'Jose Luis Cercos-Pita',
        date     = '2019-05-27',
        license  = 'GNU GPL v2',
        layer    = -math.huge,
        enabled  = false,
    }
end


function widget:Initialize()
    widgetHandler:RemoveWidget()
end
