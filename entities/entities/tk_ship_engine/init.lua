AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local math = math
local WorldToLocal = WorldToLocal
local LocalToWorld = LocalToWorld

local KeyTracker = {

}

local Inputs = {
    [IN_RELOAD]    = "Level",
    [IN_FORWARD]   = "Forward",
    [IN_BACK]      = "Backward",
    [IN_MOVELEFT]  = "Left",
    [IN_MOVERIGHT] = "Right",
    [IN_JUMP]      = "Up",
    [IN_SPEED]     = "Down",
    [IN_WALK]      = "Mode",
}

local function math_angnorm(ang)
    return Angle(
        math.NormalizeAngle(ang.p),
        math.NormalizeAngle(ang.y),
        math.NormalizeAngle(ang.r)
    )
end

local function math_physvec(vec)
    return Vector(
        vec.x > -math.huge and (vec.x < math.huge and vec.x or 0) or 0,
        vec.y > -math.huge and (vec.y < math.huge and vec.y or 0) or 0,
        vec.z > -math.huge and (vec.z < math.huge and vec.z or 0) or 0
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
    if l2 == 0 or m2 == 0 then return Vector(0, 0, 0) end
    local s = 2 * math.acos(math.Clamp(q[1] / math.sqrt(l2), -1, 1)) * rad2deg
    if s > 180 then s = s - 360 end
    s = s / math.sqrt(m2)
    
    return Vector(q[2] * s, q[3] * s, q[4] * s)
end

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self.data = {kilowatt = 0}
    self.Eff = 0
    self.Aim = 0
    self.VecInput = Vector(0, 0, 0)
    self.AngInput = Angle(0, 0, 0)
    self.AimAngle = Angle(0, 0, 0)
    self.VecThrust = Vector(0, 0, 0)
    self.AngThrust = Angle(0, 0, 0)
    self.ShouldLevel = false
    self.Ents = {}
    self.Pod = nil
    
    self.Updated = false
    self.VecThrustMul = 0
    self.AngThrustMul = 0
    
    self:SetNWBool("Generator", true)
end

function ENT:math_angaim(tar, cur)
    local dif = tar - cur
    return Angle(
        dif.p > self.AngThrustMul and self.AngThrustMul or dif.p < -self.AngThrustMul and -self.AngThrustMul or dif.p,
        dif.y > self.AngThrustMul and self.AngThrustMul or dif.y < -self.AngThrustMul and -self.AngThrustMul or dif.y,
        0
    )
end

function ENT:OnRemove()
    self.BaseClass.OnRemove(self)
    
    for k,v in pairs(self.Ents) do
        if !IsValid(v) then continue end
        self:ResetGravity(v)
    end
end

function ENT:TriggerKey(iname, value)
    if iname == "Level" then
        if value != 1 then return end
        self.ShouldLevel = !self.ShouldLevel
    elseif iname == "Forward" then
        self.VecInput.x = self.VecInput.x + (value == 1 and 1 or -1)
    elseif iname == "Backward" then
        self.VecInput.x = self.VecInput.x + (value == 1 and -1 or 1)
    elseif iname == "Left" then
        if self.Aim == 1 then
            self.AngInput.r = self.AngInput.r + (value == 1 and -1 or 1)
        else
            self.AngInput.y = self.AngInput.y + (value == 1 and 1 or -1)
        end
    elseif iname == "Right" then
        if self.Aim == 1 then
            self.AngInput.r = self.AngInput.r + (value == 1 and 1 or -1)
        else
            self.AngInput.y = self.AngInput.y + (value == 1 and -1 or 1)
        end
    elseif iname == "Up" then
        self.VecInput.z = self.VecInput.z + (value == 1 and 1 or -1)
    elseif iname == "Down" then
        self.VecInput.z = self.VecInput.z + (value == 1 and -1 or 1)
    elseif iname == "Mode" then
        if value != 1 then return end
        self.Aim = self.Aim == 0 and 1 or 0
        self.AimAngle = Angle(0,0,0)
    end
end

function ENT:IsLargeHull(ent)
    if ent:BoundingRadius() < 135 then return false end
    if ent.IsTKRD and !ent:IsVehicle() then return false end
    return true
end

function ENT:DisableGravity(ent)
    if !ent.tk_env then return end
    local phys = ent:GetPhysicsObject()
    if !IsValid(phys) then return end
    
    ent.tk_env.nogravity = true
    phys:EnableGravity(false)
    phys:EnableDrag(false)
    
    phys:EnableMotion(true)
    phys:Wake()
end

function ENT:ResetGravity(ent)
    if !ent.tk_env then return end
    local phys = ent:GetPhysicsObject()
    if !IsValid(phys) then return end
    
    ent.tk_env.nogravity = nil
    ent.tk_env.gravity = -1
    local env = ent:GetEnv()
    env:DoGravity(ent)
    
    phys:EnableMotion(false)
    phys:Wake()
end

function ENT:TurnOn()
    if self:GetActive() or !self:IsLinked() then return end
    self:SetActive(true)
    
    self.Updated = false
    self.VecInput = Vector(0, 0, 0)
    self.AngInput = Angle(0, 0, 0)
    self.AimAngle = Angle(0, 0, 0)
    
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
        if conents[k] then continue end
        if !IsValid(v) then continue end
        self:ResetGravity(v)
    end

    self.Ents = conents
    local vol = 0
    for _,ent in pairs(self.Ents) do
        local phys = ent:GetPhysicsObject()
        if not IsValid(phys) then continue end
        if not self:IsLargeHull(ent) then continue end
        vol = vol + phys:GetVolume()
    end
    
    vol = math.sqrt(vol)
    self.data.kilowatt = -math.ceil((vol / 2000) ^ 5)
    self.Updated = true
    self.VecThrustMul = 10 * math.Clamp(6000 / vol, 0.1, 1)
    self.AngThrustMul = self.VecThrustMul
    if !self:Work() then return end
end

function ENT:Think()
    local driver
    if self:GetActive() then
        if !IsValid(self.Pod) then self:TurnOff() return end
        driver = self.Pod:GetDriver()
        if !IsValid(driver) then self:TurnOff() return end
    else
        if !IsValid(self.Pod) then return end
        driver = self.Pod:GetDriver()
        if !IsValid(driver) then return end
        self:TurnOn()
    end
    
    if !self.Updated then return end
    local parent = IsValid(self:GetParent()) and self:GetParent() or self
    local pphys = parent:GetPhysicsObject()
    if !IsValid(pphys) then return end
    local pos, ang = pphys:GetPos(), math_angnorm(pphys:GetAngles())

    if self.Aim == 1 then
        local s_ang, d_ang = driver:GetAngles(), driver:EyeAngles()
        local ang_diff = d_ang - s_ang
        self.AimAngle.p = (ang_diff.p > 5 or ang_diff.p < -5) and d_ang.p or ang.p
        self.AimAngle.y = (ang_diff.y > 5 or ang_diff.y < -5) and d_ang.y or ang.y
        self.AimAngle.r = (ang_diff.r > 5 or ang_diff.r < -5) and d_ang.r or ang.r
    end

    
    local vec_fac, aim_fac = 0.015, 0.025
    if self.VecInput.x == 0 then
        self.VecThrust.x = self.VecThrust.x + (self.VecThrust.x > vec_fac and -vec_fac or (self.VecThrust.x < -vec_fac and vec_fac or -self.VecThrust.x))
    else
        self.VecThrust.x = math.Clamp(self.VecThrust.x + self.VecInput.x * vec_fac, -1 , 1)
    end
    
    if self.VecInput.y == 0 then
        self.VecThrust.y = self.VecThrust.y + (self.VecThrust.y > vec_fac and -vec_fac or (self.VecThrust.y < -vec_fac and vec_fac or -self.VecThrust.y))
    else
        self.VecThrust.y = math.Clamp(self.VecThrust.y + self.VecInput.y * vec_fac, -1 , 1)
    end
    
    if self.VecInput.z == 0 then
        self.VecThrust.z = self.VecThrust.z + (self.VecThrust.z > vec_fac and -vec_fac or (self.VecThrust.z < -vec_fac and vec_fac or -self.VecThrust.z))
    else
        self.VecThrust.z = math.Clamp(self.VecThrust.z + self.VecInput.z * vec_fac, -1 , 1)
    end
    
    
    local Ang_Aim = Angle(0,0,0)
    if self.Aim == 1 then
        Ang_Aim = self:math_angaim(self.AimAngle, ang)
        Ang_Aim.p = (Ang_Aim.p / self.AngThrustMul) * 0.5
        Ang_Aim.y = (Ang_Aim.y / self.AngThrustMul) * 0.5
        Ang_Aim.r = (Ang_Aim.r / self.AngThrustMul) * 0.5
    end
    

    local Ang_In = self.AngInput + Ang_Aim
    Ang_In.p = Ang_In.p * self.Eff
    Ang_In.y = Ang_In.y * self.Eff
    Ang_In.r = Ang_In.r * self.Eff
    
    if Ang_In.p == 0 then
        self.AngThrust.p = self.AngThrust.p + (self.AngThrust.p > aim_fac and -aim_fac or (self.AngThrust.p < -aim_fac and aim_fac or -self.AngThrust.p))
    else
        self.AngThrust.p = math.Clamp(self.AngThrust.p + Ang_In.p * aim_fac, -1 , 1)
    end
    
    if Ang_In.y == 0 then
        self.AngThrust.y = self.AngThrust.y + (self.AngThrust.y > aim_fac and -aim_fac or (self.AngThrust.y < -aim_fac and aim_fac or -self.AngThrust.y))
    else
        self.AngThrust.y = math.Clamp(self.AngThrust.y + Ang_In.y * aim_fac, -1 , 1)
    end
    
    if Ang_In.r == 0 then
        self.AngThrust.r = self.AngThrust.r + (self.AngThrust.r > aim_fac and -aim_fac or (self.AngThrust.r < -aim_fac and aim_fac or -self.AngThrust.r))
    else
        self.AngThrust.r = math.Clamp(self.AngThrust.r + Ang_In.r * aim_fac, -1 , 1)
    end
    

    local lvec,lang = LocalToWorld(self.VecThrust * self.VecThrustMul, Angle(0,0,0), pos, ang)
    local Thrust = (lvec - pos) * (100 * self.Eff)
    
    for _,ent in pairs(self.Ents) do
        if !IsValid(ent) then continue end
        local phys = ent:GetPhysicsObject()
        if !IsValid(phys) then continue end
        phys:SetVelocity(Thrust)
        phys:AddAngleVelocity(phys:GetAngleVelocity() * -1)
    end
    
    local lvec,lang = LocalToWorld(Vector(0,0,0), self.AngThrust * self.AngThrustMul, pos, ang)
    local tang = self.ShouldLevel and Angle(Lerp(1 / self.AngThrustMul, land.p, Lerp(1 / self.AngThrustMul, land.r, 0)), lang.y, 0) or lang
    local Torque = math_rotationvector(tang, ang)
    
    Torque = (1000 * Torque - pphys:GetAngleVelocity() * 20) * pphys:GetInertia()
    local magnitude = Torque:Length()
    
    local off
    if math.abs(Torque.x) > magnitude * 0.1 or math.abs(Torque.z) > magnitude * 0.1 then
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

function ENT:PreEntityCopy()
    if !IsValid(self.Pod) then return end
    local info = {pod = self.Pod:EntIndex()}
    duplicator.StoreEntityModifier(self, self:GetClass(), info)
end

function ENT:PostEntityPaste(ply, ent, entlist)
    if !self.EntityMods or !self.EntityMods[self:GetClass()] then return end
    local info = self.EntityMods[self:GetClass()]
    self.Pod = entlist[info.pod]
    if IsValid(self.Pod) then
        self.Pod.Engine = self
    end
    self.EntityMods[self:GetClass()] = nil
end

hook.Add("KeyPress", "tk_ship_engine_keypress", function(ply, key)
    local pod = ply:GetVehicle()
    if !IsValid(pod) or !IsValid(pod.Engine) then return end
    if !IsValid(pod.Engine.Pod) or pod.Engine.Pod != pod then return end
    KeyTracker[ply] = KeyTracker[ply] or {}
    KeyTracker[ply][key] = pod.Engine, key
    
    pod.Engine:TriggerKey(Inputs[key], 1)
end)

hook.Add("KeyRelease", "tk_ship_engine_keyrelease", function(ply, key)
    if !KeyTracker[ply] then return end
    if !IsValid(KeyTracker[ply][key]) then return end
    KeyTracker[ply][key]:TriggerKey(Inputs[key], 0)
    KeyTracker[ply][key] = nil
end)