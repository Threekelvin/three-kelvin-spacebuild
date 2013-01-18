AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:AddResource("asteroid_ore", 0)
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

function ENT:Update(ply)
    local data = TK.TD:GetItem(self.itemid).data
    local upgrades = TK.TD:GetUpgradeStats(ply, "asteroid")
    
    self:AddResource("asteroid_ore", data.capacity + (data.capacity * upgrades.capacity))
end