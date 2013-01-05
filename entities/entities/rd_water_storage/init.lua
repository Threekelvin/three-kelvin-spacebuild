AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:AddResource("water", self.data.water)
	
	WireLib.CreateOutputs(self, {"Water", "MaxWater"})
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
	WireLib.TriggerOutput(self, "Water", self:GetResourceAmount("water"))
	WireLib.TriggerOutput(self, "MaxWater", self:GetResourceCapacity("water"))
end