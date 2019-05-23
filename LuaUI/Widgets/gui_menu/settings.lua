local Chili = WG.Chili

SettingsWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

local this = SettingsWindow
local inherited = this.inherited

local RESOLUTIONS = {'800x600 (4:3)','1024x768 (4:3)','1152x864 (4:3)',
                     '1280x960 (4:3)','1280x1024 (4:3)', '1600x1200 (4:3)',
                     '1280x800 (16:9)', '1440x900 (16:9)', '1680x1050 (16:9)',
                     '1920x1080 (16:9)', '2048x768 (dual)', '2560x1024 (dual)',
                     '3200x1200 (dual)'}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

local function SetBackButton(win)
    button = win.ok_button
    button:SetCaption("Back")
    button.OnMouseUp = { Back }
end

local function SetRestartButton(win)
    button = win.ok_button
    button:SetCaption("Restart")
    button.OnMouseUp = { Restart }
end

local function ResolutionStrToNum(str)
    local i
    i = string.find(str, "x")
    if i == nil then
        return 0, 0
    end
    local x = tonumber(string.sub(str, 1, i - 1))
    str = string.sub(str, i + 1)
    i = string.find(str, " ")
    if i == nil then
        i = string.len(str) + 1
    end
    local y = tonumber(string.sub(str, 1, i - 1))
    return x, y
end

local function ResolutionChange(self, itemIdx)
    local win = TopLevelParent(self)
    local vsx, vsy

    if itemIdx > #RESOLUTIONS then
        -- SetBackButton(win)
        vsx, vsy = gl.GetViewSizes()
    else
        -- SetRestartButton(win)
        vsx, vsy = ResolutionStrToNum(RESOLUTIONS[itemIdx])
    end

    Spring.SetConfigInt("Fullscreen", 1)
    Spring.SendCommands("Fullscreen 0")
    Spring.SetConfigInt("XResolution", vsx)
    Spring.SetConfigInt("YResolution", vsy)
    Spring.SendCommands("Fullscreen 1")
end

--//=============================================================================

function this:New(obj)
    obj.x = obj.x or '30%'
    obj.y = obj.y or '10%'
    obj.minwidth = 320
    obj.width = obj.width or '40%'
    obj.minHeight = 64 * 4 + 3 * 5 + 2 * 16
    obj.height = obj.height or obj.minHeight

    obj = inherited.New(self, obj)

    -- Some controls are editing VBack/Restart button, so better having it built
    -- up before addressing the stuff
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
    local ok = Chili.Button:New {
        parent = grid,
        caption = "Back",
        backgroundColor = { 1, 1, 1, 1 },
        OnMouseUp = { Back },
    }
    obj.ok_button = ok

    -- Add the controls
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
    local vsx, vsy = gl.GetViewSizes()
    local items = {}
    for i,v in ipairs(RESOLUTIONS) do
        items[i] = v
    end
    items[#items + 1] = tostring(vsx) .. 'x' .. tostring(vsy) .. ' (current)'
    local _, _, resolution = ComboBoxWithLabel({
        parent = grid,
        caption = "Resolution",
        backgroundColor = { 1, 1, 1, 1 },
        OnSelect = { ResolutionChange },
        items = items,
        selected = #items,
    })

    -- Hiden by default
    obj:Hide()

    return obj
end 

function this:Show(visitor)
    self.visitor = visitor
    inherited.Show(self)
end
