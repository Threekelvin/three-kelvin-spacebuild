
PLUGIN.Name       = "Me"
PLUGIN.Prefix     = "/me"
PLUGIN.Command    = ""
PLUGIN.Level      = 1

if SERVER then
    function PLUGIN.Call(ply, arg)
        local msgdata = {false, ply, team.GetColor(ply:Team())}
        
        table.insert(msgdata, table.concat(arg, " "))
        TK.AM:SystemMessage(msgdata)
    end
else

end

