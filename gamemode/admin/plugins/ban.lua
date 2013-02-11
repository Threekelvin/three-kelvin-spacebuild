
local PLUGIN = {}
PLUGIN.Name       = "Ban Player"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Ban"
PLUGIN.Auto       = {"player", "number", "string"}
PLUGIN.Level      = 5

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
                local length = tonumber(arg[2])
                if length && length >= 0 then
                    length = math.ceil(length * 3600)
                    local steamid = tar:SteamID()
                    local reason = table.concat(arg, " ", 3)
                    
                    if length == 0 then
                        TK.AM:SystemMessage({ply, " Has Perma Banned ", tar})
                    else
                        TK.AM:SystemMessage({ply, " Has Banned ", tar, " For "..TK:FormatTime(length / 60)})
                    end
                    
                    TK.DB:AddBan(ply, steamid, nil, length, reason)
                    game.ConsoleCommand("banid 5 ".. steamid.."\n")
                    game.ConsoleCommand("kickid "..steamid.." [Banned For "..TK:FormatTime(length / 60).."]\n")
                else
                    TK.AM:SystemMessage({"Invalid Ban Length"}, {ply}, 2)
                end
            else
                TK.AM:SystemMessage({"You Can Not Ban ", tar}, {ply}, 2)	
            end
        end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)