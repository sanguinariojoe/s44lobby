local Chili = WG.Chili

PlayerWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

ICONS_FOLDER = "LuaUI/Widgets/gui_menu/rsrc/"
SIDEPICS_FOLDER = "sidepics/"
SIDEDATA = {
}
local sidedata = VFS.Include("gamedata/sidedata.lua")
for _, side in ipairs(sidedata) do
    SIDEDATA[#SIDEDATA + 1] = side.name
end

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

--//=============================================================================

function Destroy(self)
    WG.MENUOPTS.single_player.players[self.playerID] = nil
end

function Resized(self)
    local fontsize = Chili.OptimumFontSize(self.font,
                                           "Ally:  1 ",
                                           self.width - 2,
                                           0.5 * self.height - 2) - 1
    self.ally_label.font.size = math.max(4, fontsize)
    self.ally_button.font.size = math.max(4, fontsize)
    self.ally_label:UpdateLayout()
end

function Moved(self, x, y)
    WG.MENUOPTS.single_player.players[self.playerID].place = {
        x = (x + 0.5 * self.width) / self.parent.width,
        z = (y + 0.5 * self.height) / self.parent.height}
    self:SetPosBounds()
    self.parent.SnapPosition(self)
end

function ChangeSide(self)
    local side_index = 0
    for i, side in ipairs(SIDEDATA) do
        if string.lower(side) == string.lower(self.parent.side) then
            side_index = i
            break
        end
    end

    side_index = (side_index % #SIDEDATA) + 1
    local side = SIDEDATA[side_index]
    self.parent.side = side
    self.img.file = SIDEPICS_FOLDER .. side .. ".png",
    self.parent:SaveData()
end

function ChangeAlly(self)
    local n_players = WG.MENUOPTS.single_player.n_players
    self.parent.ally = self.parent.ally % n_players + 1
    self.parent.ally_button:SetCaption(tostring(self.parent.ally))
    self.parent:SaveData()
end

function PlayerWindow:New(obj)
    obj.place = obj.place or {x = obj.x, z = obj.y}
    if not obj.side then
        if WG.MENUOPTS.single_player.players[obj.playerID] then
            obj.side = WG.MENUOPTS.single_player.players[obj.playerID].side
        else
            obj.side = SIDEDATA[1]
        end
    end
    if not obj.ally then
        if WG.MENUOPTS.single_player.players[obj.playerID] then
            obj.ally = WG.MENUOPTS.single_player.players[obj.playerID].ally
        else
            obj.ally = obj.playerID
        end
    end
    obj.bounds = {0, 0, 1, 1}
    obj.x = tostring(math.floor(100 * math.max(0, obj.x - 0.02))) .. "%"
    obj.y = tostring(math.floor(100 * math.max(0, obj.y - 0.02))) .. "%"
    obj.width, obj.height = '4%', '4%'
    obj.resizable = false
    obj.draggable = true
    obj.margin = {0, 0, 0, 0}
    obj.padding = {1, 1, 1, 1}

    obj = PlayerWindow.inherited.New(self, obj)

    obj.player_icon = Chili.Image:New {
        parent = obj,
        x = "0%",
        y = "0%",
        width = "50%",
        height = "50%",
        file = ICONS_FOLDER .. "gui/cpu.png",
    }
    obj.side_button = Chili.Button:New {
        parent = obj,
        x = "50%",
        y = "0%",
        width = "50%",
        height = "50%",
        caption = "",
        padding = {1, 1, 1, 1},
        TileImageBK = ICONS_FOLDER .. "gui/s44_button_alt_bk.png",
        TileImageFG = ICONS_FOLDER .. "gui/s44_button_alt_fg.png",
        OnClick = { ChangeSide, },
    }
    obj.side_button.img = Chili.Image:New {
        parent = obj.side_button,
        x = "0%",
        y = "0%",
        width = "100%",
        height = "100%",
        file = SIDEPICS_FOLDER .. obj.side .. ".png",
    }

    obj.ally_label = Chili.Label:New {
        parent = obj,
        x = "0%",
        y = "50%",
        width = "50%",
        height = "50%",
        caption = "Ally: ",
        valign = "center",
    }

    obj.ally_button = Chili.Button:New {
        parent = obj,
        x = "50%",
        y = "50%",
        width = "50%",
        height = "50%",
        caption = tostring(obj.ally),
        padding = {1, 1, 1, 1},
        TileImageBK = ICONS_FOLDER .. "gui/s44_button_alt_bk.png",
        TileImageFG = ICONS_FOLDER .. "gui/s44_button_alt_fg.png",
        OnClick = { ChangeAlly, },
    }

    obj.OnDispose = { Destroy, }
    obj.OnResize = { Resized, }
    if not obj.OnMove then
        obj.OnMove = { Moved, }
    else
        table.insert(obj.OnMove, 1, Moved)
    end

    obj:SaveData()
    obj:SetAI(obj.ai)
    Resized(obj)

    return obj
end

function PlayerWindow:OnPlaceUpdate(x, y)
    self:SetPosRelative(
        tostring(math.floor(100 * math.max(0, x - 0.02))) .. "%",
        tostring(math.floor(100 * math.max(0, y - 0.02))) .. "%",
        nil, nil)
end

function PlayerWindow:SetPosBounds(bounds)
    if bounds then
        self.bounds = bounds
    else
        bounds = self.bounds
    end

    local x = (self.x + 0.5 * self.width) / self.parent.width
    local y = (self.y + 0.5 * self.height) / self.parent.height
    local new_x, new_y = nil, nil
    if x < bounds[1] then
        new_x = bounds[1]
    elseif x > bounds[3] then
        new_x = bounds[3]
    end
    if y < bounds[2] then
        new_y = bounds[2]
    elseif y > bounds[4] then
        new_y = bounds[4]
    end
    if new_x then
        WG.MENUOPTS.single_player.players[self.playerID].place.x = new_x
        self:SetPosRelative(
            tostring(math.floor(100 * math.max(0, new_x - 0.02))) .. "%",
            nil)
    end
    if new_y then
        WG.MENUOPTS.single_player.players[self.playerID].place.z = new_y
        self:SetPosRelative(
            nil,
            tostring(math.floor(100 * math.max(0, new_y - 0.02))) .. "%")
    end

end

function PlayerWindow:SetAI(ai)
    self.ai = ai
    WG.MENUOPTS.single_player.players[self.playerID].ai = ai
    if ai == nil then
        self.player_icon.file = ICONS_FOLDER .. "gui/player.png"
    else
        self.player_icon.file = ICONS_FOLDER .. "gui/cpu.png"
    end
end

function PlayerWindow:SaveData()
    local playerID = self.playerID
    if not WG.MENUOPTS.single_player.players[playerID] then
        WG.MENUOPTS.single_player.players[playerID] = {
            place = self.place,
            side = self.side,
            ai = self.ai,
            ally = self.ally,
        }
    else
        WG.MENUOPTS.single_player.players[playerID].place = self.place
        WG.MENUOPTS.single_player.players[playerID].side = self.side
        WG.MENUOPTS.single_player.players[playerID].ai = self.ai
        WG.MENUOPTS.single_player.players[playerID].ally = self.ally
    end
end
