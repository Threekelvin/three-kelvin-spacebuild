

PLUGIN.Name       = "Rank"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Rank"
PLUGIN.Level      = 7

if SERVER then
    function PLUGIN.Call(ply, arg)
        local count, targets = TK.AM:TargetPlayer(ply, arg[1])
        
        if count == 0 then
            TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
        elseif count > 1 then
            TK.AM:SystemMessage({"Multiple Targets Found"}, {ply}, 2)
        else
            local tar = targets[1]
            local lvl = math.Clamp(math.Round(tonumber(arg[2])), 1, 7)
            
            if tar:IsListenServerHost() then
                TK.AM:SystemMessage({"You Can Not Change", tar, "'s Rank"}, {ply}, 2)
            elseif !lvl then
                TK.AM:SystemMessage({"No Level Selected"}, {ply}, 2)
            else
                local time = tonumber(arg[3]) or 0
                if !time or time == 0 then
                    timer.Destroy("temp_lvl_"..tar:UID())
                    TK.DB:UpdatePlayer(tar, "server_player_record", {rank = lvl})
                    TK.AM:SystemMessage({ply, " Has Set ", tar, " To ", TK.AM.Rank.RGBA[lvl], "["..TK.AM.Rank.Group[lvl].."]"})
                else
                    timer.Destroy("temp_lvl_"..tar:UID())
                    timer.Create("temp_lvl_"..tar:UID(), time * 60, 1, function()
                        if IsValid(tar) then
                            local lvl_old = TK.DB:GetPlayerData(tar, "player_info").rank
                            TK.AM:SetRank(tar, lvl_old)
                            TK.AM:SystemMessage({tar, " Is Now ", TK.AM.Rank.RGBA[lvl_old], "["..TK.AM.Rank.Group[lvl_old].."]"})
                        end
                    end)
                    
                    TK.AM:SetRank(tar, lvl)
                    TK.AM:SystemMessage({ply, " Has Set ", tar, " To ", TK.AM.Rank.RGBA[lvl], "["..TK.AM.Rank.Group[lvl].."]", " For "..tostring(time).." Minute(s)"})
                end
            end
        end
    end
else

end

