function gadget:GetInfo()
    return {
        name = "Units initialization",
        desc = "Destroy all the units assigend at the beggining, and give a random new one",
        author = "Jose Luis Cercos-Pita",
        date = "2019-05-21",
        license = "GPL v2",
        layer = 0,
        enabled = true
    }
end

-- UNSYNCED
if not gadgetHandler:IsSyncedCode() then 
    return
end

-- SYNCED
local X, Y, Z = 9000, 14.5, 7615
local XS, YS, ZS = 9000, 0, 1200
local ALPHA = 60
local UNITNAME = "gerpanzerIII"
local FLAGNAMES = {"flag", "buoy"}

function isFlag(name)
    for _, flagName in ipairs(FLAGNAMES) do
        if name == flagName then
            return true
        end
    end
    return false
end

function removeUnits(units, skipflags)
    if skipflags == nil then
        skipflags = true
    end


    for _,unitID in ipairs(units) do
        local skip_unit = false
        if not skipflags or not isFlag(UnitDefs[Spring.GetUnitDefID(unitID)].name) then
            -- Detach and destroy children
            local children = Spring.GetUnitIsTransporting(unitID)
            if children ~= nil then
                for _, childID in ipairs(children) do
                    Spring.UnitDetach(childID)
                    Spring.DestroyUnit(childID, false, true)
                end
            end
            -- Destroy the unit itself
            Spring.DestroyUnit(unitID, false, true)
        end
    end    
end

function getCoordinates(name)
    local unitDef = UnitDefNames[name]
    if unitDef == nil then
        return X, Y, Z
    end
    local cparams = UnitDefNames[name].customParams
    local is_boat = cparams.wiki_parser == "boat" and not cparams.child
    local is_boatyard = cparams.wiki_parser == "yard" and unitDef.floatOnWater
    if is_boat or is_boatyard then
        return XS, YS, ZS
    end
    return X, Y, Z
end

function createUnit(unitname, x, y, z, alpha)
    unitname = unitname or UNITNAME
    local xx, yy, zz = getCoordinates(unitname)
    x = x or xx
    y = y or yy
    z = z or zz
    alpha = alpha or ALPHA

    local features = Spring.GetFeaturesInRectangle(x - 1.0, z - 1.0, x + 1.0, z + 1.0)
    for _, feature in ipairs(features) do
        Spring.DestroyFeature(feature)
    end

    local name, active, spectator, teamID
    for _, playerID in ipairs(Spring.GetPlayerList()) do
        name, active, spectator, teamID = Spring.GetPlayerInfo(playerID)
        if active then
            break
        end
    end
    local unitID = Spring.CreateUnit(unitname, x, y, z, 0, teamID)
    Spring.SetUnitNoSelect(unitID, true)
    Spring.SetUnitRotation(unitID, 0, math.rad(alpha), 0)
end

function updateUnit()
    units = Spring.GetAllUnits()
    createUnit()
    removeUnits(units)
end

function gadget:Initialize()
end

function gadget:GameFrame(n)
    if n < 2 or n > 2 then
        return
    end

    updateUnit()
end

-- keep track of choosing faction ingame
function gadget:RecvLuaMsg(msg, playerID)
    local code = string.sub(msg,1,1)
    if code ~= '\140' then
        return
    end

    UNITNAME = string.sub(msg,2,string.len(msg))
    updateUnit()
end


function gadget:GetConfigData(data)
    return {
        unitname   = UNITNAME,
    }
end

function gadget:SetConfigData(data)
    UNITNAME = data.unitname or UNITNAME
end
