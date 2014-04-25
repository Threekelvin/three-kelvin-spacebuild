
TK.DB = TK.DB or {}
TK.DB.last_gmsg = -1
TK.DB.g_flood = {}

util.AddNetworkString("TKGC_Msg")

local function CanSendMsg(ply)
    local uid = ply:UID()
    TK.DB.g_flood[uid] = (TK.DB.g_flood[uid] or 0) + 1

    if TK.DB.g_flood[uid] > 5 then return false end
    return true
end

local function ExtractFlag(flag, id)
    return bit.band(id, flag) == id
end

function TK.DB:SendPlyMsg(flag, server, rank, faction, name, msg)
    local plys = player.GetAll()
    
    if ExtractFlag(flag, 4) then
        print(server .."[Admin]", TK.AM.Rank.Tag[rank]..name, msg)
        
        for k,v in pairs(plys) do
            if v:IsModerator() then continue end
            plys[k] = nil
        end
    elseif ExtractFlag(flag, 2)  then
        print(server .."[Team]", TK.AM.Rank.Tag[rank]..name, msg)
        
        for k,v in pairs(plys) do
            if v:Team() == faction then continue end
            plys[k] = nil
        end
    else
        print(server, TK.AM.Rank.Tag[rank]..name, msg)
    end
    
    net.Start("TKGC_Msg")
        net.WriteFloat(1)
        net.WriteFloat(flag)
        net.WriteString(server)
        net.WriteFloat(rank)
        net.WriteFloat(faction)
        net.WriteString(name)
        net.WriteString(msg)
    net.Send(plys)
end

function TK.DB:SendSysMsg(server, msg)
    print(server, msg)
    
    net.Start("TKGC_Msg")
        net.WriteFloat(2)
        net.WriteString(server)
        net.WriteString(msg)
    net.Broadcast()
end

function TK.DB:RemoteFunction(server, toserver, cmd, rank, faction, name)
    if toserver != "*" and !string.find(string.lower(TK:HostName()), string.lower(toserver)) then return end
    
    print(server, " Remote Command From "..TK.AM.Rank.Tag[rank]..name, cmd)
    RunConsoleCommand("3k", unpack(string.Explode(" ", cmd)))
end

function TK.DB:SendGlobalMsg(ply, msg, flag)
    if !IsValid(ply) or !ply:IsPlayer() then return end
    if !CanSendMsg(ply) then
        TK.AM:SystemMessage({"Global Message Limit, please wait"}, {ply}, 2)
        return
    end
    
    self:InsertQuery("server_globalchat", {
        msg_conection_id = "DB_CONN_ID",
        msg_key = 0,
        msg_origin = TK:HostName(),
        msg_flag = flag,
        msg_data = msg,
        sender_rank = ply:GetRank(),
        sender_faction = IsValid(ply) and ply:Team() or 0,
        sender_name = ply:Name()
    })
    
    self:SendPlyMsg(flag, TK:HostName(), ply:GetRank(), ply:Team(), ply:Name(), msg)    
end

function TK.DB:SendGlobalSystemMsg(msg)
    self:InsertQuery("server_globalchat", {
        msg_conection_id = "DB_CONN_ID",
        msg_key = 1,
        msg_origin = TK:HostName(),
        msg_data = msg
    })
    
    self:SendSysMsg(TK:HostName(), msg)
end

function TK.DB:SendRemoteCmd(ply, svr, cmd)
    self:InsertQuery("server_globalchat", {
        msg_conection_id = "DB_CONN_ID",
        msg_key = 2,
        msg_origin = TK:HostName(),
        msg_recipient = svr,
        msg_data = cmd,
        sender_rank = ply:GetRank(),
        sender_faction = IsValid(ply) and ply:Team() or 0,
        sender_name = ply:Name()
    })
end

hook.Add("InitPostEntity", "TKDB_GChat", function()
    TK.DB:SelectQuery("server_globalchat", {"msg_idx"}, {["msg_idx > %s"] = 0}, {"msg_idx", "DESC"}, 1, function(data)
        TK.DB.last_gmsg = data[1].msg_idx or 0
    end)

    timer.Create("TKDB_GChat", 10, 0, function()
        if !TK.DB:IsConnected() then return end
        if TK.DB.last_gmsg == -1 then return end

        TK.DB:SelectQuery("server_globalchat", nil, {["msg_idx > %s"] = TK.DB.last_gmsg}, {"msg_idx"}, nil, function(data)
            for k,v in ipairs(data) do
                TK.DB.last_gmsg = v.msg_idx
                if v.msg_conection_id == TK.DB:ConnectionID() then return end

                if v.msg_key == 0 then
                    TK.DB:SendPlyMsg(v.msg_flag, v.msg_origin, v.sender_rank, v.sender_faction, v.sender_name, v.msg_data)
                elseif v.msg_key == 1 then
                    TK.DB:SendSysMsg(v.msg_origin, v.msg_data)
                elseif v.msg_key == 2 then
                    TK.DB:RemoteFunction(v.msg_origin, v.msg_recipient, v.msg_data, v.sender_rank, v.sender_faction, v.sender_name)
                end
            end
        end)
        
        TK.DB.g_flood = {}
    end)
end)

hook.Add("PlayerSay", "TKDB_GChat", function(ply, text, toteam)
    if string.sub(text, 1, 2) == "; " then 
        local flag, msg = toteam and 2 or 0, ""
        if string.sub(text, 3, 5) == "/me" then
            flag = flag + 1
            msg = string.Trim(string.sub(text, 6))
        else
            msg = string.Trim(string.sub(text, 3))
        end
        
        if msg == "" then return end
        TK.DB:SendGlobalMsg(ply, msg, flag)
        return false
    elseif string.sub(text, 1, 2) == ";@" then
        local flag, msg = 4, string.Trim(string.sub(text, 3))
        
        if msg == "" then return end
        TK.DB:SendGlobalMsg(ply, msg, flag)
        return false
    end
end)