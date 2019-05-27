function widget:GetInfo()
    return {
        name     = '1944 Flag Ranges',
        desc     = 'Phony widget to disable the original one without affecting real game options',
        author   = 'Jose Luis Cercos-Pita',
        date     = '2019-05-27',
        license  = 'GNU GPL v2',
        layer    = 5,
        enabled  = true,
    }
end


function widget:Initialize()
    widgetHandler:RemoveWidget()
end
