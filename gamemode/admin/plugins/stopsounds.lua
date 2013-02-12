
local PLUGIN = {}
PLUGIN.Name       = "Stopsounds"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Stopsounds"
PLUGIN.Level      = 1

if SERVER then	
	function PLUGIN.Call(ply, arg)
		TK.AM:StopSounds(ply)
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)