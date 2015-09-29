AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self:AddResource("carbon_dioxide", self.data.carbon_dioxide)
    WireLib.CreateOutputs(self, {"CarbonDioxide",  "MaxCarbonDioxide"})
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
    WireLib.TriggerOutput(self, "CarbonDioxide", self:GetResourceAmount("carbon_dioxide"))
    WireLib.TriggerOutput(self, "MaxCarbonDioxide", self:GetResourceCapacity("carbon_dioxide"))
end
