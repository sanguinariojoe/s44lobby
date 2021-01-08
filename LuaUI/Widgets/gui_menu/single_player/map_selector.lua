local Chili = WG.Chili

MapsWindow = Chili.Control:Inherit{
    drawcontrolv2 = true
}

MINIMAPS_FOLDER = "s44lobby/minimaps/"
local maps = {}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

--//=============================================================================

function Cancel(self)
    local win = self.win
    win:Hide()
end

function SetMap(self)
    WG.LibLobby.localLobby:SelectMap(self.caption)
    Cancel(self)
end

local function _AddMap(parent, mapName, y)
    y = y or nil

    local minimap_folder = MINIMAPS_FOLDER .. mapName
    local minimap_file = minimap_folder .. "/minimap.png"
    -- Let the widget:Update() take care on this
    -- if not VFS.FileExists(minimap_file) then
    --     WG.GetMinimap(mapName, minimap_folder)
    -- end

    w = parent.width
    local button = Chili.Button:New {
        parent = parent,
        x = 0,
        y = y,
        width = w,
        height = w + 32,
        caption = mapName,
        OnClick = { SetMap, },
    }
    button.win = parent.win

    Chili.Label:New {
        x = 0,
        y = 0,
        width = w,
        height = 32,
        parent = button,
        caption = mapName,
    }
    Chili.Image:New {
        x = 0,
        y = 32,
        width = w,
        height = w,
        parent = button,
        file = minimap_file,
    }

    return y + button.height
end


function UpdateMaps(self)
    local new_maps = VFS.GetMaps()
    local has_new_maps = #maps ~= new_maps
    if not has_new_maps then
        for i, m in ipairs(maps) do
            if m:lower() ~= new_maps[i]:lower() then
                has_new_maps = true
                break
            end
        end
    end

    if not has_new_maps then
        return
    end

    self.maps_panel:ClearChildren()
    maps = new_maps
    local y = 0
    for _, m in ipairs(maps) do
        y = _AddMap(self.maps_panel, m, y)
    end
    self.maps_panel:Resize(nil, y)
end

function MapsWindow:New(obj)
    local x = obj.x or '30%'
    local y = obj.y or '10%'
    local w = obj.width or '40%'
    local h = obj.height or '90%'

    obj.x = 0
    obj.y = 0
    obj.right = 0
    obj.bottom = 0
    obj.padding = {0,0,0,0}
    obj.margin = {0,0,0,0}
    obj.OnShow = { UpdateMaps, }

    obj = MapsWindow.inherited.New(self, obj)

    -- Create a large button to hijack the clicks of all windows behind
    local clickhijack = Chili.Button:New {
        x = "0%",
        y = "0%",
        width = "100%",
        height = "100%",
        caption = "",
        TileImageBK = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        TileImageFG = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        parent = obj,
    }

    local win = Chili.Window:New {
        x = x,
        y = y,
        width = w,
        height = h,
        resizable = false,
        draggable = false,
        parent = obj,
    }

    local scroll = Chili.ScrollPanel:New {
        x = "0%",
        y = "0%",
        width = "100%",
        height = "95%",
        horizontalScrollbar = false,
        verticalScrollbar = true,
        caption = "",
        BorderTileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        BackgroundTileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        parent = win,
    }

    obj.maps_panel = Chili.Window:New {
        x = "0%",
        y = "0%",
        width = "100%",
        resizeItems = false,
        TileImageBK = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        TileImageFG = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        parent = scroll,
    }
    obj.maps_panel.win = obj

    obj.cancel = Chili.Button:New {
        parent = win,
        x = "0%",
        y = "95%",
        width = "100%",
        height = "5%",
        caption = "Cancel",
        OnMouseUp = { Cancel },
    }
    obj.cancel.win = obj

    -- Hiden by default
    UpdateMaps(obj)
    obj:Hide()

    return obj
end
