AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    self:AddResource("nitrogen", self.data.nitrogen)
    
    WireLib.CreateOutputs(self, {"Nitrogen", "MaxNitrogen"})
    self:UpdateValues()
end

function ENT:TurnOn()

end

function ENT:TurnOff()

end

function ENT:Use()

end

function ENT:DoThink()

end

function ENT:NewNetwork(netid)
    self:UpdateValues()
end

function ENT:UpdateValues()
    WireLib.TriggerOutput(self, "Nitrogen", self:GetResourceAmount("nitrogen"))
    WireLib.TriggerOutput(self, "MaxNitrogen", self:GetResourceCapacity("nitrogen"))
end