AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:StorageTib()
	if self.upgrades then
		local amount = 1000
		return math.floor(amount + (amount * ((self.upgrades.r7 * 15) + (self.upgrades.r8 * 15) + (self.upgrades.r9 * 20)) / 100))
	else
		return 1000
	end
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.device = {2, 2}
	
	self:AddResource("raw_tiberium", self:StorageTib())
	
	self.Outputs = Wire_CreateOutputs(self, {"RawTiberium", "MaxRawTiberium"})
end

function ENT:NewNetwork(netid)
	WireLib.TriggerOutput(self, "RawTiberium", self:GetResourceAmount("raw_tiberium"))
	WireLib.TriggerOutput(self, "MaxRawTiberium", self:GetResourceCapacity("raw_tiberium"))
end


function ENT:UpdateValues()
	WireLib.TriggerOutput(self, "RawTiberium", self:GetResourceAmount("raw_tiberium"))
	WireLib.TriggerOutput(self, "MaxRawTiberium", self:GetResourceCapacity("raw_tiberium"))
end

function ENT:Update()
	self:AddResource("raw_tiberium", self:StorageTib())
end