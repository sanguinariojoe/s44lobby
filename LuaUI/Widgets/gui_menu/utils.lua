local IMAGE_DIRNAME = "LuaUI/Images/ComWin/"


function TopLevelParent(self)
    -- Go up in the parenting chain until we find something without parent (the
    -- screen)
    local win = self
    local win_parent = win.parent
    while win_parent.parent ~= nil do
        win = win_parent
        win_parent = win_parent.parent
    end

    return win
end

function Back(self)
    local Chili = WG.Chili
    local Screen0 = Chili.Screen0

    local win = TopLevelParent(self)

    -- The window that called this one shall be stored as visitor attribute
    local parent = win.visitor

    if parent.visitor ~= nil then
        parent:Show(parent.visitor)
    else
        parent:Show()
    end
    win:Hide()
end

function Quit()
    Spring.Quit()
end

function Restart()
    local script = VFS.LoadFile("script.txt")
    Spring.Restart("", script)
end

function NotImplemented()
    Spring.Log("Menu", "warning", "Calling non-implemented action")
end

function ComboBoxWithLabel(obj)
    local Chili = WG.Chili

    local grid = Chili.Grid:New {
        parent = obj.parent,
        rows = 1,
        columns = 2,
    }
    obj.parent = grid
    local label = Chili.Label:New {
        parent = obj.parent,
        caption = obj.caption,
        align = "center",
        valign = "center"
    }
    obj.caption = ""
    -- We don't want the combobox trigger an action while it is setup
    OnSelect = obj.OnSelect
    obj.OnSelect = nil
    local combobox = Chili.ComboBox:New(obj)
    combobox.OnSelect = OnSelect

    return grid, label, combobox
end

Slider = WG.Chili.Trackbar:Inherit{
    start_val = 0.0,
    end_val   = 1.0,
    curr_val  = 0.5,
    steps     = 51,

    drawcontrolv2 = true,
}

function Slider:New(obj)
    obj.min   = 0
    obj.max   = 1
    obj.step  = 1 / (obj.steps - 1)
    obj.value = (obj.curr_val - obj.start_val) / (obj.end_val - obj.start_val)

    obj = Slider.inherited.New(self, obj)

    return obj
end 

function Slider:SetValue(v)
    -- Hang the execution of the event while we translate the value to the new
    -- scale
    OnChange = self.OnChange
    -- self.OnChange = {}
    local oldvalue = self.value
    Slider.inherited.SetValue(self, v)
    -- self.OnChange = OnChange

    -- Translate the values to the new scale
    oldvalue = self.start_val + oldvalue * (self.end_val - self.start_val)
    newvalue = self.start_val + self.value * (self.end_val - self.start_val)
    self:CallListeners(self.OnChange, newvalue, oldvalue)
end

function SliderWithLabel(obj)
    local Chili = WG.Chili

    local grid = Chili.Grid:New {
        parent = obj.parent,
        rows = 1,
        columns = 2,
    }
    obj.parent = grid
    local label = Chili.Label:New {
        parent = obj.parent,
        caption = obj.caption,
        align = "center",
        valign = "center"
    }
    obj.caption = ""

    -- We don't want the combobox trigger an action while it is setup
    local OnChange = obj.OnChange
    obj.OnChange = nil
    local slider = Slider:New(obj)
    slider.OnChange = OnChange

    return grid, label, slider
end

function CheckboxWithLabel(obj)
    local Chili = WG.Chili

    local grid = Chili.Grid:New {
        parent = obj.parent,
        rows = 1,
        columns = 2,
    }
    obj.parent = grid
    local label = Chili.Label:New {
        parent = obj.parent,
        caption = obj.caption,
        align = "center",
        valign = "center"
    }
    obj.caption = ""

    -- We don't want the combobox trigger an action while it is setup
    local OnChange = obj.OnChange
    obj.OnChange = nil
    local checkbox = Chili.Checkbox:New(obj)
    checkbox.OnChange = OnChange

    return grid, label, checkbox
end

