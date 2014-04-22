AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)

    self:AddResource("magnetite", 0)
    self.Outputs = Wire_CreateOutputs(self, {"AsteroidOre", "MaxAsteroidOre"})
end

function ENT:NewNetwork(netid)
    WireLib.TriggerOutput(self, "AsteroidOre", self:GetResourceAmount("magnetite"))
    WireLib.TriggerOutput(self, "MaxAsteroidOre", self:GetResourceCapacity("asteroid_ore"))
end

function ENT:UpdateValues()
    WireLib.TriggerOutput(self, "AsteroidOre", self:GetResourceAmount("magnetite"))
    WireLib.TriggerOutput(self, "MaxAsteroidOre", self:GetResourceCapacity("magnetite"))
end

function ENT:Update(ply)
    local data = TK.TD:GetItem(self.itemid).data
    local upgrades = TK.TD:GetUpgradeStats(ply, "asteroid")
    
    self:AddResource("magnetite", data.capacity + (data.capacity * upgrades.capacity))
end

function ENT:PreEntityCopy()
    self.BaseClass.PreEntityCopy(self)
    TK.LO:MakeDupeInfo(self)
end

function ENT:PostEntityPaste(ply, ent, entlist)
    self.BaseClass.PostEntityPaste(self, ply, ent, entlist)
    TK.LO:ApplyDupeInfo(ply, ent, info)
end