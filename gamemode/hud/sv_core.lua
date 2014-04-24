
TK.HUD = TK.HUD or {}

util.AddNetworkString("TKHUD_Start_Warning")
util.AddNetworkString("TKHUD_Stop_Warning")

function TK.HUD:StartWarning(ply, msg)
    net.Start("TKHUD_Start_Warning")
        net.WriteString(msg)
    net.Send(ply)
end

function TK.HUD:StopWarning(ply, msg)
    net.Start("TKHUD_Stop_Warning")
        net.WriteString(msg)
    net.Send(ply)
end