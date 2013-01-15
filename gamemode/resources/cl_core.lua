
TK.RD = {}
TK.RD.EntityData = {}
local sync_data = {}
local ent_table = {}
local net_table = {}
local res_table = {}

net.Receive("TKRD_DNet", function()
	local netid = net.ReadInt(16)
	local netdata = net.ReadTable()
	netdata.update = CurTime() + 1
	net_table[netid] = netdata
end)

net.Receive("TKRD_KNet", function()
	net_table[net.ReadInt(16)] = nil
end)

net.Receive("TKRD_DEnt", function()
	local entid = net.ReadInt(16)
	local entdata = net.ReadTable()
	entdata.update = CurTime() + 1
	ent_table[entid] = entdata
end)

net.Receive("TKRD_KEnt", function()
	ent_table[net.ReadInt(16)] = nil
end)

net.Receive("TKRD_MEnt", function()
	net.ReadEntity():DoMenu()
end)

hook.Add("Initialize", "TK.RD", function()
	TK.RD.AddResource("oxygen", "Oxygen")
	TK.RD.AddResource("carbon_dioxide", "Carbon Dioxide")
	TK.RD.AddResource("nitrogen", "Nitrogen")
	TK.RD.AddResource("hydrogen", "Hydrogen")
	TK.RD.AddResource("liquid_nitrogen", "Liquid Nitrogen")
	TK.RD.AddResource("water", "Water")
	TK.RD.AddResource("steam", "Steam")
    TK.RD.AddResource("asteroid_ore", "Asteroid Ore")
    TK.RD.AddResource("raw_tiberium", "Raw Tiberium")
end)

local function RequestData(typ, id)
	local idx, time = typ..id, CurTime()
	if sync_data[idx] && sync_data[idx] > time then return end
	sync_data[idx] = time + 1
	RunConsoleCommand("TKRD_RequestData", typ, id)
end

function TK.RD.AddResource(idx, name)
	idx = tostring(idx)
	name = tostring(name) || idx
	
	res_table[idx] = name
end

function TK.RD.GetNetTable(netid)
	local netdata = net_table[netid]
	if !netdata || netdata.update < CurTime() then
		RequestData("Net", netid)
	end
	return netdata || {res = {}}
end

function TK.RD.GetEntTable(entid)
	local entdata = ent_table[entid]
	if !entdata || entdata.update < CurTime() then
		RequestData("Ent", entid)
	end
	return entdata || {netid = 0, res = {}, data = {}}
end

function TK.RD.IsLinked(ent)
	if !IsValid(ent) then return false end
	local entdata = ent_table[ent:EntIndex()]
	return entdata.netid > 0
end

function TK.RD.GetNetResourceAmount(netid, idx)
	local netdata = TK.RD.GetNetTable(netid)
	if !netdata then return 0 end
	if !netdata.res[idx] then return 0 end
	return netdata.res[idx].cur
end

function TK.RD.GetEntResourceAmount(ent, idx)
	if !IsValid(ent) then return 0 end
	local entdata = TK.RD.GetEntTable(ent:EntIndex())
	if entdata.netid != 0 then
		local netdata = TK.RD.GetNetTable(entdata.netid)
		if !netdata.res[idx] then return 0 end
		return netdata.res[idx].cur
	else
		if !entdata.res[idx] then return 0 end
		return entdata.res[idx].cur
	end
end

function TK.RD.GetUnitResourceAmount(ent, idx)
	if !IsValid(ent) then return 0 end
	local entdata = TK.RD.GetEntTable(ent:EntIndex())
	if !entdata.res[idx] then return 0 end
	return entdata.res[idx].cur
end

function TK.RD.GetNetResourceCapacity(netid, idx)
	local netdata = TK.RD.GetNetTable(netid)
	if !netdata then return 0 end
	if !netdata.res[idx] then return 0 end
	return netdata.res[idx].max
end

function TK.RD.GetEntResourceCapacity(ent, idx)
	if !IsValid(ent) then return 0 end
	local entdata = TK.RD.GetEntTable(ent:EntIndex())
	if entdata.netid != 0 then
		local netdata = TK.RD.GetNetTable(entdata.netid)
		if !netdata.res[idx] then return 0 end
		return netdata.res[idx].max
	else
		if !entdata.res[idx] then return 0 end
		return entdata.res[idx].max
	end
end

function TK.RD.GetUnitResourceCapacity(ent, idx)
	if !IsValid(ent)then return 0 end
	local entdata = TK.RD.GetEntTable(ent:EntIndex())
	if !entdata.res[idx] then return 0 end
	return entdata.res[idx].max
end

function TK.RD.GetResources()
	local res = {}
	for k,v in pairs(res_table) do
		table.insert(res, k)
	end
	return res
end

function TK.RD.IsResource(str)
	return tobool(res_table[str])
end

function TK.RD.GetResourceName(idx)
	return res_table[idx] || idx
end