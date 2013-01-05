
local PLUGIN = {}
PLUGIN.Name       = "Stopsounds"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Stopsounds"
PLUGIN.Auto       = {}
PLUGIN.Level      = 1

if SERVER then	
	function PLUGIN.Call(ply, arg)
		if ply:HasAccess(PLUGIN.Level) then
			TK.AM:StopSounds(ply)
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)