
TK.DB = TK.DB || {}
local PlayerData = {}
local OSTime = 0

net.Receive("DB_Sync", function()
	local dbtable = net.ReadString()
	PlayerData[dbtable] = PlayerData[dbtable] || {}
    local dir = net.ReadString()
    local typ = net.ReadInt(4)
    
    if typ == 1 then
        PlayerData[dbtable][dir] = tonumber(net.ReadFloat())
    elseif typ == 2 then
        PlayerData[dbtable][dir] = tostring(net.ReadString())
    elseif typ == 3 then
        PlayerData[dbtable][dir] = net.ReadTable()
    end
end)

net.Receive("DB_Time", function()
	OSTime = os.time() - net.ReadInt(32)
end)

function TK.DB:GetPlayerData(dbtable)
	local data = PlayerData[dbtable] || {}
	return table.Copy(data)
end

function TK.DB:OSTime()
	return os.time() - OSTime
end