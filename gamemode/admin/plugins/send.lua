
local PLUGIN = {}
PLUGIN.Name       = "Send"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Send"
PLUGIN.Auto       = {"player", "player"}
PLUGIN.Level      = 4

if SERVER then
	function PLUGIN.Call(ply, arg)
		if ply:HasAccess(PLUGIN.Level) then
			local count1, target1 = TK.AM:FindPlayer(arg[1])
			local count2, target2 = TK.AM:FindPlayer(arg[2])
			
			if count1 == 0 || count2 == 0 then
				TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
			elseif count1 > 1 || count2 > 1 then
				TK.AM:SystemMessage({"Multiple Targets Found"}, {ply}, 2)
			else
				local tar1 = target1[1]
				local tar2 = target2[1]
				if ply:CanRunOn(tar1) then
					if tar1 == tar2 then
						TK.AM:SystemMessage({"You Can Not Teleport To The Same Target"}, {ply}, 2)
						return
					end
					
					for I=1, 8 do
						local RotVec = Vector(40, 0, 36)
						RotVec:Rotate(Angle(0, (360/8)*I, 0))
						local check1 = util.QuickTrace(tar2:LocalToWorld(RotVec), Vector(0, 0, 113))
						local check2 = util.QuickTrace(tar2:LocalToWorld(RotVec), Vector(0, 0, -113))
						if !check1.StartSolid && !check2.StartSolid then
							if check1.Hit && check2.Hit then
								if check1.HitPos:Distance(check2.HitPos) > 82 then
									tar1:SetPos(check2.HitPos + Vector(0, 0, 5))
									TK.AM:SystemMessage({ply, " Has Sent ", tar1, " To ", tar2})
									return
								end
							elseif check1.Hit then
								tar1:SetPos(check1.HitPos - Vector(0, 0, 77))
								TK.AM:SystemMessage({ply, " Has Sent ", tar1, " To ", tar2})
								return
							elseif check2.Hit then
								tar1:SetPos(check2.HitPos + Vector(0, 0, 5))
								TK.AM:SystemMessage({ply, " Has Sent ", tar1, " To ", tar2})
								return
							else
								tar1:SetPos(tar2:LocalToWorld(RotVec) - Vector(0, 0, 36))
								TK.AM:SystemMessage({ply, " Has Sent ", tar1, " To ", tar2})
								return
							end
						end
					end
					tar1:SetMoveType(MOVETYPE_NOCLIP)
					tar1:SetPos(tar2:LocalToWorld((Vector(-40,0,0))))
					TK.AM:SystemMessage({ply, " Has Sent ", tar1, " To ", tar2})
				else
					TK.AM:SystemMessage({" You Can Not Send ", tar1}, {ply}, 2)
				end
			end
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)