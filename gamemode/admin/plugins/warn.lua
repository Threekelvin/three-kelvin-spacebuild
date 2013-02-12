
local PLUGIN = {}
PLUGIN.Name       = "Warn"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Warn"
PLUGIN.Level      = 4

if SERVER then

	util.AddNetworkString( "HUD_WARNING" )
	local function HUDwarning( ply, message )
		net.Start( "HUD_WARNING" )
			net.WriteString( "admin" )
			net.WriteString( message )
		net.Send( ply )
	end

	function PLUGIN.Call( ply, arg )
        local count, targets = TK.AM:FindPlayer(arg[1])
        local message = ""
        
        if count == 0 then
            message = table.concat( arg, " ", 1 )
            HUDwarning( player.GetAll(), message )
        elseif count > 1 then
            TK.AM:SystemMessage({"Multiple Targets Found"}, {ply}, 2)
        else
            local tar = targets[1]
            if ply:CanRunOn(tar) then
                message = table.concat( arg, " ", 2 )
                HUDwarning( tar, message )
            else
                TK.AM:SystemMessage({"You cannot Warn ", tar}, {ply}, 2)
            end
        end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)