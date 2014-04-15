

PLUGIN.Name       = "AFK"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "AFK"
PLUGIN.Level      = 1

if SERVER then
    function PLUGIN.Call(ply, arg)
        TK.AM:SetAFK(ply, true, table.concat(arg or {}, " "))
    end
else
    
end

