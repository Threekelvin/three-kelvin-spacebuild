AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:AddResource("oxygen", self.data.oxygen)
	
	WireLib.CreateOutputs(self, {"Oxygen", "MaxOxygen"})
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
end