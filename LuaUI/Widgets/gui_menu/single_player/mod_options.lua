local Chili = WG.Chili

ModOptionsWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

local function LoadModOptions()
    if not VFS.FileExists("ModOptions.lua") then
        Spring.Log("Game options", "Error", "Missing ModOptions.lua file")
        return {}
    end

    return VFS.Include("ModOptions.lua")
end

local function ResizeParent(obj)
    local y = 16
    for i = 0, #obj.parent.children - 1 do
        local c = obj.parent.children[#obj.parent.children - i]
        c:SetPos(nil, y)
        y = y + c.height
    end
    obj.parent:Resize(nil, y + 24)
end

local function ParseSection(opt, parent)
    local obj = Chili.Window:New {
        minHeight = 16,
        x = "0%",
        y = parent.height - 10,
        width = "100%",
        height = 20,
        resizeItems = false,
        resizable = false,
        draggable = false,
        TileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        caption = opt.name,
        parent = parent,
        data = opt,
        OnResize = { ResizeParent, }
    }
    ResizeParent(obj)
    return obj
end

local function ParseList(opt, parent)
    local obj = Chili.Window:New {
        x = "0%",
        y = parent.height - 10,
        width = "100%",
        height = 64,
        resizeItems = false,
        resizable = false,
        draggable = false,
        TileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        parent = parent,
        data = opt,
        OnResize = { ResizeParent, }
    }
    Chili.Label:New {
        x = "0%",
        y = "0%",
        width = "100%",
        caption = opt.name,
        parent = obj,
    }
    local items = {}
    local selected = 1
    for i, v in ipairs(opt.items) do
        items[i] = v.name
        if v.name == opt.def then
            selected = i
        end
    end
    Chili.ComboBox:New {
        x = "0%",
        y = 16,
        width = "100%",
        parent = obj,
        items = items,
        selected = selected,
    }
    ResizeParent(obj)
    return obj
end

local function ParseNumber(opt, parent)
    local obj = Chili.Window:New {
        x = "0%",
        y = parent.height - 10,
        width = "100%",
        height = 64,
        resizeItems = false,
        resizable = false,
        draggable = false,
        TileImage = "LuaUI/Widgets/gui_menu/rsrc/empty.png",
        parent = parent,
        data = opt,
        OnResize = { ResizeParent, }
    }
    Chili.Label:New {
        x = "0%",
        y = "0%",
        width = "100%",
        caption = opt.name,
        parent = obj,
    }
    local trackbar_caption = Chili.Label:New {
        x = "93%",
        y = 16,
        caption = tostring(opt.def),
        parent = obj,
    }
    local function OnTrackBar(obj, value, old_value)
        obj.label:SetCaption(tostring(value))
    end
    Chili.Trackbar:New {
        x = "0%",
        y = 16,
        width = "90%",
        height = 20,
        value = opt.def,
        min   = opt.min,
        max   = opt.max,
        step  = opt.step,
        parent = obj,
        label = trackbar_caption,
        OnChange = { OnTrackBar, },
    }
    ResizeParent(obj)
    return obj
end

local function ParseBool(opt, parent)
    local obj = Chili.Checkbox:New {
        x = "0%",
        y = parent.height - 10,
        width = "100%",
        height = 20,
        caption = opt.name,
        boxalign = "left",
        checked = opt.def,
        parent = parent,
    }
    ResizeParent(obj)
    return obj
end


local function ParseOption(opt, parent)
    -- Redirect the job to the appropriate backend
    if opt.type == "section" then
        return ParseSection(opt, parent)
    elseif opt.type == "list" then
        return ParseList(opt, parent)
    elseif opt.type == "number" then
        return ParseNumber(opt, parent)
    elseif opt.type == "bool" then
        return ParseBool(opt, parent)
    else
        Spring.Log("Game options", "Error", "Unknown option type " .. opt.type)
        return nil
    end
end

function ModOptionsWindow:New(obj)
    obj.minHeight = 24
    obj.x = obj.x or '0%'
    obj.y = obj.y or '0%'
    obj.width = obj.width or '100%'
    obj.height = obj.height or 24
    obj.caption = obj.caption or 'Game options'
    obj.resizable = false
    obj.draggable = false

    obj = ModOptionsWindow.inherited.New(self, obj)

    opts = LoadModOptions()
    obj.opts = {}
    -- We are traversing the pending options until either there are not more
    -- options to add or no options can be traversed (e.g. because they are
    -- missconfigured)
    while true do
        local parsed = nil
        for i, opt in ipairs(opts) do
            local parent = obj
            if opt.section then
                local parent = obj.opts[opt.section]
            end
            if parent then
                obj.opts[opt.key] = ParseOption(opt, parent)
                parsed = i
                break
            end
        end
        if parsed ~= nil then
            table.remove(opts, parsed)
        else
            break
        end
    end

    for opt in ipairs(opts) do
        Spring.Log("Game options", "Error", "Impossible to parse option " .. opt.key)
    end

    return obj
end
