
local PLUGIN = {}
PLUGIN.Name       = "Freeze"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Freeze"
PLUGIN.Level      = 4

if SERVER then	
	function PLUGIN.Call(ply, arg)
        local count, targets = TK.AM:FindTargets(ply, arg)
        
        if #arg == 0 then
            ply:Lock()
            TK.AM:SystemMessage({ply, " Has Frozen ", ply})
        elseif count == 0 then
            TK.AM:SystemMessage({"No Targets Found"}, {ply}, 2)
        else
            local msgdata = {ply, " Has Frozen "}
            for k,v in pairs(targets) do
                v:Lock()
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