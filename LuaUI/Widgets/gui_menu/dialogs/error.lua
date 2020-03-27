local Chili = WG.Chili

ErrorWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

--//=============================================================================

local function _OnClose(self)
    local win = self.parent
    win:Dispose()
end

function ErrorWindow:New(obj)
    obj.parent = obj.parent or WG.Chili.Screen0
    obj.classname = "ErrorWindow"
    obj.x = obj.x or '10%'
    obj.y = obj.y or '30%'
    obj.width = obj.width or '80%'
    obj.height = obj.height or 128
    obj.resizable = obj.resizable or false
    obj.draggable = obj.draggable or false
    obj.TileImage = "LuaUI/Widgets/chili/skins/s44/s44_window_opaque.png"
    -- Save some inner attributes
    local caption = obj.caption or "Unhandled error"
    obj.caption = nil

    obj = ErrorWindow.inherited.New(self, obj)

    obj.label = Chili.TextBox:New {
        parent = obj,
        x = 0,
        y = 0,
        height = 64,
        width = "100%",
        text = caption,
        align = "center",
    }
    obj.close = Chili.Button:New {
        parent = obj,
        x = "0%",
        y = 64,
        height = 32,
        width = "100%",
        caption = "Close",
        OnClick = { _OnClose },
    }

    return obj
end
