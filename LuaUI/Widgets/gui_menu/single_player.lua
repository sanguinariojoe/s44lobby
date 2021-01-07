local Chili = WG.Chili

SinglePlayerWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

ICONS_FOLDER = "LuaUI/Widgets/gui_menu/rsrc/"
MINIMAPS_FOLDER = "s44lobby/minimaps/"

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/single_player/map_selector.lua")

--//=============================================================================

local function OnStart(self)
end

local function OnBack(self)
    WG.LibLobby.localLobby:LeaveBattle()
    Back(self)
end

local function OnMapSelect(self)
    self.parent.maps_selector:Show()
end

local function _SetMap(obj)
    local lobby = WG.LibLobby.localLobby
    local battle = lobby:GetBattle(lobby:GetMyBattleID())
    local minimap_folder = MINIMAPS_FOLDER .. battle.mapName
    local minimap_file = minimap_folder .. "/minimap.png"
    if not VFS.FileExists(minimap_file) then
        WG.GetMinimap(battle.mapName, minimap_folder)
    end
    obj.map.file = minimap_file
    obj.select_map:SetCaption(battle.mapName)
    WG.MENUOPTS.single_player.map = battle.mapName
end

function SinglePlayerWindow:New(obj)
    obj.classname = "SinglePlayerWindow"
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png"

    obj = SinglePlayerWindow.inherited.New(self, obj)

    -- Map selection subwindow
    obj.maps_selector = MapsWindow:New {
        parent = obj,
    }
    obj.maps_selector:Hide()

    -- Map stuff
    obj.map = Chili.Image:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '50%',
        height = '90%',
        file = ICONS_FOLDER .. "download_icon.png",
    }
    obj.select_map = Chili.Button:New {
        parent = obj,
        x = '0%',
        y = '90%',
        width = '50%',
        height = '5%',
        caption = "Change map",
        backgroundColor = { 1, 1, 1, 1 },
        OnClick = { OnMapSelect },
    }

    -- Buttons
    local back = Chili.Button:New {
        parent = obj,
        x = '0%',
        y = '95%',
        width = '50%',
        height = '5%',
        caption = "Back",
        backgroundColor = { 1, 1, 1, 1 },
        OnClick = { OnBack },
    }
    obj.back_button = back
    local ok = Chili.Button:New {
        parent = obj,
        x = '50%',
        y = '95%',
        width = '50%',
        height = '5%',
        caption = "Start",
        backgroundColor = { 1, 1, 1, 1 },
        OnClick = { OnStart },
    }
    obj.ok_button = ok

    local lobby = WG.LibLobby.localLobby
    lobby:SetBattleState("Player", WG.MENUOPTS.single_player.game, WG.MENUOPTS.single_player.map, "Skirmish Battle")
    lobby:AddListener("OnUpdateBattleInfo",
        function(listener, battleID)
            if battleID ~= lobby:GetMyBattleID() then
                return
            end
            _SetMap(obj)
        end
    )

    -- Hiden by default
    obj:Hide()

    return obj
end 

function SinglePlayerWindow:Show(visitor)
    self.visitor = visitor
    SinglePlayerWindow.inherited.Show(self)
    SetEscAction(self, OnBack)
    _SetMap(self)
end
