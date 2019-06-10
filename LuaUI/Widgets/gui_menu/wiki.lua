local Chili = WG.Chili

UnitsTreeWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

--//=============================================================================

function UnitsTreeWindow:New(obj)
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.minwidth = 320
    obj.width = obj.width or '25%'
    obj.minHeight = 240
    obj.height = obj.height or '100%'

    obj = UnitsTreeWindow.inherited.New(self, obj)

    local grid = Chili.Grid:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        rows = 2,
        columns = 1,        
        padding = {0,0,0,0},
    }

    -- Add the controls
    local tree = Chili.TreeView:New {
        parent = grid,
        nodes = {"I", "II", {"II.a", "II.b", Chili.Image:New {
            keepAspect = true,
            file = "LuaUI/Widgets/gui_menu/rsrc/S44-logo-vector.png",
        }}}
    }

    -- Hiden by default
    obj:Hide()

    return obj
end 

function UnitsTreeWindow:Show(visitor)
    self.visitor = visitor
    UnitsTreeWindow.inherited.Show(self)
end
