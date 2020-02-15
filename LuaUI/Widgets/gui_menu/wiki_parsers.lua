local Chili = WG.Chili
local IconsFolder = "LuaUI/Widgets/gui_menu/rsrc/"

function _create_description(parent, unitDef, fontsize, header, y)
    txt = header .. '\n'
    if unitDef.customParams.wiki_subclass_comments then
        txt = txt .. unitDef.customParams.wiki_subclass_comments .. '\n'
    end
    if unitDef.customParams.wiki_comments then
        txt = txt .. unitDef.customParams.wiki_comments .. '\n'
    end

    local label = Chili.TextBox:New {
        parent = parent,
        text = txt,
        font = {size = fontsize},
        y = y,
        width = "100%",
    }

    return label.height
end

function _table_item(grid, img, title, txt, fontsize, y)
    local subgrid = Chili.Grid:New {
        parent = grid,
        rows = 1,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = fontsize + 13 * 2,
        padding = {0, 0, 0, 0},
        resizeItems = false,
    }

    local subsubgrid = Chili.Window:New {
        TileImage = ":cl:empty.png",
        parent = subgrid,
        height = fontsize,
        resizable = false,
        draggable = false,
        padding = {0, 0, 0, 0},
    }
    local img = Chili.Image:New {
        parent = subsubgrid,
        file = IconsFolder .. img,
        keepAspect = true,
        x = 0, --0.5 * (subsubgrid.width - fontsize),
        y = 0,
        height = 2 * fontsize,
    }
    local label = Chili.Label:New {
        parent = subsubgrid,
        caption = title,
        font = {size = 8},
        x = 0,
        y = 2 * fontsize,
        height = 8,
    }
    subsubgrid.width = label.width
    label.x = 0.5 * (subsubgrid.width - label.width)

    local label = Chili.Label:New {
        parent = subgrid,
        caption = txt,
        font = {size = fontsize},
        width="100%",
        height="100%",
    }

    return subgrid.height
end

function _create_categories(parent, unitDef, fontsize, y)
    if y == nil then y = 0 end

    local img = Chili.Image:New {
        parent = parent,
        file = IconsFolder .. "accuracy_icon.png",
        keepAspect = true,
        y = y,
        height = fontsize,
    }
    local label = Chili.TextBox:New {
        parent = parent,
        text = "Targeted as...",
        font = {size = fontsize},
        valign = "center",
        x = img.width + 5,
        y = y,
        width = parent.width - img.width - 5 - 10,
        minHeight = img.height
    }
    y = y + label.height + 5

    local categories = ""
    for name, value in pairs(unitDef.modCategories) do
        if value then
            categories = categories .. name .. ", "
        end
    end

    local label = Chili.TextBox:New {
        parent = parent,
        text = categories,
        font = {size = fontsize},
        y = y,
        width = "100%",
        minHeight = fontsize,
    }
    y = y + label.height + 10

    local img = Chili.Image:New {
        parent = parent,
        file = IconsFolder .. "explosion_icon.png",
        keepAspect = true,
        y = y,
        height = fontsize,
    }
    local label = Chili.TextBox:New {
        parent = parent,
        text = "Damaged as...",
        font = {size = fontsize},
        valign = "center",
        x = img.width + 5,
        y = y,
        width = parent.width - img.width - 5 - 10,
        minHeight = img.height
    }
    y = y + label.height + 5

    local label = Chili.TextBox:New {
        parent = parent,
        text = Game.armorTypes[unitDef.armorType],
        font = {size = fontsize},
        y = y,
        width = "100%",
        minHeight = fontsize,
    }

    return y + label.height + 10
end

