local Chili = WG.Chili
local IconsFolder = "LuaUI/Widgets/gui_menu/rsrc/"
squadDefs = include("LuaRules/Configs/squad_defs.lua")
sortieDefs = include("LuaRules/Configs/sortie_defs.lua")
morphDefs = include("LuaRules/Configs/morph_defs.lua")

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

    return label.height + 20
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

function _parse_weapon(parent, unitDef, weapon, n, fontsize, x, y)
    if x == nil then x = 0 end
    if y == nil then y = 0 end

    weaponDef = WeaponDefs[weapon.weaponDef]

    -- We need to inspect the targets to look for weapons that actually
    -- targets nothing, used as helpers for units. Those weapons shall not
    -- be documented at all
    local targets = ""
    local name, value
    for name, value in pairs(weapon.onlyTargets) do
        if value then
            targets = targets .. name .. "\n"
        end
    end
    if targets == "none\n" then
        return y
    end

    local header = "\n" .. weaponDef.name .. " x " .. tostring(n) .. "\n"
    if weaponDef.customParams.wiki_comments ~= nil then
        header = header .. weaponDef.customParams.wiki_comments .. "\n"
    end
    
    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = header,
        font = {size = fontsize},
        x = x,
        y = y,
        width= "100%",
    }
    y = y + label.height

    -- Heading and Pitch data
    -- ======================
    local dir = weapon.mainDir or {weapon.mainDirX, weapon.mainDirY, weapon.mainDirZ}
    local angle = math.deg(math.acos(weapon.maxAngleDif))
    local minHeading, maxHeading, minPitch, maxPitch
    local pitchBase = math.deg(math.atan2(
        dir[2], math.sqrt(dir[1] * dir[1] + dir[3] * dir[3])))
    if pitchBase + angle > 90 then
        -- The barrel can be heading everywhere
        minHeading = -360
        maxHeading = 360
        minPitch = math.max(-90, pitchBase - angle)
        maxPitch = 90
    else
        local headingBase = math.deg(math.atan2(-dir[1], dir[3]))
        minHeading = headingBase - angle
        maxHeading = headingBase + angle
        minPitch = math.max(-90, pitchBase - angle)
        maxPitch = math.min(90, pitchBase + angle)
    end
    local speedHeading = unitDef.customParams.turretturnspeed or unitDef.turnRate * 0.16
    local speedPitch = unitDef.customParams.elevationspeed or speedHeading

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
                "gunheading_icon.png",
                "Min heading",
                string.format("%.1f", minHeading),
                fontsize)
    _table_item(grid,
                "gunpitch_icon.png",
                "Min pitch",
                string.format("%.1f", minPitch),
                fontsize)
    _table_item(grid,
                "gunheading_icon.png",
                "Max heading",
                string.format("%.1f", maxHeading),
                fontsize)
    _table_item(grid,
                "gunpitch_icon.png",
                "Max pitch",
                string.format("%.1f", maxPitch),
                fontsize)
    _table_item(grid,
                "gunheading_icon.png",
                "Heading speed",
                string.format("%.1f", speedHeading),
                fontsize)
    _table_item(grid,
                "gunpitch_icon.png",
                "Pitch speed",
                string.format("%.1f", speedPitch),
                fontsize)
    y = y + grid.height + 10

    -- Shot statistics
    -- ===============
    local pen100 = weaponDef.customParams.armor_penetration or 0
    local pen1000 = pen100
    if weaponDef.customParams.armor_penetration_100m then
        pen100 = weaponDef.customParams.armor_penetration_100m
    end
    if weaponDef.customParams.armor_penetration_1000m then
        pen1000 = weaponDef.customParams.armor_penetration_1000m
    end
    local salvoSize = weaponDef.salvoSize * weaponDef.projectiles
    local salvoTime = math.max(weaponDef.reload,
                               weaponDef.salvoSize * weaponDef.salvoDelay)

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 4,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 4 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "range_icon.png",
                "Range",
                string.format("%.1f", weaponDef.range),
                fontsize)
    _table_item(grid,
                "explosion_icon.png",
                "Effect radius",
                string.format("%.1f", weaponDef.damageAreaOfEffect or 0),
                fontsize)
    _table_item(grid,
                "accuracy_icon.png",
                "Inaccuracy",
                string.format("%.1f", weaponDef.accuracy),
                fontsize)
    _table_item(grid,
                "accuracy_icon.png",
                "Moving inaccuracy",
                string.format("%.1f", weaponDef.movingAccuracy),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "100m",
                string.format("%.1f", pen100),
                fontsize)
    _table_item(grid,
                "penetration.png",
                "1000m",
                string.format("%.1f", pen1000),
                fontsize)
    _table_item(grid,
                "reload_icon.png",
                "Fire rate",
                string.format("%.1f", salvoSize / salvoTime),
                fontsize)
    _table_item(grid,
                "ammo_icon.png",
                "Ammo cost",
                tostring(weaponDef.customParams.weaponcost or 0),
                fontsize)

    y = y + grid.height + 10

    -- Targets and damage inflicted
    -- ============================
    local damages = ""
    local name, damage
    for id, damage in pairs(weaponDef.damages) do
        if Game.armorTypes[id] ~= nil then
            local name = Game.armorTypes[id]
            damages = damages .. name .. ", " .. tostring(damage) .. "\n"
        end
    end
    local img = Chili.Image:New {
        parent = parent,
        file = IconsFolder .. "accuracy_icon.png",
        keepAspect = true,
        x = x,
        y = y,
        height = fontsize,
    }
    local label = Chili.TextBox:New {
        parent = parent,
        text = "Targets...",
        font = {size = fontsize},
        valign = "center",
        x = x + img.width + 5,
        y = y,
        width = parent.width - img.width - 5 - 10,
        minHeight = img.height
    }
    y = y + label.height + 5
    local label = Chili.TextBox:New {
        parent = parent,
        text = targets,
        font = {size = fontsize},
        valign = "center",
        x = x,
        y = y,
        width = parent.width - img.width - 5 - 10,
        minHeight = img.height
    }
    y = y + label.height + 10

    local img = Chili.Image:New {
        parent = parent,
        file = IconsFolder .. "explosion_icon.png",
        keepAspect = true,
        x = x,
        y = y,
        height = fontsize,
    }
    local label = Chili.TextBox:New {
        parent = parent,
        text = "Damages...",
        font = {size = fontsize},
        valign = "center",
        x = x + img.width + 5,
        y = y,
        width = parent.width - img.width - 5 - 10,
        minHeight = img.height
    }
    y = y + label.height + 5
    local label = Chili.TextBox:New {
        parent = parent,
        text = damages,
        font = {size = fontsize},
        valign = "center",
        x = x,
        y = y,
        width = parent.width - img.width - 5 - 10,
        minHeight = img.height
    }
    y = y + label.height + 10

    return y
