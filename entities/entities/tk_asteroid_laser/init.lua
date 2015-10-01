AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self.data = self.data or {}
    self:SetRange(self.data.range)
    self:SetNWBool("Generator", true)
    self:AddResource("raw_asteroid_ore", 0, true)
    self:AddSound("l", 7, 65)
    self.Inputs = WireLib.CreateInputs(self, {"On"})
    self.Outputs = WireLib.CreateOutputs(self, {"On",  "Range"})
end

function ENT:SetRange(val)
    self:SetNWInt("Range", val)
    self.range = val
    self.rangesqr = val * val
    WireLib.TriggerOutput(self, "Range", val)
end

function ENT:TurnOn()
    if self:GetActive() or not self:IsLinked() then return end
    self:SetActive(true)
    WireLib.TriggerOutput(self, "On", 1)
    self:SoundPlay(1)
end

function ENT:TurnOff()
    if not self:GetActive() then return end
    self:SetActive(false)
    WireLib.TriggerOutput(self, "On", 0)
    self:SoundStop(1)
end

function ENT:TriggerInput(iname, value)
    if iname == "On" then
        if value ~= 0 then
            self:TurnOn()
        else
            self:TurnOff()
        end
    end
end

function ENT:DoThink(eff)
    if not self:GetActive() then return end
    if not self:Work() then return end
    local trace = util.QuickTrace(self:LocalToWorld(Vector(0, 0, 32)), self:GetUp() * (self.data.range + 32), self)
    if not IsValid(trace.Entity) then return end
    local ent = trace.Entity
    local owner = self:CPPIGetOwner()
    if not IsValid(owner) then return end
    if owner:IsAFK() then return end
    local yield = math.floor(self.data.magnetite * eff)
    if yield == 0 then return end

    if ent:GetClass() == "tk_asteroid" then
        ent:Mine(yield)
        TK.DB:AddScore(owner, yield)
    elseif ent:GetClass() == "tk_asteroid_ore" then
        TK.DB:AddScore(owner, self:SupplyResource("raw_asteroid_ore", yield))
    elseif ent:IsPlayer() or ent:IsNPC() then
        local dmg_info = DamageInfo()
        dmg_info:SetDamage(math.random(yield, yield * 2))
        dmg_info:SetDamageType(DMG_RADIATION)
        dmg_info:SetAttacker(self:CPPIGetOwner())
        dmg_info:SetInflictor(self)
        ent:TakeDamageInfo(dmg_info)
    end
end

function ENT:NewNetwork(netid)
    if netid == 0 then
        self:TurnOff()
    end
end

function ENT:UpdateValues()
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end
