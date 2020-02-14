local Chili = WG.Chili

PostprocessWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

local this = PostprocessWindow
local inherited = this.inherited

-- Control settings
local GAMMA      = {start_val=0.5, end_val=1.0, steps=51}
local DGAMMA     = {start_val=0.0, end_val=1.0, steps=51}
local GRAIN      = {start_val=0.0, end_val=0.1, steps=51}
local SCRATCHES  = {start_val=0.0, end_val=1.0, steps=51}
local VIGNETTE   = {start_val=2.0, end_val=0.7, steps=51}
local ABERRATION = {start_val=0.0, end_val=0.5, steps=51}
local SEPIA      = {start_val=0.0, end_val=1.0, steps=51}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

--//=============================================================================

function this:New(obj)
    obj.x = obj.x or '30%'
    obj.y = obj.y or '10%'
    obj.minwidth = 320
    obj.width = obj.width or '40%'
    obj.minHeight = 40 * 8 + 64 + 3 * 5 + 2 * 16
    obj.height = obj.height or obj.minHeight
    obj.resizable = false
    obj.draggable = false

    obj = inherited.New(self, obj)

    -- Some controls are editing VBack/Restart button, so better having it built
    -- up before addressing the stuff
    local grid = Chili.Grid:New {
        parent = obj,
        x = '0%',
        y = 40 * 8 + 2 * 5,
        width = '100%',
        height = 64 + 5,
        rows = 1,
        columns = 1,        
        padding = {5,0,5,5},
    }
    local ok = Chili.Button:New {
        parent = grid,
        caption = "Back",
        backgroundColor = { 1, 1, 1, 1 },
        OnMouseUp = { Back },
    }
    obj.ok_button = ok

    -- Add the controls
    local grid = Chili.Grid:New {
        parent = obj,
        x = '0%',
        y = '0%',
        width = '100%',
        height = 40 * 8 + 2 * 5,
        rows = 8,
        columns = 1,        
        padding = {5,5,5,5},
    }

    SliderWithLabel({
        parent = grid,
        caption = "Gamma",
        backgroundColor = { 1, 1, 1, 1 },
        OnChange = { function(self, v)
            if v == nil then return end
            WG.POSTPROC.tonemapping.gamma = v
        end },
        start_val = GAMMA.start_val,
        end_val = GAMMA.end_val,
        steps = GAMMA.steps,
        curr_val = WG.POSTPROC.tonemapping.gamma,
    })
    SliderWithLabel({
        parent = grid,
        caption = "Gamma Fluctuation",
        backgroundColor = { 1, 1, 1, 1 },
        OnChange = { function(self, v)
            if v == nil then return end
            WG.POSTPROC.tonemapping.dGamma = v
        end },
        start_val = DGAMMA.start_val,
        end_val = DGAMMA.end_val,
        steps = DGAMMA.steps,
        curr_val = WG.POSTPROC.tonemapping.dGamma,
    })
    SliderWithLabel({
        parent = grid,
        caption = "Film grain",
        backgroundColor = { 1, 1, 1, 1 },
        OnChange = { function(self, v)
            if v == nil then return end
            WG.POSTPROC.filmgrain.grain = v
        end },
        start_val = GRAIN.start_val,
        end_val = GRAIN.end_val,
        steps = GRAIN.steps,
        curr_val = WG.POSTPROC.filmgrain.grain,
    })
    SliderWithLabel({
        parent = grid,
        caption = "Scratches",
        backgroundColor = { 1, 1, 1, 1 },
        OnChange = { function(self, v)
            if v == nil then return end
            WG.POSTPROC.scratches.threshold = v
        end },
        start_val = SCRATCHES.start_val,
        end_val = SCRATCHES.end_val,
        steps = SCRATCHES.steps,
        curr_val = WG.POSTPROC.scratches.threshold,
    })
    SliderWithLabel({
        parent = grid,
        caption = "Vignette",
        backgroundColor = { 1, 1, 1, 1 },
        OnChange = { function(self, v)
            if v == nil then return end
            WG.POSTPROC.vignette.vignette[2] = v
        end },
        start_val = VIGNETTE.start_val,
        end_val = VIGNETTE.end_val,
        steps = VIGNETTE.steps,
        curr_val = WG.POSTPROC.vignette.vignette[2],
    })
    SliderWithLabel({
        parent = grid,
        caption = "Color aberration",
        backgroundColor = { 1, 1, 1, 1 },
        OnChange = { function(self, v)
            if v == nil then return end
            WG.POSTPROC.aberration.aberration = v
        end },
        start_val = ABERRATION.start_val,
        end_val = ABERRATION.end_val,
        steps = ABERRATION.steps,
        curr_val = WG.POSTPROC.aberration.aberration,
    })
    CheckboxWithLabel({
        parent = grid,
        caption = "Gray/Sepia color",
        backgroundColor = { 1, 1, 1, 1 },
        OnChange = { function(self, v)
            if v == nil then return end
            WG.POSTPROC.grayscale.enabled = v
        end },
        checked = WG.POSTPROC.grayscale.enabled,
    })
    SliderWithLabel({
        parent = grid,
        caption = "Sepia Tone",
        backgroundColor = { 1, 1, 1, 1 },
        OnChange = { function(self, v)
            if v == nil then return end
            WG.POSTPROC.grayscale.sepia = v
        end },
        start_val = SEPIA.start_val,
        end_val = SEPIA.end_val,
        steps = SEPIA.steps,
        curr_val = WG.POSTPROC.grayscale.sepia,
    })

    -- Hiden by default
    obj:Hide()

    return obj
end 

function this:Show(visitor)
    self.visitor = visitor
    inherited.Show(self)
end
