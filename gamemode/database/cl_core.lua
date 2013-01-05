
TK.DB = TK.DB || {}
local PlayerData = {}
local OSTime = 0

net.Receive("DB_Sync", function()
	local dbtable = net.ReadString()
	PlayerData[dbtable] = PlayerData[dbtable] || {}
	
	if net.ReadBit() == 1 then
		local dir, value = string.sub(net.ReadString(), 2), string.sub(net.ReadString(), 2)
		PlayerData[dbtable][dir] = tonumber(value)
	else
		local dir, value = string.sub(net.ReadString(), 2), string.sub(net.ReadString(), 2)
		PlayerData[dbtable][dir] = value
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