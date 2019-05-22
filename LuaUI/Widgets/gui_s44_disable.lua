function widget:GetInfo()
    return {
        name = "1944 Disable Game UI",
        desc = "Disable the ingame UI to enable the lobby one",
        author = "Jose Luis Cercos-Pita",
        date = "2019-05-20",
        license = "GPL v2",
        layer = 99999999,
        experimental = false,
        enabled = true,
    }
end

-- syntax + defaults from https://github.com/spring/spring/blob/104.0/doc/uikeys.txt
-- complex syntax: https://springrts.com/wiki/Uikeys.txt

local widgets = {
    "Faction Change",
    "1944 Aircraft Selection Buttons",
    "1944 Build Indicators",
    "1944 Flag Income",
    "1944 Flag Ranges",
    "1944 Minefield Warning",
    "1944 Minimum Ranges",
    "1944 Player List Echo for Stats",
    "1944 Ranks",
    "1944 Resource Bars",
    "1944 Selection Buttons",
    "1944 Supply Radius",
    "1944 Tooltip Replacement",
    "BuildBar",
    "BuildETA",
    "Chili Inactivity Win",
    "Chili Pro Console2",
    "External VR Grid",
    "Indirect Fire Accuracy",
    "S44 Healthbars",
    "Simple player list",
    "Take Reminder",  -- Just in case
    "Team Platter Expanded",
    "notAchili Framework",
}

local unbinds = {
    -- "f11",
    "Shift+esc",
}

local comms = {
    "resbar 0",
    "console 0",
    "tooltip 0",
}

function disableUI()
    for _,widget in pairs(widgets) do
        Spring.SendCommands({"luaui disablewidget " .. widget})
    end
    
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

function widget:Shutdown()
    -- Restore?? Don't needed at first glance
end
