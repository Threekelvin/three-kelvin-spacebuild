
local PLUGIN = {}
PLUGIN.Name       = "Unban"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Unban"
PLUGIN.Level      = 6

if SERVER then
	function PLUGIN.Call(ply, arg)
        if string.match(arg[1], "STEAM_[0-5]:[0-9]:[0-9]+") then
            local steamid = string.match(arg[1], "STEAM_[0-5]:[0-9]:[0-9]+")
            TK.AM:SystemMessage({ply, " Has Unbanned ", steamid})
            TK:RemoveBan(ply, steamid, nil, table.concat(arg, " ", 2))
        elseif string.match(arg[1], "(%d+%.%d+%.%d+%.%d+)") then
            local ip = string.match(arg[1], "(%d+%.%d+%.%d+%.%d+)")
            TK.AM:SystemMessage({ply, " Has Unbanned ", ip})
            TK:RemoveBan(ply, nil, ip, table.concat(arg, " ", 2))
        end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)