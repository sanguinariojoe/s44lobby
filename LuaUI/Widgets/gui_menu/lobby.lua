local Chili = WG.Chili

LobbyWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

lobby_win = nil

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/lobby/login.lua")
VFS.Include("LuaUI/Widgets/gui_menu/lobby/vcode.lua")
VFS.Include("LuaUI/Widgets/gui_menu/lobby/battles_list.lua")
VFS.Include("LuaUI/Widgets/gui_menu/lobby/chats.lua")
VFS.Include("LuaUI/Widgets/gui_menu/lobby/battle_room.lua")
VFS.Include("LuaUI/Widgets/gui_menu/dialogs/error.lua")

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

    obj.classname = "LobbyWindow"
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = ":cl:empty.png"

    obj = LobbyWindow.inherited.New(self, obj)

    -- Login windows
    obj.log_win = LoginWindow:New {
        parent = obj,
    }
    obj.log_win:Hide()
    obj.vcode_win = VerificationCodeWindow:New(
        {parent = obj},
        obj.log_win)
    obj.vcode_win:Hide()

    -- Main tab panel
    tabs_win = Chili.Window:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '95%',
        resizable = false,
        draggable = false,
    }
    obj.tabs = Chili.TabPanel:New {
        parent = tabs_win,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        padding = {5, 5, 5, 5},
        tabs = {
            {name="Battle list", children={BattlesWindow:New({})}},
            {name="Chat", children={ChatsWindow:New({})}},
            {name="Battle room", children={BattleRoomWindow:New({})}},
        },
    }

    -- Connection status label
    obj.status_label = Chili.Button:New {
        parent = obj,
        x = '90%',
        y = '95%',
        width = '10%',
        height = '5%',        
        caption = "offline",
        OnClick = { OnStatus },
    }
    obj.status_label.font.color = {1, 0.2, 0.2, 1}

    -- Back button
    local ok = Chili.Button:New {
        parent = obj,
        x = '0%',
        y = '95%',
        width = '90%',
        height = '5%',
        caption = "Back",
        backgroundColor = { 1, 1, 1, 1 },
        OnClick = { Back },
    }
    obj.ok_button = ok

    -- Hiden by default
    obj:Hide()    

    -- Start the connection process
    lobby_win = obj
    local lobby = WG.LibLobby.lobby
    local first_connect = true
    lobby:AddListener("OnAccepted",
        function(listener)
            lobby_win.status_label.caption = "online"
            lobby_win.status_label.font.color = {0.3, 0.4, 0.1, 1}
            lobby_win.log_win:Hide()
        end
    )
    lobby:AddListener("OnDenied",
        function(listener, reason)
            lobby_win.status_label.caption = "denied"
            lobby_win.status_label.font.color = {1, 0.2, 0.2, 1}
            ErrorWindow:New({caption = "Login failed... " .. reason})
        end
    )
    lobby:AddListener("OnConnect",
        function(listener)
            Spring.Echo("OnConnect")
            if lobby_win.status_label.caption ~= "connecting" then
                return
            end
            lobby_win.status_label.caption = "connected"
            lobby_win.status_label.font.color = {1, 1, 0.6, 1}
            -- Try to login with the already known user and password
            local log_win = lobby_win.log_win
            if first_connect then
                if log_win.user.text ~= "" and log_win.pass.text ~= "" then
                    lobby:Login(log_win.user.text, log_win.pass.text,
                                3, nil, "Spring:1944")
                else
                    log_win.tabs:ChangeTab("Register")
                    log_win:Show()
                end
            else
                log_win:Show()
            end
            first_connect = false
        end
    )
    lobby:AddListener("OnDisconnected",
        function(listener, reason, intentional)
            if not intentional then
                local txt = reason or ""
                ErrorWindow:New({caption = "Disconnected... " .. txt})
            end
            lobby_win.status_label.caption = "offline"
            lobby_win.status_label.font.color = {1, 0.2, 0.2, 1}
            lobby_win.log_win:Hide()
        end
    )
    lobby:AddListener("OnRegistrationAccepted",
        function(listener)
            lobby_win.status_label.caption = "registered"
            lobby_win.status_label.font.color = {1, 1, 0.6, 1}
            lobby_win.log_win:Hide()
        end
    )
    lobby:AddListener("OnRegistrationDenied",
        function(listener, reason)
            ErrorWindow:New({caption = "Registration failed... " .. reason})
            lobby_win.status_label.caption = "denied"
            lobby_win.status_label.font.color = {1, 0.2, 0.2, 1}
            lobby_win.log_win.tabs:ChangeTab("Register")
            lobby_win.log_win:Show()
        end
    )
    lobby:AddListener("OnAgreement", 
        function(listener)
            lobby_win.status_label.caption = "loading"
            lobby_win.status_label.font.color = {1, 1, 0.6, 1}
        end
    )
    lobby:AddListener("OnAgreementEnd", 
        function(listener)
            lobby_win.status_label.caption = "sign terms"
            lobby_win.status_label.font.color = {1, 1, 0.6, 1}
        end
    )
    lobby:AddListener("OnJoinBattleFailed",
        function(listener, reason)
            ErrorWindow:New({caption = "Fail joining battle... " .. reason})
        end
    )
    lobby:AddListener("OnBattleAboutToStart",
        function(listener, battleType)
            -- Let know the game it was launched by the lobby
            WG.LOBBY2GAME.launched_by_lobby = true
        end
    )

    return obj
end 

function LobbyWindow:Show(visitor)
    self.visitor = visitor
    LobbyWindow.inherited.Show(self)
    -- Start connection if required
    if self.status_label.caption == "offline" then
        OnStatus(self.status_label)
    end
end

function OnStatus(self)
    local lobby = WG.LibLobby.lobby
    local win = self.parent
    if self.caption == "offline" then
        -- The connection failed, so we retry
        self.caption = "connecting"
        self.font.color = {1, 1, 0.6, 1}
        lobby:Connect("springrts.com", "8200")
        return
    end
    -- The user specifically wants to disconnect
    lobby:Disconnect()
    win.log_win:Hide()
    win.vcode_win:Hide()
end
