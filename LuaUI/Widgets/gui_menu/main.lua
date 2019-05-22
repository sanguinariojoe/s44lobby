local main_window = {
    win
}
main_window.__index = main_window

local function NotImplemented()
    Spring.Log("Menu", "warning", "Calling non-implemented action")
end

local function Quit()
    Spring.SendCommands({"QuitForce",})
end

function main_window:setup(Chili, parent)
    -- Create the window
    self.win = Chili.Window:New{
        parent = Screen0,
        x = '30%',
        y = '10%',
        width = '40%',
        height = '80%',
    }
    local logo = Chili.Image:New {
        parent = self.win,
        width = "100%",
        height = "15%",
        keepAspect = true,
        file = "LuaUI/Widgets/gui_menu/rsrc/S44-logo-vector.png",
    }
    local grid = Chili.Grid:New {
        parent = self.win,
        x = '0%',
        y = '15%',
        width = '100%',
        height = '85%',
        rows = 5,
        columns = 1,        
        padding = {5,5,5,5},
    }
    -- Add the buttons
    local PlayButton = Chili.Button:New {
        parent = grid,
        caption = "Multiplayer",
        backgroundColor = { 1, 1, 1, 1 },
        font = { size = fontSize },
        OnMouseUp = { NotImplemented },
    }
    local WikiButton = Chili.Button:New {
        parent = grid,
        caption = "Units",
        backgroundColor = { 1, 1, 1, 1 },
        font = { size = fontSize },
        OnMouseUp = { NotImplemented },
    }
    local ConfigButton = Chili.Button:New {
        parent = grid,
        caption = "Configure",
        backgroundColor = { 1, 1, 1, 1 },
        font = { size = fontSize },
        OnMouseUp = { NotImplemented },
    }
    local QuitButton = Chili.Button:New {
        parent = grid,
        caption = "Exit",
        backgroundColor = { 1, 1, 1, 1 },
        font = { size = fontSize },
        OnMouseUp = { Quit },
    }
end

function main_window:show()
    if self.win == nil then
        Spring.Log("Menu", "error", "Setup main window before showing it!")
        return
    end
    self.win:Show()
end

function main_window:hide()
    if self.win == nil then
        Spring.Log("Menu", "error", "Setup main window before hiding it!")
        return
    end
    self.win:Hide()
end

return main_window
