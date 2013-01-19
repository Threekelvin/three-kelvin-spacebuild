AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')


function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:AddResource("raw_tiberium", 0)
	
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

function ENT:Update(ply)
	local data = TK.TD:GetItem(self.itemid).data
    local upgrades = TK.TD:GetUpgradeStats(ply, "tiberium")
    
    self:AddResource("raw_tiberium", data.capacity + (data.capacity * upgrades.capacity))
end

function ENT:PreEntityCopy()
	TK.LO:MakeDupeInfo(self)
end

function ENT:PostEntityPaste(ply, ent, CreatedEntities)
	TK.LO:ApplyDupeInfo(ply, ent, CreatedEntities)
end