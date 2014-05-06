
TK.DB = TK.DB or {}
TK.DB.PlayerData = {}
TK.DB.PlayerCache = {}

function TK.DB:SetPlayerData(ply, dbtable, data)
    if !self.PlayerData[ply.uid] then return end
    if !self.PlayerData[ply.uid][dbtable] then return end
    local p_data = self.PlayerData[ply.uid][dbtable]
    local n_data = {}
    
    for idx,val in pairs(data or {}) do
        if !p_data[idx] or p_data == val then continue end
        
        p_data[idx] = val
        gamemode.Call("TKDB_Player_Data", ply, dbtable, idx, val)
        
        if self:NoSync(dbtable, idx) then continue end
        n_data[idx] = val
    end

    self.PlayerData[ply.uid][dbtable] = p_data
    
    if table.Count(n_data) == 0 then return end
    net.Start("TKDB_Sync")
        net.WriteString(dbtable)
        net.WriteTable(n_data)
    net.Send(ply)
end

function TK.DB:SetNetworkData(ply, data)
    if data.nick_name then
        ply:SetNWString("TKName", data.nick_name)
    end
    if data.rank then
        TK.AM:SetRank(ply, tonumber(data.rank))
    end
    if data.team then
        ply:SetTeam(data.team)
        local col = team.GetColor(ply:Team())
        ply:SetWeaponColor(Vector(col.r / 255, col.g / 255, col.b / 255))
    end
    if data.playtime then
        ply:SetNWInt("TKPlaytime", data.playtime)
    end
    if data.score then
        ply:SetNWInt("TKScore", data.score)
    end
end

function TK.DB:UpdatePlayer(ply, dbtable, data)
    self:UpdateQuery(dbtable, data, {["steamid = %s"] = ply.steamid})
    self:SetPlayerData(ply, dbtable, data)
    self:SetNetworkData(ply, data)
end

function TK.DB:BuildPlayer(ply)
    self.PlayerData[ply.uid] = {}
    for dbtable,data in pairs(list.Get("TK_Database")) do
        if !string.match(dbtable, "^player_") then continue end
        self.PlayerData[ply.uid][dbtable] = {}
        
        local n_data = {}
        for idx,val in pairs(data) do
            if table.HasValue(val, "PRIMARY KEY") then continue end
            if val.default then
                self.PlayerData[ply.uid][dbtable][idx] = val.default
                if self:NoSync(dbtable, idx) then continue end
                n_data[idx] = val.default
            else
                for k,v in ipairs(val) do
                    local value = string.match(v, "DEFAULT (%w+)") or string.match(v, "DEFAULT '(%w+)'")
                    if !value then continue end
                    
                    self.PlayerData[ply.uid][dbtable][idx] = self:DatabaseToGmod(dbtable, idx, value)

                    if self:NoSync(dbtable, idx) then break end
                    n_data[idx] = value
                    break
                end
            end
        end
        
        net.Start("TKDB_Sync")
            net.WriteString(dbtable)
            net.WriteTable(n_data)
        net.Send(ply)
    end
end

function TK.DB:NewPlayer(ply)   
    for dbtable,data in pairs(list.Get("TK_Database")) do
        if !string.match(dbtable, "^player_") then continue end
        local n_data = {steamid = ply.steamid}
        for idx,val in pairs(data) do
            if !val.default then continue end
            n_data[idx] = val.default
        end
        self:InsertQuery(dbtable, n_data)
    end
end

function TK.DB:NewTable(ply, dbtable)
    local data = list.Get("TK_Database")[dbtable]
    local n_data = {steamid = ply.steamid}
    for idx,val in pairs(data) do
        if !val.default then continue end
        n_data[idx] = val.default
    end
    self:InsertQuery(dbtable, n_data)
end

function TK.DB:LoadPlayer(ply)
    for dbtable,data in pairs(list.Get("TK_Database")) do
        if !string.match(dbtable, "^player_") then continue end
        self:SelectQuery(dbtable, nil, {["steamid = %s"] = ply.steamid}, nil, 1, function(data, ply, dbtable)
            if !data[1] then 
                TK.DB:NewTable(ply, dbtable)
            else
                TK.DB:SetPlayerData(ply, dbtable, data[1])
                TK.DB:SetNetworkData(ply, data[1])
            end
        end, ply, dbtable)
    end
end

