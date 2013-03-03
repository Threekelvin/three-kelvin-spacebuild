
DEFINE_BASECLASS("base_anim")
ENT.SLIsGhost = true

local IsValid = IsValid
local pairs = pairs
local table = table

function ENT:Initialize()
    if !IsValid(self.parent) then self:Remove() return end
    local min, max = self.parent:GetCollisionBounds()
    
    self:SetSolid(SOLID_NONE)
    self:SetMoveType(MOVETYPE_NONE)
    
    self:SetModel(self.parent:GetModel())
    self:PhysicsInit(SOLID_OBB)
    self:SetPos(self.parent:GetPos())
    self:SetAngles(self.parent:GetAngles())
    self:SetParent(self.parent)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Wake()
    end

    self:SetTrigger(true)
    self:SetNotSolid(true)
    self:DrawShadow(false)
    self:SetCollisionBounds(min, max)
    
    self.inside = {}
end

local function EnvPrioritySort(a, b)
    if a.atmosphere.priority == b.atmosphere.priority then
        return a.atmosphere.radius < b.atmosphere.radius
    end
    return a.atmosphere.priority < b.atmosphere.priority
end

function ENT:StartTouch(ent)
    if !IsValid(self.env) || !ent.tk_env then return end
    if IsValid(ent.tk_env.core) then return end
    
    self.inside[ent:EntIndex()] = ent
    
    local oldenv = ent:GetEnv()
    table.insert(ent.tk_env.envlist, self.env)
    table.sort(ent.tk_env.envlist, EnvPrioritySort)
    local newenv = ent:GetEnv()
    
    if oldenv != newenv then
        newenv:DoGravity(ent)
        gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
    end
end

function ENT:EndTouch(ent)
    local entid = ent:EntIndex()
    
    if self.inside[entid] && IsValid(self.env) then
        local oldenv = ent:GetEnv()
        for k,v in pairs(ent.tk_env.envlist) do
            if v == self.env then
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
    
    self.inside[entid] = nil
end

function ENT:OnRemove()
    if !IsValid(self.env) then return end
    
    for idx,ent in pairs(self.inside) do
        if !IsValid(ent) then continue end
        
        local oldenv = ent:GetEnv()
        for k,v in pairs(ent.tk_env.envlist) do
            if v == self.env then
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

function ENT:UpdateTransmitState()
    return TRANSMIT_NEVER
end