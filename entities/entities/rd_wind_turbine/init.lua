AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self:ResetSequence(self:LookupSequence("rotate"))
    self.windspeed = 0
    self.speed = 0
    
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
    
    self:SetNWBool("Generator", true)
    WireLib.CreateOutputs(self, {"On", "Output"})
end

function ENT:Think()
    self.speed = self.speed + 0.01 * (self.windspeed - self.speed)
    if self.speed < 0.0005 then self.speed = 0 end
    self:SetPlaybackRate(self.speed)
    self:NextThink(CurTime())
    return true
end

function ENT:TurnOn()
    if self:GetActive() then return end
    self:SetActive(true)
    WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
    if !self:GetActive() then return end
    self:SetActive(false)
    self.windspeed = 0
    WireLib.TriggerOutput(self, "On", 0)
    WireLib.TriggerOutput(self, "Output", 0)
end

function ENT:Use()

end

function ENT:DoThink()
    local env = self:GetEnv()
    if !env:IsPlanet() then self:TurnOff() return end
    self.windspeed = env.atmosphere.windspeed / 100
    self:TurnOn()
    self:SetPower(self.data.power)
    WireLib.TriggerOutput(self, "Output", self:GetPowerGrid())
end

function ENT:NewNetwork(netid)
    if netid == 0 then
        self:TurnOff()
    end
end

function ENT:UpdateValues()

end