AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:AddResource("steam", self.data.steam)
	
	WireLib.CreateOutputs(self, {"Steam", "MaxSteam"})
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
	WireLib.TriggerOutput(self, "Steam", self:GetResourceAmount("steam"))
	WireLib.TriggerOutput(self, "MaxSteam", self:GetResourceCapacity("steam"))
end