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

function ENT:UpdateTransmitState() 
	return TRANSMIT_ALWAYS 
end

concommand.Add("3k_teleporter_send", function(ply, cmd, args)
	local ent = Entity(tonumber(args[1]))
	if IsValid(ent) && ent:GetClass() == "tk_teleporter" && IsValid(ply) then
		for I = 1, 8 do
			local RotVec = Vector(40, 0, 36)
			RotVec:Rotate(Angle(0, (360/8)*I, 0))
			local check1 = util.QuickTrace(ent:LocalToWorld(RotVec), Vector(0, 0, 113))
			local check2 = util.QuickTrace(ent:LocalToWorld(RotVec), Vector(0, 0, -113))
			if !check1.StartSolid && !check2.StartSolid then
				if check1.Hit && check2.Hit then
					if check1.HitPos:Distance(check2.HitPos) > 82 then
						ply:SetPos(check2.HitPos + Vector(0, 0, 5))
						return
					end
				elseif check1.Hit then
					ply:SetPos(check1.HitPos - Vector(0, 0, 77))
					return
				elseif check2.Hit then
					ply:SetPos(check2.HitPos + Vector(0, 0, 5))
					return
				else
					ply:SetMoveType(MOVETYPE_NOCLIP)
					ply:SetPos(ent:LocalToWorld(RotVec) - Vector(0, 0, 36))
					return
				end
			end
		end
	end
end)

hook.Add("OnAtmosphereChange", "TK_Tele_Name", function(ent, old, new)
	if ent:GetClass() == "tk_teleporter" then
		ent:SetNWString("Name", new.atmosphere.name)
	end
end)