end

function _parse_weapons(parent, header, unitDef, fontsize, x, y)
    if ((unitDef.customParams.wiki_parser == "boat") and unitDef.customParams.mother) then
        return y
    end

    if x == nil then x = 0 end
    if y == nil then y = 0 end

    local weapons = unitDef.weapons
    if weapons ~= nil and #weapons > 0 then
        if header ~= nil then
            local label = Chili.TextBox:New {
                parent = parent,
                text = header,
                font = {size = fontsize},
                x = x,
                y = y,
                width= "100%",
            }
            y = y + label.height
        end
        -- It may have several incidences of the same turret
        local n = {}
        for _, weapon in pairs(weapons) do
            local name = WeaponDefs[weapon.weaponDef].name

            if n[string.lower(name)] == nil then
                n[string.lower(name)] = 1
            else
                n[string.lower(name)] = n[string.lower(name)] + 1
            end
        end
        for _, weapon in pairs(weapons) do
            local name = WeaponDefs[weapon.weaponDef].name

            if n[string.lower(name)] ~= nil then
                y = _parse_weapon(parent, unitDef, weapon, n[string.lower(name)], fontsize, x + 13, y)
                n[string.lower(name)] = nil
            end
        end
    end

    return y
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

    return y + 10
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

    return y + 10
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

    return y + 10
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
        text = "\nLine of sight\n--------------------------\n",
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
        text = "\nMotion\n---------------\n",
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

    return y + 10
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
        text = "\nLine of sight\n--------------------------\n",
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
        text = "\nMotion\n---------------\n",
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

    return y + 10
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
        text = "\nLine of sight\n--------------------------\n",
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
        text = "\nMotion\n---------------\n",
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

    return y + 10
end

