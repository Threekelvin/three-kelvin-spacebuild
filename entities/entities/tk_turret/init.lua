AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()

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

function ENT:Update(ply)
    local data = TK.TD:GetItem(self.itemid).data

end