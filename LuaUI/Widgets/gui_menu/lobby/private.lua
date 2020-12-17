local Chili = WG.Chili

PrivateChatWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

local MAX_CHAT_LENGTH = 2500

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/list.lua")
VFS.Include("LuaUI/Widgets/gui_menu/lobby/chat.lua")

--//=============================================================================

function loginName(self)
    local obj = self.parent
    while obj.classname ~= "LobbyWindow" do
        obj = obj.parent
        if obj == nil then
            Spring.Log("Menu",
                       LOG.ERROR,
                       "Private chat without LobbyWindow parent")
            return
        end
    end

    return obj.log_win.user.text
end

local function _ChatInput(self, key, mods, isRepeat, label, unicode, ...)
    if Spring.GetKeyCode("enter") ~= key then
        return
    end
    local text = self.text
    self:SetText("")
    local obj = self.parent
    WG.LibLobby.lobby:SayPrivate(obj.userName, text)

    if obj.logName == nil then
        obj.logName = loginName(obj)
    end
    NewMessage(obj, obj.logName, text)
end

function PrivateChatWindow:New(obj)
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png"
    obj.padding = obj.padding or {0, 0, 0, 0}

    obj = PrivateChatWindow.inherited.New(self, obj)

    obj.chat_container = Chili.ScrollPanel:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '95%',
        horizontalScrollbar = false,
        BorderTileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        BackgroundTileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
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
        width = '100%',
        height = '5%',
        text = "",
        OnKeyPress = { _ChatInput },
    }

    -- Events
    local lobby = WG.LibLobby.lobby
    lobby:AddListener("OnSaidPrivate",
        function(listener, userName, message)
            if obj.userName ~= userName then
                return
            end
            NewMessage(obj, userName, message)
        end
    )

    return obj
end
