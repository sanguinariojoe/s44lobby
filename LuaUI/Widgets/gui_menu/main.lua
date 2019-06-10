local Chili = WG.Chili

MainWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

local this = MainWindow
local inherited = this.inherited

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

local function GoToSettings(self)
    local win = TopLevelParent(self)
    local child = win.settings_win
    child:Show(win)
    win:Hide()
end

local function GoToWiki(self)
    local win = TopLevelParent(self)
    local child = win.wiki_win
    child:Show(win)
    win:Hide()
end

--//=============================================================================

function this:New(obj, settings_win, wiki_win)
    self.settings_win = settings_win
    self.wiki_win = wiki_win

    obj.x = obj.x or '30%'
    obj.y = obj.y or '10%'
    obj.minwidth = 320
    obj.width = obj.width or '40%'
    obj.minHeight = 64 * 4
    obj.height = obj.height or '80%'

    obj = inherited.New(self, obj)

    local logo = Chili.Image:New {
        parent = obj,
        width = "100%",
        height = "15%",
        keepAspect = true,
        file = "LuaUI/Widgets/gui_menu/rsrc/S44-logo-vector.png",
    }
    local grid = Chili.Grid:New {
        parent = obj,
        x = '0%',
        y = '15%',
        width = '100%',
        height = '85%',
        rows = 4,
        columns = 1,        
        padding = {5,5,5,5},
    }
    -- Add the buttons
    local PlayButton = Chili.Button:New {
        parent = grid,
        caption = "Multiplayer",
        backgroundColor = { 1, 1, 1, 1 },
        OnMouseUp = { NotImplemented },
    }
    local WikiButton = Chili.Button:New {
        parent = grid,
        caption = "Units",
        backgroundColor = { 1, 1, 1, 1 },
        OnMouseUp = { GoToWiki },
    }
    local ConfigButton = Chili.Button:New {
        parent = grid,
        caption = "Settings",
        backgroundColor = { 1, 1, 1, 1 },
        OnMouseUp = { GoToSettings },
    }
    local QuitButton = Chili.Button:New {
        parent = grid,
        caption = "Exit",
        backgroundColor = { 1, 1, 1, 1 },
        OnMouseUp = { Quit },
    }

    return obj
end
