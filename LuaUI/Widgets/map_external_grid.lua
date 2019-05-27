function widget:GetInfo()
    return {
        name     = 'External VR Grid',
        desc     = 'Phony widget to disable the original one without affecting real game options',
        author   = 'Jose Luis Cercos-Pita',
        date     = '2019-05-27',
        license  = 'GNU GPL v2',
        layer    = -3,
        enabled  = true,
    }
end


function widget:Initialize()
    widgetHandler:RemoveWidget()
end
