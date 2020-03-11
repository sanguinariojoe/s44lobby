local Chili = WG.Chili

LoginWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/lobby_vcode.lua")

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
    WG.LibLobby.lobby:Connect("springrts.com", "8200")
end

function Register(self)
    local win = self.win
    win.vcode_win:Show()
    win:Hide()
end

function LoginWindow:New(obj)
    obj.x = obj.x or '30%'
    obj.y = obj.y or '30%'
    obj.width = obj.width or '40%'
    obj.resizable = false
    obj.draggable = false

    obj = LoginWindow.inherited.New(self, obj)

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
    }
    obj.user = Chili.EditBox:New {
        parent = log_grid,
        text = WG.MENUOPTS.login_user,
    }
    obj.pass_label = Chili.Label:New {
        parent = log_grid,
        caption = "Password ",
    }
    obj.pass = Chili.EditBox:New {
        parent = log_grid,
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
    }
    obj.new_user = Chili.EditBox:New {
        parent = reg_grid,
        text = WG.MENUOPTS.login_user,
    }
    obj.new_pass_label = Chili.Label:New {
        parent = reg_grid,
        caption = "Password ",
    }
    obj.new_pass = Chili.EditBox:New {
        parent = reg_grid,
        text = WG.MENUOPTS.login_pass,
    }
    obj.new_email = Chili.Label:New {
        parent = reg_grid,
        caption = "Email ",
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
        parent = obj,
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

    -- Create a window to insert the verification code
    obj.vcode_win = VerificationCodeWindow:New({parent = WG.Chili.Screen0}, obj)
    obj.vcode_win:Hide()

    -- Hiden by default
    obj:Hide()

    return obj
end 
