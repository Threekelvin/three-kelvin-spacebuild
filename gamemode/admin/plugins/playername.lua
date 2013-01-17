
local PLUGIN = {}
PLUGIN.Name       = "Player Name"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "PlayerName"
PLUGIN.Auto       = {"string"}
PLUGIN.Level      = 1

if SERVER then
	function PLUGIN.Call(ply, arg)
		if ply:HasAccess(PLUGIN.Level) then
			if !IsValid(ply) then return end
			
			local name_old   = ply:Name()
			local name = TK.AM:NameMakeSafe(table.concat(arg, " "))
			
			if name == "[Too Many Invalid Characters]" then return end
			local team_color = team.GetColor(ply:Team())
			
			TK.DB:UpdatePlayerData(ply, "player_info", {name = name})
			
			msgdata = {team_color , name_old, " Has Changed Thier Name To ",team_color, name}
			TK.AM:SystemMessage(msgdata)
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)