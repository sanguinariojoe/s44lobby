local Chili = WG.Chili

BattlesWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

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
local content_x = {}
local content_w = {}
local order_id = 0  -- That means not ordering at all

function SortBattles(list_win)
    if order_id == 0 then
        return
    end

    local argsort = {}
    for i, battle in ipairs(list_win.battles) do
        local fields = {StatusIcon(battle),
                        WG.LibLobby.lobby:GetBattlePlayerCount(battle.battleID),
                        battle.maxPlayers,
                        battle.spectatorCount,
                        battle.title,
                        battle.gameName,
                        battle.mapName}
        local key = fields[math.abs(order_id)]
        local index = i
        if order_id < 0 then
            index = #list_win.battles + 1 - i
        end
        argsort[i] = {index, key}
    end

    table.sort(argsort, function(a, b) return a[2] < b[2] end)
    local new_battles = {}
    for _, k in pairs(argsort) do
        Spring.Echo(#new_battles + 1, '<-', k[1])
        list_win.battles[k[1]].win:SetPos(nil, 32 * #new_battles)
        new_battles[#new_battles + 1] = list_win.battles[k[1]]
    end
    list_win.battles = new_battles
end

function AddHeaderButton(parent, x, id)
    local button = Chili.Button:New {
        parent = parent,
        x = x,
        y = y,
        height = 32,
        width = header_widths[id],
        caption = header_captions[id],
        font = {
            size = header_fontsizes[id],
        },
        header_id = id,
        OnClick = { function(self)
            if math.abs(order_id) == self.header_id then
                order_id = -order_id
            else
                order_id = self.header_id
            end
            SortBattles(self.parent.parent.list_win)
        end },
    }
    return button
end

function StatusIcon(battle)
    if battle.passworded then
        return '\204\132'
    end
    if battle.isRunning == true then
        return '\204\128'
    end
    return '\204\133'
end

function BattleStrings(battle)
    return {
        StatusIcon(battle),
        tostring(WG.LibLobby.lobby:GetBattlePlayerCount(battle.battleID)),
        tostring(battle.maxPlayers),
        tostring(battle.spectatorCount),
        tostring(battle.title),
        tostring(battle.gameName),
        tostring(battle.mapName),
    }
end

function AddField(parent, txt, id)
    if string.len(txt) > 5 then
        txt = StringUtilities.GetTruncatedStringWithDotDot(txt,
                                                           parent.font,
                                                           content_w[id])
    end
    local field = Chili.Label:New {
        parent = parent,
        x = content_x[id],
        y = 0,
        height = 32,
        width = content_w[id],
        caption = txt,
        align   = "center",
        valign  = "center",
    }
    return field    
end

function AddBattle(parent, battleID)
    local n = #parent.battles
    parent:Resize(parent.width, 32 * (n + 1))
    local subwin = Chili.Button:New {
        parent = parent,
        x = '0%',
        y = 32 * n,
        width = '100%',
        height = 32,
        padding = {0, 0, 0, 0},
        margin = {0, 0, 0, 0},
        TileImageBK = ":cl:empty.png",
        caption = "",
    }

    local battle = WG.LibLobby.lobby:GetBattle(battleID)
    battle.win = subwin

    battle.win.labels = {}
    for i, s in ipairs(BattleStrings(battle)) do
        battle.win.labels[i] = AddField(subwin, s, i)
    end

    parent.battles[#parent.battles + 1] = battle
end

function UpdateBattle(parent, battleID)
    for i, battle in ipairs(parent.battles) do
        if battle.battleID == battleID then
            -- Replace the battle info by the new one
            local win = battle.win
            parent.battles[i] = WG.LibLobby.lobby:GetBattle(battleID)
            parent.battles[i].win = win
            battle = parent.battles[i]
            -- Set the new captions
            for j, s in ipairs(BattleStrings(battle)) do
                if string.len(s) > 5 then
                    s = StringUtilities.GetTruncatedStringWithDotDot(
                        s, parent.font, content_w[j])
                end
                battle.win.labels[j]:SetCaption(s)
            end
            return
        end
    end
    Spring.Log("Menu", LOG.ERROR, "Cannot find battle", battleID)
end

function RemoveBattle(parent, battleID)
    for i, battle in ipairs(parent.battles) do
        if battle.battleID == battleID then
            battle.win:Dispose()
            for j = i + 1, #parent.battles do
                parent.battles[j].win.y = parent.battles[j].win.y - 32
                parent.battles[j - 1] = parent.battles[j]
            end
            parent.battles[#parent.battles] = nil
            return
        end
    end
    Spring.Log("Menu", LOG.ERROR, "Cannot find battle", battleID)
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
    obj.scroll = Chili.ScrollPanel:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '100%',
        height = '100%',
        horizontalScrollbar = false,
        BorderTileImage = ":cl:empty.png",
        BackgroundTileImage = ":cl:empty.png",
    }
    obj.buttons = {}
    local x = 0
    for i = 1, 7 do
        local button = AddHeaderButton(obj.scroll, x, i)
        obj.buttons[i] = button
        content_x[i] = x
        content_w[i] = button.width
        x = x + button.width
    end
    obj.list_win = Chili.Window:New {
        parent = obj.scroll,
        x = '0%',
        y = 32,
        width = '100%',
        height = 10,
        resizable = false,
        draggable = false,
        TileImage = ":cl:empty.png",
        padding = {0, 0, 0, 0},
        margin = {0, 0, 0, 0}
    }
    obj.list_win.battles = {}

    local lobby = WG.LibLobby.lobby
    lobby:AddListener("OnBattleOpened",
        function(listener, battleID)
            AddBattle(obj.list_win, battleID)
        end
    )
    lobby:AddListener("OnUpdateBattleInfo",
        function(listener, battleID)
            UpdateBattle(obj.list_win, battleID)
        end
    )
    lobby:AddListener("OnJoinedBattle",
        function(listener, battleID, userName, scriptPassword)
            UpdateBattle(obj.list_win, battleID)
        end
    )
    lobby:AddListener("OnLoginInfoEnd",
        function(listener)
            for _, battle in ipairs(obj.list_win.battles) do
                UpdateBattle(obj.list_win, battle.battleID)
            end
        end
    )
    lobby:AddListener("OnBattleClosed",
        function(listener, battleID)
            RemoveBattle(obj.list_win, battleID)
        end
    )

    return obj
end 
