
local PLUGIN = {}
PLUGIN.Name       = "God"
PLUGIN.Prefix     = "!"
PLUGIN.Command    ="God"
PLUGIN.Auto       = {"players"}
PLUGIN.Level      = 4

if SERVER then
	function PLUGIN.Call(ply, arg)
        local count, targets = TK.AM:FindTargets(ply, arg)
        
        if #arg == 0 then
            ply:GodEnable()
            TK.AM:SystemMessage({ply, " Enabled God Mode On ", ply})
        elseif count == 0 then
            TK.AM:SystemMessage({"No Targets Found"}, {ply}, 2)
        else
            local msgdata = {ply, " Enabled God Mode On "}
            for k,v in pairs(targets) do
                v:GodEnable()
                table.insert(msgdata, v)
                table.insert(msgdata, ", ")
            end
            msgdata[#msgdata] = nil
            TK.AM:SystemMessage(msgdata)
        end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)