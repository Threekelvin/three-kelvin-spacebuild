AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local math = math

local Barrle_Attachments = {
    "barrel_l",
    "barrel_r"
}

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    self.rps = 25 / 66.67
    
    self.t_pos = Vector(0,0,0)
    self.t_ent = NULL
    self.t_mode = 0
    self.t_auto = true
    self.t_shouldfire = false
    
    self.aim_vec = Vector(0,0,0)
    self.bearing = 0
    self.elevation = 0
    
    self.barrels = {}
    self.barrel_idx = 0
    
    for k,v in pairs(Barrle_Attachments) do
        local id = self:LookupAttachment(v)
        if id == 0 then continue end
        table.insert(self.barrels, id)
    end
    

    WireLib.CreateInputs(self, {"Activate", "X", "Y", "Z", "Pos [VECTOR]", "Target [ENTITY]", "Auto", "Fire"})
    WireLib.CreateOutputs(self, {"Can Fire", "Ammo"})
end

function ENT:TriggerInput(iname, value)
    if iname == "Activate" then
        if value != 0 then
            self:TurnOn()
        else
            self:TurnOff()
        end
    elseif iname == "X" then
        self.t_pos.x = value
        self.t_mode = 0
    elseif iname == "Y" then
        self.t_pos.y = value
        self.t_mode = 0
    elseif iname == "Z" then
        self.t_pos.z = value
        self.t_mode = 0
    elseif iname == "Pos" then
        self.t_pos = value
        self.t_mode = 0
    elseif iname == "Target" then
        self.t_ent = value
        self.t_mode = 1
    elseif iname == "Fire" then
        self:Fire()
    elseif iname == "Auto" then
        if value != 0 then
            self.t_auto = true
        else
            self.t_auto = false
        end
    end
end

function ENT:DoThink(eff)
    
end

function ENT:Think()
    if self.t_auto then
        self.aim_vec = self.Owner:LocalToWorld(self.Owner:OBBCenter())
    elseif self.t_mode == 1 then 
        if !IsValid(self.t_ent) then
            self.aim_vec = Vector(0,0,0)
        else
            self.aim_vec = self.t_ent:LocalToWorld(self.t_ent:OBBCenter())
        end
    elseif self.t_mode == 0 then
        self.aim_vec = self.t_pos
    end
    
    local vec = self:WorldToLocal(self.aim_vec)
    local bearing = math.deg(-math.atan2(vec.y, vec.x)) + 90
    local elevation = math.deg(math.asin(vec.z / vec:Length()))

    self.bearing = (math.ApproachAngle(self.bearing, bearing, self.rps) + 180) % 360 - 180
    self.elevation = math.ApproachAngle(self.elevation, elevation, self.rps * 0.5)
    
    print(self.bearing)

    self:SetPoseParameter("aim_yaw", self.bearing)
    self:SetPoseParameter("aim_pitch", self.elevation)
    
    self:NextThink(CurTime())
    return true
end

function ENT:CanFire()
    return self.t_shouldfire && self:GetEnv():CanCombat()
end

function ENT:GetBarrel()
    self.barrel_idx = self.barrel_idx + 1
    if self.barrel_idx > table.Count(self.barrels) then
        self.barrel_idx = 1
    end
    
    local barrel = self.barrels[barrel_idx]
    if !barrel then
        return self:GetPos() + self:GetUp() * self:OBBMaxs().z
    end
    
    return self:GetAttachment(barrel)
end

function ENT:Fire()
    if !self:CanFire() then return end
    local fire_pos = self:GetBarrel()
    local fire_ang = self.aim_vec:Angle() + Angle(90,0,0)
    
    if self.Bullet.Type == "shell" then
        local ent = ents.Create("tk_shell")
        ent.Bullet = self.Bullet
        ent.Cannon = self
        ent:SetPos(fire_pos)
        ent:SetAngles(fire_ang)
        ent:Spawn()
    elseif self.Bullet.Type == "beam" then
    
    elseif self.Bullet.Type == "missle" then
        local ent = ents.Create("tk_missle")
        ent.Bullet = self.Bullet
        ent.Cannon = self
        ent:SetPos(fire_pos)
        ent:SetAngles(fire_ang)
        ent:Spawn()
    end
    
    if self.Bullet.FireEffect then
        local fxd = EffectData()
        fxd:SetEntity(self)
        fxd:SetOrigin(fire_pos)
        fxd:SetAngles(fire_ang)
        util.Effect(self.Bullet.FireEffect, fxd)
    end
    
    if self.Bullet.FireSound then
        sound.Play(self.Bullet.FireSound, fire_pos)
    end
end

function ENT:Update(ply)
    local data = TK.TD:GetItem(self.itemid).data
    self.Bullet = TK.DC:GetBullet(data.bullet)
    
    self.data.power = self.Bullet.Power || 0
end