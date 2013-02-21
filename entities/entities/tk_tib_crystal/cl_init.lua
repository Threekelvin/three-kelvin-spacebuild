include('shared.lua')

local TibEffects = CreateClientConVar("3k_tib_effects", 1, true, false)

function ENT:Initialize()
    self.NextUpdate = CurTime() + math.random(5, 10)
    self.LastModel = ""
    self.Offset = 0
end

function ENT:Draw()
    self:DrawTib()
end

function ENT:DrawTranslucent()
    self:Draw()
end

function ENT:Think()
    local model = self:GetModel() 
    if self.LastModel != model then
        self.Ghost = self.LastModel
        self.LastModel = model
        self.Offset = 10 + (self:OBBMaxs().z - self:OBBMins().z)
        self.Speed = self.Offset / 10
        
        self.pos = self:GetPos()
        self.time = SysTime()
    end

    if !TibEffects:GetBool() || self.NextUpdate > CurTime() then return end
    self.NextUpdate = self.NextUpdate + math.random(5, 10)
    
    local effectdata = EffectData()
    effectdata:SetOrigin(self:GetPos())
    effectdata:SetScale(1)
    util.Effect("VortDispel", effectdata, true, true)
end