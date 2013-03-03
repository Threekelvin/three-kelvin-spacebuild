AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self:SetModel("models/techbot/turret/flak/flak_turret.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:ResetSequence(0)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end

function ENT:Think()
    local owner = self:CPPIGetOwner()
    if !owner then return end
    local pos = self:WorldToLocal(owner:LocalToWorld(owner:OBBCenter()))

    local bearing = math.Rad2Deg(-math.atan2(pos.y, pos.x)) + 90
    bearing = bearing > 180 && bearing - 360 || bearing < -180 && bearing + 360 || bearing

    local elevation = math.Rad2Deg(math.asin(pos.z / pos:Length()))
    
    self:SetPoseParameter("aim_yaw", bearing)
    self:SetPoseParameter("aim_pitch", elevation)
    
    self:NextThink(CurTime())
    return true
end