
local PLUGIN = {}
PLUGIN.Name       = "GoTo"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "GoTo"
PLUGIN.Auto       = {"player"}
PLUGIN.Level      = 2

if SERVER then
	function PLUGIN.Call(ply,arg)
		if ply:HasAccess(PLUGIN.Level) then
			local count, targets = TK.AM:FindPlayer(arg[1])
			
			if count == 0 then
				TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
			elseif count > 1 then
				TK.AM:SystemMessage({"Multiple Targets Found"}, {ply}, 2)
			else
				local tar = targets[1]
				if tar == ply then
					TK.AM:SystemMessage({"You Can Not Teleport To Yourself"}, {ply}, 2)
					return
				end
				for I=1, 8 do
					local RotVec = Vector(40, 0, 36)
					RotVec:Rotate(Angle(0, (360/8)*I, 0))
					local check1 = util.QuickTrace(tar:LocalToWorld(RotVec), Vector(0, 0, 113))
					local check2 = util.QuickTrace(tar:LocalToWorld(RotVec), Vector(0, 0, -113))
					if !check1.StartSolid && !check2.StartSolid then
						if check1.Hit && check2.Hit then
							if check1.HitPos:Distance(check2.HitPos) > 82 then
								ply:SetPos(check2.HitPos + Vector(0, 0, 5))
								TK.AM:SystemMessage({ply, " Has Teleported To ", tar})
								return
							end
						elseif check1.Hit then
							ply:SetPos(check1.HitPos - Vector(0, 0, 77))
							TK.AM:SystemMessage({ply, " Has Teleported To ", tar})
							return
						elseif check2.Hit then
							ply:SetPos(check2.HitPos + Vector(0, 0, 5))
							TK.AM:SystemMessage({ply, " Has Teleported To ", tar})
							return
						else
							ply:SetPos(tar:LocalToWorld(RotVec) - Vector(0, 0, 36))
							TK.AM:SystemMessage({ply, " Has Teleported To ", tar})
							return
						end
					end
				end
				ply:SetMoveType(MOVETYPE_NOCLIP)
				ply:SetPos(tar:LocalToWorld((Vector(-40,0,0))))
				TK.AM:SystemMessage({ply, " Has Teleported To ", tar})
			end
		else
			TK.AM:SystemMessage({"Access Denied"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)