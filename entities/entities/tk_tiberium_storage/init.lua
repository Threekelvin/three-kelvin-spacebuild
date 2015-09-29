AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")


function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    self:AddResource("tiberium", self.data.tiberium)
    
    self.Outputs = Wire_CreateOutputs(self, {"Tiberium", "MaxTiberium"})
end

function ENT:NewNetwork(netid)
    WireLib.TriggerOutput(self, "Tiberium", self:GetResourceAmount("tiberium"))
    WireLib.TriggerOutput(self, "MaxTiberium", self:GetResourceCapacity("tiberium"))
end


function ENT:UpdateValues()
    WireLib.TriggerOutput(self, "Tiberium", self:GetResourceAmount("tiberium"))
    WireLib.TriggerOutput(self, "MaxTiberium", self:GetResourceCapacity("tiberium"))
end