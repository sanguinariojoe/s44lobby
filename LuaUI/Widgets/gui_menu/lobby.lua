local Chili = WG.Chili

LobbyWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/lobby_login.lua")

--//=============================================================================

function SetTCPAllowConnect()
    -- First check if TCPAllowConnect is already set. In that case we are
    -- returning false, so the engine would knows the setting is correct and we
    -- can proceed
    val = Spring.GetConfigString("TCPAllowConnect")
    if val == "*" then
        return false
    end
    for token in string.gmatch(val, "[^%s]+") do
        if token == "springrts.com:8200" then
            return false
        end
    end

    Spring.SetConfigString("TCPAllowConnect", val .. " springrts.com:8200")
    return true
end

function LobbyWindow:New(obj)
    local reboot = SetTCPAllowConnect()
    if reboot then
        Spring.Echo("====================================================")
        Spring.Echo("")
        Spring.Log("Menu",
                   LOG.WARNING,
                   "Lobby needs to set TCPAllowConnect... Restarting...")
        Spring.Echo("")
        Spring.Echo("====================================================")
        Restart()
    end

    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = ":c:empty.png"

    obj = LobbyWindow.inherited.New(self, obj)

    -- Login window
    obj.log_win = LoginWindow:New {
        parent = WG.Chili.Screen0,
    }
    -- obj.log_win:Show()

    -- Create a back button
    local ok = Chili.Button:New {
        parent = obj,
        x = '0%',
        y = '95%',
        width = '100%',
        height = '5%',
        caption = "Back",
        backgroundColor = { 1, 1, 1, 1 },
        OnMouseUp = { Back },
    }
    obj.ok_button = ok

    -- Hiden by default
    obj:Hide()

    return obj
end 

function LobbyWindow:Show(visitor)
    self.visitor = visitor
    LobbyWindow.inherited.Show(self)
end
