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
    "lobby.lua",
    "main.lua",
    "settings.lua",
    "postprocess.lua",
    "wiki.lua",
}

function widget:Initialize()
    if not WG.Chili then
        Spring.Log("Menu", "error", "Chili is not available!")
        widgetHandler:RemoveWidget()
        return
    end
    if not WG.LibLobby then
        Spring.Log("Menu", "error", "LibLobby is not available!")
        widgetHandler:RemoveWidget(widget)
        return
    end

    Chili = WG.Chili
    Screen0 = Chili.Screen0

    for _, file in ipairs(components) do
        VFS.Include("LuaUI/Widgets/gui_menu/" .. file, Chili, VFS.RAW_FIRST)
    end

    -- Setup the windows
    local lobby = Chili.LobbyWindow:New({
        parent = Screen0,
    })
    local postprocess = Chili.PostprocessWindow:New({
        parent = Screen0,
    })
    local settings = Chili.SettingsWindow:New({
        parent = Screen0,
    }, postprocess)
    local wiki = Chili.UnitsTreeWindow:New({
        parent = Screen0,
    })
    local main = Chili.MainWindow:New({
        parent = Screen0,
    }, lobby, settings, wiki)
    -- Fire up main window
    main:Show()
end
