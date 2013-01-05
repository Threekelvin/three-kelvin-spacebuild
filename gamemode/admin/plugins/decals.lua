
local PLUGIN = {}
PLUGIN.Name       = "Decals"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Decals"
PLUGIN.Auto       = {}
PLUGIN.Level      = 1

if SERVER then
	function PLUGIN.Call(ply, arg)
		if ply:HasAccess(PLUGIN.Level) then
			ply:ConCommand("r_cleardecals")
			TK.AM:SystemMessage({"Removed All Decals"}, {ply}, 2)
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)