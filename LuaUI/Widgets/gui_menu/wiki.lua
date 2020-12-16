local Chili = WG.Chili

UnitsTreeWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

DescriptionWindow = nil

local X, Y, Z, H = 512, 14.5, 516, 262
local XS, YS, ZS, HS = 512, 0, 820, 450

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/wiki_parsers.lua")

--//=============================================================================

UNITS_DEPTHS = {}  -- Depth of each unit, to find the critical line
CURRENT_DEPTH = 0  -- Current parsing depth
UNITS = {}  -- Global list of units already added to the tree
local selected_unit = nil


local function __split_str(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function _unit_name(id, side)
    -- Get an unitDefID, and return its name. This function is also resolving
    -- morphing links.
    -- id can be directly the name of the unit in case just the morphing
    -- link resolution should be carried out
    local name = id
    if type(name) == "number" then
        name = UnitDefs[id].name
    end

    -- Morphing link resolution
    fields = __split_str(name, "_")
    if #fields >= 4 and fields[1] == side and fields[2] == "morph" then
        -- It is a morphing unit, see BuildMorphDef function in
        -- LuaRules/Gadgets/unit_morph. We are interested in the morphed
        -- unit instead of the morphing one
        name = fields[4]
        for i = 5,#fields do
            -- Some swe nightmare names has underscores...
            name = name .. "_" .. fields[i]
        end
    end

    return name
end

function CreateTitle(parent, imgpath, txt)
    local img = Chili.Image:New {
        parent = parent,
        file = imgpath,
        y = '0%',
        width = '25%',
        keepAspect = true,
    }

    img.x = 0.5 * (parent.width - img.width)
    y = img.height + 5

    local dw = parent.padding[1] + parent.padding[3]
    local label = Chili.Label:New {
        x = '0%',
        y = y,
        width = '100%',
        parent = parent,
        caption = txt,
        align  = "center",
        valign = "center",
        font = {size = math.floor(21 * (parent.width - dw) / (473.0 - dw))},
    }

    return y + label.height + 10
end

function ParseFaction(faction)
    local obj = DescriptionWindow
    obj:ClearChildren()

    local y = CreateTitle(obj,
                          'LuaUI/Widgets/faction_change/' .. string.lower(faction.name) .. '.png',
                          faction.wiki_title)
    local h = obj.height - y

    local grid = Chili.ScrollPanel:New {
        parent = obj,
        x = '0%',
        y = y,
        width = '100%',
        height = h,
        horizontalScrollbar = false,
    }

    grid.BorderTileImage = ":cl:empty.png"
    grid.BackgroundTileImage = ":cl:empty.png"

    local fontsize = 14
    local dw = obj.padding[1] + obj.padding[3]
    if fontsize > math.floor(21 * (obj.width - dw) / (473.0 - dw)) then
        fontsize = math.floor(21 * (obj.width - dw) / (473.0 - dw))
    end
    local label = Chili.TextBox:New {
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        parent = grid,
        text = faction.wiki_desc,
        font = {size = fontsize},
    }
end

function ParseUnit(unitDef)
    -- Ask to replace the unit
    Spring.SendLuaRulesMsg('\140' .. unitDef.name)

    local obj = DescriptionWindow
    obj:ClearChildren()

    local y = CreateTitle(obj,
                          'unitpics/' .. unitDef.buildpicname,
                          unitDef.humanName)
    local dh = obj.padding[2] + obj.padding[4]
    local h = obj.height - dh - y

    local scroll = Chili.ScrollPanel:New {
        parent = obj,
        x = '0%',
        y = y,
        width = '100%',
        height = h,
        horizontalScrollbar = false,
    }
    scroll.BorderTileImage = ":cl:empty.png"
    scroll.BackgroundTileImage = ":cl:empty.png"

    --[[
    local grid = Chili.StackPanel:New {
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        parent = scroll,
    }
    --]]
    local grid = scroll

    local fontsize = 14
    local dw = obj.padding[1] + obj.padding[3]
    if fontsize > math.floor(21 * (obj.width - dw) / (473.0 - dw)) then
        fontsize = math.floor(21 * (obj.width - dw) / (473.0 - dw))
    end

    -- Main unit documentation
    local customParams = unitDef.customParams
    y = _parse_squad(grid, unitDef, fontsize)
    if customParams then
        local parser = customParams.wiki_parser
        if parser == "yard" then
            y = _parse_yard(grid, unitDef, fontsize)
        elseif parser == "storage" then
            y = _parse_storage(grid, unitDef, fontsize)
        elseif parser == "supplies" then
            y = _parse_supplies(grid, unitDef, fontsize)
        elseif parser == "infantry" then
            y = _parse_infantry(grid, unitDef, fontsize)
        elseif parser == "vehicle" then
            y = _parse_vehicle(grid, unitDef, fontsize)
        elseif parser == "aircraft" then
            y = _parse_aircraft(grid, unitDef, fontsize)
        elseif parser == "boat" then
            if not customParams.child then
                -- Otherwise it is a turret
                y = _parse_boat(grid, unitDef, fontsize)
            end
        end
        -- Readjust the camera
        if (parser == "boat") or ((parser == "yard") and unitDef.floatOnWater) then
            WG.look_at_x = XS
            WG.look_at_y = YS
            WG.look_at_z = ZS
            WG.look_height = HS
        else
            WG.look_at_x = X
            WG.look_at_y = Y
            WG.look_at_z = Z            
            WG.look_height = H            
        end
    end

    -- Parse the weapons
    -- =================
    y = _parse_weapons(grid, "\nWeapons\n----------------\n", unitDef, fontsize, 0, y)
end

function NodeSelected(self, node)
    local obj = node.children[1]
    if obj.faction ~= nil then
        ParseFaction(obj.faction)
        return
    end

    if obj.unitDef ~= nil then
        local name = obj.unitDef.name
        WG.MENUOPTS.wiki_unit = name
        if Chili.CompareLinks(UNITS[name], obj) then
            local parent = obj.parent.parent
            while parent and parent.Expand do
                parent:Expand()
                parent = parent.parent
            end
            ParseUnit(node.children[1].unitDef)
        else
            local parent = obj.parent.parent
            while parent and parent.Expand do
                parent:Collapse()
                parent = parent.parent
            end
            UNITS[name].parent:Select()
        end
        return
    end    
end

function _unit_node(name)
    local unitDef = UnitDefNames[name]
    local buildPic = unitDef.buildpicname
    local obj = TreeNode('unitpics/' .. buildPic, unitDef.humanName)
    obj.unitDef = unitDef
    return obj
end

function table.has(table, value)
    for _, v in ipairs(table) do
        if value == v then return true end
    end
    return false
end

function _unit_children(unitDef, side)
    -- Get the children
    local children = {}
    local tmpchildren = unitDef.buildOptions
    for _, child in ipairs(tmpchildren) do
        if not table.has(children, child) then
            children[#children + 1] = _unit_name(child, side):lower()
        end
    end

    if unitDef.name == side .. "pontoontruck" then
        -- The factories transformations are added as morphing links build
        -- options. However, the pontoontruck morph to shipyard is not specified
        -- as a build option, so we must manually add it
        children[#children + 1] = side .. "boatyard"
    end

    -- Add the morph options
    tmpchildren = _morph_children(unitDef)
    for _, child in ipairs(tmpchildren) do
        if not table.has(children, child) then
            children[#children + 1] = child
        end
    end

    -- Add also the squad/sortie members as children
    tmpchildren = _squad_children(unitDef)
    for child, _ in pairs(tmpchildren) do
        children[#children + 1] = child
    end

    return children
end

function _units_depth(name, side)
    if CURRENT_DEPTH == 0 then
        UNITS_DEPTHS = {}
    end

    CURRENT_DEPTH = CURRENT_DEPTH + 1

    if UNITS_DEPTHS[name] ~= nil and UNITS_DEPTHS[name] <= CURRENT_DEPTH then
        -- A better line was already found, skip it
        CURRENT_DEPTH = CURRENT_DEPTH - 1
        return
    end
    UNITS_DEPTHS[name] = CURRENT_DEPTH
    
    local children = _unit_children(UnitDefNames[name], side)
    for i, name in ipairs(children) do
        _units_depth(name, side)
    end

    CURRENT_DEPTH = CURRENT_DEPTH - 1
end

function _units_tree(startUnit, side)
    -- Departs from the starting unit, and traverse all the tech tree derived
    -- from him, simply following the building capabilities of each unit.
    local name = startUnit
    local obj = _unit_node(name)
    local tree = {}

    CURRENT_DEPTH = CURRENT_DEPTH + 1
    if UNITS[name] ~= nil or UNITS_DEPTHS[name] < CURRENT_DEPTH then
        -- Not the critical line
        CURRENT_DEPTH = CURRENT_DEPTH - 1
        return obj, tree
    end
    UNITS[name] = obj

    local children = _unit_children(obj.unitDef, side)

    -- Now we can add the entities
    for i, name in ipairs(children) do
        subobj, subtree = _units_tree(name, side)
        tree[#tree + 1] = subobj
        if #subtree > 0 then
            tree[#tree + 1] = subtree
        end
    end

    CURRENT_DEPTH = CURRENT_DEPTH - 1
    return obj, tree
end

function UnitsTreeWindow:New(obj)
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = ":cl:empty.png"

    obj = UnitsTreeWindow.inherited.New(self, obj)

    -- Create unit description subwindow
    local subwin = Chili.Window:New {
        parent = obj,
        x = '75%',
        y = '0%',
        width = '25%',
        height = '95%',
        resizable = false,
        draggable = false,
    }

    DescriptionWindow = subwin

    -- Create the units tree subwindow
    local subwin = Chili.Window:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '25%',
        height = '95%',
        resizable = false,
        draggable = false,
    }

    local data = {}
    local factions = VFS.Include("gamedata/sidedata.lua")
    for _, faction in ipairs(factions) do
        if faction.startUnit ~= 'gmtoolbox' and faction.name ~= 'Random Team (GM)' then
            data[#data + 1], _ = TreeNode(
                'LuaUI/Widgets/faction_change/' .. string.lower(faction.name) .. '.png',
                faction.name)
            data[#data].faction = faction
            _units_depth(string.lower(faction.startUnit),
                         string.lower(faction.name))
            local obj, tree = _units_tree(string.lower(faction.startUnit),
                                          string.lower(faction.name))
            data[#data + 1] = {obj, tree}
        end
    end
    ParseUnit(UnitDefNames[WG.MENUOPTS.wiki_unit:lower()])

    local scroll = Chili.ScrollPanel:New {
        parent = subwin,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
    }
    scroll.BorderTileImage = ":cl:empty.png"
    scroll.BackgroundTileImage = ":cl:empty.png"

    local tree = Chili.TreeView:New {
        parent = scroll,
        nodes = data,
        OnSelectNode = { NodeSelected },
    }
    obj.tree = tree

    -- Create a back button
    local ok = Chili.Button:New {
        parent = obj,
        x = '0%',
        y = '95%',
        width = '100%',
        height = '5%',
        caption = "Back",
        backgroundColor = { 1, 1, 1, 1 },
        OnMouseUp = { Back },
    }
    obj.ok_button = ok

    -- Hiden by default
    obj:Hide()

    return obj
end 

function UnitsTreeWindow:Show(visitor)
    self.visitor = visitor
    UnitsTreeWindow.inherited.Show(self)
    local name = WG.MENUOPTS.wiki_unit:lower()
    UNITS[name].parent:Select()
    SetEscAction(self, Back)
end
