
TK.DB = TK.DB or {}
local PlayerData = {}
local OSTime = 0

net.Receive("DB_Sync", function()
    local dbtable = net.ReadString()
    PlayerData[dbtable] = PlayerData[dbtable] or {}
    local idx = net.ReadString()
    local typ = net.ReadInt(4)
    
    if typ == 1 then
        PlayerData[dbtable][idx] = net.ReadFloat()
    elseif typ == 2 then
        PlayerData[dbtable][idx] = net.ReadString()
    elseif typ == 3 then
        PlayerData[dbtable][idx] = net.ReadTable()
    end
    
    gamemode.Call("TKDBPlayerData", dbtable, idx, PlayerData[dbtable][idx])
end)

net.Receive("DB_Time", function()
    OSTime = os.time() - net.ReadInt(32)
end)

function TK.DB:GetPlayerData(dbtable)
    local data = PlayerData[dbtable] or {}
    return table.Copy(data)
end

function TK.DB:OSTime()
    return os.time() - OSTime
end

hook.Add("Initialize", "PlayerData", function()
    PlayerData = table.Merge(TK.DB:MakePlayerData(), PlayerData)
    
    function GAMEMODE:TKDBPlayerData(dbtable, idx, data)
    end
end)