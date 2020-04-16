local Chili = WG.Chili

BattleRoomWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

battleroom_win = nil
ICONS_FOLDER = "LuaUI/Widgets/gui_menu/rsrc/"
MINIMAPS_FOLDER = "s44lobby/minimaps/"

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/list.lua")
VFS.Include("LuaUI/Widgets/gui_menu/lobby/chat.lua")

--//=============================================================================

local function _getLobby(self)
    local obj = self.parent
    while obj ~= nil and obj.classname ~= "LobbyWindow" do
        obj = obj.parent
    end
    if obj == nil then
        Spring.Log("Menu",
                   LOG.ERROR,
                   "Battleroom without LobbyWindow parent")
    end

    return obj
end

local function _loginName(self)
    return _getLobby(self).log_win.user.text
end

local function _changeTab(self)
    local obj = _getLobby(self).tabs
    obj.tabbar:Select("Battle room")
    obj.tabbar:DisableHighlight()
    obj.tabbar:EnableHighlight()
end

local function _ChatInput(self, key, mods, isRepeat, label, unicode, ...)
    if Spring.GetKeyCode("enter") ~= key then
        return
    end
    local text = self.text
    self:SetText("")
    local obj = self.parent
    WG.LibLobby.lobby:SayBattle(text)

    -- The server already will send a SaidBattle command echo, so no need to add
    -- the message
    --[[
    if obj.logName == nil then
        obj.logName = _loginName(obj)
    end
    NewMessage(obj, obj.logName, text)
    --]]
end

local function _UserStatusIcon(status)
    if status.isSpectator then
        return '\204\131'
    elseif not status.sync then
        return '\204\135'
    end

    if status.isReady then
        return '\204\136'
    end
    return 'x'
end

local function _OnSpec(self)
    obj = self.parent
    local lobby = WG.LibLobby.lobby
    local isSpec = lobby:GetUserBattleStatus(lobby:GetMyUserName()).isSpectator

    if not isSpec or obj.auto_unspec then
        obj.auto_unspec = false
        lobby:SetBattleStatus({isSpectator = true, isReady = true})
        -- self:SetCaption("Spectator")
    else
        obj.auto_unspec = true
        lobby:SetBattleStatus({isSpectator = false, isReady = true})
        -- self:SetCaption("Joining")
    end
end

local function _SetMinimap(obj)
    local lobby = WG.LibLobby.lobby
    local battle = lobby:GetBattle(lobby:GetMyBattleID())
    local minimap_folder = MINIMAPS_FOLDER .. battle.mapName
    local minimap_file = minimap_folder .. "/minimap.png"
    if not VFS.FileExists(minimap_file) then
        WG.GetMinimap(battle.mapName, minimap_folder)
    end
    obj.map.file = minimap_file
end

local function _CheckDownload(name, category)
    local lobby = WG.LibLobby.lobby
    local battle = lobby:GetBattle(lobby:GetMyBattleID())
    if battle == nil then
        return nil
    end
    if category == "engine" then
        return name == battle.engineName .. " " .. battle.engineVersion
    elseif category == "game" then
        return name == battle.gameName
    elseif category == "map" then
        return name == battle.mapName
    else
        return false
    end
end

local function _OnDownloadProgress(name, category, progress)
    if not _CheckDownload(name, category) then
        return
    end

    local obj = battleroom_win
    if progress == 0 then
        return
    end
    obj.download_progress[category] = progress
    local total_progress, n = 0, 0
    for _, p in pairs(obj.download_progress) do
        total_progress = total_progress + p
        n = n + 1
    end
    total_progress = math.floor(100.0 * total_progress / n)
    obj.download:SetValue(total_progress)
    if obj.download.caption ~= "Failed" then
        obj.download:SetCaption(tostring(total_progress) .. "%")
    end
end

local function _OnDownloadFailed(name, category)
    if not _CheckDownload(name, category) then
        return
    end

    local obj = battleroom_win
    Spring.Log("Menu",
               LOG.ERROR,
               "Failure downloading " .. category .. " '" .. name .. "'")
    obj.download:SetCaption("Failed")
