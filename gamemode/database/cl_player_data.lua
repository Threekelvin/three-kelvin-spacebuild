TK.DB = TK.DB or {}
TK.DB.PlayerData = {}

net.Receive("TKDB_Sync", function()
    local dbtable = net.ReadString()
    local data = net.ReadTable()
    TK.DB.PlayerData[dbtable] = TK.DB.PlayerData[dbtable] or {}

    for idx, val in pairs(data) do
        TK.DB.PlayerData[dbtable][idx] = val
        gamemode.Call("TKDB_Player_Data", dbtable, idx, val)
    end
end)

hook.Add("Initialize", "PlayerData", function()
    function GAMEMODE:TKDB_Player_Data(dbtable, idx, val)
    end
end)

function TK.DB:GetPlayerData(dbtable)
    return TK.DB.PlayerData[dbtable] or {}
end
