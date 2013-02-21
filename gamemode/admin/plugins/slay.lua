
local PLUGIN = {}
PLUGIN.Name       = "Slay"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Slay"
PLUGIN.Level      = 3

if SERVER then
    function PLUGIN.Call(ply, arg)
        local count, targets = TK.AM:FindTargets(ply, arg)
        
        if #arg == 0 then
            if ply:Alive() then
                ply:Kill()
                TK.AM:SystemMessage({ply, " Has Slayed ", ply})
            end
        elseif count == 0 then
            TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
        else
            local msgdata = {ply, " Has Slayed "}
            for k,v in pairs(targets) do
                if v:Alive() then
                    v:Kill()
                    table.insert(msgdata, v)
                    table.insert(msgdata, ", ")
                end
            end
            if #msgdata > 3 then
                msgdata[#msgdata] = nil
                TK.AM:SystemMessage(msgdata)
            end
        end
    end
else

end

TK.AM:RegisterPlugin(PLUGIN)