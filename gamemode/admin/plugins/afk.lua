
local PLUGIN = {}
PLUGIN.Name       = "AFK"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "AFK"
PLUGIN.Auto       = {}
PLUGIN.Level      = 1

if SERVER then
	function PLUGIN.Call(ply, arg)
		if IsValid(ply) && ply:HasAccess(PLUGIN.Level) then
			TK.AM:SetAFK(ply, true, table.concat(arg || {}, " "))
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
        end
	end
else
	
end

TK.AM:RegisterPlugin(PLUGIN)