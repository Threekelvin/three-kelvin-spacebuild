local PLUGIN = {}
PLUGIN.Name       = "Me"
PLUGIN.Prefix     = "/me"
PLUGIN.Command    = ""
PLUGIN.Auto       = {"string"}
PLUGIN.Level      = 1

if SERVER then
	function PLUGIN.Call(ply, arg)
		if ply:HasAccess(PLUGIN.Level) then
			local msgdata = {ply, team.GetColor(ply:Team())}
			
			table.insert(msgdata, table.concat(arg, " "))
			TK.AM:SystemMessage(msgdata)
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)