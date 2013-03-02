include('shared.lua')

function ENT:Initialize()
    self.NextUpdate = CurTime() + math.random(5, 10)
end

function ENT:Draw()
    TK.TI:DrawTib(self)
    
    if self.NextUpdate > CurTime() then return end
    self.NextUpdate = self.NextUpdate + math.random(5, 10)
    
    local fxd = EffectData()
    fxd:SetOrigin(self:GetPos())
    fxd:SetScale(1)
    util.Effect("VortDispel", fxd, true, true)
end

function ENT:DrawTranslucent()
    self:Draw()
end