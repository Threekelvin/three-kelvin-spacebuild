
local PLUGIN = {}
PLUGIN.Name       = "Team"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Team"
PLUGIN.Auto       = {"player", "number"}
PLUGIN.Level      = 6

if SERVER then
	function PLUGIN.Call(ply, arg)
		if ply:HasAccess(PLUGIN.Level) then
			local count, targets = TK.AM:TargetPlayer(ply, arg[1])
			
			if count == 0 then
				TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
			elseif count > 1 then
				TK.AM:SystemMessage({"Multiple Targets Found"}, {ply}, 2)
			else
				local tar = targets[1]
				local faction = math.Clamp(math.Round(tonumber(arg[2])), 1, 4)
				
				if tar:IsListenServerHost() then
					TK.AM:SystemMessage({"You Can Not Change", tar, "'s Rank"}, {ply}, 2)
				elseif !faction then
					TK.AM:SystemMessage({"No Team Selected"}, {ply}, 2)
				else
					TK.DB:UpdatePlayerData(tar, "player_team", {team = faction})
					TK.AM:SystemMessage({ply, " has added ", tar, " to the ", team.GetColor(faction), team.GetName(faction)})
				end
			end
			
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)