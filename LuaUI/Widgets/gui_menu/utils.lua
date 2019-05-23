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

    parent:Show()
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
