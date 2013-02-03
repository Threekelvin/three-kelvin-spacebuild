
local PLUGIN = {}
PLUGIN.Name       = "Addons"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Addons"
PLUGIN.Auto       = {}
PLUGIN.Level      = 1

if SERVER then
	function PLUGIN.Call(ply,arg)
		if ply:HasAccess(PLUGIN.Level) then
			ply:ConCommand("3k_addon_check")
		else
			TK.AM:SystemMessage({"Access Denied"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)