function widget:GetInfo()
    return {
        name = "Chili based menu",
        desc = "Let's configure the game, and join games",
        author = "Jose Luis Cercos-Pita",
        date = "2019-05-22",
        license = "GPL v2",
        layer = 0,
        experimental = false,
        enabled = true,
    }
end 

local components = {
    "main.lua",
    "settings.lua",
    "postprocess.lua",
}

function widget:Initialize()
    if not WG.Chili then
        Spring.Log("Menu", "error", "Chili is not available!")
        widgetHandler:RemoveWidget()
        return
    end

    Chili = WG.Chili
    Screen0 = Chili.Screen0

    for _, file in ipairs(components) do
        VFS.Include("LuaUI/Widgets/gui_menu/" .. file, Chili, VFS.RAW_FIRST)
    end

    -- Setup the windows
    local postprocess = Chili.PostprocessWindow:New({
        parent = Screen0,
    })
    local settings = Chili.SettingsWindow:New({
        parent = Screen0,
    }, postprocess)
    local main = Chili.MainWindow:New({
        parent = Screen0,
    }, settings)
    -- Fire up main window
    main:Show()
end
