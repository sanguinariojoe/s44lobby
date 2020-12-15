function widget:GetInfo()
    return {
        name = "lobby2game",
        desc = "Controls lobby-game interoperatibility",
        author = "Jose Luis Cercos-Pita",
        date = "2020-06-01",
        license = "GPL v2",
        layer = 0,
        experimental = false,
        enabled = true,
    }
end 

WG.LOBBY2GAME = {
    launched_by_lobby = false,
}

function widget:GetConfigData()
    Spring.Echo("widget:GetConfigData")
    return {
        launched_by_lobby = WG.LOBBY2GAME.launched_by_lobby,
    }
end

function widget:SetConfigData(data)
    Spring.Echo("widget:SetConfigData")
    -- No matters what configuration says, we want to start as not launched
    -- by lobby, and just when the lobby launchs the game, overwrite
    -- WG.LOBBY2GAME.launched_by_lobby for widget:GetConfigData()
    data.launched_by_lobby = false
end
