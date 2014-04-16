

PLUGIN.Name       = "Player Name"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "PlayerName"
PLUGIN.Level      = 1

if SERVER then
    function PLUGIN.Call(ply, arg)
        if !IsValid(ply) then return end
        
        local name_old   = ply:Name()
        local name = TK.AM:NameMakeSafe(table.concat(arg, " "))
        
        if name == "[Too Many Invalid Characters]" then return end
        local team_color = team.GetColor(ply:Team())
        
        TK.DB:UpdatePlayerData(ply, "player_info", {name = name})
        
        msgdata = {team_color , name_old, " Has Changed Their Name To ",team_color, name}
        TK.AM:SystemMessage(msgdata)
    end
else

end

