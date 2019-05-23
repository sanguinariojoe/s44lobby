local Chili = WG.Chili

SettingsWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

local this = SettingsWindow
local inherited = this.inherited

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

--//=============================================================================

function this:New(obj)
    obj.x = obj.x or '30%'
    obj.y = obj.y or '10%'
    obj.minwidth = 320
    obj.width = obj.width or '40%'
    obj.minHeight = 64 * 4 + 3 * 5 + 2 * 16
    obj.height = obj.height or obj.minHeight

    obj = inherited.New(self, obj)

    local grid = Chili.Grid:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '100%',
        height = 64 * 3 + 2 * 5,
        rows = 3,
        columns = 1,        
        padding = {5,5,5,5},
    }
    -- Add the controls
    local _, _, quality = ComboBoxWithLabel({
        parent = grid,
        caption = "Graphics Quality",
        backgroundColor = { 1, 1, 1, 1 },
        OnSelect = { NotImplemented },
        items = {'very low','low','medium','high','very high'},
    })
    local _, _, detail = ComboBoxWithLabel({
        parent = grid,
        caption = "Graphics Detail",
        backgroundColor = { 1, 1, 1, 1 },
        OnSelect = { NotImplemented },
        items = {'low','medium','high'},
    })
    vsx, vsy = gl.GetViewSizes()
    local _, _, resolution = ComboBoxWithLabel({
        parent = grid,
        caption = "Resolution",
        backgroundColor = { 1, 1, 1, 1 },
        OnSelect = { NotImplemented },
        items = {'800x600 (4:3)','1024x768 (4:3)','1152x864 (4:3)',
                 '1280x960 (4:3)','1280x1024 (4:3)', '1600x1200 (4:3)',
                 '1280x800 (16:9)', '1440x900 (16:9)', '1680x1050 (16:9)',
                 '1920x1200 (16:9)', '2048x768 (dual)', '2560x1024 (dual)',
                 '3200x1200 (dual)',
                 tostring(vsx) .. 'x' .. tostring(vsy) .. ' (current)'},
        selected = 14,
    })

    local grid = Chili.Grid:New {
        parent = obj,
        x = '0%',
        y = 64 * 3 + 2 * 5,
        width = '100%',
        height = 64 + 5,
        rows = 1,
        columns = 1,        
        padding = {5,0,5,5},
    }
    local BackButton = Chili.Button:New {
        parent = grid,
        caption = "Back",
        backgroundColor = { 1, 1, 1, 1 },
        OnMouseUp = { Back },
    }

    -- Hiden by default
    obj:Hide()

    return obj
end 

function this:Show(visitor)
    self.visitor = visitor
    inherited.Show(self)
end
