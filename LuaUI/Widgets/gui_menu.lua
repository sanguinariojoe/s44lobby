function widget:GetInfo()
    return {
        name = "Chili based menu",
        desc = "You can use this menu to both play the game, and tweak settings",
        author = "Jose Luis Cercos-Pita",
        date = "2020-05-22",
        license = "GPL v2",
        layer = 0,
        experimental = false,
        enabled = true,
    }
end 

local components = {
    "background.lua",
    "lobby.lua",
    "main.lua",
    "settings.lua",
    "postprocess.lua",
    "wiki.lua",
}

WG.MENUOPTS = {
    login_tab = "Register",
    login_user = "",
    login_pass = "",
    script_password = "",
    channels = {{name="s44", key=nil, lastID=nil, persistent=true,},
                {name="s44games", key=nil, lastID=nil, persistent=true,},},
    wiki_unit = "gerpanzeriii",
    games = {"Spring: 1944."},
    show_all_games = false,
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

    local postprocess = nil
    local wiki = nil
    if LUA_NAME ~= "LuaMenu" then
        -- Components just available in LuaUI, not in LuaMenu
        postprocess = Chili.PostprocessWindow:New({
            parent = Screen0,
        })
        wiki = Chili.UnitsTreeWindow:New({
            parent = Screen0,
        })
    else
        -- The fixed background for LuaMenu
        local background = Chili.BackgroundControl:New({
            parent = Screen0,
        })
    end
    -- Setup everything
    local lobby = Chili.LobbyWindow:New({
        parent = Screen0,
    })
    local settings = Chili.SettingsWindow:New({
        parent = Screen0,
    }, postprocess)
    local main = Chili.MainWindow:New({
        parent = Screen0,
    }, lobby, settings, wiki)
    -- Fire up main window
    main:Show()

    if LUA_NAME ~= "LuaMenu" then
        widgetHandler:AddAction("s44esckey", Chili.ExecuteEscAction)
        Spring.SendCommands({"unbindkeyset esc"})
        Spring.SendCommands("bind esc s44esckey")
    end
end

function widget:GetConfigData()
    return {
        login_tab       = WG.MENUOPTS.login_tab,
        login_user      = WG.MENUOPTS.login_user,
        login_pass      = WG.MENUOPTS.login_pass,
        script_password = WG.MENUOPTS.script_password,
        channels        = WG.MENUOPTS.channels,
        wiki_unit       = WG.MENUOPTS.wiki_unit,
        games           = WG.MENUOPTS.games,
        show_all_games  = WG.MENUOPTS.show_all_games
    }
end

function widget:SetConfigData(data)
    WG.MENUOPTS.login_tab       = data.login_tab or WG.MENUOPTS.login_tab
    WG.MENUOPTS.login_user      = data.login_user or WG.MENUOPTS.login_user
    WG.MENUOPTS.login_pass      = data.login_pass or WG.MENUOPTS.login_pass
    WG.MENUOPTS.script_password = data.script_password or WG.MENUOPTS.script_password
    WG.MENUOPTS.channels        = data.channels or WG.MENUOPTS.channels
    WG.MENUOPTS.wiki_unit       = data.wiki_unit or WG.MENUOPTS.wiki_unit
    WG.MENUOPTS.games           = data.games or WG.MENUOPTS.games
    WG.MENUOPTS.show_all_games  = data.show_all_games or WG.MENUOPTS.show_all_games
end

function widget:Shutdown()
    if LUA_NAME ~= "LuaMenu" then
        widgetHandler:RemoveAction("s44esckey")
        Spring.SendCommands("unbind esc s44esckey")
    end
end
