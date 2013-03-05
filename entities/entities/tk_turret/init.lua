AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.t_pos = Vector(0,0,0)
    self.t_ent = NULL
    self.t_mode = 0
    self.t_auto = false

    WireLib.CreateInputs(self, {"Activate", "X", "Y", "Z", "Pos [VECTOR]", "Target [ENTITY]", "Fire", "Auto"})
    WireLib.CreateOutputs(self, {"Can Fire", "Ammo"})
end

function ENT:TriggerInput(iname, value)
    if iname == "Activate" then
        if value != 0 then
            self:TurnOn()
        else
            self:TurnOff()
        end
    elseif iname == "X" then
        self.t_pos.x = value
        self.t_mode = 0
    elseif iname == "Y" then
        self.t_pos.y = value
        self.t_mode = 0
    elseif iname == "Z" then
        self.t_pos.z = value
        self.t_mode = 0
    elseif iname == "Pos" then
        self.t_pos = value
        self.t_mode = 0
    elseif iname == "Target" then
        self.t_ent = value
        self.t_mode = 1
    elseif iname == "Fire" then
        self:Fire()
    elseif iname == "Auto" then
        if value != 0 then
            self.t_auto = true
        else
            self.t_auto = false
        end
    end
end

function ENT:DoThink(eff)

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

function ENT:Fire()

end

function ENT:Update(ply)
    local data = TK.TD:GetItem(self.itemid).data
    self.bullet = TK.DC:GetBullet(data.bullet)
    
    self.data.power = self.bullet.Power || 0
end