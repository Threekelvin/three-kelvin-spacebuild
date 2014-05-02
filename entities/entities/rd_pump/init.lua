AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)

    self:SetNWInt("Range", self.data.range)
    self:SetNWInt("Linked", 0)
    self.rangesqr = self.data.range * self.data.range
    self.next_use = 0
    
    self:SetNWBool("Generator", true)
    self:AddSound("l", 2, 65)
    
    WireLib.CreateInputs(self, {"On", "Mute"})
    WireLib.CreateOutputs(self, {"On"})
end

function ENT:TurnOn()
    if self:GetActive() or !self:IsLinked() or self:GetLinked() == 0 then return end
    self:SetActive(true)
    self:SoundPlay(1)
    WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
    if !self:GetActive() then return end
    self:SetActive(false)
    self:SoundStop(1)
    WireLib.TriggerOutput(self, "On", 0)
end

function ENT:Use(ply)
    if !IsValid(ply) or !ply:IsPlayer() then return end
    if !self:CPPICanUse(ply) then return end
    if self.next_use > CurTime() then return end
    self.next_use = CurTime() + 1
    
    self:DoMenu(ply)
end

function ENT:SetLinked(netid)
    self:SetNWInt("Linked", netid)
end

function ENT:DoCommand(ply, cmd, arg)
    if cmd == "on" then
        if tobool(arg[1]) then
            self:TurnOn()
        else
            self:TurnOff()
        end
    elseif cmd == "link" then
        local entid = tonumber(arg[1])
        local ent = Entity(entid)
        if !IsValid(ent) or !ent.IsTKRD or !ent.IsNode then return end
        if ent == TK.RD:GetNetTable(self:GetEntTable().netid).node then return end
        self:SetLinked(ent:GetNWInt("NetID"))
    elseif cmd == "set" then
        if !TK.RD:IsResource(arg[1]) then return end
        local amt = math.floor(tonumber(arg[2]))
        local entdata = self:GetEntTable()
        if amt <= 0 then
            entdata.data[arg[1]] = nil
            entdata.update = {}
        else
            entdata.data[arg[1]] = math.Clamp(amt, 0, 1000)
            entdata.update = {}
        end
    end
end

function ENT:TriggerInput(iname, value)
    if iname == "On" then
        if value != 0 then
            self:TurnOn()
        else
            self:TurnOff()
        end
    elseif iname == "Multiplier" then
        self.mult = math.max(0, value)
    elseif iname == "Mute" then
        self.mute = tobool(value)
    end
end

function ENT:DoThink(eff)
    if !self:GetActive() then return end
    
    local lnetid = self:GetLinked()
    local lnetdata = TK.RD:GetNetTable(lnetid)
    local entdata = self:GetEntTable()
    if !IsValid(lnetdata.node) then self:TurnOff() return end
    
    local netid = self:GetEntTable().netid
    local netdata = TK.RD:GetNetTable(netid)
    if (lnetdata.node:GetPos() - self:GetPos()):LengthSqr() > self.rangesqr then
        self:SetLinked(0)
        self:TurnOff()
        self:SoundPlay(0)
        return
    end
    
    self.data.kilowatt = 0
    for k,v in pairs(entdata.data) do
        self.data.kilowatt = self.data.kilowatt - math.ceil(v * 0.01)
    end
    
    if !self:Work() then return end    
    
    for k,v in pairs(entdata.data) do
        local amt = self:ConsumeResource(k, v * eff)
        if amt > 0 then 
            self:SupplyResource(k, TK.RD:NetSupplyResource(lnetid, k, amt))
        end
    end
end

function ENT:NewNetwork(netid)
    if netid == 0 then
        self:TurnOff()
    elseif netid == self:GetLinked() then
        self:SetLinked(0)
    end
end

function ENT:UpdateValues()

end