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
    Spring.SendCommands({"QuitForce",})
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

function TreeNode(file, caption)
    local Chili = WG.Chili

    local grid = Chili.Grid:New {
        x = 0,
        y = 0,
        width = "100%",
        height = 48,
    }

    local image = Chili.Image:New {
        parent = grid,
        file = file,
        keepAspect = true,
    }
    
    local label = Chili.Label:New {
        parent = grid,
        caption = caption,
        align = "left",
        valign = "center",
    }

    return grid, image, label
end
