AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:AddResource("energy", self.data.energy)
	
	WireLib.CreateOutputs(self, {"Energy", "MaxEnergy"})
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
end