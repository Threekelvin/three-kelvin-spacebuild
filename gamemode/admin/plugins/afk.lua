
local PLUGIN = {}
PLUGIN.Name       = "AFK"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "AFK"
PLUGIN.Auto       = {}
PLUGIN.Level      = 1

if SERVER then
	function PLUGIN.Call(ply, arg)
		TK.AM:SetAFK(ply, true, table.concat(arg || {}, " "))
	end
else
	
end

TK.AM:RegisterPlugin(PLUGIN)