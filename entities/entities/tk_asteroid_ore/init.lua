AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetMass(math.huge)
        phys:EnableMotion(true)
        phys:Wake()
    end

    timer.Simple(math.random(90, 150), function()
        SafeRemoveEntity(self)
    end)
end

function ENT:Think()
    if self:GetCollisionGroup() == 0 then return end
    local phys = self:GetPhysicsObject()
    if not phys:IsPenetrating() then
        self:SetCollisionGroup(COLLISION_GROUP_NONE)
    end
end

function ENT:OnAtmosphereChange(old_env, new_env)
    if new_env:IsSpace() or new_Env:IsShip() then return end
    SafeRemoveEntity(self)
end
