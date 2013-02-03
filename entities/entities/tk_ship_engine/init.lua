AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local math = math
local WorldToLocal = WorldToLocal
local LocalToWorld = LocalToWorld
local LerpAngle = LerpAngle

local function math_angnorm(ang)
    return Angle(
        math.NormalizeAngle(ang.p),
        math.NormalizeAngle(ang.y),
        math.NormalizeAngle(ang.r)
    )
end
 
local function math_angclamp(ang, min, max)
    return Angle(
        math.Clamp(ang.p, min, max),
        math.Clamp(ang.y, min, max),
        math.Clamp(ang.r, min, max)
    )
end

local function math_vecclamp(vec, min, max)
    return Vector(
        math.Clamp(vec.x, min, max),
        math.Clamp(vec.y, min, max),
        math.Clamp(vec.z, min, max)
    )
end

local function math_physvec(vec)
    return Vector(
        vec.x > -math.huge && (vec.x < math.huge && vec.x || 0) || 0,
        vec.y > -math.huge && (vec.y < math.huge && vec.y || 0) || 0,
        vec.z > -math.huge && (vec.z < math.huge && vec.z || 0) || 0
    )
end

local function math_qmul(lhs, rhs)
    local lhs, rhs = lhs, rhs
	return {
		lhs[1] * rhs[1] - lhs[2] * rhs[2] - lhs[3] * rhs[3] - lhs[4] * rhs[4],
		lhs[1] * rhs[2] + lhs[2] * rhs[1] + lhs[3] * rhs[4] - lhs[4] * rhs[3],
		lhs[1] * rhs[3] + lhs[3] * rhs[1] + lhs[4] * rhs[2] - lhs[2] * rhs[4],
		lhs[1] * rhs[4] + lhs[4] * rhs[1] + lhs[2] * rhs[3] - lhs[3] * rhs[2]
	}
end

local function math_qdiv(lhs, rhs)
    local lhs, rhs = lhs, rhs
	local l = rhs[1] * rhs[1] + rhs[2] * rhs[2] + rhs[3] * rhs[3] + rhs[4] * rhs[4]
	return {
		( lhs[1] * rhs[1] + lhs[2] * rhs[2] + lhs[3] * rhs[3] + lhs[4] * rhs[4]) / l,
		(-lhs[1] * rhs[2] + lhs[2] * rhs[1] - lhs[3] * rhs[4] + lhs[4] * rhs[3]) / l,
		(-lhs[1] * rhs[3] + lhs[3] * rhs[1] - lhs[4] * rhs[2] + lhs[2] * rhs[4]) / l,
		(-lhs[1] * rhs[4] + lhs[4] * rhs[1] - lhs[2] * rhs[3] + lhs[3] * rhs[2]) / l
	}
end

local function math_rotationvector(tang, cang)
    local deg2rad = math.pi / 180 * 0.5
    local rad2deg = 180 / math.pi
    
    //-- Target --\\
    tang = tang * deg2rad

    local qr = {math.cos(tang.r), math.sin(tang.r), 0, 0}
    local qp = {math.cos(tang.p), 0, math.sin(tang.p), 0}
    local qy = {math.cos(tang.y), 0, 0, math.sin(tang.y)}
    local tar = math_qmul(qy, math_qmul(qp, qr))
    
    //-- Current --\\
    cang = cang * deg2rad
    
    local qr = {math.cos(cang.r), math.sin(cang.r), 0, 0}
    local qp = {math.cos(cang.p), 0, math.sin(cang.p), 0}
    local qy = {math.cos(cang.y), 0, 0, math.sin(cang.y)}
    local cur = math_qmul(qy, math_qmul(qp, qr))
    
    local q = math_qdiv(tar, cur)
    
    //-- Rotation Vec --\\
    local l2 = q[1]*q[1] + q[2]*q[2] + q[3]*q[3] + q[4]*q[4]
	local m2 = math.max(q[2]*q[2] + q[3]*q[3] + q[4]*q[4], 0)
	if l2 == 0 || m2 == 0 then return Vector(0, 0, 0) end
	local s = 2 * math.acos(math.Clamp(q[1] / math.sqrt(l2), -1, 1)) * rad2deg
	if s > 180 then s = s - 360 end
	s = s / math.sqrt(m2)
    
	return Vector(q[2] * s, q[3] * s, q[4] * s)
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
    self.data = {}
    self.Eff = 0
    self.Aim = false
    self.Thrust = Vector(0, 0, 0)
    self.AngThrust = Angle(0, 0, 0)
    self.AimAngle = Angle(0, 0, 0)
    self.AimVector = Vector(0 ,0, 0)
    self.ShouldLevel = false
    self.MaxThrust = 150
    self.Ents = {}
    
    self:SetNWBool("Generator", true)
    
    self.Inputs = WireLib.CreateInputs(self, 
    {"Activate", "Thrust [VECTOR]", "AngThrust [ANGLE]", "AimAngle [ANGLE]", "AimVector [VECTOR]", "Level"})
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	
    for k,v in pairs(self.Ents) do
        if !IsValid(v) then continue end
        self:ResetGravity(v)
    end
