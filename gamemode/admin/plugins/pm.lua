
local PLUGIN = {}
PLUGIN.Name       = "PM"
PLUGIN.Prefix     = ">"
PLUGIN.Command    = nil
PLUGIN.Auto       = {"player", "string"}
PLUGIN.Level      = 1

if SERVER then
	function PLUGIN.Call(ply, arg)
		if ply:HasAccess(PLUGIN.Level) then
			local count, targets = TK.AM:FindPlayer(arg[1])
			
			if count == 0 then
				TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
			elseif count > 1 then
				TK.AM:SystemMessage({"Multiple Targets Found"}, {ply}, 2)
			else
				msgdata = {Color(255,140,0), "[PM] ", ply}
				table.insert(msgdata, ": "..table.concat(arg, " ", 2))
				TK.AM:SystemMessage(msgdata, {ply, targets[1]})
			end
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)