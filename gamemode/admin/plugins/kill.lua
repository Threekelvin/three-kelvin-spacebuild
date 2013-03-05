

PLUGIN.Name       = "Kill"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Kill"
PLUGIN.Level      = 1

if SERVER then
    function PLUGIN.Call(ply,arg)
        ply:Kill()
    end
else

end

