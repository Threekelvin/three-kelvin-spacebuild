AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    self:AddResource("liquid_nitrogen", self.data.liquid_nitrogen)
    
    WireLib.CreateOutputs(self, {"LiquidNitrogen", "MaxLiquidNitrogen"})
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
    WireLib.TriggerOutput(self, "LiquidNitrogen", self:GetResourceAmount("liquid_nitrogen"))
    WireLib.TriggerOutput(self, "MaxLiquidNitrogen", self:GetResourceCapacity("liquid_nitrogen"))
end