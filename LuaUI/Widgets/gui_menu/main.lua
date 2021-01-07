local Chili = WG.Chili

MainWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

local this = MainWindow
local inherited = this.inherited

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

local function GoToSinglePlayer(self)
    local win = TopLevelParent(self)
    local child = win.single_player_win
    child:Show(win)
    win:Hide()
end

local function GoToLobby(self)
    local win = TopLevelParent(self)
    local child = win.lobby_win
    child:Show(win)
    win:Hide()
end

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

function __AddButton(parent, caption, action, y, h)
    y = y or 0
    h = h or 0.2
    local fontsize = Chili.OptimumFontSize(parent.font,
                                           "Multiplayer",
                                           0.8 * ((parent.width - 10) - 10),
                                           0.6 * (h * (parent.height - 10) - 10))

    if h <= 1.0 then
        h = tostring(math.floor(100 * h)) .. "%"
    end

    return Chili.Button:New{
        parent = parent,
        x = "0%",
        y = y,
        width = "100%",
        height = h,
        padding = {0, 0, 0, 0},
        caption = caption,
        font = {size = fontsize},
        OnClick = {action}
    }
end

function this:New(obj, single_player_win, lobby_win, settings_win, wiki_win)
    self.single_player_win = single_player_win
    self.lobby_win = lobby_win
    self.settings_win = settings_win
    self.wiki_win = wiki_win

    obj.x = obj.x or '30%'
    obj.y = obj.y or '20%'
    obj.minwidth = 320
    obj.width = obj.width or '40%'
    obj.minHeight = 64 + 32 * 4
    obj.height = obj.height or '60%'
    obj.resizable = false
    obj.draggable = false
    obj = inherited.New(self, obj)

    local logo = Chili.Image:New {
        parent = obj,
        width = "100%",
        height = "40%",
        keepAspect = true,
        file = "LuaUI/Widgets/gui_menu/rsrc/S44-logo-vector.png",
    }

    if self.wiki_win then
        __AddButton(obj, "Single player", GoToSinglePlayer, "40%", 0.12)
        __AddButton(obj, "Multiplayer", GoToLobby, "52%", 0.12)
        __AddButton(obj, "Units", GoToWiki, "64%", 0.12)
        __AddButton(obj, "Settings", GoToSettings, "76%", 0.12)
        __AddButton(obj, "QuitButton", Quit, "88%", 0.12)
    else
        __AddButton(obj, "Single player", GoToSinglePlayer, "40%", 0.15)
        __AddButton(obj, "Multiplayer", GoToLobby, "55%", 0.15)
        __AddButton(obj, "Settings", GoToSettings, "70%", 0.15)
        __AddButton(obj, "Quit", Quit, "85%", 0.15)
    end

    return obj
end
