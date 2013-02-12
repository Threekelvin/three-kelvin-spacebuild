
local PLUGIN = {}
PLUGIN.Name       = "Kick"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Kick"
PLUGIN.Level      = 4

if SERVER then
	function PLUGIN.Call(ply, arg)
        local count, targets = TK.AM:FindPlayer(arg[1])
        
        if count == 0 then
            TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
        elseif count > 1 then
            TK.AM:SystemMessage({"Multiple Targets Found"}, {ply}, 2)	
        else
            local tar = targets[1]
            if ply:CanRunOn(tar) && ply != tar then
                local reason = table.concat(arg, " ", 2)
                TK.AM:SystemMessage({ply, " Has Kicked ", tar})
                game.ConsoleCommand("kickid "..tar:SteamID().." "..reason.."\n")
            else
                TK.AM:SystemMessage({"You cannot Kick ", tar}, {ply}, 2)	
            end
        end
	end
	
	concommand.Add("kickid2",function(ply, cmd, arg)
		PLUGIN.Call(ply, arg)
	end)
else

end

TK.AM:RegisterPlugin(PLUGIN)