function _parse_yard(parent, unitDef, fontsize)
    local header = "This is a yard, i.e. a static building meant to recruit/build new units. Buildings in general are expensive and fragile critical units, that should indeed be placed far away from enemy sight and fire."

    local y = _create_description(parent, unitDef, fontsize, header)

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nStructural details\n---------------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "hammer_icon.png",
                "Build cost",
                tostring(unitDef.metalCost),
                fontsize)
    _table_item(grid,
                "clock_icon.png",
                "Build time",
                tostring(unitDef.buildTime / unitDef.buildSpeed),
                fontsize)
    
    _table_item(grid,
                "heart_icon.png",
                "Health points",
                string.format("%.1f", unitDef.health),
                fontsize)
    _table_item(grid,
                "ammo_icon.png",
                "Supply range",
                tostring(unitDef.customParams.supplyrange),
                fontsize)
    y = y + grid.height

    y = _create_categories(parent, unitDef, fontsize, y)
end

function _parse_storage(parent, unitDef, fontsize)
    local header = "This is a storage, i.e. a static building meant to store ammo. You really don't want to run out of ammo, so ensure to have several ammo storages. On the other hand, storages are quite expensive structures, so don't spam too much storages, or they'll drain your precious command points, and build them as spaced as possible to avoid a chain destruction in a single strike.\nOf course, this units should be placed as far away as possible of enemy fire."

    local y = _create_description(parent, unitDef, fontsize, header)

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nStructural details\n---------------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "hammer_icon.png",
                "Build cost",
                tostring(unitDef.metalCost),
                fontsize)
    local buildSpeed = unitDef.buildSpeed
    if buildSpeed == nil or buildSpeed == 0 then
        buildSpeed = 1
    end
    _table_item(grid,
                "clock_icon.png",
                "Build time",
                tostring(unitDef.buildTime / buildSpeed),
                fontsize)
    
    _table_item(grid,
                "heart_icon.png",
                "Health points",
                string.format("%.1f", unitDef.health),
                fontsize)
    _table_item(grid,
                "ammo_icon.png",
                "Ammo capacity",
                tostring(unitDef.energyStorage),
                fontsize)
    y = y + grid.height

    y = _create_categories(parent, unitDef, fontsize, y)
end

function _parse_supplies(parent, unitDef, fontsize)
    local header = "This is a supply spot. Its very only objective is providing an ammo resupply area that your units may conveniently use.\nSupply spots are always very fragile, so althought they may be cheap units, try to keep away from fire."

    local y = _create_description(parent, unitDef, fontsize, header)

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nStructural details\n---------------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "hammer_icon.png",
                "Build cost",
                tostring(unitDef.metalCost),
                fontsize)
    local buildSpeed = unitDef.buildSpeed
    if buildSpeed == nil or buildSpeed == 0 then
        buildSpeed = 1
    end
    _table_item(grid,
                "clock_icon.png",
                "Build time",
                tostring(unitDef.buildTime / buildSpeed),
                fontsize)
    
    _table_item(grid,
                "heart_icon.png",
                "Health points",
                string.format("%.1f", unitDef.health),
                fontsize)
    _table_item(grid,
                "ammo_icon.png",
                "Supply range",
                tostring(unitDef.customParams.supplyrange),
                fontsize)
    y = y + grid.height

    y = _create_categories(parent, unitDef, fontsize, y)
end

