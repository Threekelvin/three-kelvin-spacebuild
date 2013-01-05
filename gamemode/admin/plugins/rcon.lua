
local PLUGIN = {}
PLUGIN.Name       = "RCON"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "RCON"
PLUGIN.Auto       = {"string"}
PLUGIN.Level      = 7

if SERVER then
	function PLUGIN.Call(ply, arg)
		if ply:HasAccess(PLUGIN.Level) then
			local cmd = {}
			for k,v in pairs(arg) do
				local temp = string.Explode(" ", v)
				for l,b in pairs(temp) do
					table.insert(cmd, b)
				end
			end
			RunConsoleCommand(unpack(cmd))
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)