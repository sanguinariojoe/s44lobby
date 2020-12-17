local Chili = WG.Chili

BackgroundControl = Chili.Control:Inherit{
    drawcontrolv2 = true
}

local this = BackgroundControl
local inherited = this.inherited

local BACKGROUNDS_DIR = "LuaUI/Widgets/gui_menu/rsrc/background/"
VFS.Include("LuaUI/Widgets/gui_menu/utils.lua")

--//=============================================================================

function RandomImage()
    local imgs = VFS.DirList(BACKGROUNDS_DIR)
    return imgs[math.random(#imgs)]
end

function Resize(self)
    local xSize, ySize = Spring.GetWindowGeometry()
    local w, h = self.backgroundImage.width, self.backgroundImage.height
    local f = math.max(xSize / w, ySize / h)
    local W, H = math.ceil(w * f), math.ceil(h * f)
    local dW, dH = W - xSize, H - ySize
    self.backgroundImage:SetPos(-dW / 2, -dH / 2, W, H)
end

function this:New(obj)
    obj.x = 0
    obj.y = 0
    obj.right = 0
    obj.bottom = 0
    obj.padding = {0,0,0,0}
    obj.margin = {0,0,0,0}

    obj = BackgroundControl.inherited.New(self, obj)

    obj.backgroundImage = Image:New {
        parent = obj,
        x = 0,
        y = 0,
        padding = {0,0,0,0},
        margin = {0,0,0,0},
        color = self.colorOverride,
        keepAspect = true,
        file = RandomImage(),
    }

    obj.OnResize = {
        function(self)
            Resize(self)
        end
    }

    Resize(obj)

    return obj
end
