AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetMass(50000)
        phys:EnableMotion(true)
        phys:Wake()
    end
    
    
    timer.Simple(math.random(90, 150), function()
        SafeRemoveEntity(self)
    end)
end