AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self:AddResource("oxygen", self.data.oxygen)
    self:AddResource("nitrogen", self.data.nitrogen)
    self:AddResource("water", self.data.water)
    WireLib.CreateOutputs(self, {"Oxygen",  "MaxOxygen",  "Nitrogen",  "MaxNitrogen",  "Water",  "MaxWater"})
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
    WireLib.TriggerOutput(self, "Oxygen", self:GetResourceAmount("oxygen"))
    WireLib.TriggerOutput(self, "MaxOxygen", self:GetResourceCapacity("oxygen"))
    WireLib.TriggerOutput(self, "Nitrogen", self:GetResourceAmount("nitrogen"))
    WireLib.TriggerOutput(self, "MaxNitrogen", self:GetResourceCapacity("nitrogen"))
    WireLib.TriggerOutput(self, "Water", self:GetResourceAmount("water"))
    WireLib.TriggerOutput(self, "MaxWater", self:GetResourceCapacity("water"))
end
