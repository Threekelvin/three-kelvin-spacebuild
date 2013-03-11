AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.t_pos = Vector(0,0,0)
    self.t_ent = NULL
    self.t_mode = 0
    self.t_auto = false

    WireLib.CreateInputs(self, {"Activate", "X", "Y", "Z", "Pos [VECTOR]", "Target [ENTITY]", "Fire", "Auto"})
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
    local aim_vec
    if self.t_auto then
    
    elseif self.t_mode == 1 then 
        if !IsValid(self.t_ent) then
            aim_vec = Vector(0,0,0)
        else
            aim_vec = self.t_ent:LocalToWorld(self.t_ent:OBBCenter())
        end
    elseif self.t_mode == 0 then
        aim_vec = self.t_pos
    end
    

    local bearing = math.Rad2Deg(-math.atan2(aim_vec.y, aim_vec.x)) + 90
    bearing = bearing > 180 && bearing - 360 || bearing < -180 && bearing + 360 || bearing

    local elevation = math.Rad2Deg(math.asin(aim_vec.z / aim_vec:Length()))
    
    self:SetPoseParameter("aim_yaw", bearing)
    self:SetPoseParameter("aim_pitch", elevation)
    
    self:NextThink(CurTime())
    return true
end

function ENT:CanFire()
    return self:GetEnv():CanCombat()
end

function ENT:GetBarrel()

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