end

function ENT:TriggerInput(iname, value)
    if iname == "Activate" then
        if tobool(value) then
            self:TurnOn()
        else
            self:TurnOff()
        end
	elseif iname == "Thrust" then
        self.Thrust = math_vecclamp(value, -1, 1)
    elseif iname == "AngThrust" then
        self.AngThrust = math_angclamp(value, -1, 1)
        self.Aim = 0
    elseif iname == "AimAngle" then
        self.AimAngle = math_angnorm(value)
        self.Aim = 1
    elseif inmage == "AimVector" then
        self.AimVector = value
        self.Aim = 2
    elseif iname == "Level" then
        self.ShouldLevel = tobool(value)
    end
end

function ENT:DisableGravity(ent)
     local phys = ent:GetPhysicsObject()
    if !IsValid(phys) then return end
    
    ent.tk_env.nogravity = true
    phys:EnableGravity(false)
    phys:EnableDrag(false)
    
    phys:EnableMotion(true)
    phys:Wake()
    
    self.TotalMass = self.TotalMass + phys:GetMass()
end

function ENT:ResetGravity(ent)
    local phys = ent:GetPhysicsObject()
    if !IsValid(phys) then return end
    
    ent.tk_env.nogravity = nil
    ent.tk_env.gravity = -1
    local env = ent:GetEnv()
    env:DoGravity(ent)
    
    phys:EnableMotion(false)
    phys:Wake()
    
    self.TotalMass = self.TotalMass - phys:GetMass()
end

function ENT:TurnOn()
	if self:GetActive() || !self:IsLinked() then return end
    self:SetActive(true)
    
    self.TotalMass = 0
    self.Ents = self:GetConstrainedEntities()
    for k,v in pairs(self.Ents) do
       self:DisableGravity(v)
    end
end

function ENT:TurnOff()
	if !self:GetActive() then return end
	self:SetActive(false)
    
    for k,v in pairs(self.Ents) do
        if !IsValid(v) then continue end
        self:ResetGravity(v)
    end
end

function ENT:DoThink(eff)
	if !self:GetActive() then return end
    self.Eff = eff
    
    local conents = self:GetConstrainedEntities()
    for k,v in pairs(conents) do
        if self.Ents[k] then continue end
        self:DisableGravity(v)
    end
    
    for k,v in pairs(self.Ents) do
        if !IsValid(v) || conents[k] then continue end
        self:ResetGravity(v)
    end

    self.Ents = conents
	self.data.power = math.floor(table.Count(self.Ents) * -5 )
    if !self:Work() then return end
end

function ENT:Think()
    if !self:GetActive() then return end
    local parent = IsValid(self:GetParent()) && self:GetParent() || self
    local pphys = parent:GetPhysicsObject()
    if !IsValid(pphys) then return end
    
    local pos, ang = pphys:GetPos(), math_angnorm(pphys:GetAngles())
    local propcount = table.Count(self.Ents)
    
    local vec = Vector(self.Thrust.x, self.Thrust.y, self.Thrust.z)
    local lvec,lang = LocalToWorld(vec, Angle(0,0,0), pos, ang)
    local Thrust = (lvec - pos) * self.MaxThrust * self.Eff
    
    for _,ent in pairs(self.Ents) do
        if !IsValid(ent) then continue end
        local phys = ent:GetPhysicsObject()
        if !IsValid(phys) then continue end
        phys:SetVelocity(Thrust)
        phys:AddAngleVelocity(phys:GetAngleVelocity() * -1)
    end
    
    local Torque
    if self.Aim == 2 then
        local lvec,_ = LocalToWorld(self.AimVector, Angle(0,0,0), pos, ang)
        local lang = LerpAngle(0.01, ang, lvec:Angle())
        local tang = self.ShouldLevel && Angle(0, lang.y, 0) || lang
        Torque = math_rotationvector(tang, ang)
    elseif self.Aim == 1 then
        local lang = LerpAngle(0.01, ang, self.AimAngle)
        local tang = self.ShouldLevel && Angle(0, lang.y, 0) || lang
        Torque = math_rotationvector(tang, ang)
    else
        local lvec,lang = LocalToWorld(Vector(0,0,0), self.AngThrust, pos, ang)
        local tang = self.ShouldLevel && Angle(0, lang.y, 0) || lang
        Torque = math_rotationvector(tang, ang)
    end
    
    Torque = (1000 * Torque - pphys:GetAngleVelocity() * 20) * pphys:GetInertia()
    local magnitude = Torque:Length()
    
    local off
    if math.abs(Torque.x) > magnitude * 0.1 || math.abs(Torque.z) > magnitude * 0.1 then
        off = Vector(-Torque.z, 0, Torque.x)
    else
        off = Vector(-Torque.y, Torque.x, 0)
    end
    off = off:GetNormal() * magnitude * 0.5
    local dir = Torque:Cross(off):GetNormal()
    
    off = math_physvec(off)
    dir = math_physvec(dir)

    pphys:ApplyForceOffset(dir, off)
    pphys:ApplyForceOffset(dir * -1, off * -1)
    
    self:NextThink(CurTime())
    return true
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end