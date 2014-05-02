AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')


function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    self:GetNWInt("crystal", 0)
    self.Stable = true
    self.PowerLevel = 0
    
    self.data.yield = 0
    self.data.kilowatt = 0
    
    self:SetNWBool("Generator", true)
    self:AddResource("raw_tiberium", 0, true)
    self:AddSound("a", 4, 75)
    self:AddSound("l", 8, 75)
    self:AddSound("d", 4, 100)
    self:AddSound("s", 4, 75)
    
    self.Inputs = Wire_CreateInputs(self, {"On"})
    self.Outputs = Wire_CreateOutputs(self, {"On", "Output"})
end

function ENT:UpdateTransmitState() 
    return TRANSMIT_ALWAYS 
end

function ENT:TurnOn()
    if self:GetActive() or !self:IsLinked() then return end
    self:SetActive(true)
    self:SoundPlay(1)
    self:SoundPlay(2)
    self.PowerLevel = 0
    
    WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
    if !self:GetActive() then return end
    self:SetActive()
    self:SoundStop(2)
    self:SoundStop(3)
    self:SoundPlay(4)
    self.PowerLevel = 0
    
    WireLib.TriggerOutput(self, "On", 0)
end

function ENT:TriggerInput(iname, value)
    if iname == "On" then
        if value != 0 then
            self:TurnOn()
        else
            self:TurnOff()
        end
    end
end

function ENT:DoThink(eff)
    if !self:GetActive() then return end
    if !self:Work() then return end
    
    local crystal
    for k,v in pairs(ents.FindInCone(self:GetPos(), self:GetForward(), 100, 45)) do
        if v:GetClass() == "tk_tib_crystal" then
            crystal = v
            break
        end
    end
    
    if IsValid(crystal) then
        local owner, uid = self:CPPIGetOwner()
        if !IsValid(owner) then return end
        
        if self.PowerLevel < 1 then
            self.PowerLevel = self.PowerLevel + (1/10)
        else
            self.PowerLevel = 1
        end
        if self:GetCrystal() != crystal:EntIndex() then
            self:SetNWInt("crystal", crystal:EntIndex())
            self.PowerLevel = 0
        end
        local yield = math.floor(self.data.yield * self.PowerLevel * eff)
        
        if self.Stable != crystal.isStable then
            self.Stable = crystal.isStable
            if self.Stable then
                self:SoundStop(3)
                self:SoundPlay(2)
            else
                self:SoundStop(2)
                self:SoundPlay(3)
            end
        end
        
        yield = math.min(yield, crystal.Tib)
        yield = self:SupplyResource("raw_tiberium", yield)
        WireLib.TriggerOutput(self, "Output", yield)
        
        local value = TK.TD:Ore(owner, "raw_tiberium")
        
        if !owner:IsAFK() then
            owner.tk_cache.score = math.floor((owner.tk_cache.score or 0) + value * yield * 0.75)
            owner.tk_cache.exp = math.floor((owner.tk_cache.exp or 0) + value * yield * 0.375)
        end
        
        crystal.Tib = crystal.Tib - yield
    else
        if self:GetCrystal() != 0 then
            self:SetNWInt("crystal", 0)
            self.Stable = true
            self:SoundStop(3)
            self:SoundPlay(2)
            WireLib.TriggerOutput(self, "Output", 0)
        end
    end
end

function ENT:NewNetwork(netid)
    if netid == 0 then
        self:TurnOff()
    end
end

function ENT:UpdateValues()

end

function ENT:Update(ply)
    local data = TK.TD:GetItem(self.itemid).data
    local upgrades = TK.TD:GetUpgradeStats(ply, "tiberium")
    
    self.data.yield = data.yield + (data.yield * upgrades.yield)
    self.data.kilowatt = data.kilowatt - (data.kilowatt * upgrades.kilowatt)
end

function ENT:PreEntityCopy()
    self.BaseClass.PreEntityCopy(self)
    TK.LO:MakeDupeInfo(self)
end

function ENT:PostEntityPaste(ply, ent, entlist)
    self.BaseClass.PostEntityPaste(self, ply, ent, entlist)
    TK.LO:ApplyDupeInfo(ply, ent, info)
end

function ENT:UpdateTransmitState() 
    return TRANSMIT_ALWAYS 
end