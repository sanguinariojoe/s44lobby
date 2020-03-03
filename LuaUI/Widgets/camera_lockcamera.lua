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

WG.look_at_x = 8990
WG.look_at_y = 14
WG.look_at_z = 7620
WG.look_height = 262

local CAMERADATA = {
    name = ta,
    mode = 1,
    flipped = -1,
    px = WG.look_at_x,
    py = WG.look_at_y,
    pz = WG.look_at_z,
    height = WG.look_height,
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
        local camera_data = CAMERADATA
        camera_data.px = WG.look_at_x
        camera_data.py = WG.look_at_y
        camera_data.pz = WG.look_at_z
        camera_data.height = WG.look_height
        Spring.SetCameraState(camera_data, 1)
    end
end
