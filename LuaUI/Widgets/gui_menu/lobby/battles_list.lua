local Chili = WG.Chili

BattlesWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
VFS.Include("LuaUI/Widgets/gui_menu/list.lua")

--//=============================================================================

local header_captions = {'\204\128',
                         '\204\130',
                         'Max',
                         '\204\131',
                         'Title',
                         'Game',
                         'Map'}
local header_widths = {'6%',
                       '6%',
                       '6%',
                       '6%',
                       '25%',
                       '25%',
                       '25%'}
local header_fontsizes = {28,
                          28,
                          21,
                          36,
                          21,
                          21,
                          21}

function StatusIcon(battle)
    if battle.passworded then
        return '\204\132'
    end
    if battle.isRunning == true then
        return '\204\128'
    end
    return '\204\133'
end


function BattleFields(battle)
    return {
        StatusIcon(battle),
        WG.LibLobby.lobby:GetBattlePlayerCount(battle.battleID),
        battle.maxPlayers,
        battle.spectatorCount,
        battle.title,
        battle.gameName,
        battle.mapName,
    }
end

function AddBattle(list_widget, battleID)
    local battle = WG.LibLobby.lobby:GetBattle(battleID)
    battle.fields = BattleFields(battle)
    list_widget:AddEntry(battle)
end

function FindBattle(list_widget, battleID)
    for i, battle in ipairs(list_widget.entries) do
        if battle.battleID == battleID then
            return i
        end
    end
    return nil
end

function UpdateBattle(list_widget, battleID)
    local i = FindBattle(list_widget, battleID)
    if i == nil then
        Spring.Log("Menu", LOG.ERROR, "Cannot find battle", battleID)
        return
    end

    local battle = WG.LibLobby.lobby:GetBattle(battleID)
    battle.fields = BattleFields(battle)
    list_widget:UpdateEntry(i, battle)
end

function RemoveBattle(list_widget, battleID)
    local i = FindBattle(list_widget, battleID)
    if i == nil then
        Spring.Log("Menu", LOG.ERROR, "Cannot find battle", battleID)
        return
    end

    list_widget:RemoveEntry(i)
end

function BattlesWindow:New(obj)
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.resizable = false
    obj.draggable = false
    obj.TileImage = ":cl:empty.png"

    obj = BattlesWindow.inherited.New(self, obj)

    -- Battles list
    -- ============
    local headers = {}
    for i = 1, #header_captions do
        local header = {
            caption = header_captions[i],
            width = header_widths[i],
            fontsize = header_fontsizes[i],
        }
        headers[i] = header
    end
    obj.battles_list = ListWidget:New {parent = obj, headers = headers}

    local lobby = WG.LibLobby.lobby
    lobby:AddListener("OnBattleOpened",
        function(listener, battleID)
            AddBattle(obj.battles_list, battleID)
        end
    )
    lobby:AddListener("OnUpdateBattleInfo",
        function(listener, battleID)
            UpdateBattle(obj.battles_list, battleID)
        end
    )
    lobby:AddListener("OnJoinedBattle",
        function(listener, battleID, userName, scriptPassword)
            UpdateBattle(obj.battles_list, battleID)
        end
    )
    lobby:AddListener("OnLoginInfoEnd",
        function(listener)
            for _, battle in ipairs(obj.battles_list.entries) do
                UpdateBattle(obj.battles_list, battle.battleID)
            end
        end
    )
    lobby:AddListener("OnBattleClosed",
        function(listener, battleID)
            RemoveBattle(obj.battles_list, battleID)
        end
    )

    return obj
end 
