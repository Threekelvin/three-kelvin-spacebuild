AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:AddResource("energy", self.data.energy)
	self:AddResource("oxygen", self.data.oxygen)
	self:AddResource("water", self.data.water)
	
	WireLib.CreateOutputs(self, {"Energy", "MaxEnergy", "Oxygen", "MaxOxygen", "Water", "MaxWater"})
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
	WireLib.TriggerOutput(self, "Energy", self:GetResourceAmount("energy"))
	WireLib.TriggerOutput(self, "MaxEnergy", self:GetResourceCapacity("energy"))
	WireLib.TriggerOutput(self, "Oxygen", self:GetResourceAmount("oxygen"))
	WireLib.TriggerOutput(self, "MaxOxygen", self:GetResourceCapacity("oxygen"))
	WireLib.TriggerOutput(self, "Water", self:GetResourceAmount("water"))
	WireLib.TriggerOutput(self, "MaxWater", self:GetResourceCapacity("water"))
end