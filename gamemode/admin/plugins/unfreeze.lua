
local PLUGIN = {}
PLUGIN.Name       = "UnFreeze"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "UnFreeze"
PLUGIN.Level      = 4

if SERVER then    
    function PLUGIN.Call(ply, arg)
        local count, targets = TK.AM:FindTargets(ply, arg)
        
        if #arg == 0 then
            ply:UnLock()
            TK.AM:SystemMessage({ply, " Has UnFrozen ", ply})
        elseif count == 0 then
            TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
        else
            local msgdata = {ply, " Has UnFrozen "}
            for k,v in pairs(targets) do
                v:UnLock()
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