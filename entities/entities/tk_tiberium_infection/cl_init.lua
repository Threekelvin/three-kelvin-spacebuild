include('shared.lua')

local OutlineDang = Material("models/alyx/emptool_glow")

function ENT:Initialize()
    self.scale_max = math.Rand(0.2, 0.6)
    self.scale = 0
    self:SetModelScale(0, 0)
end

function ENT:Draw()
    self:SetModelScale(self.scale * 1.1, 0)
    render.MaterialOverride(OutlineDang)
    self:DrawModel()
    
    self:SetModelScale(self.scale, 0)
    render.MaterialOverride(nil)
    self:DrawModel()
    
    self.scale = math.min(self.scale + 0.1 * FrameTime(), self.scale_max)
end

function ENT:DrawTranslucent()
    self:Draw()
end