end

local function _OnDownloadFinished(name, category)
    if not _CheckDownload(name, category) then
        return
    end

    local obj = battleroom_win
    obj.download_progress[category] = 1.0
    local progress, n = 0, 0
    for _, p in pairs(obj.download_progress) do
        progress = progress + p
        n = n + 1
    end
    progress = math.floor(100.0 * progress / n + 0.5)
    if progress >= 100 then
        obj.download:SetCaption("Finished")
        obj.download:Hide()
        _SetMinimap(obj)
    end
end

local function _Download(name, category)
    local obj = battleroom_win
    obj.download_progress[category] = 0
    obj.map.file = ICONS_FOLDER .. "download_icon.png"
    obj.download:SetValue(0)
    obj.download:SetCaption("0%")
    obj.download:Show()
    WG.DownloadArchive(name, category, {
        DownloadProgress = _OnDownloadProgress,
        DownloadFailed = _OnDownloadFailed,
        DownloadFinished = _OnDownloadFinished})
end

function BattleRoomWindow:New(obj)
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = ":cl:empty.png"
    obj.padding = obj.padding or {0, 0, 0, 0}
    obj.classname = "BattleRoomWindow"
    obj.download_progress = {}
    -- Auto-unspec status:
    -- 0 = Don't do anything
    -- 1 = Try to unspec
    -- 2 = Wait for results
    obj.auto_unspec = false

    obj = BattleRoomWindow.inherited.New(self, obj)

    obj.map = Chili.Image:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '20%',
        height = '30%',
        file = ICONS_FOLDER .. "download_icon.png",
    }

    -- Download progress bar that would replace the image while working
    obj.download = Chili.Progressbar:New {
        parent = obj.map,
        x = '0%',
        y = '40%',
        width = '100%',
        height = '20%',
        value = 0,
        caption = "0%",
        color = {1,1,0.6,1},
        backgroundColor = {0.05,0.05,0.05,0.5},
    }
    obj.download:Hide()

    obj.mod_opts = ListWidget:New {
        parent = obj,
        x = '0%',
        y = '30%',
        width = '20%',
        height = '70%',
        headers = {{
            caption = 'Option',
            width = '50%',
            fontsize = 14,
        },
        {
            caption = 'Value',
            width = '50%',
            fontsize = 14,
        }},
    }
    
    obj.chat_container = Chili.ScrollPanel:New {
        parent = obj,
        x = '20%',
        y = '0%',
        width = '60%',
        height = '95%',
        horizontalScrollbar = false,
        BorderTileImage = ":cl:empty.png",
        BackgroundTileImage = ":cl:empty.png",
    }
    obj.chat = Chili.TextBox:New {
        parent = obj.chat_container,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        text = "",
    }

    obj.chat_input = Chili.EditBox:New {
        parent = obj,
        x = '20%',
        y = '95%',
        width = '60%',
        height = '5%',
        text = "",
        OnKeyPress = { _ChatInput },
    }

    obj.users = ListWidget:New {
        parent = obj,
        x = '80%',
        y = '0%',
        width = '20%',
        height = '95%',
        headers = {{
            caption = 'Users',
            width = '70%',
            fontsize = 14,
        },
        {
            caption = '\204\130',
            width = '15%',
            fontsize = 14,
        },
        {
            caption = '\204\134',
            width = '15%',
            fontsize = 14,
        }},
        order_id = 3,
    }

    obj.spec_button = Chili.Button:New {
        parent = obj,
        x = '80%',
        y = '95%',
        width = '20%',
        height = '5%',
        caption = "Joining",
        OnClick = { _OnSpec },
    }

    -- Events
    local lobby = WG.LibLobby.lobby
    lobby:AddListener("OnJoinBattle",
        function(listener, battleID, hashCode)
            obj.battleID = battleID
            obj.hashCode = hashCode
            obj.auto_unspec = true
            obj.spec_button:SetCaption("Joining")

            local battle = lobby:GetBattle(battleID)
            obj.download_progress = {}
            local engineName = battle.engineName .. " " .. battle.engineVersion
            if not VFS.HasArchive(engineName) then
                -- TODO: For the time being this is always happening... A
                -- reliable way to look for available engines is required
                _Download(engineName, "engine")
            end
            if not VFS.HasArchive(battle.gameName) then
                _Download(battle.gameName, "game")
            end
            if not VFS.HasArchive(battle.mapName) then
                _Download(battle.mapName, "map")
            end

            _changeTab(obj)

            obj.users:ClearEntries()
            for _, userName in ipairs(battle.users) do
                local data = {
                    userName = userName,
                    scriptPassword = nil,
                    fields = {userName, ' ', ' '},
                    OnClick = nil,
                }
                obj.users:AddEntry(data)
            end

            obj.chat:SetText("")
        end
    )
    lobby:AddListener("OnUpdateBattleInfo",
        function(listener, battleID)
            if battleID ~= lobby:GetMyBattleID() then
                return
            end
            local battle = lobby:GetBattle(battleID)
            obj.download_progress = {}
            local engineName = battle.engineName .. " " .. battle.engineVersion
            if not VFS.HasArchive(engineName) then
                -- TODO: For the time being this is always happening... A
                -- reliable way to look for available engines is required
                _Download(engineName, "engine")
            end
            if not VFS.HasArchive(battle.gameName) then
                _Download(battle.gameName, "game")
            end
            if not VFS.HasArchive(battle.mapName) then
                _Download(battle.mapName, "map")
            end
        end
    )
    lobby:AddListener("OnJoinedBattle",
        function(listener, battleID, userName, scriptPassword)
            if battleID ~= obj.battleID or FindUser(obj, userName) ~= nil then
                return
            end

            local data = {
                userName = userName,
                scriptPassword = scriptPassword,
                fields = {userName, ' ', ' '},
                OnClick = nil,
            }
            obj.users:AddEntry(data)
        end
    )
    lobby:AddListener("OnLeftBattle",
        function(listener, battleID, userName)
            if battleID ~= obj.battleID then
                return
            end

            local i = FindUser(obj, userName)
            if i == nil then
                Spring.Log("Menu",
                           LOG.WARNING,
                           "Untracked user " .. userName .. " left the battle")
                return
            end
            obj.users:RemoveEntry(i)
        end
    )
    lobby:AddListener("OnUpdateUserBattleStatus",
        function(listener, userName, status)
            local i = FindUser(obj, userName)
            if i == nil then
                return
            end

            local entry = obj.users.entries[i]
            entry.status = status
            if status.isSpectator then
                entry.fields[2] = ' '
                entry.fields[3] = ' '
            else
                entry.fields[2] = tostring(status.teamNumber)
                entry.fields[3] = tostring(status.allyNumber)
            end
            obj.users:UpdateEntry(i, entry)

            if userName == lobby:GetMyUserName() then
                if not status.isSpectator then
                    obj.spec_button:SetCaption("Joined")
                elseif obj.auto_unspec then
                    obj.spec_button:SetCaption("Joining")
                else
                    obj.spec_button:SetCaption("Spectator")
                end
            elseif obj.auto_unspec then
                lobby:SetBattleStatus({isSpectator = false,
                                       isReady = true})
            end
        end
    )

    lobby:AddListener("OnSaidBattle",
        function(listener, userName, message)
            NewMessage(obj, userName, message)
        end
    )
    lobby:AddListener("OnSaidBattleEx",
        function(listener, userName, message)
            NewMessage(obj, userName, message)
        end
    )

    lobby:AddListener("OnSetModOptions",
        function(listener, data)
            for k,v in pairs(data) do
                local entry = {
                    fields = {k, v},
                    OnClick = nil,
                }
                obj.mod_opts:AddEntry(entry)
            end
        end
    )

    battleroom_win = obj

    return obj
end
