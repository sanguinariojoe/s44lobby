local Chili = WG.Chili

BattlesWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

--//=============================================================================

local button_captions = {'\204\128',
                         '\204\129',
                         '\204\130',
                         'Max',
                         '\204\131',
                         'Game',
                         'Map'}
local button_sizes = {'5%',
                      '5%',
                      '5%',
                      '7.5%',
                      '7.5%',
                      '35%',
                      '35%'}

function AddButton(parent, x, id)
    local button = Chili.Button:New {
        parent = parent,
        x = x,
        y = y,
        height = 32,
        width = button_sizes[id],
        caption = button_captions[id],
    }
    return button.width
end

function CreateBattlesList(parent, battles_list)
    local x = 0
    for i = 1, 7 do
        x = x + AddButton(parent, x, i)
    end

    for _, battle in ipairs(battles_list) do
    end
end

function BattlesWindow:New(obj)
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = ":cl:empty.png"

    obj = BattlesWindow.inherited.New(self, obj)

    -- Battles list
    -- ============
    obj.scroll = Chili.ScrollPanel:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        horizontalScrollbar = false,
        BorderTileImage = ":cl:empty.png",
        BackgroundTileImage = ":cl:empty.png",
    }
    obj.battles_list = {}
    CreateBattlesList(obj.scroll, obj.battles_list)

    return obj
end 
