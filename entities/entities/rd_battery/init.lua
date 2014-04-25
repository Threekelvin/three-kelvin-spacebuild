AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    self:AddResource("kilojoules", self.data.kilojoules)
    
    WireLib.CreateOutputs(self, {"Kilojoules", "MaxKilojoules"})
    self:UpdateValues()
end

function ENT:TurnOn()

end

function ENT:TurnOff()

end

function ENT:Use()

end

function ENT:Work()
    return true
end

function ENT:DoThink(eff)
    
end

function ENT:DoPostThink()
    local power = self:GetPowerGrid() - self:GetUnitPowerGrid()
    local energy = power > 0 and math.min(power, self.data.power) or  math.max(power, -self.data.power)
    
    if energy > 0 then
        self:SetPower(-energy)
        self:SupplyResource("kilojoules", energy)
    else
        self:SetPower(self:ConsumeResource("kilojoules", -energy))
    end
end

function ENT:NewNetwork(netid)
    self:UpdateValues()
end

function ENT:UpdateValues()
    WireLib.TriggerOutput(self, "Kilojoules", self:GetResourceAmount("kilojoules"))
    WireLib.TriggerOutput(self, "MaxKilojoules", self:GetResourceCapacity("kilojoules"))
end