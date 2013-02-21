AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    self:AddResource("nitrogen", self.data.nitrogen)
    self:AddResource("hydrogen", self.data.hydrogen)
    self:AddResource("liquid_nitrogen", self.data.liquid_nitrogen)
    
    WireLib.CreateOutputs(self, {"Nitrogen", "MaxNitrogen", "Hydrogen", "MaxHydrogen", "LiquidNitrogen", "MaxLiquidNitrogen"})
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
    WireLib.TriggerOutput(self, "Nitrogen", self:GetResourceAmount("nitrogen"))
    WireLib.TriggerOutput(self, "MaxNitrogen", self:GetResourceCapacity("nitrogen"))
    WireLib.TriggerOutput(self, "Hydrogen", self:GetResourceAmount("hydrogen"))
    WireLib.TriggerOutput(self, "MaxHydrogen", self:GetResourceCapacity("hydrogen"))
    WireLib.TriggerOutput(self, "LiquidNitrogen", self:GetResourceAmount("liquid_nitrogen"))
    WireLib.TriggerOutput(self, "MaxLiquidNitrogen", self:GetResourceCapacity("liquid_nitrogen"))
end