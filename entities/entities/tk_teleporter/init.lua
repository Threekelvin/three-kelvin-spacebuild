AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Tiberium/large_trip.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end
	
	self:SetNWString("Name", "Space")
end

function ENT:Use(act, call)
	umsg.Start("3k_teleporter_open", act)
		umsg.Entity(self)
	umsg.End()
end

function ENT:Think()
    if self:GetNWString("Name", "Space") == "Space" then
        local env = TK.AT:GetAtmosphereOnPos(self:GetPos())
        self:SetNWString("Name", env.atmosphere.name)
    end
    
    self:NextThink(CurTime() + 10)
    return true
end

function ENT:UpdateTransmitState() 
	return TRANSMIT_ALWAYS 
end

concommand.Add("3k_teleporter_send", function(ply, cmd, args)
	local ent = Entity(tonumber(args[1]))
	if !IsValid(ply) || !IsValid(ent) || ent:GetClass() != "tk_teleporter" then return end
    
    local pos = ent:GetPos()
    local grid = 5
    
    for X = 1, grid do
        for Y = 1, grid do
            local x_pos = (-16 * grid) + 32 * (X - 1)
            local y_pos = (-16 * grid) + 32 * (Y - 1)
        
            local td = {}
            td.start = pos + Vector(x_pos, y_pos, 36)
            td.endpos = pos + Vector(x_pos, y_pos, -36)
            td.mins = ply:OBBMins()
            td.maxs = ply:OBBMaxs()
            
            local trace_down = util.TraceHull(td)
            td.start = pos + Vector(x_pos, y_pos, 36)
            td.endpos = pos + Vector(x_pos, y_pos, 108)
            local trace_up = util.TraceHull(td)
            
            if trace_down.Fraction + trace_up.Fraction >= 0.5 then
                ply:SetPos(trace_down.HitPos)
                return
            end
        end
    end
    
    ply:SetMoveType(MOVETYPE_NOCLIP)
    ply:SetPos(pos)
end)