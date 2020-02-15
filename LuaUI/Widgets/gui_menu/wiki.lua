local Chili = WG.Chili

UnitsTreeWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

DescriptionWindow = nil

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/wiki_parsers.lua")

--//=============================================================================

UNITS = {}  -- Global list of units already added to the tree

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

    grid.BorderTileImage = ":c:empty.png"
    grid.BackgroundTileImage = ":c:empty.png"

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
    local obj = DescriptionWindow
    obj:ClearChildren()

    local y = CreateTitle(obj,
                          'unitpics/' .. unitDef.buildpicname,
                          unitDef.humanName)
    local h = obj.height - y

    local scroll = Chili.ScrollPanel:New {
        parent = obj,
        x = '0%',
        y = y,
        width = '100%',
        height = h,
        horizontalScrollbar = false,
    }
    scroll.BorderTileImage = ":c:empty.png"
    scroll.BackgroundTileImage = ":c:empty.png"

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
    if customParams then
        local parser = customParams.wiki_parser
        if parser == "yard" then
            _parse_yard(grid, unitDef, fontsize)
        elseif parser == "storage" then
            _parse_storage(grid, unitDef, fontsize)
        elseif parser == "supplies" then
            _parse_supplies(grid, unitDef, fontsize)
        elseif parser == "infantry" then
            _parse_infantry(grid, unitDef, fontsize)
        elseif parser == "vehicle" then
            _parse_vehicle(grid, unitDef, fontsize)
        elseif parser == "aircraft" then
            _parse_aircraft(grid, unitDef, fontsize)
        elseif parser == "boat" then
            if customParams.child then
                _parse_turret(grid, unitDef, fontsize)
            else
                _parse_boat(grid, unitDef, fontsize)
            end
        end
    end
end

function NodeSelected(self, node)
    if node.children[1].faction ~= nil then
        ParseFaction(node.children[1].faction)
        return
    end

    if node.children[1].unitDef ~= nil then
        ParseUnit(node.children[1].unitDef)
        return
    end    
end

function _units_tree(startUnit, side)
    -- Departs from the starting unit, and traverse all the tech tree derived
    -- from him, simply following the building capabilities of each unit.
    local name = startUnit
    local unitDef = UnitDefNames[name]
    local buildPic = unitDef.buildpicname
    local obj = TreeNode('unitpics/' .. buildPic, unitDef.humanName)
    obj.unitDef = unitDef

    if UNITS[name] ~= nil then
        -- The unit has been already digested. Parsing that again will result
        -- in an infinite loop
        return obj, {}
    end
    UNITS[name] = unitDef.humanName

    local tree = {}

    -- Add its children to the tree
    local children = unitDef.buildOptions
    if name == side .. "pontoontruck" then
        -- The factories transformations are added as morphing links build
        -- options. However, the pontoontruck morph to shipyard is not specified
        -- as a build option, so we must manually add it
        children[#children + 1] = side .. "boatyard"
    end
    for i = 1,#children do
        name = _unit_name(children[i], side)
        subobj, subtree = _units_tree(name, side)
        tree[#tree + 1] = subobj
        if #subtree > 0 then
            tree[#tree + 1] = subtree
        end
    end
    return obj, tree
end

function UnitsTreeWindow:New(obj)
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = ":c:empty.png"

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
            local obj, tree = _units_tree(string.lower(faction.startUnit),
                                          string.lower(faction.name))
            data[#data + 1] = {obj, tree}
        end
    end

    local scroll = Chili.ScrollPanel:New {
        parent = subwin,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
    }
    scroll.BorderTileImage = ":c:empty.png"
    scroll.BackgroundTileImage = ":c:empty.png"

    local tree = Chili.TreeView:New {
        parent = scroll,
        nodes = data,
        OnSelectNode = { NodeSelected },
    }    

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
end
