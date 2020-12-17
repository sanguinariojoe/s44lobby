local Chili = WG.Chili

JoinChannelWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/list.lua")
local FitString = StringUtilities.GetTruncatedStringWithDotDot

--//=============================================================================

local function OnJoin(self)
    WG.LibLobby.lobby:Join(self.user_data.chanName)
end

function JoinChannelWindow:New(obj)
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png"
    obj.padding = obj.padding or {0, 0, 0, 0}
    obj.OnShow = { OnShowJoinChannelWindow, }

    obj = JoinChannelWindow.inherited.New(self, obj)

    obj.channels = ListWidget:New {
        parent = obj,
        name = "JoinChannelWindow.channels",
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        headers = {{caption = 'Channel', width = '20%', fontsize = 14,},
                   {caption = 'Topic', width = '80%', fontsize = 14,},
                  },
    }

    -- Ask for the channels list
    local lobby = WG.LibLobby.lobby
    lobby:AddListener("OnChannel",
        function(listener, chanName, userCount, topic)
            for _, c in ipairs(WG.MENUOPTS.channels) do
                if c.name == chanName then
                    -- Ignore the already joined channels 
                    return
                end
            end
            local entry = {chanName = chanName,
                           fields = {chanName, topic},
                           OnClick = { OnJoin, },}
            obj.channels:AddEntry(entry)
        end
    )
    lobby:AddListener("OnAccepted",
        function(listener)
            lobby:Channels()
        end
    )

    return obj
end