function _parse_infantry(parent, unitDef, fontsize)
    local header = "This is an infantry soldier. Soldiers are the basic unit in Spring-1944, and you always want to have a number of them deployed along the battlefield... Don't stop recruiting them!\nAlong this line, infantry units are the very only units that can capture terrain flags, and are one of the most efficient ways to provide a line of sight for armoured vehicles (it should be recalled that vehicles have in general a quite limite sight distance).\nInfantry is cheap, but very fragile... And vulnerable to almost every weapon of the game. On top of that, infantry can be easily suppressed by fear."

    local y = _create_description(parent, unitDef, fontsize, header)

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nStructural details\n---------------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "hammer_icon.png",
                "Build cost",
                tostring(unitDef.metalCost),
                fontsize)
    _table_item(grid,
                "heart_icon.png",
                "Health points",
                string.format("%.1f", unitDef.health),
                fontsize)
    _table_item(grid,
                "flag_icon.png",
                "Flag capturing",
                tostring(unitDef.customParams.flagcaprate or 0),
                fontsize)
    y = y + grid.height

    y = _create_categories(parent, unitDef, fontsize, y)

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nLine of sight\n-----------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "binocs_icon.png",
                "Sight range",
                string.format("%.1f", unitDef.losRadius),
                fontsize)
    _table_item(grid,
                "airplane_icon.png",
                "Air detect",
                string.format("%.1f", unitDef.airLosRadius),
                fontsize)
    
    _table_item(grid,
                "tank_icon.png",
                "Noise detect",
                string.format("%.1f", unitDef.seismicRadius),
                fontsize)
    y = y + grid.height

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nMotion\n-----------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "run_icon.png",
                "Max speed",
                string.format("%.1f", unitDef.speed / 8.0 * 3.6),
                fontsize)
    _table_item(grid,
                "turn_icon.png",
                "Turn rate",
                string.format("%.1f", unitDef.turnRate * 0.16),
                fontsize)
    
    _table_item(grid,
                "slope_icon.png",
                "Max slope",
                string.format("%.1f", unitDef.moveDef.maxSlope),
                fontsize)
    _table_item(grid,
                "water_icon.png",
                "Max water depth",
                string.format("%.1f", (unitDef.moveDef.depth or 0) / 8.0),
                fontsize)
    y = y + grid.height
end

function _parse_vehicle(parent, unitDef, fontsize)
    local header = "Vehicles are in general faster and stronger than infantry, becoming by themselves a determinant factor in terrain battles. However, vehicles have some significant drawbacks to be considered as well: In general, manufacturing vehicles is not a cheap operation, and their line of sight is quite limited, usually requiring some infantry scouting support."

    local y = _create_description(parent, unitDef, fontsize, header)

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nStructural details\n---------------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 3,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 3 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "hammer_icon.png",
                "Build cost",
                tostring(unitDef.metalCost),
                fontsize)
    _table_item(grid,
                "heart_icon.png",
                "Health points",
                string.format("%.1f", unitDef.health),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "Front armour",
                tostring(unitDef.customParams.armor_front or 0),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "Rear armour",
                tostring(unitDef.customParams.armor_rear or 0),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "Sides armour",
                tostring(unitDef.customParams.armor_side or 0),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "Top armour",
                tostring(unitDef.customParams.armor_top or 0),
                fontsize)
    y = y + grid.height

    y = _create_categories(parent, unitDef, fontsize, y)

    if unitDef.customParams.maxammo ~= nil then
        local img = Chili.Image:New {
            parent = parent,
            file = IconsFolder .. "ammo_icon.png",
            keepAspect = true,
            y = y,
            height = fontsize,
        }
        local label = Chili.TextBox:New {
            parent = parent,
            text = "Max ammo...",
            font = {size = fontsize},
            valign = "center",
            x = img.width + 5,
            y = y,
            width = parent.width - img.width - 5 - 10,
            minHeight = img.height
        }
        y = y + label.height + 5

        local label = Chili.TextBox:New {
            parent = parent,
            text = tostring(unitDef.customParams.maxammo),
            font = {size = fontsize},
            y = y,
            width = "100%",
            minHeight = fontsize,
        }
        y = y + label.height + 10
    end
    
    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nLine of sight\n-----------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "binocs_icon.png",
                "Sight range",
                string.format("%.1f", unitDef.losRadius),
                fontsize)
    _table_item(grid,
                "airplane_icon.png",
                "Air detect",
                string.format("%.1f", unitDef.airLosRadius),
                fontsize)
    
    _table_item(grid,
                "tank_icon.png",
                "Noise detect",
                string.format("%.1f", unitDef.seismicRadius),
                fontsize)
    y = y + grid.height

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nMotion\n-----------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "run_icon.png",
                "Max speed",
                string.format("%.1f", unitDef.speed / 8.0 * 3.6),
                fontsize)
    _table_item(grid,
                "turn_icon.png",
                "Turn rate",
                string.format("%.1f", unitDef.turnRate * 0.16),
                fontsize)
    
    _table_item(grid,
                "slope_icon.png",
                "Max slope",
                string.format("%.1f", unitDef.moveDef.maxSlope),
                fontsize)
    _table_item(grid,
                "water_icon.png",
                "Max water depth",
                string.format("%.1f", (unitDef.moveDef.depth or 0) / 8.0),
                fontsize)
    y = y + grid.height
