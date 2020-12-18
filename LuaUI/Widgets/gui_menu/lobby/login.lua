local Chili = WG.Chili

LoginWindow = Chili.Control:Inherit{
    drawcontrolv2 = true
}

log_win = nil

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

--//=============================================================================

function Cancel(self)
    local win = self.win
    win:Hide()
end

function Login(self)
    local win = self.win
    -- Store the new user and password
    WG.MENUOPTS.login_user = win.user.text
    WG.MENUOPTS.login_pass = win.pass.text
    -- Connect to the lobby
    win:Hide()

    local lobby = WG.LibLobby.lobby
    lobby:AddListener("OnDenied",
        function(listener, reason)
            Spring.Log("Menu", LOG.WARNING, reason)
            lobby:RemoveListener("OnDenied", listener)
            win:Show()
        end
    )
    lobby:Login(win.user.text, win.pass.text,
                3, nil, "Spring:1944")
end

function Register(self)
    local win = self.win
    win:Hide()
    WG.LibLobby.lobby:Register(win.new_user.text,
                               win.new_pass.text,
                               win.new_email.text)
end

function LoginWindow:New(obj)
    local x = obj.x or '30%'
    local y = obj.y or '30%'
    local w = obj.width or '40%'

    obj.x = 0
    obj.y = 0
    obj.right = 0
    obj.bottom = 0
    obj.padding = {0,0,0,0}
    obj.margin = {0,0,0,0}

    obj = LoginWindow.inherited.New(self, obj)

    -- Create a large button to hijack the clicks of all windows behind
    local clickhijack = Chili.Button:New {
        x = "0%",
        y = "0%",
        width = "100%",
        height = "100%",
        caption = "",
        TileImageBK = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        TileImageFG = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        parent = obj,
    }

    local win = Chili.Window:New {
        x = x,
        y = y,
        width = w,
        resizable = false,
        draggable = false,
        parent = obj,
    }

    -- Login fields
    -- ============
    local log_grid = Chili.Grid:New {
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        rows = 3,
        columns = 2,
    }

    obj.user_label = Chili.Label:New {
        parent = log_grid,
        caption = "User ",
        align   = "center",
        valign  = "center",
    }
    obj.user = Chili.EditBox:New {
        parent = log_grid,
        text = WG.MENUOPTS.login_user,
    }
    obj.pass_label = Chili.Label:New {
        parent = log_grid,
        caption = "Password ",
        align   = "center",
        valign  = "center",
    }
    obj.pass = Chili.EditBox:New {
        parent = log_grid,
        passwordInput = true,
        text = WG.MENUOPTS.login_pass,
    }

    obj.log_cancel = Chili.Button:New {
        parent = log_grid,
        caption = "Cancel",
        OnMouseUp = { Cancel },
    }
    obj.log_ok = Chili.Button:New {
        parent = log_grid,
        caption = "Ok",
        OnMouseUp = { Login },
    }

    -- Registering fields
    -- ==================
    local reg_grid = Chili.Grid:New {
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        rows = 4,
        columns = 2,        
    }

    obj.new_user_label = Chili.Label:New {
        parent = reg_grid,
        caption = "User ",
        align   = "center",
        valign  = "center",
    }
    obj.new_user = Chili.EditBox:New {
        parent = reg_grid,
        text = WG.MENUOPTS.login_user,
    }
    obj.new_pass_label = Chili.Label:New {
        parent = reg_grid,
        caption = "Password ",
        align   = "center",
        valign  = "center",
    }
    obj.new_pass = Chili.EditBox:New {
        parent = reg_grid,
        passwordInput = true,
        text = WG.MENUOPTS.login_pass,
    }
    obj.new_email = Chili.Label:New {
        parent = reg_grid,
        caption = "Email ",
        align   = "center",
        valign  = "center",
    }
    obj.new_email = Chili.EditBox:New {
        parent = reg_grid,
    }

    obj.reg_cancel = Chili.Button:New {
        parent = reg_grid,
        caption = "Cancel",
        OnMouseUp = { Cancel },
    }
    obj.reg_ok = Chili.Button:New {
        parent = reg_grid,
        caption = "Ok",
        OnMouseUp = { Register },
    }

    -- Tabs panel
    obj.tabs = Chili.TabPanel:New {
        parent = win,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        padding = {5, 5, 5, 5},
        OnTabChange = { function(self, tabname)
            WG.MENUOPTS.login_tab = tabname
        end },
    }
    obj.tabs.tabbar.minItemWidth = 128
    obj.tabs:AddTab({name="Login", children={log_grid}})
    obj.tabs:AddTab({name="Register", children={reg_grid}})
    obj.tabs:ChangeTab(WG.MENUOPTS.login_tab)

    -- Store references to the main object into the event triggers
    obj.log_ok.win = obj
    obj.log_cancel.win = obj
    obj.reg_ok.win = obj
    obj.reg_cancel.win = obj

    -- Hiden by default
    obj:Hide()

    -- Events
    log_win = obj
    local lobby = WG.LibLobby.lobby
    lobby:AddListener("OnRegistrationAccepted",
        function(listener)
            log_win.user.text = log_win.new_user.text
            log_win.pass.text = log_win.new_pass.text
            log_win.tabs:ChangeTab("Login")
            Login(log_win.log_ok)
        end
    )
    lobby:AddListener("OnAgreementEnd", 
        function(listener)
            log_win:Hide()
        end
    )

    return obj
end 
