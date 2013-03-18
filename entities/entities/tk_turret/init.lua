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
    self.tick = 1 / 66.67
    self.dps = 30 * self.tick
    
    self.t_pos = Vector(0,0,0)
    self.t_ent = NULL
    self.t_mode = 0
    self.t_shouldfire = false
    self.t_predict = true
    
    self.t_lastfire = 0
    self.t_clip = 0
    
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
    
    WireLib.CreateInputs(self, {"Activate", "X", "Y", "Z", "Pos [VECTOR]", "Target [ENTITY]", "Predict", "Fire"})
    WireLib.CreateOutputs(self, {"Aim Vec [VECTOR]", "Can Fire"})
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
    elseif iname == "Predict" then
        self.t_predict = value != 0 && true || false
    elseif iname == "Fire" then
        if value != 0 then
            self:FireBullet()
        end
    end
end

function ENT:DoThink(eff)
    
end

function ENT:Think()
    if self.t_mode == 1 then 
        if !IsValid(self.t_ent) then
            self.aim_vec = Vector(0,0,0)
        else
            if self.t_predict then
                self.aim_vec = self:PredictEnt(self.t_ent)
            else
                self.aim_vec = self.t_ent:NearestPoint(self:GetPos())
            end
        end
    elseif self.t_mode == 0 then
        self.aim_vec = self.t_pos
    end
    
    local vec = self:WorldToLocal(self.aim_vec)
    local bearing = math.deg(-math.atan2(vec.y, vec.x)) + 90
    local elevation = math.deg(math.asin(vec.z / vec:Length()))

    self.bearing = math.ApproachAngle(self.bearing, bearing, self.dps)
    self.elevation = math.ApproachAngle(self.elevation, elevation, self.dps)
    
    local dif_b = math.abs((self.bearing % 360) - (bearing % 360))
    local dif_e = math.abs(self.elevation - elevation)
    self.t_shouldfire = dif_b < 1 && dif_e < 1
    
    self:SetPoseParameter("aim_yaw", (self.bearing + 180) % 360 - 180)
    self:SetPoseParameter("aim_pitch", self.elevation)
    
    WireLib.TriggerOutput(self, "Aim Vec", self.aim_vec)
    WireLib.TriggerOutput(self, "Can Fire", self:CanFire() && 1 || 0)
    
    self:NextThink(CurTime())
    return true
end

function ENT:PredictEnt(ent)
    local phys = ent:GetPhysicsObject()
    if !IsValid(phys) then return false end
    
    local vel = phys:GetVelocity()
    local pos = ent:NearestPoint(self:GetPos())
    local dis = self:GetPos():Distance(pos)
    return pos + vel * self.tick * dis / self.Bullet.Speed
end

function ENT:CanFire()
    if !self.t_shouldfire then return false end
    for _,ent in pairs(self.tk_env.envlist) do
        if !ent:CanCombat() then return false end
    end    
    return true
end

function ENT:GetBarrel()
    self.barrel_idx = self.barrel_idx + 1
    if self.barrel_idx > table.Count(self.barrels) then
        self.barrel_idx = 1
    end
    
    local barrel = self.barrels[self.barrel_idx]
    return self:GetAttachment(barrel)
end

function ENT:FireBullet()
    if !self:CanFire() then return end
    local angpos = self:GetBarrel()
    local fire_pos, fire_ang = angpos.Pos, angpos.Ang
    
    if self.Bullet.Type == "shell" then
        local ent = ents.Create("tk_shell")
        ent.Bullet = self.Bullet
        ent.Cannon = self
        ent:SetPos(fire_pos)
        ent:SetAngles(fire_ang)
        ent:Spawn()
    elseif self.Bullet.Type == "beam" then
        local td = {}
        td.start = fire_pos
        td.endpos = fire_pos + fire_ang:Forward() * self.Bullet.Range
        td.filter = self
        
        local trace = util.TraceLine(td)
        if trace.Hit then
            if self.Bullet.HitEffect then
                local fxd = EffectData()
                fxd:SetOrigin(trace.HitPos)
                fxd:SetAngles(trace.HitNormal:Angle())
                util.Effect(self.Bullet.HitEffect, fxd, true, true)
            end
        
            if self.Bullet.HitSound then
                sound.Play(self.Bullet.HitSound, trace.HitPos)
            end
        end
        
        if IsValid(trace.Entity) then
            TK.DC:DoDamage(trace.Entity, self.Bullet.DmgValue, self.Bullet.DmgType)
        end
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
        fxd:SetOrigin(fire_pos)
        fxd:SetAngles(fire_ang)
        util.Effect(self.Bullet.FireEffect, fxd, true, true)
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