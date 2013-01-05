
local PLUGIN = {}
PLUGIN.Name       = "Ban ID"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "BanID"
PLUGIN.Auto       = {"string", "number", "string"}
PLUGIN.Level      = 6

if SERVER then
	function PLUGIN.Call(ply, arg)
		if ply:HasAccess(PLUGIN.Level) then
			local steamid = string.match(arg[1], "STEAM_[0-5]:[0-9]:[0-9]+")
			if steamid then
				local count, targets = TK.AM:FindPlayer(steamid)
				
				if count == 0 then
					local length = tonumber(arg[2])
					if length && length >= 0 then
						length = math.ceil(length * 60)
						local reason = table.concat(arg, " ", 3)
						
						if length == 0 then
							TK.AM:SystemMessage({ply, " Has Perma Banned ", steamid})
						else
							TK.AM:SystemMessage({ply, " Has Banned ", steamid, " For "..TK:FormatTime(length, 1)})
						end
						
						TK:AddBan(ply, steamid, nil, length, reason)
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
								TK.AM:SystemMessage({ply, " Has Perma Banned ", tar})
							else
								TK.AM:SystemMessage({ply, " Has Banned ", tar, " For "..TK:FormatTime(length, 1)})
							end
							
							TK:AddBan(ply, steamid, nil, length, reason, tar:Name())
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
				TK.AM:SystemMessage({"Invalid Steam ID"}, {ply}, 2)	
			end
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)