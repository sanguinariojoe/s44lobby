function widget:GetInfo()
    return {
        name = "LockCamera",
        desc = "Lock the camera pointing towards the target unit",
        author = "Jose Luis Cercos-Pita",
        date = "2019-05-21",
        license = "GPL v2",
        layer = -1,
        enabled = true
    }
end

local CAMERADATA = {
    name = ta,
    mode = 1,
    flipped = -1,
    px = 8990,
    py = 14,
    pz = 7620,
    height = 262,
    angle = 0.88474917,
    fov = 45,
    dx = 0,
    dy = -0.6340154,
    dz = -0.7745162,
}

------------------------------------------------
--speedups
------------------------------------------------
local GetCameraState = Spring.GetCameraState
local SetCameraState = Spring.SetCameraState

function widget:Initialize()
end

function widget:Shutdown()
end

function widget:Update(dt)
    -- Spring.SetCameraState(CAMERADATA)
end

function widget:GameFrame(n)
    --[[
    Spring.Echo("***Frame", n)
    for index,value in pairs(Spring.GetCameraState()) do
        Spring.Echo(index,value)
    end
    --]]
    if n % 30 == 0 then -- every second
        Spring.SetCameraState(CAMERADATA, 1)
    end
end
