local Chili = WG.Chili

SinglePlayerWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

ICONS_FOLDER = "LuaUI/Widgets/gui_menu/rsrc/"
MINIMAPS_FOLDER = "s44lobby/minimaps/"
local available_places, player_objs = {}, {}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/single_player/map_selector.lua")
VFS.Include("LuaUI/Widgets/gui_menu/single_player/player.lua")
VFS.Include("LuaUI/Widgets/gui_menu/single_player/mod_options.lua")

--//=============================================================================

local function _findLast(txt, str)
    local i = txt:match(".*" .. str .. "()")
    if i==nil then return nil else return i-1 end
end

local function _playerPlace(playerID)
    for i, place in ipairs(available_places) do
        if place.player == nil then
            place.player = playerID
            return place.x, place.z
        end
    end
    -- Set it in the center
    return nil, nil
end

local function _addPlayer(parent, playerID)
    if player_objs[playerID] then
        Spring.Log("Single Player", "Warning", "Trying to add an already existing player")
        return nil
    end

    local ai = "C.R.A.I.G."
    if playerID == 1 and not WG.MENUOPTS.single_player.spectate then
        ai = nil
    end
    local x, z = _playerPlace(playerID)
    if x == nil then
        x = 0.5
    end
    if z == nil then
        z = 0.5
    end

    player_objs[playerID] = PlayerWindow:New {
        parent = parent,
        playerID = playerID,
        x = x,
        y = z,
        ai = ai,
    }

    return playerID
end

local function _resetPlayer(playerID)
    if not player_objs[playerID] then
        Spring.Log("Single Player", "Warning", "Trying to reset an unknown player")
        return
    end

    player_objs[playerID]:SetPosBounds()
    player_objs[playerID].parent:SnapPosition()
    player_objs[playerID]:SetAI(player_objs[playerID].ai)
    player_objs[playerID]:Show()
end

local function _removePlayer(playerID)
    if not player_objs[playerID] then
        Spring.Log("Single Player", "Warning", "Trying to remove an unknown player")
        return
    end
    for i, place in ipairs(available_places) do
        if place.player == playerID then
            available_places[i].player = nil
        end
    end
    player_objs[playerID]:Hide()
end

local function SnapPosition(player, r)
    r = r or 0.02
    local x = (player.x + 0.5 * player.width) / player.parent.width
    local z = (player.y + 0.5 * player.height) / player.parent.height
    for i, place in ipairs(available_places) do
        if place.player == player.playerID then
            available_places[i].player = nil
        end
    end
    for i, place in ipairs(available_places) do
        if place.player == nil then
            dx = x - place.x
            dz = z - place.z
            if dx * dx + dz * dz < r * r then
                available_places[i].player = player.playerID
                x = place.x
                z = place.z
                WG.MENUOPTS.single_player.players[player.playerID].place.x = x
                WG.MENUOPTS.single_player.players[player.playerID].place.z = z
                player:SetPosRelative(
                    tostring(math.floor(100 * math.max(0, x - 0.02))) .. "%",
                    tostring(math.floor(100 * math.max(0, z - 0.02))) .. "%")
                return
            end
        end
    end
end

local function ParseSMD(map)
    local paths = {"maps/" .. map .. ".smd",
                   "maps/" .. VFS.GetArchiveInfo(map).name .. ".smd"}
    for _, path in ipairs(paths) do
        if VFS.FileExists(path) then
            local str = VFS.LoadFile(path)
            str = str:gsub("//", "--")
            str = str:gsub("=", '="')
            str = str:gsub(";", '",')
            str = str:gsub("%[", '')
            str = str:gsub("%]", '=')
            str = str:gsub("%}", '},')
            -- Look for the trailing comma
            str = str:sub(1, _findLast(str, ",") - 1)
            str = str .. "\nreturn MAP"

            local f = loadstring(str)
            return f()            
        end
    end

    return nil
end

local function MapInfo(map)
    VFS.MapArchive(map)
    if not VFS.FileExists("mapinfo.lua") then
        local status, retval = pcall(ParseSMD, map);
        if status then
            local info = retval
            -- Parse teams
            local i = 0
            info.teams = {}
            while info["TEAM" .. tostring(i)] do
                info.teams[i] = {
                    startPos = {
                        x = tonumber(info["TEAM" .. tostring(i)].StartPosX),
                        z = tonumber(info["TEAM" .. tostring(i)].StartPosZ),
                    }
                }
                i = i + 1
            end
            return info
        end
        return nil
    end

    local info = VFS.Include("mapinfo.lua")
    VFS.UnmapArchive(map)
    return info
end

local function SetNPlayers(obj, n_players)
    WG.MENUOPTS.single_player.n_players = n_players
    for i = 1, n_players do
        if player_objs[i] then
            _resetPlayer(i)
        else
            _addPlayer(obj.players, i)
        end
    end

    for i = #player_objs, n_players + 1, -1 do
        _removePlayer(i)
    end
end

