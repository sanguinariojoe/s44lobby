local Chili = WG.Chili

PasswordWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

--//=============================================================================

local function _OnCancel(self)
    local win = self.parent
    win.pass:SetText("")
    win:Dispose()
end

function PasswordWindow:New(obj)
    obj.parent = obj.parent or WG.Chili.Screen0
    obj.classname = "PasswordWindow"
    obj.x = obj.x or '30%'
    obj.y = obj.y or '30%'
    obj.width = obj.width or '40%'
    obj.height = obj.height or 128
    obj.resizable = obj.resizable or false
    obj.draggable = obj.draggable or false
    obj.TileImage = "LuaUI/Widgets/chili/skins/s44/s44_window_opaque.png"
    -- Save some inner attributes
    local caption = obj.caption or "Password required"
    obj.caption = nil
    local OnClick = obj.OnClick
    obj.OnClick = nil

    obj = PasswordWindow.inherited.New(self, obj)

    -- A label with the chosen caption
    obj.label = Chili.Label:New {
        parent = obj,
        x = 0,
        y = 0,
        height = 32,
        width = "100%",
        caption = caption,
        align   = "center",
        valign  = "center",
    }
    -- An editable box to introduce the password
    obj.pass = Chili.EditBox:New {
        parent = obj,
        x = 0,
        y = 32,
        height = 32,
        width = "100%",
        passwordInput = true,
        text = "",
    }
    -- And the buttons
    obj.ok = Chili.Button:New {
        parent = obj,
        x = "0%",
        y = 64,
        height = 32,
        width = "50%",
        caption = "OK",
        OnClick = OnClick,
    }
    obj.cancel = Chili.Button:New {
        parent = obj,
        x = "50%",
        y = 64,
        height = 32,
        width = "50%",
        caption = "Cancel",
        OnClick = { _OnCancel },
    }

    return obj
end
