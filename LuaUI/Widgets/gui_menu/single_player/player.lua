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

function ChangeSide(self)
    Spring.Echo("ChangeSide...")
    local side_index = 0
    for i, side in ipairs(SIDEDATA) do
        if string.lower(side) == string.lower(self.parent.side) then
            side_index = i
            break
        end
    end

    Spring.Echo("    ", side_index)
    side_index = (side_index % #SIDEDATA) + 1
    local side = SIDEDATA[side_index]
    Spring.Echo("    ", side_index)
    self.parent.side = side
    Spring.Echo("    ", self.parent.side)
    self.img.file = SIDEPICS_FOLDER .. side .. ".png",
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
    obj.x = tostring(math.floor(100 * math.max(0, obj.x - 0.02))) .. "%"
    obj.y = tostring(math.floor(100 * math.max(0, obj.y - 0.02))) .. "%"
    obj.width, obj.height = '4%', '4%'
    obj.resizable = false
    obj.draggable = true
    obj.margin = {0, 0, 0, 0}
    obj.padding = {1, 1, 1, 1}
    obj.OnDispose = { Destroy, }

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

    obj:SaveData()
    obj:SetAI(obj.ai)

    return obj
end

function PlayerWindow:OnPlaceUpdate(x, y)
    self:SetPosRelative(
        tostring(math.floor(100 * math.max(0, x - 0.02))) .. "%",
        tostring(math.floor(100 * math.max(0, y - 0.02))) .. "%",
        nil, nil)
    self.place = WG.MENUOPTS.single_player.players[self.playerID].place
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
        }
    else
        WG.MENUOPTS.single_player.players[playerID].place = self.place
        WG.MENUOPTS.single_player.players[playerID].side = self.side
        WG.MENUOPTS.single_player.players[playerID].ai = self.ai
    end
end
