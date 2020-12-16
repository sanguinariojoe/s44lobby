local Chili = WG.Chili

SettingsWindow = Chili.Window:Inherit{
    drawcontrolv2 = true
}

local this = SettingsWindow
local inherited = this.inherited

local RESOLUTIONS = {'800x600 (4:3)','1024x768 (4:3)','1152x864 (4:3)',
                     '1280x960 (4:3)','1280x1024 (4:3)', '1600x1200 (4:3)',
                     '1280x800 (16:9)', '1440x900 (16:9)', '1680x1050 (16:9)',
                     '1920x1080 (16:9)', '2048x768 (dual)', '2560x1024 (dual)',
                     '3200x1200 (dual)'}

local QUALITY_KEYS = {'very low', 'low', 'medium', 'high', 'very high'}  -- To ensure the order
local QUALITIES = {['very low']  = {["DepthBufferBits"]=16,
                                    ["ReflectiveWater"]=0,
                                    ["Shadows"]=0,
                                    ["3DTrees"]=0,
                                    ["AdvSky"]=0,
                                    ["DynamicSky"]=0,
                                    ["SmoothPoints"]=0,
                                    ["SmoothLines"]=0,
                                    ["FSAA"]=0,
                                    ["FSAALevel"]=0,
                                    ["AdvUnitShading"]=0,
                                    ["AllowDeferredMapRendering"]=0},
                   ['low']       = {["DepthBufferBits"]=16,
                                    ["ReflectiveWater"]=0,
                                    ["Shadows"]=0,
                                    ["3DTrees"]=1,
                                    ["AdvSky"]=0,
                                    ["DynamicSky"]=0,
                                    ["SmoothPoints"]=0,
                                    ["SmoothLines"]=0,
                                    ["FSAA"]=0,
                                    ["FSAALevel"]=0,
                                    ["AdvUnitShading"]=0,
                                    ["AllowDeferredMapRendering"]=0},
                   ['medium']    = {["DepthBufferBits"]=16,
                                    ["ReflectiveWater"]=1,
                                    ["Shadows"]=0,
                                    ["3DTrees"]=1,
                                    ["AdvSky"]=0,
                                    ["DynamicSky"]=0,
                                    ["SmoothPoints"]=0,
                                    ["SmoothLines"]=1,
                                    ["FSAA"]=0,
                                    ["FSAALevel"]=0,
                                    ["AdvUnitShading"]=0,
                                    ["AllowDeferredMapRendering"]=0},
                   ['high']      = {["DepthBufferBits"]=24,
                                    ["ReflectiveWater"]=2,
                                    ["Shadows"]=1,
                                    ["3DTrees"]=1,
                                    ["AdvSky"]=0,
                                    ["DynamicSky"]=0,
                                    ["SmoothPoints"]=0,
                                    ["SmoothLines"]=1,
                                    ["FSAA"]=0,
                                    ["FSAALevel"]=0,
                                    ["AdvUnitShading"]=1,
                                    ["AllowDeferredMapRendering"]=0},
                   ['very high'] = {["DepthBufferBits"]=24,
                                    ["ReflectiveWater"]=3,
                                    ["Shadows"]=1,
                                    ["3DTrees"]=1,
                                    ["AdvSky"]=1,
                                    ["DynamicSky"]=1,
                                    ["SmoothPoints"]=1,
                                    ["SmoothLines"]=1,
                                    ["FSAA"]=1,
                                    ["FSAALevel"]=1,
                                    ["AdvUnitShading"]=1,
                                    ["AllowDeferredMapRendering"]=1}}
local QUALITY_WIDGETS = {['very low'] =  {"disablewidget Screen-Space Ambient Occlusion",
                                          "disablewidget Post-processing"},
                         ['low'] =       {"disablewidget Screen-Space Ambient Occlusion",
                                          "disablewidget Post-processing"},
                         ['medium'] =    {"disablewidget Screen-Space Ambient Occlusion",
                                          "disablewidget Post-processing"},
                         ['high'] =      {"disablewidget Screen-Space Ambient Occlusion",
                                          "enablewidget Post-processing"},
                         ['very high'] = {"enablewidget Screen-Space Ambient Occlusion",
                                          "enablewidget Post-processing"}}
