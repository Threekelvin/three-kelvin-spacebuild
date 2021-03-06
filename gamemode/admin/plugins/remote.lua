PLUGIN.Name = "Remote Command"
PLUGIN.Prefix = "!"
PLUGIN.Command = "Remote"
PLUGIN.Level = 5

if SERVER then
    function PLUGIN.Call(ply, arg)
        local svr, cmd = arg[1], arg[2]
        if !svr or svr == "" then return end
        if !cmd or cmd == "" then return end

        for k, v in pairs(TK.AM:GetAllPlugins()) do
            if v.Command then
                if string.lower(cmd) == string.lower(v.Command) then
                    if !ply:HasAccess(v.Level) then
                        TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)

                        return
                    end

                    break
                end
            end
        end

        TK.DB:SendRemoteCmd(ply, svr, table.concat(arg, " ", 2))
        TK.AM:SystemMessage({"Remote Command Sent To ",  svr}, {ply}, 2)
    end
end
