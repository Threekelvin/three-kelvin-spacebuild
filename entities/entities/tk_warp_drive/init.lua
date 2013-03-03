AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self.Ents = {}
    
    self:AddResource("liquid_nitrogen", 0)
    
    self.j_data = {}
    self.j_pos = self:GetPos()
    self.j_ang = self:GetAngles()
    self.j_par = self
    self.j_ang_enable = false
    self.j_lpos = self:GetPos()
    self.j_spool = 0
    
    self:SetNWBool("Generator", true)
    self:AddSound("a", 7, 100)
    self:AddSound("d", 6, 100)
    
    local entdata = self:GetEntTable()
    entdata.data.spool = self.j_spool
    entdata.update = {}
    
    WireLib.CreateInputs(self, {"Activate", "Jump", "X", "Y", "Z", "Pos [VECTOR]", "Use Angle", "Pitch", "Yaw", "Roll", "Ang [ANGLE]"})
    WireLib.CreateOutputs(self, {"Spooled", "Jump Pos [VECTOR]", "Jump Ang [ANGLE]"})
    
    WireLib.TriggerOutput(self, "Jump Pos", self.j_pos)
    WireLib.TriggerOutput(self, "Jump Ang", self.j_ang)
end

function ENT:Jump()
    if self.j_spool != 100 then self:SoundPlay(2) return end
    
    self.j_par = IsValid(self:GetParent()) && self:GetParent() || self
    local conent = self.j_par:GetConstrainedEntities()
    self.j_data = {}
    
    for _,ent in pairs(conent) do
        ent = IsValid(ent:GetParent()) && ent:GetParent() || ent
        local data = {}
        data.ent = ent
        data.phys = {}
        
        for I = 0, ent:GetPhysicsObjectCount() - 1 do
            local physobj = ent:GetPhysicsObjectNum(I)
            data.phys[I] = {}
            data.phys[I].pos = self.j_par:WorldToLocal(physobj:GetPos())
            if !self.j_ang_enable then continue end
            data.phys[I].ang = self.j_par:WorldToLocalAngles(physobj:GetAngles())
        end
        self.j_data[ent] = data
    end
    
    self.j_par:SetPos(self.j_pos)
    if self.j_ang_enable then
        self.j_par:SetAngles(self.j_ang)
    end
    
    for k,v in pairs(self.j_data) do
        for id,data in pairs(v.phys) do
            local physobj = v.ent:GetPhysicsObjectNum(id)
            physobj:SetPos(self.j_par:LocalToWorld(data.pos))
            if !self.j_ang_enable then continue end
            physobj:SetAngles(self.j_par:LocalToWorldAngles(data.ang))
        end
    end
    
    self:SoundPlay(1)
    
    local entdata = self:GetEntTable()
    self.j_spool = 0
    entdata.data.spool = self.j_spool
    entdata.update = {}
    WireLib.TriggerOutput(self, "Spooled", self.j_spool)
end

function ENT:TriggerInput(iname, value)
    if iname == "Activate" then
        if value != 0 then
            self:TurnOn()
        else
            self:TurnOff()
        end
    elseif iname == "Jump" then
        self:Jump()
    elseif iname == "X" then
        local pos = Vector(value, self.j_pos.y, self.j_pos.z)
        if !util.IsInWorld(pos) then return end
        self.j_pos = pos
    elseif iname == "Y" then
        local pos = Vector(self.j_pos.x, value, self.j_pos.z)
        if !util.IsInWorld(pos) then return end
        self.j_pos = pos
    elseif iname == "Z" then
        local pos = Vector(self.j_pos.x, self.j_pos.y, value)
        if !util.IsInWorld(pos) then return end
        self.j_pos = pos
    elseif iname == "Pos" then
        if !util.IsInWorld(value) then return end
        self.j_pos = value
    elseif iname == "Use Angle" then
        if value != 0 then
            self.j_ang_enable = true
        else
            self.j_ang_enable = false
        end
    elseif iname == "Pitch" then
        self.j_ang.p = value
    elseif iname == "Yaw" then
        self.j_ang.y = value
    elseif iname == "Roll" then
        self.j_ang.r = value
    elseif iname == "Ang" then
        self.j_ang = value
    end
    
    WireLib.TriggerOutput(self, "Jump Pos", self.j_pos)
    WireLib.TriggerOutput(self, "Jump Ang", self.j_ang)
end

function ENT:TurnOn()
    if self:GetActive() || !self:IsLinked() then return end
    self:SetActive(true)
end

function ENT:TurnOff()
    if !self:GetActive() then return end
    self:SetActive(false)
end

function ENT:DoThink(eff)
    if !self:GetActive() then return end

    self.Ents = self:GetConstrainedEntities()
    self.data.power = math.floor(table.Count(self.Ents) * -5)
    if !self:Work() then return end
    local pos, ang = self:GetPos(), self:GetAngles()
    if (pos - self.j_pos):LengthSqr() < 100 then return end
    local entdata = self:GetEntTable()
    
    local ln2 = self:ConsumeResource("liquid_nitrogen", 5)
    self.j_spool = math.min(self.j_spool + 3.4 + (3.4 * (ln2 / 5)) * eff, 100)
    
    if (pos - self.j_lpos):LengthSqr() > 100 then
        self.j_spool = 0
    end
    
    if self.j_spool != entdata.data.spool then
        entdata.data.spool = self.j_spool
        entdata.update = {}
        WireLib.TriggerOutput(self, "Spooled", self.j_spool)
    end
    self.j_lpos = pos
end

function ENT:NewNetwork(netid)
    if netid == 0 then
        self:TurnOff()
    end
end

function ENT:UpdateValues()

end