end

function _parse_aircraft(parent, unitDef, fontsize)
    local header = "This is an aircraft. Aircrafts are specially expensive to manufacture, althought a significant percentage of the expent command points are recovered if the aircraft comes back home, depending on the damage received during the incursion. Thus, you should try to carry out precise strikes without an excessive risk"

    local y = _create_description(parent, unitDef, fontsize, header)

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nStructural details\n---------------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 1,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 1 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "hammer_icon.png",
                "Build cost",
                tostring(unitDef.metalCost),
                fontsize)
    _table_item(grid,
                "heart_icon.png",
                "Health points",
                string.format("%.1f", unitDef.health),
                fontsize)
    y = y + grid.height

    y = _create_categories(parent, unitDef, fontsize, y)

    if unitDef.customParams.maxammo ~= nil then
        local img = Chili.Image:New {
            parent = parent,
            file = IconsFolder .. "ammo_icon.png",
            keepAspect = true,
            y = y,
            height = fontsize,
        }
        local label = Chili.TextBox:New {
            parent = parent,
            text = "Max ammo...",
            font = {size = fontsize},
            valign = "center",
            x = img.width + 5,
            y = y,
            width = parent.width - img.width - 5 - 10,
            minHeight = img.height
        }
        y = y + label.height + 5

        local label = Chili.TextBox:New {
            parent = parent,
            text = tostring(unitDef.customParams.maxammo),
            font = {size = fontsize},
            y = y,
            width = "100%",
            minHeight = fontsize,
        }
        y = y + label.height + 10
    end

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nLine of sight\n-----------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "binocs_icon.png",
                "Sight range",
                string.format("%.1f", unitDef.losRadius),
                fontsize)
    _table_item(grid,
                "airplane_icon.png",
                "Air detect",
                string.format("%.1f", unitDef.airLosRadius),
                fontsize)
    _table_item(grid,
                "tank_icon.png",
                "Noise detect",
                string.format("%.1f", unitDef.seismicRadius),
                fontsize)
    y = y + grid.height

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nMotion\n-----------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "run_icon.png",
                "Max speed",
                string.format("%.1f", unitDef.speed / 8.0 * 3.6),
                fontsize)
    _table_item(grid,
                "turn_icon.png",
                "Turn rate",
                string.format("%.1f", unitDef.turnRate * 0.16),
                fontsize)
    
    _table_item(grid,
                "fuel_icon.png",
                "Max fuel",
                string.format("%.1f", unitDef.customParams.maxfuel),
                fontsize)
    y = y + grid.height
end

