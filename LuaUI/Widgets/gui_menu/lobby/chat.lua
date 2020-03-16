local Chili = WG.Chili

ChatWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

local MAX_CHAT_LENGTH = 2500

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/list.lua")
local FitString = StringUtilities.GetTruncatedStringWithDotDot

--//=============================================================================

local function _CompileMessage(obj, author, msg)
    local head = ""
    if obj.chat.last_author ~= author then
        head = head .. ' \n    <' .. author .. '> : \n'
    end
    obj.chat.last_author = author
    return head .. msg:gsub("\\n", "\n")
end

local function _CropChat(text)
    if string.len(text) <= MAX_CHAT_LENGTH then
        return text
    end

    -- Just simply drop characters from the beggining
    local crop = string.sub(text, string.len(text) - MAX_CHAT_LENGTH)
    -- Now find the find line change
    local index = string.find(crop, '\n')
    if index == nil then
        return crop
    end
    return string.sub(crop, index + 2)
end

local function _NewMessage(obj, author, msg)
    local msg = _CompileMessage(obj, author, msg)
    local text = obj.chat.text:sub(1, obj.chat.text:len() - 4)
    local text = text .. msg .. '\n \n \n'
    obj.chat:SetText(_CropChat(text))

    local _, _, _, y = obj.chat_container:GetCurrentExtents()
    obj.chat_container:SetScrollPos(nil, y, false)
end

local function _ChatInput(self, key, mods, isRepeat, label, unicode, ...)
    if Spring.GetKeyCode("enter") ~= key then
        return
    end
    local text = self.text
    self:SetText("")
    WG.LibLobby.lobby:Say(self.parent.chanName, text)
end

local function _FindUser(obj, userName)
    for i, e in ipairs(obj.users.entries) do
        if e.userName == userName then
            return i
        end
    end

    return nil
end

function ChatWindow:New(obj)
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = ":cl:empty.png"
    obj.official_server = obj.official_server or false
    obj.padding = obj.padding or {0, 0, 0, 0}

    obj = ChatWindow.inherited.New(self, obj)

    -- The chat at the left
    obj.chat_container = Chili.ScrollPanel:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '80%',
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

    Spring.SendCommands("unbind Any+enter chat")
    obj.chat_input = Chili.EditBox:New {
        parent = obj,
        x = '0%',
        y = '95%',
        width = '80%',
        height = '5%',
        text = "",
        OnKeyPress = { _ChatInput },
    }

    -- The users at right
    obj.users = ListWidget:New {
        parent = obj,
        x = '80%',
        y = '0%',
        width = '20%',
        height = '100%',
        headers = {{
            caption = 'Users',
            width = '100%',
            fontsize = 14,
        }},
    }

    -- Events
    local lobby = WG.LibLobby.lobby
    if obj.official_server then
        lobby:AddListener("OnMOTD",
            function(listener, message)
                local text = obj.chat.text .. message .. '\n'
                obj.chat:SetText(_CropChat(text))
            end
        )
        lobby:AddListener("OnAddUser",
            function(listener, userName, userTable)
                local data = userTable
                data.userName = userName
                data.fields = {userName, }
                obj.users:AddEntry(data)
            end
        )
        lobby:AddListener("OnRemoveUser",
            function(listener, userName)
                local i = _FindUser(obj, userName)
                if i == nil then
                    Spring.Log("Menu",
                               LOG.ERROR,
                               "Incorrect user", userName)
                    return
                end
                obj.users:RemoveEntry(i)
            end
        )
    else
        lobby:AddListener("OnChannelTopic",
            function(listener, chanName, author, changedTime, topic)
                if obj.chanName ~= chanName then
                    return
                end
                _NewMessage(obj, author, topic)
            end
        )
        lobby:AddListener("OnClients",
            function(listener, chanName, clients)
                if obj.chanName ~= chanName then
                    return
                end
                for _, c in ipairs(clients) do
                    if _FindUser(obj, c) == nil then
                        data = {userName = c, fields = {c, }, }
                        obj.users:AddEntry(data)
                    end
                end
            end
        )
        lobby:AddListener("OnJoined",
            function(listener, chanName, userName)
                if obj.chanName ~= chanName or _FindUser(obj, userName) ~= nil then
                    return
                end
                data = {userName = userName, fields = {userName, }, }
                obj.users:AddEntry(data)
            end
        )
        lobby:AddListener("OnSaid",
            function(listener, chanName, userName, message)
                if obj.chanName ~= chanName then
                    return
                end
                _NewMessage(obj, userName, message)
            end
        )
        lobby:AddListener("OnSaidEx",
            function(listener, chanName, userName, message)
                if obj.chanName ~= chanName then
                    return
                end
                _NewMessage(obj, userName, message)
            end
        )
        -- Ask for past messages
        lobby:AddListener("OnJSON",
            function(listener, data)
                for k, v in pairs(data) do
                    if k == "SAID" and obj.chanName == v.chanName then
                        -- Store the ID for future calls
                        for _, c in ipairs(WG.MENUOPTS.channels) do
                            if c.name == obj.chanName then
                                c.lastID = v.id
                                break
                            end
                        end
                        _NewMessage(obj, v.userName, v.msg)
                    end
                end
            end
        )

        for _, c in ipairs(WG.MENUOPTS.channels) do
            if c.name == obj.chanName then
                -- obj.lastID = c.lastID
                break
            end
        end
        lobby:GetChannelMessages(obj.chanName, obj.lastID)
    end

    

    return obj
end
