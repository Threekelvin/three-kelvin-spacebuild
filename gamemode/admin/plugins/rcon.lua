
local PLUGIN = {}
PLUGIN.Name       = "RCON"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "RCON"
PLUGIN.Level      = 7

if SERVER then
    function PLUGIN.Call(ply, arg)
        local cmd = {}
        for k,v in pairs(arg) do
            local temp = string.Explode(" ", v)
            for l,b in pairs(temp) do
                table.insert(cmd, b)
            end
        end
        RunConsoleCommand(unpack(cmd))
    end
else

end

TK.AM:RegisterPlugin(PLUGIN)