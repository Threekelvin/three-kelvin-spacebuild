AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:StorageOre()
	if self.upgrades then
		local amount = 10000
		return math.floor(amount + (amount * ((self.upgrades.r10 * 15) + (self.upgrades.r11 * 15) + (self.upgrades.r12 * 20)) / 100))
	else
		return 10000
	end
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.device = {1, 2}

	self:AddResource("asteroid_ore", self:StorageOre())
	self.Outputs = Wire_CreateOutputs(self, {"AsteroidOre", "MaxAsteroidOre"})
end

function ENT:NewNetwork(netid)
	WireLib.TriggerOutput(self, "AsteroidOre", self:GetResourceAmount("asteroid_ore"))
	WireLib.TriggerOutput(self, "MaxAsteroidOre", self:GetResourceCapacity("asteroid_ore"))
end

function ENT:UpdateValues()
	WireLib.TriggerOutput(self, "AsteroidOre", self:GetResourceAmount("asteroid_ore"))
	WireLib.TriggerOutput(self, "MaxAsteroidOre", self:GetResourceCapacity("asteroid_ore"))
end

function ENT:Update()
	self:AddResource("asteroid_ore", self:StorageOre())
end