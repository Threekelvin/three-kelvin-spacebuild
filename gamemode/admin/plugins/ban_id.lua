PLUGIN.Name = "Ban ID"
PLUGIN.Prefix = "!"
PLUGIN.Command = "BanID"
PLUGIN.Level = 6

if SERVER then
    function PLUGIN.Call(ply, arg)
        local steamid = string.match(arg[1], "STEAM_[0-5]:[0-9]:[0-9]+")

        if steamid then
            local count, targets = TK.AM:FindPlayer(steamid)

            if count == 0 then
                local length = tonumber(arg[2])

                if length and length >= 0 then
                    length = math.ceil(length * 3600)
                    local reason = table.concat(arg, " ", 3)

                    if length == 0 then
                        TK.AM:SystemMessage({ply,  " Has Perma Banned ",  steamid})
                    else
                        TK.AM:SystemMessage({ply,  " Has Banned ",  steamid,  " For " .. TK:FormatTime(length / 60)})
                    end

                    TK.DB:AddBan(ply, steamid, nil, length, reason)
                else
                    TK.AM:SystemMessage({"Invalid Ban Length"}, {ply}, 2)
                end
            else
                local tar = targets[1]

                if ply:CanRunOn(tar) and ply ~= tar then
                    local length = tonumber(arg[2])

                    if length and length >= 0 then
                        length = math.ceil(length * 3600)
                        local reason = table.concat(arg, " ", 3)

                        if length == 0 then
                            TK.AM:SystemMessage({ply,  " Has Perma Banned ",  tar})
                        else
                            TK.AM:SystemMessage({ply,  " Has Banned ",  tar,  " For " .. TK:FormatTime(length / 60)})
                        end

                        TK.DB:AddBan(ply, tar.steamid, tar.ip, length, reason)
                        game.ConsoleCommand("banid 5 " .. tar.steamid .. "\n")
                        game.ConsoleCommand("kickid " .. tar.steamid .. " [Banned For " .. TK:FormatTime(length / 60) .. "]\n")
                    else
                        TK.AM:SystemMessage({"Invalid Ban Length"}, {ply}, 2)
                    end
                else
                    TK.AM:SystemMessage({"You Can Not Ban ",  tar}, {ply}, 2)
                end
            end
        else
            TK.AM:SystemMessage({"Invalid Steam ID"}, {ply}, 2)
        end
    end
end
