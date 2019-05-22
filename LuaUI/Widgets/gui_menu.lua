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


function widget:Initialize()
    if not WG.Chili then
        Spring.Log("Menu", "error", "Chili is not available!")
        widgetHandler:RemoveWidget()
        return
    end

    Chili = WG.Chili
    Screen0 = Chili.Screen0

    local main_win = VFS.Include("LuaUI/Widgets/gui_menu/main.lua")
    main_win:setup(Chili, Screen0)
    main_win:show()
end
