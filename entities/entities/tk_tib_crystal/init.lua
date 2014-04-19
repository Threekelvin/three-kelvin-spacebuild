AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:GetField()
    return {}
end

function ENT:Initialize()
    self.Stage = 1
    self:SendStage()
    
    self:SetModel(TK.TI.Settings[self.Stage].model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMaterial("models/tiberium_g")

    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Wake()
        self.MaxTib = math.Round((phys:GetVolume() / 50) * math.Rand(0.75, 1.25))
        self.Tib = self.MaxTib
    else
        self.MaxTib = 0
        self.Tib = 0
    end
    
    self.delay = 0
    self.CurTib = 0
    self.isStable = true
    self.isCritical = 6
    self:SetStable(true)
end

function ENT:GetStage()
    return self.Stage
end

function ENT:SetStable(val)
    self.isStable = val
    self:SendStatus()
end

function ENT:CanAdvance()
    local next_stage = self:GetStage() + 1
    local data = TK.TI.Settings[next_stage]
    if !data then return false end
    if self.delay < data.delay then return false end
    
    local num = 0
    for k,v in pairs(self:GetField()) do
        if v:GetStage() != next_stage then continue end
        num = num + 1
    end
    
    if num >= data.limit then return false end
    return true
end

function ENT:NextStage()
    local next_stage = self:GetStage() + 1
    local data = TK.TI.Settings[next_stage]
    if !data then return end
    
    self.Stage = next_stage
    self:SetModel(data.model)
    self:PhysicsInit(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Wake()
        self.MaxTib = self.MaxTib + math.Round((phys:GetVolume() / 50) * math.Rand(0.75, 1.25))
    end
    
    self.Tib = self.MaxTib
    self.delay = 0
    
    self:SendStage()
end

function ENT:StartTouch(ent)
    if !IsValid(ent) then return end
    TK.TI:Infect(ent)
end

function ENT:OnRemove()
    local fxdata = EffectData()
    fxdata:SetOrigin(self:GetPos())
    util.Effect("tib_die", fxdata, true)
end

function ENT:Explode()
    local radius = self:BoundingRadius()
    TK.TI:InfectBlast(self, 100 + (radius * 2))
    
    local fxdata = EffectData()
    fxdata:SetOrigin(self:GetPos())
    fxdata:SetScale(self:GetStage() / 2)
    util.Effect("tib_explode", fxdata, true)
    self:Remove()
    
    radius = radius / 2
    for i = 1, 4 do
        ParticleEffect("electrical_arc_01_system", fxdata:GetOrigin() + Vector(math.random(-radius, radius), math.random(-radius, radius),math.random(25, radius)), Angle(0,0,0))
    end
end

function ENT:Think()
    if self.Tib <= 0 then
        self:Remove()
        return
    end
    
    local Changed = self.Tib - self.CurTib
    self.CurTib = self.Tib
    
    if self.isStable then
        if math.random(1, 250) == 25 then
            self:SetStable(false)
            timer.Simple(60, function()
                if !IsValid(self) then return end
                self:SetStable(true)
            end)
        end
    end
    
    if Changed == 0 then
        self.isCritical = 6
        if self.isStable then
            if math.random(1, 250) == 75 then
                if self:CanAdvance() then 
                    self:NextStage() 
                end
            end
            self.delay = math.min(self.delay + 1, 500)
        end
    elseif !self.isStable then
        self.isCritical = self.isCritical - 1
        if self.isCritical <= 0 then
            self:Explode()
        end
    end
    
    self:NextThink(CurTime() + 1)
    return true
end

///--- Tib Sync ---\\\
util.AddNetworkString("TKTib_S")
util.AddNetworkString("TKTib_M")

function ENT:SendStatus(ply)
    local data = {}
    data.stable = self.isStable

    net.Start("TKTib_S")
        net.WriteInt(self:EntIndex(), 16)
        net.WriteTable(data)
    net.Send(ply or player.GetAll())
end

function ENT:SendStage(ply)
    local data = {}
    data.stage = self.Stage
    data.pos = self:GetPos()
    
    net.Start("TKTib_M")
        net.WriteInt(self:EntIndex(), 16)
        net.WriteTable(data)
    net.Send(ply or player.GetAll())
end

hook.Add("PlayerInitialSpawn", "TKTib_SendStatus", function(ply)
    timer.Simple(5, function()
        if !IsValid(ply) then return end
        for _,ent in pairs(ents.FindByClass("tk_tib_crystal")) do
            ent:SendStatus(ply)
            ent:SendStage(ply)
        end
    end)
end)