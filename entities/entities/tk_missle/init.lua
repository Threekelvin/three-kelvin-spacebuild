AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')
ENT.SLIsGhost = true

function ENT:Initialize()
    self.Entity:PhysicsInit(SOLID_OBB)     
    self.Entity:SetMoveType(MOVETYPE_NONE)
    self.Entity:SetSolid(SOLID_NONE)
    self:SetTrigger(true)
    self:SetNotSolid(true)
    self:DrawShadow(false)
    
    self.tick = 1 / 66.67
    self.pos = self:GetPos()
    self.vel = self:GetUp() * self.Bullet.Speed * self.tick
    self.life = false
    if self.Bullet.Lifetime then
        self.life = SysTime() + self.Bullet.Lifetime
    end
    
    if self.Bullet.Material then
        self:SetMaterial(self.Bullet.Material)
    end
    
    if self.Bullet.Color then
        self:SetColor(self.Bullet.Color)
    end
    
    if self.Bullet.Trail then
        local trail = self.Bullet.Trail
        util.SpriteTrail(self, 0, trail.Color, false, trail.StartSize, trail.EndSize, trail.Length, 1 / (trail.StartSize + trail.EndSize) * 0.5, trail.Texture)
    end
end

function ENT:Detonate()
    if self.Bullet.Detonate then
        self.Bullet.Detonate(self)
        return
    end

    if self.Bullet.HitEffect then
        local fxd = EffectData()
        fxd:SetEntity(self)
        fxd:SetOrigin(self.pos)
        fxd:SetAngles(self:GetUp():Angle())
        util.Effect(self.Bullet.HitEffect, fxd)
    end
    
    if self.Bullet.HitSound then
        sound.Play(self.Bullet.HitSound, self.pos)
    end
    
    TK.DC:DoBlastDamage(self.pos, self.Bullet.DmgRadius, self.Bullet.DmgValue, self.Bullet.DmgType)
    SafeRemoveEntity(self)
end

function ENT:StartTouch(ent)
    self:Detonate()
end

function ENT:Think()
    if self.life then
        if SysTime() > self.life then 
            self:Detonate()
            return
        end
    end
    
    if self.tk_env then
        self.vel = self.vel - Vector(0, 0, 600 * self.tk_env.gravity * self.tick)
    end
    
    local td = {}
    td.start = self.pos

    self.pos = self.pos + self.vel
    if !util.IsInWorld(self.pos) then 
        self.pos = td.start
        self:Detonate()
        return
    end
    self:SetPos(self.pos)
    self:SetAngles(self.vel:Angle() + Angle(0,0,90))
    
    td.endpos = self.pos
    td.filter = {self, self.Bullet.Cannon}
    
    local trace = util.TraceLine(td)
    if trace.hit then
        self.pos = trace.HitPos
        self:Detonate()
        return
    end
    
    self:NextThink(0)
    return true
end