local function SetMap(obj)
    local lobby = WG.LibLobby.localLobby
    local battle = lobby:GetBattle(lobby:GetMyBattleID())
    local minimap_folder = MINIMAPS_FOLDER .. battle.mapName
    local minimap_file = minimap_folder .. "/minimap.png"
    -- We are invariably executing this, because we need the header
    local hdr = WG.GetMinimap(battle.mapName, minimap_folder)
    obj.players.maphdr = hdr
    obj.mapimg.file = minimap_file
    obj.select_map:SetCaption(battle.mapName)
    WG.MENUOPTS.single_player.map = battle.mapName

    local info = MapInfo(battle.mapName)
    if not info then
        Spring.Log("Single Player", "Warning", "No info can be found for map '" .. battle.mapName .. "'")
        return
    else
        obj.mapimg:ClearChildren()
        old_places = available_places
        available_places = {}
        for i, t in pairs(info.teams) do
            if t.startPos then
                local x, z = global2local(t.startPos.x, t.startPos.z, hdr.mapx, hdr.mapy)
                available_places[#available_places + 1] = {x = x, z = z, player = nil}
                if old_places[#available_places] then
                    available_places[#available_places].player = old_places[#available_places].player
                end
                Chili.Image:New {
                    parent = obj.mapimg,
                    x = tostring(math.floor(100 * math.max(0, x - 0.015))) .. "%",
                    y = tostring(math.floor(100 * math.max(0, z - 0.015))) .. "%",
                    width = "3%",
                    height = "3%",
                    file = ICONS_FOLDER .. "gui/team_place.png",
                }
            end
        end
    end

    local n_players = WG.MENUOPTS.single_player.n_players
    SetNPlayers(obj, n_players)
    if (obj.opts_panel.n_players.value ~= n_players) then
        obj.opts_panel.n_players_label:SetCaption(tostring(n_players))
        obj.opts_panel.n_players:SetValue(n_players)
    end

    local relative_bounds
    if hdr.mapx > hdr.mapy then
        local f = hdr.mapy / hdr.mapx
        relative_bounds = {0, 0.5 * (1 - f), 1.0, 1.0 - 0.5 * (1 - f)}
    elseif hdr.mapx < hdr.mapy then
        local f = hdr.mapx / hdr.mapy
        relative_bounds = {0.5 * (1 - f), 0, 1.0 - 0.5 * (1 - f), 1.0}
    else
        relative_bounds = {0, 0, 1, 1}
    end

    for _, player_obj in ipairs(player_objs) do
        player_obj:SetPosBounds(relative_bounds)
    end
end

local function OnStart(self)
    WG.LibLobby.localLobby:StartBattle("Skirmish", "Player")
end

local function OnBack(self)
    WG.LibLobby.localLobby:LeaveBattle()
    Back(self)
end

local function OnMapSelect(self)
    self.parent.maps_selector:Show()
end

local function OnSpectator(self, value)
    if not value then
        player_objs[1]:SetAI(nil)
    else
        player_objs[1]:SetAI("C.R.A.I.G.")
    end
    WG.MENUOPTS.single_player.spectate = value
end

local function OnNPlayers(self, value, old_value)
    self.parent.n_players_label:SetCaption(tostring(value))
    -- Why 3 levels of parenting??
    SetNPlayers(self.parent.parent.parent, value)
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
    obj.map = Chili.Window:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '50%',
        height = '90%',
        padding = {0, 0, 0, 0},
        margin = {0, 0, 0, 0},
        resizable = false,
        draggable = false,
        TileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
    }
    obj.mapimg = Chili.Image:New {
        parent = obj.map,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        padding = {0, 0, 0, 0},
        margin = {0, 0, 0, 0},
        file = ICONS_FOLDER .. "download_icon.png",
    }
    obj.players = Chili.Window:New {
        parent = obj.map,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        padding = {0, 0, 0, 0},
        margin = {0, 0, 0, 0},
        resizable = false,
        draggable = false,
        TileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
    }
    obj.players.SnapPosition = SnapPosition

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

    -- Options panel
    local scroll = Chili.ScrollPanel:New {
        x = "50%",
        y = "0%",
        width = "50%",
        height = "95%",
        horizontalScrollbar = false,
        verticalScrollbar = true,
        caption = "",
        BorderTileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        BackgroundTileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        parent = obj,
    }

    obj.opts_panel = Chili.Window:New {
        x = "0%",
        y = "0%",
        width = "100%",
        height = "100%",
        resizeItems = false,
        resizable = false,
        draggable = false,
        TileImage = "LuaUI/Widgets/chili/skins/s44/s44_window_opaque.png",
        parent = scroll,
    }

    local y = 0
    local label = Chili.Label:New {
        x = "0%",
        y = y,
        width = "50%",
        caption = "Number of players:",
        parent = obj.opts_panel,
    }
    local spectate = Chili.Checkbox:New {
        x = "53%",
        y = y,
        width = "47%",
        caption = "(Spectate only)",
        boxalign = "left",
        checked = WG.MENUOPTS.single_player.spectate,
        parent = obj.opts_panel,
    }
    spectate.OnChange = { OnSpectator, }
    y = label.height

    obj.opts_panel.n_players_label = Chili.Label:New {
        x = "93%",
        y = y,
        caption = tostring(WG.MENUOPTS.single_player.n_players),
        parent = obj.opts_panel,
    }
    obj.opts_panel.n_players = Chili.Trackbar:New {
        x = "0%",
        y = y,
        width = "90%",
        height = obj.opts_panel.n_players_label.height - 5,
        value = WG.MENUOPTS.single_player.n_players,
        min   = 1,
        max   = 6,
        step  = 1,
        parent = obj.opts_panel,
    }
    obj.opts_panel.n_players.OnChange = { OnNPlayers, }
    y = y + obj.opts_panel.n_players_label.height

    obj.opts_panel.mod_options = ModOptionsWindow:New {
        y = y,
        parent = obj.opts_panel,
    }
    y = y + obj.opts_panel.mod_options.height
    
    obj.opts_panel:Resize(nil, y + 32)

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
            SetMap(obj)
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
    SetMap(self)
end
