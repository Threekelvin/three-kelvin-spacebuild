DEFINE_BASECLASS("base_anim")
ENT.SLIsGhost = true
local IsValid = IsValid
local pairs = pairs
local table = table

function ENT:Initialize()
    if not IsValid(self.parent) then
        self:Remove()

        return
    end

    self:SetModel(self.parent:GetModel())
    self:SetMoveType(MOVETYPE_NONE)
    self:PhysicsInit(SOLID_OBB)
    self:SetSolid(SOLID_OBB)
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
    self:SetCollisionBounds(self.parent:GetCollisionBounds())
    self.inside = {}
end

local function EnvPrioritySort(a, b)
    if a.atmosphere.priority == b.atmosphere.priority then return a.atmosphere.radius < b.atmosphere.radius end

    return a.atmosphere.priority < b.atmosphere.priority
end

function ENT:StartTouch(ent)
    if not IsValid(self.env) or not ent.tk_env then return end
    if IsValid(ent.tk_env.core) then return end
    self.inside[ent:EntIndex()] = ent
    local old_env = ent:GetEnv()
    table.insert(ent.tk_env.envlist, self.env)
    table.sort(ent.tk_env.envlist, EnvPrioritySort)
    local new_env = ent:GetEnv()

    if old_env ~= new_env then
        new_env:DoGravity(ent)
        gamemode.Call("OnAtmosphereChange", ent, old_env, new_env)
    end
end

function ENT:EndTouch(ent)
    local entid = ent:EntIndex()

    if self.inside[entid] and IsValid(self.env) then
        local old_env = ent:GetEnv()

        for k, v in pairs(ent.tk_env.envlist) do
            if v == self.env then
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

    self.inside[entid] = nil
end

function ENT:OnRemove()
    if not IsValid(self.env) then return end

    for idx, ent in pairs(self.inside) do
        if not IsValid(ent) then continue end
        local old_env = ent:GetEnv()

        for k, v in pairs(ent.tk_env.envlist) do
            if v == self.env then
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
end

function ENT:UpdateTransmitState()
    return TRANSMIT_NEVER
end
