local Chili = WG.Chili

ChatsWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

chats_win = nil

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/lobby/chat.lua")
local FitString = StringUtilities.GetTruncatedStringWithDotDot

--//=============================================================================

function Joined2Channel(obj, name)
    x, y, w, h = obj.main_chat.x, obj.main_chat.y, obj.main_chat.width, obj.main_chat.height
    local chat = ChatWindow:New({parent = nil,
                                 x = x,
                                 y = y,
                                 width = w,
                                 height = h,
                                 chanName = name,
                                 official_server = false})
    obj.chats:AddTab({name=FitString(name, obj.font, 128),
                      children={chat}})
end

function ChatsWindow:New(obj)
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = ":cl:empty.png"

    obj = ChatsWindow.inherited.New(self, obj)

    obj.main_chat = ChatWindow:New({parent = nil,
                                      chanName = name,
                                      official_server = true})
    local main_name= FitString("Official Server", obj.font, 128)
    obj.chats = Chili.TabPanel:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        tabs = {{name = main_name, children = {obj.main_chat}}},
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