function _parse_turret(parent, unitDef, n, fontsize, x, y)
    if x == nil then x = 0 end
    if y == nil then y = 0 end

    y = y + 10
    local label = Chili.TextBox:New {
        parent = parent,
        text = "\n" .. unitDef.humanName .. " x " .. tostring(n) .. "\n",
        font = {size = fontsize},
        x = x,
        y = y,
        width= "100%",
    }
    y = y + label.height

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 1,
        columns = 2,
        x = x,
        y = y,
        width = "100%",
        minHeight = 1 * (32 + 13 * 2),
        autosize = true,
    }

    _table_item(grid,
                "heart_icon.png",
                "Health points",
                string.format("%.1f", unitDef.health),
                fontsize)
    if unitDef.customParams.maxammo ~= nil then
        _table_item(grid,
                    "ammo_icon.png",
                    "Max ammo",
                    tostring(unitDef.customParams.maxammo),
                    fontsize)
    end
    y = y + grid.height + 10

    y = _parse_weapons(parent, nil, unitDef, fontsize, x, y)

    return y
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
        text = "\nLine of sight\n--------------------------\n",
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
        text = "\nMotion\n---------------\n",
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

    -- Turrets
    y = y + 10
    if unitDef.customParams.mother and unitDef.customParams.children then
        local label = Chili.TextBox:New {
            parent = parent,
            text = "\nTurrets\n---------------\n",
            font = {size = fontsize},
            y = y,
            width= "100%",
        }
        y = y + label.height
        local children = loadstring("return " .. unitDef.customParams.children)()
        -- It may have several incidences of the same turret
        local n = {}
        for _, child in ipairs(children) do
            if n[string.lower(child)] == nil then
                n[string.lower(child)] = 1
            else
                n[string.lower(child)] = n[string.lower(child)] + 1
            end
        end
        for _, child in ipairs(children) do
            if n[string.lower(child)] ~= nil then
                local unitDef = UnitDefNames[string.lower(child)]
                y = _parse_turret(parent, unitDef, n[string.lower(child)], fontsize, 13, y)
                n[string.lower(child)] = nil
            end
        end
    end

    return y
end

function _squad_children(unitDef)
    if squadDefs[unitDef.name] == nil and sortieDefs[unitDef.name] == nil then
        -- Not a squad
        return {}
    end
    local squad = squadDefs[unitDef.name] or sortieDefs[unitDef.name]
    local members = {}
    local member
    for _, member in pairs(squad.members) do
        if members[member:lower()] == nil then
            members[member:lower()] = 1
        else
            members[member:lower()] = members[member:lower()] + 1
        end
    end
    return members
end

function _morph_children(unitDef)
    if morphDefs[unitDef.name] == nil then
        return {}
    end
    local morphs = {}
    local morph
    if morphDefs[unitDef.name].into ~= nil then
        morphs[#morphs + 1] = morphDefs[unitDef.name].into:lower()
    else
        for _, morph in ipairs(morphDefs[unitDef.name]) do
            morphs[#morphs + 1] = morph.into:lower()
        end
    end
    return morphs
end

function _parse_squad(parent, unitDef, fontsize)
    local y = 0

    local members = _squad_children(unitDef)
    if #members == 0 then
        return 0
    end

    local label = Chili.TextBox:New {
        parent = parent,
        text = "This is a team composed by the following members...",
        font = {size = fontsize},
        y = y,
        width = "100%",
    }

    y = label.height + 20

    for member, n in pairs(members) do
        local memberDef = UnitDefNames[member]
        local img = Chili.Image:New {
            parent = parent,
            file = 'unitpics/' .. memberDef.buildpicname,
            keepAspect = true,
            y = y,
            height = fontsize,
        }
        local label = Chili.TextBox:New {
            parent = parent,
            text = memberDef.humanName .. ' x ' .. n,
            font = {size = fontsize},
            valign = "center",
            x = img.width + 5,
            y = y,
            width = parent.width - img.width - 5 - 10,
            minHeight = img.height
        }
        y = y + label.height + 10
    end

    local grid = Chili.Grid:New {
        parent = parent,
        rows = 1,
        columns = 2,
        y = y,
        width = "100%",
        minHeight = 1 * (32 + 13 * 2),
        autosize = true,
    }

    local squad = squadDefs[unitDef.name] or sortieDefs[unitDef.name]
    _table_item(grid,
                "hammer_icon.png",
                "Build cost",
                tostring(squad.buildCostMetal),
                fontsize)
    y = y + grid.height

    return y + 10
end
