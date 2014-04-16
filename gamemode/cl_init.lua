
include('shared.lua')

usermessage.Hook("TKOSSync", function(msg)
    local servertime = tonumber(msg:ReadString())
    TK.OSSync = math.ceil(servertime - os.time())
end)

hook.Add("Initialize", "ClientInit", function()    
    RunConsoleCommand("r_eyemove", "0")
end)