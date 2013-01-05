
local PLUGIN = {}
PLUGIN.Name       = "Ban IP"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "BanIP"
PLUGIN.Auto       = {"string", "number", "string"}
PLUGIN.Level      = 6

if SERVER then
	function PLUGIN.Call(ply, arg)
		if ply:HasAccess(PLUGIN.Level) then
			local ip = string.match(arg[1], "(%d+%.%d+%.%d+%.%d+)")
			if ip then
				local count, targets = TK.AM:FindPlayer(ip)
				
				if count == 0 then
					local length = tonumber(arg[2])
					if length && length >= 0 then
						length = math.ceil(length * 60)
						local reason = table.concat(arg, " ", 3)
						
						if length == 0 then
							TK.AM:SystemMessage({ply, " Has Perma Banned ", ip})
						else
							TK.AM:SystemMessage({ply, " Has Banned ", ip, " For "..TK:FormatTime(length, 1)})
						end
						
						TK:AddBan(ply, nil, ip, length, reason)
					else
						TK.AM:SystemMessage({"Invalid Ban Length"}, {ply}, 2)
					end
				else
					local tar = targets[1]
					if ply:CanRunOn(tar) && ply != tar then
						local length = tonumber(arg[2])
						if length && length >= 0 then
							length = math.ceil(length * 60)
							local steamid = tar:SteamID()
							local reason = table.concat(arg, " ", 3)
							
							if length == 0 then
								TK.AM:SystemMessage({ply, " Has Perma IP Banned ", tar})
							else
								TK.AM:SystemMessage({ply, " Has IP Banned ", tar, " For "..TK:FormatTime(length, 1)})
							end
							
							TK:AddBan(ply, nil, TK.AM:GetIP(tar), length, reason, tar:Name())
							game.ConsoleCommand("banid 5 ".. steamid.."\n")
							game.ConsoleCommand("kickid "..steamid.." [Banned For "..TK:FormatTime(length, 1).."] "..reason.."\n")
						else
							TK.AM:SystemMessage({"Invalid Ban Length"}, {ply}, 2)
						end
					else
						TK.AM:SystemMessage({"You Can Not Ban ", tar}, {ply}, 2)	
					end
				end
			else
				TK.AM:SystemMessage({"Invalid IP"}, {ply}, 2)	
			end
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)