function _parse_boat(parent, unitDef, fontsize)
    local header = "Boats are the units meant to move and fight by water. In some battle theaters water is just another way to move troops, while in some others a significant number of flags (and tehrefore income) are placed in water, wo you will need a strong army to dispute them."

    local y = _create_description(parent, unitDef, fontsize, header)

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nStructural details\n---------------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 3,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 3 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "hammer_icon.png",
                "Build cost",
                tostring(unitDef.metalCost),
                fontsize)
    _table_item(grid,
                "heart_icon.png",
                "Health points",
                string.format("%.1f", unitDef.health),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "Front armour",
                tostring(unitDef.customParams.armor_front or 0),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "Rear armour",
                tostring(unitDef.customParams.armor_rear or 0),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "Sides armour",
                tostring(unitDef.customParams.armor_side or 0),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "Top armour",
                tostring(unitDef.customParams.armor_top or 0),
                fontsize)
    y = y + grid.height

    y = _create_categories(parent, unitDef, fontsize, y)

    if unitDef.customParams.maxammo ~= nil then
        local img = Chili.Image:New {
            parent = parent,
            file = IconsFolder .. "ammo_icon.png",
            keepAspect = true,
            y = y,
            height = fontsize,
        }
        local label = Chili.TextBox:New {
            parent = parent,
            text = "Max ammo...",
            font = {size = fontsize},
            valign = "center",
            x = img.width + 5,
            y = y,
            width = parent.width - img.width - 5 - 10,
            minHeight = img.height
        }
        y = y + label.height + 5

        local label = Chili.TextBox:New {
            parent = parent,
            text = tostring(unitDef.customParams.maxammo),
            font = {size = fontsize},
            y = y,
            width = "100%",
            minHeight = fontsize,
        }
        y = y + label.height + 10
    end

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nLine of sight\n-----------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "binocs_icon.png",
                "Sight range",
                string.format("%.1f", unitDef.losRadius),
                fontsize)
    _table_item(grid,
                "airplane_icon.png",
                "Air detect",
                string.format("%.1f", unitDef.airLosRadius),
                fontsize)
    _table_item(grid,
                "tank_icon.png",
                "Noise detect",
                string.format("%.1f", unitDef.seismicRadius),
                fontsize)
    y = y + grid.height

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nMotion\n-----------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "run_icon.png",
                "Max speed",
                string.format("%.1f", unitDef.speed / 8.0 * 3.6),
                fontsize)
    _table_item(grid,
                "turn_icon.png",
                "Turn rate",
                string.format("%.1f", unitDef.turnRate * 0.16),
                fontsize)
    
    _table_item(grid,
                "water_icon.png",
                "Min depth",
                string.format("%.1f", unitDef.moveDef.depth),
                fontsize)
    y = y + grid.height
end

function _parse_turret(parent, unitDef, fontsize)
    local header = "This is a turret. The turrets are substructures attached to a main vehicle/structure. They can be disabled one by one, or even got suppressed by enemy fire depending on the specific turret. However, the very only way to completely destroy a turret is destroying the owner vehicle/structure."

    local y = _create_description(parent, unitDef, fontsize, header)

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nStructural details\n---------------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 3,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 3 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "hammer_icon.png",
                "Build cost",
                tostring(unitDef.metalCost),
                fontsize)
    _table_item(grid,
                "heart_icon.png",
                "Health points",
                string.format("%.1f", unitDef.health),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "Front armour",
                tostring(unitDef.customParams.armor_front or 0),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "Rear armour",
                tostring(unitDef.customParams.armor_rear or 0),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "Sides armour",
                tostring(unitDef.customParams.armor_side or 0),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "Top armour",
                tostring(unitDef.customParams.armor_top or 0),
                fontsize)
    y = y + grid.height

    y = _create_categories(parent, unitDef, fontsize, y)

    if unitDef.customParams.maxammo ~= nil then
        local img = Chili.Image:New {
            parent = parent,
            file = IconsFolder .. "ammo_icon.png",
            keepAspect = true,
            y = y,
            height = fontsize,
        }
        local label = Chili.TextBox:New {
            parent = parent,
            text = "Max ammo...",
            font = {size = fontsize},
            valign = "center",
            x = img.width + 5,
            y = y,
            width = parent.width - img.width - 5 - 10,
            minHeight = img.height
        }
        y = y + label.height + 5

        local label = Chili.TextBox:New {
            parent = parent,
            text = tostring(unitDef.customParams.maxammo),
            font = {size = fontsize},
            y = y,
            width = "100%",
            minHeight = fontsize,
        }
        y = y + label.height + 10
    end

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\nLine of sight\n-----------------------------------\n",
        font = {size = fontsize},
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 2,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 2 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "binocs_icon.png",
                "Sight range",
                string.format("%.1f", unitDef.losRadius),
                fontsize)
    _table_item(grid,
                "airplane_icon.png",
                "Air detect",
                string.format("%.1f", unitDef.airLosRadius),
                fontsize)
    _table_item(grid,
                "tank_icon.png",
                "Noise detect",
                string.format("%.1f", unitDef.seismicRadius),
                fontsize)
    y = y + grid.height
end
