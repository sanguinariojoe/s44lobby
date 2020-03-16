local Chili = WG.Chili

ChatsWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

chats_win = nil

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/lobby/chat.lua")
VFS.Include("LuaUI/Widgets/gui_menu/lobby/join_channel.lua")
local FitString = StringUtilities.GetTruncatedStringWithDotDot

--//=============================================================================

local function _ChangeTab(obj, tabName)
    -- Small shortcut to change tab, as well as highlighting such a tab
    obj.tabbar:Select(tabName)
    obj.tabbar:DisableHighlight()
    obj.tabbar:EnableHighlight()
end

local function _OnLeaveChannel(obj)
    WG.LibLobby.lobby:Leave(obj.user_data.chanName)
    for i, c in ipairs(WG.MENUOPTS.channels) do
        if c.name == obj.user_data.chanName then
            for j = i + 1, #WG.MENUOPTS.channels do
                WG.MENUOPTS.channels[j - 1] = WG.MENUOPTS.channels[j]
            end
            WG.MENUOPTS.channels[#WG.MENUOPTS.channels] = nil
            break
        end
    end
    obj.user_data.tabs:RemoveTab(obj.user_data.tabName)
    _ChangeTab(obj.user_data.tabs, '+')
end

function Joined2Channel(obj, name)
    local new_channel = true
    local persistent = false
    for _, c in ipairs(WG.MENUOPTS.channels) do
        if c.name == name then
            new_channel = false
            persistent = c.persistent
            break
        end
    end
    if new_channel then
        WG.MENUOPTS.channels[#WG.MENUOPTS.channels + 1] = {
            name = name,
            key = nil,
            lastID = nil,
            persistent = false,
        }
    end

    local caption = FitString(name, obj.font, 128)
    if obj.chats:GetTab(caption) then
        -- The chat already exists
        _ChangeTab(obj.chats, caption)
        return
    end

    x, y, w, h = obj.main_chat.x, obj.main_chat.y, obj.main_chat.width, obj.main_chat.height
    local chat = ChatWindow:New({parent = nil,
                                 x = x,
                                 y = y,
                                 width = w,
                                 height = h,
                                 chanName = name,
                                 official_server = false})
    obj.chats:RemoveTab('+')
    obj.chats:AddTab({name=caption, children={chat}})
    if not persistent then
        local tab = obj.chats.tabbar.children[#obj.chats.tabbar.children]
        local close_button = Chili.Button:New {
            parent = tab,
            x = -16,
            y = 0,
            width = 16,
            height = 16,
            padding = {0, 0, 0, 0},
            margin = {0, 0, 0, 0},
            TileImageBK = ":cl:empty.png",
            caption = "X",
            OnClick = { _OnLeaveChannel, },
            user_data = {
                tabs = obj.chats,
                chanName = name,
                tabName = caption,
            },
        }
    end
    obj.chats:AddTab({name='+', children={obj.add_chat}})
    _ChangeTab(obj.chats, name)
end

local function OnShowChatsWindow(self)
    if self.first_show then
        _ChangeTab(self.chats, "Official Server")
    end
    self.first_show = false
end

function ChatsWindow:New(obj)
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = ":cl:empty.png"
    obj.first_show = true
    obj.OnShow = { OnShowChatsWindow, }

    obj = ChatsWindow.inherited.New(self, obj)

    obj.main_chat = ChatWindow:New({parent = nil,
                                    chanName = name,
                                    official_server = true})
    obj.add_chat = JoinChannelWindow:New({parent = nil})
    local main_name= FitString("Official Server", obj.font, 128)
    obj.chats = Chili.TabPanel:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        tabs = {{name = main_name, children = {obj.main_chat}},
                {name = '+', children = {obj.add_chat}},},
    }

    -- Join the channels
    chats_win = obj
    local lobby = WG.LibLobby.lobby
    lobby:AddListener("OnJoin",
        function(listener, chanName)
            Joined2Channel(obj, chanName)
        end
    )
    lobby:AddListener("OnJoinFailed",
        function(listener, chanName, reason)
            -- Drop the channel from the list
            local new_channels = {}
            for _, c in ipairs(WG.MENUOPTS.channels) do
                if chanName ~= c.name then
                    new_channels[#new_channels + 1] = c
                end
            end
            WG.MENUOPTS.channels = new_channels
        end
    )
    lobby:AddListener("OnAccepted",
        function(listener)
            for _, channel in ipairs(WG.MENUOPTS.channels) do
                lobby:Join(channel.name, channel.key)
            end
        end
    )

    return obj
end
