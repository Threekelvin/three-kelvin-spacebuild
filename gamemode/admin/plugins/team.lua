

PLUGIN.Name       = "Team"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Team"
PLUGIN.Level      = 6

if SERVER then
    function PLUGIN.Call(ply, arg)
        local count, targets = TK.AM:TargetPlayer(ply, arg[1])
        
        if count == 0 then
            TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
        elseif count > 1 then
            TK.AM:SystemMessage({"Multiple Targets Found"}, {ply}, 2)
        else
            local tar = targets[1]
            local faction = math.floor(tonumber(arg[2]))
            local teams = team.GetAllTeams()
            
            if !teams[faction] || !teams[faction].Joinable then
                TK.AM:SystemMessage({"No Valid Team Selected"}, {ply}, 2)
            else
                TK.DB:UpdatePlayerData(tar, "player_team", {team = faction})
                TK.AM:SystemMessage({ply, " has added ", tar, " to ", team.GetColor(faction), team.GetName(faction)})
            end
        end
    end
else

end

