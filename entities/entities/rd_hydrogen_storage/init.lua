AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:AddResource("hydrogen", self.data.hydrogen)
	
	WireLib.CreateOutputs(self, {"Hydrogen", "MaxHydrogen"})
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
	WireLib.TriggerOutput(self, "Hydrogen", self:GetResourceAmount("hydrogen"))
	WireLib.TriggerOutput(self, "MaxHydrogen", self:GetResourceCapacity("hydrogen"))
end