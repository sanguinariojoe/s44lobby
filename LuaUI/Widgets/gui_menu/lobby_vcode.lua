local Chili = WG.Chili

VerificationCodeWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

--//=============================================================================

function Cancel(self)
    local win = self.win
    local parent = win.login_win

    win:Hide()
    parent:Show()
end

function Ok(self)
    local win = self.win

    local parent = win.login_win
    -- Store the new user and password
    WG.MENUOPTS.login_user = parent.new_user.text
    WG.MENUOPTS.login_pass = parent.new_pass.text
    -- Setup the login tab
    parent.user.text = WG.MENUOPTS.login_user
    parent.pass.text = WG.MENUOPTS.login_pass
    -- Change to the login tab
    WG.MENUOPTS.login_tab = "Login"
    parent.tabs:ChangeTab("Login")

    win:Hide()
    parent:Show()
end

function VerificationCodeWindow:New(obj, login_win)
    self.login_win = login_win

    obj.x = obj.x or '30%'
    obj.y = obj.y or '30%'
    obj.width = obj.width or '40%'
    obj.resizable = false
    obj.draggable = false

    obj = VerificationCodeWindow.inherited.New(self, obj)

    -- Login fields
    -- ============
    local grid = Chili.Grid:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        rows = 2,
        columns = 2,
    }

    obj.label = Chili.Label:New {
        parent = grid,
        caption = "Verification code ",
    }
    obj.vcode = Chili.EditBox:New {
        parent = grid,
        text = "check email",
    }

    obj.cancel = Chili.Button:New {
        parent = grid,
        caption = "Cancel",
        OnMouseUp = { Cancel },
    }
    obj.ok = Chili.Button:New {
        parent = grid,
        caption = "Ok",
        OnMouseUp = { Ok },
    }

    -- Store references to the main object into the event triggers
    obj.ok.win = obj
    obj.cancel.win = obj

    -- Hiden by default
    obj:Hide()

    return obj
end 
