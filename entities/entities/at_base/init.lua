AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local CurTime = CurTime
local IsValid = IsValid
local pairs = pairs
local table = table
local math = math

local function Extract_Bit(bit, field)
    if not bit or not field then return false end
    local retval = 0
    if ((field <= 7) and (bit <= 4)) then
        if (field >= 4) then
            field = field - 4
            if (bit == 4) then return true end
        end
        if (field >= 2) then
            field = field - 2
            if (bit == 2) then return true end
        end
        if (field >= 1) then
            field = field - 1
            if (bit == 1) then return true end
        end
    end
    return false
end

local function EnvPrioritySort(a, b)
    if a.atmosphere.priority == b.atmosphere.priority then
        return a.atmosphere.radius < b.atmosphere.radius
    end
    return a.atmosphere.priority < b.atmosphere.priority
end

function ENT:Initialize()
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_NONE)
    
    self.atmosphere = {}
    self.atmosphere.name = "Base Atmosphere"
    self.atmosphere.sphere    = true
    self.atmosphere.noclip     = false
    self.atmosphere.combat     = true
    self.atmosphere.priority    = 5
    self.atmosphere.radius         = 0
    self.atmosphere.gravity     = 0
    self.atmosphere.windspeed     = 0
    self.atmosphere.tempcold    = 3
    self.atmosphere.temphot        = 3
    self.atmosphere.flags       = 0
    self.atmosphere.resources     = {}
    
    self.outside = {}
    self.inside = {}
end

function ENT:StartTouch(ent)
    if !ent.tk_env then return end
    if self.atmosphere.sphere then
        if (ent:GetPos() - self:GetPos()):LengthSqr() <= self:GetRadius2() then
            self.inside[ent:EntIndex()] = ent
            
            local oldenv = ent:GetEnv()
            table.insert(ent.tk_env.envlist, self)
            table.sort(ent.tk_env.envlist, EnvPrioritySort)
            local newenv = ent:GetEnv()
            
            if oldenv != newenv then
                newenv:DoGravity(ent)
                gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
            end
        else
            self.outside[ent:EntIndex()] = ent
        end
    else
        self.inside[ent:EntIndex()] = ent
        
        local oldenv = ent:GetEnv()
        table.insert(ent.tk_env.envlist, self.tk_env.ship)
        table.sort(ent.tk_env.envlist, EnvPrioritySort)
        local newenv = ent:GetEnv()
        
        if oldenv != newenv then
            newenv:DoGravity(ent)
            gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
        end
    end
end

function ENT:EndTouch(ent)
    if !ent.tk_env then return end
    local entid = ent:EntIndex()
    
    if self.inside[entid] == ent then
        local oldenv = ent:GetEnv()
        for k,v in pairs(ent.tk_env.envlist) do
            if v == self then
                table.remove(ent.tk_env.envlist, k)
                break
            end
        end
        local newenv = ent:GetEnv()
        
        if oldenv != newenv then
            newenv:DoGravity(ent)
            gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
        end
    end
    
    self.outside[entid] = nil
    self.inside[entid] = nil
end

function ENT:Think()
    if !self.atmosphere.sphere then return end
    
    for idx,ent in pairs(self.outside) do
        if IsValid(ent) then
            if (ent:GetPos() - self:GetPos()):LengthSqr() > self:GetRadius2() then continue end
            self.outside[idx] = nil
            self.inside[idx] = ent
            
            local oldenv = ent:GetEnv()
            table.insert(ent.tk_env.envlist, self)
            table.sort(ent.tk_env.envlist, EnvPrioritySort)
            local newenv = ent:GetEnv()
            
            if oldenv != newenv then
                newenv:DoGravity(ent)
                gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
            end
        else
            self.outside[idx] = nil
        end
    end
    
    for idx,ent in pairs(self.inside) do
        if IsValid(ent) then
            if (ent:GetPos() - self:GetPos()):LengthSqr() < self:GetRadius2() then continue end
            self.outside[idx] = ent
            self.inside[idx] = nil
            
            local oldenv = ent:GetEnv()
            for k,v in pairs(ent.tk_env.envlist) do
                if v == self then
                    table.remove(ent.tk_env.envlist, k)
                    break
                end
            end
            local newenv = ent:GetEnv()
            
            if oldenv != newenv then
                newenv:DoGravity(ent)
                gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
            end
        else
            self.inside[idx] = nil
        end
    end

    self:NextThink(CurTime() + 0.25)
    return true
end

function ENT:OnRemove()
    for idx,ent in pairs(self.inside) do
        if IsValid(ent) then
            local oldenv = ent:GetEnv()
            for k,v in pairs(ent.tk_env.envlist) do
                if v == self then
                    table.remove(ent.tk_env.envlist, k)
                    break
                end
            end
            local newenv = ent:GetEnv()
            
            if oldenv != newenv then
                newenv:DoGravity(ent)
                gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
            end
        end
    end
end

function ENT:PhysicsSetup()
    local radius = self.atmosphere.radius
    if radius <= 0 then return end
    local min, max = Vector(-radius,-radius,-radius), Vector(radius,radius,radius)
    
    if self.atmosphere.sphere then
        self:PhysicsInitSphere(radius)
    else
        self:PhysicsInitBox(min, max)
    end
    
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
    for k,v in pairs(data || {}) do
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
        return math.floor(((4/3) * math.pi * self.atmosphere.radius ^ 3) * 0.001)
    else
        return math.floor((self.atmosphere.radius ^ 3) * 0.001)
    end
end

function ENT:Sunburn()
    return Extract_Bit(2, self.atmosphere.flags)
end

function ENT:HasResource(res)
    return self.atmosphere.resources[res] && self.atmosphere.resources[res] > 0
end

function ENT:CanNoclip()
    return self.atmosphere.noclip
end

function ENT:CanCombat()
    return self.atmosphere.combat
end

function ENT:GetResourcePercent(res)
    return self.atmosphere.resources[res] || 0
end

function ENT:InAtmosphere(pos)
    if self.atmosphere.sphere then
        if (pos - self:GetPos()):LengthSqr() < self:GetRadius2() then
            return true
        end
    else
        local cen, rad = self:GetPos(), self:GetRadius()
        if pos.x < cen.x + rad && pos.x > cen.x - rad && pos.y < cen.y + rad && pos.y > cen.y - rad && pos.z < cen.z + rad && pos.z > cen.z - rad then
            return true
        end
    end
    return false
end

function ENT:DoGravity(ent)
    if !IsValid(ent) || !ent.tk_env || ent.tk_env.nogravity then return end
    local phys = ent:GetPhysicsObject()
    if !IsValid(phys) then return end

    local grav = self.atmosphere.gravity
    if !ent.tk_env.gravity == grav then return end
    
    local bool = grav > 0
    phys:EnableGravity(bool)
    phys:EnableDrag(bool)
    ent:SetGravity(grav + 0.001)
    ent.tk_env.gravity = grav
end

function ENT:InSun(ent)
    if !IsValid(ent) then return false end
    local pos = ent:LocalToWorld(ent:OBBCenter())
    
    for k,v in pairs(TK.AT:GetSuns()) do
        local trace = {}
        trace.start = pos - (pos - v):GetNormal() * 2048
        trace.endpos = pos
        trace.filter = {ent, ent:GetParent()}
        local tr = util.TraceLine(trace)
        if !tr.Hit then
            return true
        end
    end
    
    return false
end

function ENT:DoTemp(ent)
    if !IsValid(ent) then return 3, false end

    if self:InSun(ent) then
        return self.atmosphere.temphot, true
    end
    
    return self.atmosphere.tempcold, false
end