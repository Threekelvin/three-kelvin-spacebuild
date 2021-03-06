PLUGIN.Name = "UnGod"
PLUGIN.Prefix = "!"
PLUGIN.Command = "UnGod"
PLUGIN.Level = 4

if SERVER then
    function PLUGIN.Call(ply, arg)
        local count, targets = TK.AM:FindTargets(ply, arg)

        if #arg == 0 then
            ply:GodDisable()
            TK.AM:SystemMessage({ply,  " Disabled God Mode On ",  ply})
        elseif count == 0 then
            TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
        else
            local msgdata = {ply,  " Disabled God Mode On "}

            for k, v in pairs(targets) do
                v:GodDisable()
                table.insert(msgdata, v)
                table.insert(msgdata, ", ")
            end

            msgdata[#msgdata] = nil
            TK.AM:SystemMessage(msgdata)
        end
    end
end
