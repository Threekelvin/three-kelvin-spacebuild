
local PLUGIN = {}
PLUGIN.Name       = "Kill"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Kill"
PLUGIN.Auto       = {}
PLUGIN.Level      = 1

if SERVER then
	function PLUGIN.Call(ply,arg)
		if ply:HasAccess(PLUGIN.Level) then
			ply:Kill()
		else
			TK.AM:SystemMessage({"Access Denied"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)