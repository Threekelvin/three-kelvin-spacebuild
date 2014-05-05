AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)

    self:AddResource("magnetite", self.data.magnetite)
    self.Outputs = Wire_CreateOutputs(self, {"Magnetite", "MaxMagnetite"})
end

function ENT:NewNetwork(netid)
    WireLib.TriggerOutput(self, "Magnetite", self:GetResourceAmount("magnetite"))
    WireLib.TriggerOutput(self, "MaxMagnetite", self:GetResourceCapacity("asteroid_ore"))
end

function ENT:UpdateValues()
    WireLib.TriggerOutput(self, "Magnetite", self:GetResourceAmount("magnetite"))
    WireLib.TriggerOutput(self, "MaxMagnetite", self:GetResourceCapacity("magnetite"))
end