local DEF_QUALITY = 'unknown'

local DETAIL_KEYS = {'low', 'medium', 'high'}  -- To ensure the order
local DETAILS = {['low']    = {["ShadowMapSize"]=1024,
                               -- ["TreeRadius"]=600,  -- Overwritten at restart
                               ["GroundDetail"]=20,
                               ["UnitLodDist"]=100,
                               ["GrassDetail"]=0,
                               ["GroundDecals"]=0,
                               -- ["UnitIconDist"]=100,  -- Overwritten by cmd_distIcon.lua
                               ["MaxParticles"]=100,
                               ["MaxNanoParticles"]=100},
                 ['medium'] = {["ShadowMapSize"]=4096,
                               -- ["TreeRadius"]=1900,  -- Overwritten at restart
                               ["GroundDetail"]=70,
                               ["UnitLodDist"]=350,
                               ["GrassDetail"]=15,
                               ["GroundDecals"]=0,
                               -- ["UnitIconDist"]=550,  -- Overwritten by cmd_distIcon.lua
                               ["MaxParticles"]=4000,
                               ["MaxNanoParticles"]=6000},
                 ['high']   = {["ShadowMapSize"]=8192,
                               -- ["TreeRadius"]=3000,  -- Overwritten at restart
                               ["GroundDetail"]=120,
                               ["UnitLodDist"]=1000,
                               ["GrassDetail"]=30,
                               ["GroundDecals"]=1,
                               -- ["UnitIconDist"]=1000,  -- Overwritten by cmd_distIcon.lua
                               ["MaxParticles"]=20000,
                               ["MaxNanoParticles"]=20000}}
local DEF_DETAIL = 'unknown'

local RESTART_QUERIES = {quality=false, detail=false}

--//=============================================================================

VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

local function SetBackButton(win)
    button = win.ok_button
    button:SetCaption("Back")
    button.OnMouseUp = { Back }
end

local function SetRestartButton(win)
    button = win.ok_button
    button:SetCaption("Restart")
    button.OnMouseUp = { Quit }
end

local function SetAutoButton(win)
    for _,v in pairs(RESTART_QUERIES) do
        if v then
            SetRestartButton(win)
            return
        end
    end
    SetBackButton(win)
end

local function GetDefaultSettings(map)
    -- map shall be QUALITIES or DETAILS
    local stored_settings = {}
    for name, settings in pairs(map) do
        local is_this = true
        for k, v in pairs(settings) do
            stored_settings[k] = Spring.GetConfigInt(k)
            if stored_settings[k] ~= v then
                is_this = false
            end
        end
        if is_this then
            return name, settings
        end
    end
    return "custom", stored_settings
end

local function SetSettings(settings)
    for k, v in pairs(settings) do
        Spring.SetConfigInt(k, v)
    end    
end

local function QualityChange(self, itemIdx)
    local win = TopLevelParent(self)
    local name = self.items[itemIdx]
    if name == DEF_QUALITY then
        RESTART_QUERIES.quality = false
    else
        RESTART_QUERIES.quality = true
    end
    SetAutoButton(win)
    SetSettings(QUALITIES[name])
    for _,cmd in ipairs(QUALITY_WIDGETS[name]) do
        Spring.SendCommands({"luaui " .. cmd})
    end
end

local function DetailChange(self, itemIdx)
    local win = TopLevelParent(self)
    local name = self.items[itemIdx]
    if name == DEF_DETAIL then
        RESTART_QUERIES.detail = false
    else
        RESTART_QUERIES.detail = true
    end
    SetAutoButton(win)
    SetSettings(DETAILS[name])
end

local function ResolutionStrToNum(str)
    local i
    i = string.find(str, "x")
    if i == nil then
        return 0, 0
    end
    local x = tonumber(string.sub(str, 1, i - 1))
    str = string.sub(str, i + 1)
    i = string.find(str, " ")
    if i == nil then
        i = string.len(str) + 1
    end
    local y = tonumber(string.sub(str, 1, i - 1))
    return x, y
