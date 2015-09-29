PLUGIN.Name = "status"
PLUGIN.Prefix = "!"
PLUGIN.Command = "status"
PLUGIN.Level = 4

if SERVER then
    function PLUGIN.Call(ply, arg)
        ply:PrintMessage(HUD_PRINTCONSOLE, "# name\t\tsteamid\t\t\tping\tloss\tIP")

        for k, v in pairs(player.GetAll()) do
            local str = string.format("# %s\t%s\t%u\t%u\t%s", v:Nick(), v:SteamID(), v:Ping(), v:PacketLoss(), v:IPAddress())
            ply:PrintMessage(HUD_PRINTCONSOLE, str)
        end

        TK.AM:SystemMessage({"Printed to console."}, {ply}, 2)
    end
end
