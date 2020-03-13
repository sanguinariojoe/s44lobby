local Chili = WG.Chili

ChatWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/list.lua")
local FitString = StringUtilities.GetTruncatedStringWithDotDot

--//=============================================================================

function ChatInput(self, key, mods, isRepeat, label, unicode, ...)
    if Spring.GetKeyCode("enter") ~= key then
        return
    end
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

    obj.chat_input = Chili.EditBox:New {
        parent = obj,
        x = '0%',
        y = '95%',
        width = '80%',
        height = '5%',
        text = "",
        OnKeyPress = { ChatInput },
    }

    -- The users at right
    obj.users = ListWidget:New {
        parent = obj,
        x = '80%',
        y = '0%',
        width = '20%',
        height = '100%',
        headers = {{
            caption = 'Nickname',
            width = '100%',
            fontsize = 14,
        }},
    }

    local lobby = WG.LibLobby.lobby
    if obj.official_server then
        lobby:AddListener("OnMOTD",
            function(listener, message)
                local text = obj.chat.text .. message .. '\n'
                obj.chat:SetText(text)
            end
        )
    end

    return obj
end