function TreeNode(file, caption, w)
    local Chili = WG.Chili
    w = w or "100%"

    local win = Chili.Window:New{
        x = 0,
        y = 0,
        width = w,
        height = 32 + 2 * 5,
        padding = {5, 5, 5, 5},
        resizable = false,
        draggable = false,
        TileImage = IMAGE_DIRNAME .. "empty.png",
    }

    local image = Chili.Image:New {
        parent = win,
        x = 0,
        y = 0,
        width = 32,
        height = 32,
        file = file,
        keepAspect = true,
    }

    local label = Chili.Label:New {
        parent = win,
        x = 37,
        y = 0,
        width = "100%",
        height = 32,
        caption = caption,
        align = "left",
        valign = "center",
        font = {size = 16},
    }

    return win, image, label
end

-- =============================================================================
-- Control escape key
-- =============================================================================
local _EscActor, _EscAction = nil, nil

function SetEscAction(actor, action)
    _EscActor = actor
    _EscAction = action
end

function ExecuteEscAction()
    if _EscAction ~= nil then
        _EscAction(_EscActor)
    end
end

-- =============================================================================
-- Map size utils
-- =============================================================================
function global2local(x, z, mapsize_x, mapsize_z)
    local u, v = x / (8 * mapsize_x), z / (8 * mapsize_z)
    if mapsize_x > mapsize_z then
        local f = mapsize_z / mapsize_x
        v = f * v + 0.5 * (1 - f)
    elseif mapsize_x < mapsize_z then
        local f = mapsize_x / mapsize_z
        u = f * u + 0.5 * (1 - f)
    end
    return u, v
end

function local2global(u, v, mapsize_x, mapsize_z)
    if mapsize_x > mapsize_z then
        local f = mapsize_z / mapsize_x
        v = f * (v - 0.5 * (1 - f))
    elseif mapsize_x < mapsize_z then
        local f = mapsize_x / mapsize_z
        u = f * (u - 0.5 * (1 - f))
    end
    return u * 8 * mapsize_x, v * 8 * mapsize_z
end



-- =============================================================================
-- Chobby great string utilities
-- =============================================================================

StringUtilities = StringUtilities or {}

function StringUtilities.GetTruncatedString(myString, myFont, maxLength)
    if (not maxLength) then
        return myString
    end
    local length = string.len(myString)
    while myFont:GetTextWidth(myString) > maxLength do
        length = length - 1
        myString = string.sub(myString, 0, length)
        if length < 1 then
            return ""
        end
    end
    return myString
end

function StringUtilities.GetTruncatedStringWithDotDot(myString, myFont, maxLength)
    if (not maxLength) or (myFont:GetTextWidth(myString) <= maxLength) then
        return myString
    end
    local truncation = StringUtilities.GetTruncatedString(myString, myFont, maxLength)
    local dotDotWidth = myFont:GetTextWidth("..")
    truncation = StringUtilities.GetTruncatedString(truncation, myFont, maxLength - dotDotWidth)
    return truncation .. ".."
end

function StringUtilities.TruncateStringIfRequired(myString, myFont, maxLength)
    if (not maxLength) or (myFont:GetTextWidth(myString) <= maxLength) then
        return false
    end
    return StringUtilities.GetTruncatedString(myString, myFont, maxLength)
end

function StringUtilities.TruncateStringIfRequiredAndDotDot(myString, myFont, maxLength)
    if (not maxLength) or (myFont:GetTextWidth(myString) <= maxLength) then
        return false
    end
    return StringUtilities.GetTruncatedStringWithDotDot(myString, myFont, maxLength)
end

function string.starts(String,Start)
    return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
    return End=='' or string.sub(String,-string.len(End))==End
end

function string.trim(str)
    return str:match'^()%s*$' and '' or str:match'^%s*(.*%S)'
end

function string.split(str, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for s in string.gmatch(str, "([^"..sep.."]+)") do
        table.insert(t, s)
    end
    return t
end

function math.randompassword(length)
    local index, pw, rnd = 0, ""
    local chars = {
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        "abcdefghijklmnopqrstuvwxyz",
        "0123456789",
        "!\"#$%&'()*+,-./:;<=>?@[]^_{|}~"
    }
    repeat
        index = index + 1
        rnd = math.random(chars[index]:len())
        if math.random(2) == 1 then
            pw = pw .. chars[index]:sub(rnd, rnd)
        else
            pw = chars[index]:sub(rnd, rnd) .. pw
        end
        index = index % #chars
    until pw:len() >= length
    return pw
end
