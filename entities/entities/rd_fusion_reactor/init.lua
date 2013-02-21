AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self.ambient = 0
    self.heat = 0
    
    self:SetNWBool("Generator", true)
    self:AddResource("hydrogen", 0)
    self:AddResource("liquid_nitrogen", 0)
    self:AddSound("a", 6, 75)
    self:AddSound("l", 9, 100)
    self:AddSound("s", 1, 75)
    
    WireLib.CreateInputs(self, {"On", "Mute"})
    WireLib.CreateOutputs(self, {"On", "Heat", "Output"})
end

function ENT:TurnOn()
    if self:GetActive()  || !self:IsLinked() then return end
    self:SetActive(true)
    self:SoundPlay(1)
    self:SoundPlay(2)
    self:SoundStop(3)
    WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
    if !self:GetActive()  then return end
    self:SetActive(false)
    self:SetPower(false)
    self:SetPower(0)
    self:SoundStop(1)
    self:SoundStop(2)
    self:SoundPlay(3)
    WireLib.TriggerOutput(self, "On", 0)
    WireLib.TriggerOutput(self, "Output", 0)
end

function ENT:TriggerInput(iname, value)
    if iname == "On" then
        if value != 0 then
            self:TurnOn()
        else
            self:TurnOff()
        end
    elseif iname == "Mute" then
        self.mute = tobool(value)
    end
end

function ENT:TriggerInput(iname, value)
    if iname == "On" then
        if value != 0 then
            self:TurnOn()
        else
            self:TurnOff()
        end
    end
end

function ENT:Explode()
    self:Remove()
end

function ENT:DoThink()
    local env = self:GetEnv()
    self.ambient = env:DoTemp(self)
    self.heat = math.floor(self.heat + 0.01 * (self.ambient - self.heat))
    WireLib.TriggerOutput(self, "Heat", self.heat)
    if self.heat > 3000 then self:Explode() end
    
    if !self:GetActive() then return end
    
    local hydrogen = self:ConsumeResource("hydrogen", self.data.hydrogen)
    if hydrogen < self.data.hydrogen then self:TurnOff() return end
    if !self:Work() then return end

    self.heat = math.floor(self.heat + (hydrogen * 2))
    if self.heat > self.ambient then
        local excess = self.heat - self.ambient
        local nitrogen = self:ConsumeResource("liquid_nitrogen", excess)
        self.heat = self.heat - nitrogen
    end
    
    WireLib.TriggerOutput(self, "Output", self:GetPowerGrid())
end

function ENT:NewNetwork(netid)
    if netid == 0 then
        self:TurnOff()
    end
end

function ENT:UpdateValues()

end