function TK.DB:UnloadPlayer(ply)
    if !self.PlayerCache[ply.uid] then return end
    if !self.PlayerData[ply.uid] then return end
    
    for dbtable,data in pairs(self.PlayerCache[ply.uid]) do
        local n_data = {}
        for idx,val in pairs(data) do
            n_data[idx] = self.PlayerData[ply.uid][dbtable][idx] + val
        end
        if table.Count(n_data) == 0 then continue end
        self:UpdatePlayer(ply, dbtable, n_data)
    end
    self.PlayerCache[ply.uid] = {}
end

function TK.DB:CheckForData(ply)
    self:SelectQuery("server_player_record", nil, {["steamid = %s"] = ply:SteamID()}, nil, 1, function(data, ply)
        if data[1] then
            TK.DB:UpdateQuery("server_player_record", {ip = ply.ip, steam_name = ply:GetName()}, {["steamid = %s"] = ply.steamid})
            TK.DB:SetNetworkData(ply, data[1])
            TK.DB:LoadPlayer(ply)
        else
            TK.DB:InsertQuery("server_player_record", {steamid = ply.steamid, ip = ply.ip, uniqueid = ply.uid, steam_name = ply:GetName(), nick_name = ply:GetSafeName()})
            TK.DB:SetNetworkData(ply, {nick_name = ply:GetSafeName(), rank = 1, team = 1})
            TK.DB:NewPlayer(ply)
        end
    end, ply)
end

function TK.DB:StartCache(ply)
    self.PlayerCache[ply.uid] = {}

    timer.Create("TK_Data_Cache_".. ply.uid, 60, 0, function()
        if !IsValid(ply) then return end
        TK.DB:AddPlayTime(ply, 1)
        TK.DB:UnloadPlayer(ply)
    end)
end

hook.Add("PlayerAuthed", "TK_Load_Player", function(ply)
    ply.ip = ply:Ip()
    ply.steamid = ply:SteamID()
    ply.uid = ply:UniqueID()
    
    TK.DB:BuildPlayer(ply)                          
    TK.DB:SelectQuery("server_ban_data", {"idx"}, {["ban_lifted = 0"] = 0, ["(ban_lenght = 0 OR (ban_start + ban_lenght) > UNIX_TIMESTAMP())"] = 0, ["ply_steamid = %s"] = ply.steamid}, nil, 1, function(data, ply)
        if !IsValid(ply) then return end
        if !data[1] then
            TK.DB:CheckForData(ply)
            TK.DB:StartCache(ply)
        else
            MySQL.Msg("[TK] Banned Player Attempted  To Join - ".. ply:Name() .. " - ".. ply.steamid)
            game.ConsoleCommand("banid 5 " .. ply.steamid .. "\n")
            game.ConsoleCommand("kickid " .. ply.steamid .. " You are Banned from this server!\n")
        end
    end, ply)
end)

hook.Add("PlayerDisconnected", "TK_Unload_Player", function(ply)
    timer.Destroy("TK_Data_Cache_".. ply.uid)
    TK.DB:UnloadPlayer(ply)
    TK.DB.PlayerData[ply.uid] = nil
    TK.DB.PlayerCache[ply.uid] = nil
end)

hook.Add("Initialize", "TK_Player_Data", function()
    util.AddNetworkString("TKDB_Sync")
    for dbtable,data in pairs(list.Get("TK_Database")) do
        if !string.match(dbtable, "^player_") then continue end
        util.AddNetworkString(dbtable)
    end
    
    function GAMEMODE:TKDB_Player_Data(ply, dbtable, idx, val)
    end
end)

function TK.DB:GetPlayerData(ply, dbtable)
    if !IsValid(ply) then return end
    return table.Copy(self.PlayerData[ply.uid][dbtable]) or {}
end

function TK.DB:AddPlayTime(ply, time)
    if !self.PlayerCache[ply.uid] then return end
    self.PlayerCache[ply.uid]["player_stats"] = self.PlayerCache[ply.uid]["player_stats"] or {}
    self.PlayerCache[ply.uid]["player_stats"]["playtime"] = (self.PlayerCache[ply.uid]["player_stats"]["playtime"] or 0) + time
end

function TK.DB:AddScore(ply, score)
    if !self.PlayerCache[ply.uid] then return end
    self.PlayerCache[ply.uid]["player_stats"] = self.PlayerCache[ply.uid]["player_stats"] or {}
    self.PlayerCache[ply.uid]["player_stats"]["score"] = (self.PlayerCache[ply.uid]["player_stats"]["score"] or 0) + score
end