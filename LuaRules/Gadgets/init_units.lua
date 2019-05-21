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
local ALPHA = 60
local FLAGNAMES = {"flag", "buoy"}

function isFlag(name)
    for _, flagName in ipairs(FLAGNAMES) do
        if name == flagName then
            return true
        end
    end
    return false
end

function gadget:Initialize()
end

function gadget:GameFrame(n)
    if n < 2 or n > 2 then
        return
    end

    -- Get all the already existing units
    units = Spring.GetAllUnits()

    -- Create a new random unit
    local name, active, spectator, teamID
    for _, playerID in ipairs(Spring.GetPlayerList()) do
        name, active, spectator, teamID = Spring.GetPlayerInfo(playerID)
        if active then
            break
        end
    end
    --[[
    unitDef = UnitDefs[math.random(#UnitDefs)]
    local name = unitDef.name
    --]]
    local name = "gerpanzerIII"
    local unitID = Spring.CreateUnit(name, X, Y, Z, 0, teamID)
    Spring.SetUnitRotation(unitID, 0, math.rad(ALPHA), 0)

    for _,unitID in pairs(units) do
        if not isFlag(UnitDefs[Spring.GetUnitDefID(unitID)].name) then
            Spring.DestroyUnit(unitID, false, true)
        end
    end
end
