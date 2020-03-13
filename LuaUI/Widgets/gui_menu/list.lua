local Chili = WG.Chili

ListWidget = Chili.ScrollPanel:Inherit {
    drawcontrolv2 = true
}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")
local FitString = StringUtilities.GetTruncatedStringWithDotDot

--//=============================================================================

local function _SortList(obj)
    if obj.order_id == 0 then
        return
    end

    local argsort = {}
    for i, entry in ipairs(obj.entries) do
        local key = entry.fields[math.abs(obj.order_id)]
        local index = i
        if obj.order_id < 0 then
            index = #obj.entries + 1 - i
        end
        argsort[i] = {index, key}
    end

    table.sort(argsort, function(a, b) return a[2] < b[2] end)
    local new_entries = {}
    for _, k in pairs(argsort) do
        obj.entries[k[1]].widget:SetPos(nil, 32 * #new_entries)
        new_entries[#new_entries + 1] = obj.entries[k[1]]
    end
    obj.entries = new_entries
end

local function _AddHeaderButton(parent, header)
    local button = Chili.Button:New {
        parent = parent,
        x = header.x,
        y = 0,
        width = header.width,
        height = 32,
        caption = header.caption,
        font = {
            size = header.fontsize,
        },
        header_id = header.header_id,
        OnClick = { function(self)
            local obj = self.parent
            if math.abs(obj.order_id) == self.header_id then
                obj.order_id = -obj.order_id
            else
                obj.order_id = self.header_id
            end
            _SortList(obj)
        end },
    }
    return button
end

function ListWidget:AddEntry(data)
    if #data.fields ~= #self.headers then
        Spring.Log("Menu",
                   LOG.ERROR,
                   "Incorrect number of fields", #data.fields, #self.headers)
        return
    end

    local n = #self.entries
    self.list_win:Resize(nil, 32 * (n + 1))

    -- Create the widget
    local widget = Chili.Button:New {
        parent = self.list_win,
        x = '0%',
        y = 32 * n,
        width = '100%',
        height = 32,
        padding = {0, 0, 0, 0},
        margin = {0, 0, 0, 0},
        TileImageBK = ":cl:empty.png",
        caption = "",
        OnClick = data.OnClick,
    }

    -- And inside the fields
    widget.labels = {}
    for i, f in ipairs(data.fields) do
        local x, w = self.headers[i].x, self.headers[i].width
        local txt = tostring(f)
        if string.len(txt) > 5 then
            txt = FitString(txt, self.font, w)
        end
        local label = Chili.Label:New {
            parent = widget,
            x = x,
            y = 0,
            height = 32,
            width = w,
            caption = txt,
            align   = "center",
            valign  = "center",
        }
        widget.labels[i] = label
    end

    self.entries[n + 1] = data
    self.entries[n + 1].widget = widget

    _SortList(self)
end

function ListWidget:UpdateEntry(i, data)
    if #data.fields ~= #self.headers then
        Spring.Log("Menu",
                   LOG.ERROR,
                   "Incorrect number of fields", #data.fields, #self.headers)
        return
    end

    local widget = self.entries[i].widget

    for j, f in ipairs(data.fields) do
        local txt = tostring(f)
        if string.len(txt) > 5 then
            txt = FitString(tostring(txt), self.font, w)
        end
        widget.labels[j]:SetCaption(txt)
    end    

    self.entries[i] = data
    self.entries[i].widget = widget
    
    _SortList(self)
end

function ListWidget:RemoveEntry(i)
    self.entries[i].widget:Dispose()
    for j = i + 1, #self.entries do
        self.entries[j].widget:SetPos(nil, self.entries[j].widget.y - 32)
        self.entries[j - 1] = self.entries[j]
    end
    self.entries[#self.entries] = nil
    self.list_win:Resize(nil, 32 * #self.entries)
end

function ListWidget:New(obj)
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or '100%'
    obj.horizontalScrollbar = obj.horizontalScrollbar or false
    obj.BorderTileImage = obj.BorderTileImage or ":cl:empty.png"
    obj.BackgroundTileImage = obj.BackgroundTileImage or ":cl:empty.png"
    obj.order_id = obj.order_id or 0
    if obj.headers == nil then
        Spring.Log("Menu",
                   LOG.ERROR,
                   "List widget should be generated with a header")
        return
    end

    obj = ListWidget.inherited.New(self, obj)

    -- Create the header
    local x = 0
    for i, h in ipairs(obj.headers) do
        h.x = x
        h.header_id = i
        obj.headers[i] = _AddHeaderButton(obj, h)
        x = x + obj.headers[i].width
    end

    -- Create the entries window
    obj.list_win = Chili.Window:New {
        parent = obj,
        x = '0%',
        y = 32,
        width = '100%',
        height = 32,
        resizable = false,
        draggable = false,
        TileImage = ":cl:empty.png",
        padding = {0, 0, 0, 0},
        margin = {0, 0, 0, 0}
    }

    local entries = obj.entries or {}
    obj.entries = {}
    for i, e in ipairs(entries) do
        obj:AddEntry(e)
    end

    _SortList(obj)

    return obj
end