end

local function ResolutionChange(self, itemIdx)
    local win = TopLevelParent(self)
    local vsx, vsy

    if itemIdx > #RESOLUTIONS then
        -- SetBackButton(win)
        vsx, vsy = gl.GetViewSizes()
    else
        -- SetRestartButton(win)
        vsx, vsy = ResolutionStrToNum(RESOLUTIONS[itemIdx])
    end

    Spring.SetConfigInt("Fullscreen", 1)
    Spring.SendCommands("Fullscreen 0")
    Spring.SetConfigInt("XResolution", vsx)
    Spring.SetConfigInt("YResolution", vsy)
    Spring.SendCommands("Fullscreen 1")
end

local function GoToPostProcess(self)
    local win = TopLevelParent(self)
    local child = win.postprocess_win
    child:Show(win)
    win:Hide()
end

--//=============================================================================

function this:New(obj, postprocess_win)
    self.postprocess_win = postprocess_win

    obj.x = obj.x or '30%'
    obj.y = obj.y or '10%'
    obj.minwidth = 320
    obj.width = obj.width or '40%'
    obj.minHeight = 64 * 5 + 3 * 5 + 2 * 16
    obj.height = obj.height or obj.minHeight
    obj.resizable = false
    obj.draggable = false

    obj = inherited.New(self, obj)

    -- Some controls are editing VBack/Restart button, so better having it built
    -- up before addressing the stuff
    local grid = Chili.Grid:New {
        parent = obj,
        x = '0%',
        y = 64 * 3 + 2 * 5,
        width = '100%',
        height = 64 * 2 + 5,
        rows = 2,
        columns = 1,        
        padding = {5,0,5,5},
    }
    local postprocess = Chili.Button:New {
        parent = grid,
        caption = "GFX Post-Processing",
        backgroundColor = { 1, 1, 1, 1 },
        OnMouseUp = { GoToPostProcess },
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
        height = 64 * 3 + 2 * 5,
        rows = 3,
        columns = 1,        
        padding = {5,5,5,5},
    }

    local name, settings = GetDefaultSettings(QUALITIES)
    DEF_QUALITY = name
    local itemIdx
    for i,k in ipairs(QUALITY_KEYS) do
        if name == k then
            itemIdx = i
        end
    end
    if itemIdx == nil then
        itemIdx = #QUALITY_KEYS + 1
        QUALITY_KEYS[itemIdx] = name
        QUALITIES[name] = settings
    end
    local _, _, quality = ComboBoxWithLabel({
        parent = grid,
        caption = "Graphics Quality",
        backgroundColor = { 1, 1, 1, 1 },
        OnSelect = { QualityChange },
        items = QUALITY_KEYS,
        selected = itemIdx,
    })

    local name, settings = GetDefaultSettings(DETAILS)
    DEF_DETAIL = name
    local itemIdx
    for i,k in ipairs(DETAIL_KEYS) do
        if name == k then
            itemIdx = i
        end
    end
    if itemIdx == nil then
        itemIdx = #DETAIL_KEYS + 1
        DETAIL_KEYS[itemIdx] = name
        DETAILS[name] = settings
    end
    local _, _, detail = ComboBoxWithLabel({
        parent = grid,
        caption = "Graphics Detail",
        backgroundColor = { 1, 1, 1, 1 },
        OnSelect = { DetailChange },
        items = DETAIL_KEYS,
        selected = itemIdx,
    })

    local vsx, vsy = gl.GetViewSizes()
    local items = {}
    for i,v in ipairs(RESOLUTIONS) do
        items[i] = v
    end
    items[#items + 1] = tostring(vsx) .. 'x' .. tostring(vsy) .. ' (current)'
    local _, _, resolution = ComboBoxWithLabel({
        parent = grid,
        caption = "Resolution",
        backgroundColor = { 1, 1, 1, 1 },
        OnSelect = { ResolutionChange },
        items = items,
        selected = #items,
    })

    -- Hiden by default
    obj:Hide()

    return obj
end 

function this:Show(visitor)
    self.visitor = visitor
    inherited.Show(self)
    SetEscAction(self, Back)
end
