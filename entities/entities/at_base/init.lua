AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
local IsValid = IsValid
local pairs = pairs
local table = table

local function EnvPrioritySort(a, b)
    if a.atmosphere.priority == b.atmosphere.priority then return a.atmosphere.radius < b.atmosphere.radius end

    return a.atmosphere.priority < b.atmosphere.priority
end

function ENT:Initialize()
    self:SetMoveType(MOVETYPE_NONE)
    self.atmosphere = {}
    self.atmosphere.name = "Base Atmosphere"
    self.atmosphere.sphere = true
    self.atmosphere.noclip = false
    self.atmosphere.combat = true
    self.atmosphere.priority = 5
    self.atmosphere.radius = 0
    self.atmosphere.gravity = 0
    self.atmosphere.windspeed = 0
    self.atmosphere.tempcold = 3
    self.atmosphere.temphot = 3
    self.atmosphere.flags = 0
    self.atmosphere.resources = {}
    self.outside = {}
    self.inside = {}
end

function ENT:HasFlag(id)
    return bit.band(id, self.atmosphere.flags) == id
end

function ENT:MoveInside(ent)
    self.inside[ent] = ent
    self.outside[ent] = nil
    local old_env = ent:GetEnv()
    table.insert(ent.tk_env.envlist, self)
    table.sort(ent.tk_env.envlist, EnvPrioritySort)
    local new_env = ent:GetEnv()

    if old_env ~= new_env then
        new_env:DoGravity(ent)
        gamemode.Call("OnAtmosphereChange", ent, old_env, new_env)
    end
end

function ENT:MoveOutside(ent)
    self.outside[ent] = ent
    self.inside[ent] = nil
    local old_env = ent:GetEnv()

    for k, v in pairs(ent.tk_env.envlist) do
        if v == self then
            table.remove(ent.tk_env.envlist, k)
            break
        end
    end

    local new_env = ent:GetEnv()

    if old_env ~= new_env then
        new_env:DoGravity(ent)
        gamemode.Call("OnAtmosphereChange", ent, old_env, new_env)
    end
end

function ENT:StartTouch(ent)
    if not ent.tk_env then return end

    if self.atmosphere.sphere then
        if (ent:GetPos() - self:GetPos()):LengthSqr() <= self:GetRadius2() then
            self:MoveInside(ent)
        else
            self.outside[ent] = ent
        end
    else
        self:MoveInside(ent)
    end
end

function ENT:EndTouch(ent)
    if not ent.tk_env then return end

    if self.inside[ent] then
        self:MoveOutside(ent)
    end

    self.outside[ent] = nil
    self.inside[ent] = nil
end

function ENT:Think()
    if not self.atmosphere.sphere then return end

    for idx, ent in pairs(self.outside) do
        if IsValid(ent) then
            self:CheckEntity(ent)
        else
            self.outside[idx] = nil
        end
    end

    for idx, ent in pairs(self.inside) do
        if IsValid(ent) then
            self:CheckEntity(ent)
        else
            self.inside[idx] = nil
        end
    end

    self:NextThink(CurTime() + 0.1)

    return true
end

function ENT:CheckEntity(ent)
    if self.inside[ent] then
        if (ent:GetPos() - self:GetPos()):LengthSqr() < self:GetRadius2() then return end
        self:MoveOutside(ent)
    elseif self.outside[ent] then
        if (ent:GetPos() - self:GetPos()):LengthSqr() > self:GetRadius2() then return end
        self:MoveInside(ent)
    end
end

function ENT:OnRemove()
    for idx, ent in pairs(self.inside) do
        if not IsValid(ent) then continue end
        self:MoveOutside(ent)
    end
end

function ENT:PhysicsSetup()
    local radius = self.atmosphere.radius
    if radius <= 0 then return end
    local min, max = Vector(-radius, -radius, -radius), Vector(radius, radius, radius)

    if self.atmosphere.sphere then
        self:PhysicsInitSphere(radius)
    else
        self:PhysicsInitBox(min, max)
    end

    self:SetSolid(SOLID_OBB)
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Wake()
    end

    self:SetTrigger(true)
    self:SetNotSolid(true)
    self:DrawShadow(false)
    self:SetCollisionBounds(min, max)
end

function ENT:SetupAtomsphere(data)
    for k, v in pairs(data or {}) do
        local typ = type(self.atmosphere[k])

        if typ == "number" then
            self.atmosphere[k] = tonumber(v)
        elseif typ == "boolean" then
            self.atmosphere[k] = tobool(v)
        else
            self.atmosphere[k] = v
        end
    end

    self:PhysicsSetup()
end

function ENT:IsAtmosphere()
    return true
end

function ENT:IsStar()
    return false
end

function ENT:IsShip()
    return false
end

function ENT:IsPlanet()
    return false
end

function ENT:IsSpace()
    return false
end

function ENT:GetName()
    return self.atmosphere.name
end

function ENT:GetRadius()
    return self.atmosphere.radius
end

function ENT:GetRadius2()
    return self.atmosphere.radius * self.atmosphere.radius
end

function ENT:GetGravity()
    return self.atmosphere.gravity
end

function ENT:GetVolume()
    if self.atmosphere.sphere then
        return math.floor(((4 / 3) * math.pi * self.atmosphere.radius ^ 3) * 0.001)
    else
        return math.floor((self.atmosphere.radius ^ 3) * 0.001)
    end
end

function ENT:Sunburn()
    return self:HasFlag(ATMOSPHERE_SUNBURN)
end

function ENT:HasResource(res)
    return self.atmosphere.resources[res] and self.atmosphere.resources[res] > 0
end

function ENT:CanNoclip()
    return self.atmosphere.noclip
end

function ENT:CanCombat()
    return self.atmosphere.combat
end

function ENT:GetResourcePercent(res)
    return self.atmosphere.resources[res] or 0
end

function ENT:InAtmosphere(pos)
    if self.atmosphere.sphere then
        if (pos - self:GetPos()):LengthSqr() < self:GetRadius2() then return true end
    else
        local cen, rad = self:GetPos(), self:GetRadius()
        if pos.x < cen.x + rad and pos.x > cen.x - rad and pos.y < cen.y + rad and pos.y > cen.y - rad and pos.z < cen.z + rad and pos.z > cen.z - rad then return true end
    end

    return false
end

function ENT:DoGravity(ent)
    if not IsValid(ent) or not ent.tk_env or ent.tk_env.nogravity then return end
    local grav = self.atmosphere.gravity
    if ent.tk_env.gravity == grav then return end
    local bool = grav > 0.001

    for i = 0,  ent:GetPhysicsObjectCount() do
        local phys = ent:GetPhysicsObjectNum(i)
        if not IsValid(phys) then continue end
        phys:EnableGravity(bool)
        phys:EnableDrag(bool)
    end

    ent:SetGravity(grav + 0.001)
    ent.tk_env.gravity = grav
end

function ENT:InSun(ent)
    if not IsValid(ent) then return false end
    local pos = ent:LocalToWorld(ent:OBBCenter())

    for k, v in pairs(TK.AT:GetSuns()) do
        local trace = {}
        trace.start = pos - (pos - v):GetNormal() * 2048
        trace.endpos = pos
        trace.filter = {ent,  ent:GetParent()}
        local tr = util.TraceLine(trace)
        if not tr.Hit then return true end
    end

    return false
end

function ENT:DoTemp(ent)
    if not IsValid(ent) then return 3, false end
    if self:InSun(ent) then return self.atmosphere.temphot, true end

    return self.atmosphere.tempcold, false
end
