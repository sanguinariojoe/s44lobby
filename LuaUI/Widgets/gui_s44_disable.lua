function widget:GetInfo()
    return {
        name = "1944 Disable Game UI",
        desc = "Disable the ingame UI to enable the lobby one",
        author = "Jose Luis Cercos-Pita",
        date = "2019-05-20",
        license = "GNU GPL v2",
        layer = 99999999,
        experimental = false,
        enabled = true,
    }
end

local unbinds = {
    -- "f11",
    "Any+enter",
    "Shift+esc",
}

local comms = {
    "resbar 0",
    "console 0",
    "tooltip 0",
}

function disableUI()
    for _,unbind in pairs(unbinds) do
        Spring.SendCommands({"unbindkeyset " .. unbind})
    end

    for _,comm in pairs(comms) do
        Spring.SendCommands({comm})
    end

    -- Finally, remove the minimap
    gl.SlaveMiniMap(true)    
end

function widget:Initialize()
    disableUI()
end

function widget:GameFrame(n)
    if n <= 1 then
        -- A last try to remove some persistent widgets
        disableUI()
    end
end
