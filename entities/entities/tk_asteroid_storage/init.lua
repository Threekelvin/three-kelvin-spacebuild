AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self.data = self.data or {}
    self:AddResource("raw_asteroid_ore", self.data.magnetite)
    self.Outputs = Wire_CreateOutputs(self, {"RawAsteroidOre",  "MaxRawAsteroidOre"})
end

function ENT:NewNetwork(netid)
    WireLib.TriggerOutput(self, "RawAsteroidOre", self:GetResourceAmount("raw_asteroid_ore"))
    WireLib.TriggerOutput(self, "MaxRawAsteroidOre", self:GetResourceCapacity("raw_asteroid_ore"))
end

function ENT:UpdateValues()
    WireLib.TriggerOutput(self, "RawAsteroidOre", self:GetResourceAmount("raw_asteroid_ore"))
    WireLib.TriggerOutput(self, "MaxRawAsteroidOre", self:GetResourceCapacity("raw_asteroid_ore"))
end
