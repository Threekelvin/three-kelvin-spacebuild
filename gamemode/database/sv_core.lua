
require("mysqloo")

TK.DB = TK.DB || {}

local MySQL = {}
local PlayerData = {}

///--- MySql Settings ---\\\
MySQL.SQLSettings = {
	Host = "127.0.0.1",
	Port = 3306,
	Name = "threekelvin",
	Username = "gmod_dev",
	Password = "zKKZ8KSHCmx4Rzve"
}

MySQL.DataBase = nil
MySQL.ConnectionID = 0
MySQL.OSTime = 0
MySQL.Connected = false
MySQL.Running = false
MySQL.PriorityCache = {}
MySQL.Cache = {}
MySQL.NextConnect = CurTime() + 60
///--- ---\\\

util.AddNetworkString( "HUD_WARNING" )
function MySQL.Msg(msg)
	print(msg)
	net.Start( "HUD_WARNING" )
		net.WriteString( "database" )
		net.WriteString( MySQL.Connected && "" || "No database connection" )
	net.Broadcast()
end

function MySQL.NetworkValue(ply, idx, data)
	if idx == "name" then
		ply:SetNWString("TKName", data)
	elseif idx == "playtime" then
		ply:SetNWInt("TKPlaytime", tonumber(data))
	elseif idx == "score" then
		ply:SetNWInt("TKScore", tonumber(data))
	elseif idx == "rank" then
		TK.AM:SetRank(ply, tonumber(data))
	elseif idx == "team" then
		ply:SetTeam(tonumber(data))
	end
end

function MySQL.Setup()
	MySQL.MakePriorityQuery("SELECT CONNECTION_ID()", function(Data)
		MySQL.ConnectionID = tonumber(Data[1]["CONNECTION_ID()"])
	end)
	
	MySQL.MakePriorityQuery("SELECT UNIX_TIMESTAMP()", function(Data)
		local time = tonumber(Data[1]["UNIX_TIMESTAMP()"])
		MySQL.OSTime = os.time() - time
		net.Start("DB_Time")
			net.WriteInt(time, 32)
		net.Broadcast()
	end)

    for k,v in pairs(TK.DB:GetCreateQueries()) do
        MySQL.MakePriorityQuery(v)
    end
end

function MySQL.ProcessQuery(data)
	if mysqloo then
		local query = MySQL.DataBase:query(data[1])
		if !query then return false end
		query:start()
		MySQL.Running = true
		
		query.onFailure = function(msg)
			MySQL.Running = false
			MySQL.Msg("Failure - "..msg)
			query = nil
			data = nil				
		end
		query.onError = function(query, msg)
			MySQL.Running = false
			MySQL.Msg("Error - "..msg)
			
			if msg == "MySQL server has gone away" then
				MySQL.Connected = false
				pcall(MySQL.MakePriorityQuery, data[1], data[2], unpack(data[3]))
			end
			query = nil
			data = nil
		end
		query.onSuccess = function()
			MySQL.Running = false
			if data[2] then
				pcall(data[2], query:getData(), unpack(data[3]))
			end
			query = nil
			data = nil
		end
		return true
	elseif tmysql then
		MySQL.Running = true
		tmysql.query(data[1], function(result, status, msg)
			MySQL.Running = false
			if status == QUERY_SUCCESS then
				pcall(data[2], result, unpack(data[3]))
			else
				if string.sub(msg, 1, 22) == "Can't connect to MySQL" then
					MySQL.Connected = false
					pcall(MySQL.MakePriorityQuery, data[1], data[2], unpack(data[3]))
				else
					MySQL.Msg("Error - "..msg)
				end
			end
			data = nil
		end, QUERY_FLAG_ASSOC)
		return true
	end
	return false
end

function MySQL.MakePriorityQuery(str, func, ...)
	table.insert(MySQL.PriorityCache,  {str, func, {...}})
end

function TK.DB:MakeQuery(str, func, ...)
	table.insert(MySQL.Cache, {str, func, {...}})
end

///--- Client Sync System ---\\\
util.AddNetworkString("DB_Sync")
util.AddNetworkString("DB_Time")
util.AddNetworkString("player_info")
util.AddNetworkString("player_team")
util.AddNetworkString("player_loadout")
util.AddNetworkString("player_inventory")
util.AddNetworkString("terminal_setting")
util.AddNetworkString("terminal_storage")
util.AddNetworkString("terminal_refinery")
util.AddNetworkString("terminal_upgrades")

function TK.DB:GetPlayerData(ply, dbtable)
	if !IsValid(ply) then return end
	
	return PlayerData[ply.uid][dbtable] || {}
end

function TK.DB:SetPlayerData(ply, dbtable, content)
	if !IsValid(ply) then return end
    
	PlayerData[ply.uid][dbtable] = PlayerData[ply.uid][dbtable] || {}
	local data = PlayerData[ply.uid][dbtable]

	for k,v in pairs(content) do
		if data[k] == v then continue end
        net.Start("DB_Sync")
            net.WriteString(dbtable)
            net.WriteString(k)
            
            local typ = type(v)
            if typ == "number" then
                net.WriteInt(1, 4)
                net.WriteFloat(tonumber(v))
            elseif typ == "string" then
                net.WriteInt(2, 4)
                net.WriteString(tostring(v))
            elseif typ == "table" then
                net.WriteInt(3, 4)
                net.WriteTable(v)
            end
        net.Send(ply)
        
        MySQL.NetworkValue(ply, k, v)
        
        data[k] = v
        
        gamemode.Call("TKDBPlayerData", ply, dbtable, k, v)
	end
end
///--- ---\\\

///--- Update ---\\\
function TK.DB:UpdatePlayerData(ply, dbtable, update)
	if !IsValid(ply) then return end

	TK.DB:MakeQuery(TK.DB:FormatUpdateQuery(dbtable, update, {"steamid = %s", ply:SteamID()}))
	
	local data = {}
	for k,v in pairs(update) do
		if type(v) == "boolean" then
			data[k] = TK.DB:OSTime()
		else
			data[k] = v
		end
	end
	
	TK.DB:SetPlayerData(ply, dbtable, data)
end
///--- ---\\\

function TK.DB:IsConnected()
	return tobool(MySQL.Connected)
end

///--- OSTime ---\\\
function TK.DB:OSTime()
	return os.time() - MySQL.OSTime
end
///--- ---\\\

///--- Load Player Data ---\\\
function MySQL.LoadPlayerData(ply, steamid, ip, uid)
	MySQL.MakePriorityQuery(TK.DB:FormatSelectQuery("player_record", {"ip"}, {"steamid = %s", steamid}), function(exists, ply, steamid, ip, uid)
		if !IsValid(ply) then return end
		if exists[1] then
			if exists[1].ip != ip then TK.DB:MakeQuery(TK.DB:FormatUpdateQuery("player_record", {ip = ip}, {"steamid = %s", steamid})) end
		else
			MySQL.MakePriorityQuery(TK.DB:FormatInsertQuery("player_record", {steamid = steamid, ip = ip, uniqueid = uid}))
			MySQL.MakePriorityQuery(TK.DB:FormatInsertQuery("player_info", {steamid = steamid, name = ply:Name()}))
			MySQL.MakePriorityQuery(TK.DB:FormatInsertQuery("player_team", {steamid = steamid}))
            MySQL.MakePriorityQuery(TK.DB:FormatInsertQuery("player_loadout", {steamid = steamid}))
            MySQL.MakePriorityQuery(TK.DB:FormatInsertQuery("player_inventory", {steamid = steamid, inventory = util.TableToJSON({1, 2, 3, 4})}))
			MySQL.MakePriorityQuery(TK.DB:FormatInsertQuery("terminal_setting", {steamid = steamid}))
			MySQL.MakePriorityQuery(TK.DB:FormatInsertQuery("terminal_storage", {steamid = steamid}))
			MySQL.MakePriorityQuery(TK.DB:FormatInsertQuery("terminal_refinery", {steamid = steamid}))
			MySQL.MakePriorityQuery(TK.DB:FormatInsertQuery("terminal_upgrades", {steamid = steamid}))
		end
		
		MySQL.MakePriorityQuery(TK.DB:FormatSelectQuery("player_info", {}, {"steamid = %s", steamid}), function(data, ply, uid)
			data[1].steamid = nil
			TK.DB:SetPlayerData(ply, "player_info", data[1])
		end, ply, uid)
		
		MySQL.MakePriorityQuery(TK.DB:FormatSelectQuery("player_team", {}, {"steamid = %s", steamid}), function(data, ply, uid)
			data[1].steamid = nil
			TK.DB:SetPlayerData(ply, "player_team", data[1])
		end, ply, uid)
        
        MySQL.MakePriorityQuery(TK.DB:FormatSelectQuery("player_loadout", {}, {"steamid = %s", steamid}), function(data, ply, uid)
			data[1].steamid = nil
			TK.DB:SetPlayerData(ply, "player_loadout", data[1])
		end, ply, uid)
        
        MySQL.MakePriorityQuery(TK.DB:FormatSelectQuery("player_inventory", {}, {"steamid = %s", steamid}), function(data, ply, uid)
			data[1].steamid = nil
            data[1].inventory = util.JSONToTable(data[1].inventory)
			TK.DB:SetPlayerData(ply, "player_inventory", data[1])
		end, ply, uid)
		
		MySQL.MakePriorityQuery(TK.DB:FormatSelectQuery("terminal_setting", {}, {"steamid = %s", steamid}), function(data, ply, uid)
			data[1].steamid = nil
			TK.DB:SetPlayerData(ply, "terminal_setting", data[1])
		end, ply, uid)
		
		MySQL.MakePriorityQuery(TK.DB:FormatSelectQuery("terminal_storage", {}, {"steamid = %s", steamid}), function(data, ply, uid)
			data[1].steamid = nil
			TK.DB:SetPlayerData(ply, "terminal_storage", data[1])
		end, ply, uid)
		
		MySQL.MakePriorityQuery(TK.DB:FormatSelectQuery("terminal_refinery", {}, {"steamid = %s", steamid}), function(data, ply, uid)
			data[1].steamid = nil
			TK.DB:SetPlayerData(ply, "terminal_refinery", data[1])
		end, ply, uid)
		
		MySQL.MakePriorityQuery(TK.DB:FormatSelectQuery("terminal_upgrades", {}, {"steamid = %s", steamid}), function(data, ply, uid)
			data[1].steamid = nil
			TK.DB:SetPlayerData(ply, "terminal_upgrades", data[1])
		end, ply, uid)
	end, ply, steamid, ip, uid)
end
///--- ---\\\

///--- Hooks ---\\\
hook.Add("Tick", "MySQLQuery", function()
	if MySQL.Running || (#MySQL.PriorityCache == 0 && #MySQL.Cache == 0) then return end
	
	if MySQL.Connected then
		if #MySQL.PriorityCache != 0 then
			local query = MySQL.PriorityCache[1]
			if MySQL.ProcessQuery(query) then
				table.remove(MySQL.PriorityCache, 1)
			else
				MySQL.Connected = false
			end
		elseif #MySQL.Cache != 0 then
			local query = MySQL.Cache[1]
			if MySQL.ProcessQuery(query) then
				table.remove(MySQL.Cache, 1)
			else
				MySQL.Connected = false
			end
		else
			MySQL.Msg("Query System Error")
		end
	elseif CurTime() >= MySQL.NextConnect then
		MySQL.NextConnect = CurTime() + 60
		if mysqloo then
			local status = MySQL.DataBase:status()
			if status == 0 then
				MySQL.Connected = true
			elseif status != 1 then
				MySQL.DataBase:connect()
			end
		elseif tmysql then
			tmysql.query("SELECT CONNECTION_ID()", function(result, status, msg)
				MySQL.Running = false
				if status == QUERY_SUCCESS then
					MySQL.Connected = true
					print("-------------------")
					MySQL.Msg("Database Connected")
					print("-------------------")
				end
			end, QUERY_FLAG_ASSOC)
		end
	end
end)
	
hook.Add("Initialize", "MySQLLoad", function()
	timer.Create("TK.DB_Stats_Update", 60, 0, function()
		for _,ply in pairs(player.GetAll()) do
			local data = TK.DB:GetPlayerData(ply, "player_info")
            local update = {playtime = data.playtime + 1}
            
            for k,v in pairs(ply.tk_cache) do
                update[k] = data[k] + v
                ply.tk_cache[k] = nil
            end
			TK.DB:UpdatePlayerData(ply, "player_info", update)
		end
	end)
    
    function GAMEMODE:TKDBPlayerData(ply, dbtable, idx, data)
    end
end)

hook.Add("InitPostEntity", "MySQLLoad", function()
	if mysqloo then
		print("-------------------")
		print("mysqloo Connecting")
		print("-------------------")
		MySQL.DataBase = mysqloo.connect(MySQL.SQLSettings.Host, MySQL.SQLSettings.Username, MySQL.SQLSettings.Password, MySQL.SQLSettings.Name, MySQL.SQLSettings.Port)
		MySQL.DataBase:connect()
		MySQL.DataBase.onConnected = function()
			print("-------------------")
			MySQL.Msg("Database Connected")
			print("-------------------")
			
			if !MySQL.Connected then
				MySQL.Connected = true
			end
			
			MySQL.Setup()
			
		end
		MySQL.DataBase.onConnectionFailed = function(dbobj, msg)
			print("-------------------")
			MySQL.Msg(msg)
			print("-------------------")
		end
	elseif tmysql then
		print("-------------------")
		print("tmysql Connecting")
		print("-------------------")
		if tmysql.initialize(MySQL.SQLSettings.Host, MySQL.SQLSettings.Username, MySQL.SQLSettings.Password, MySQL.SQLSettings.Name, MySQL.SQLSettings.Port) then
			print("-------------------")
			MySQL.Msg("Database Connected")
			print("-------------------")
			
			if !MySQL.Connected then
				MySQL.Connected = true
			end
			
			MySQL.Setup()
		end
	end
end)

hook.Add("PlayerAuthed", "TKLoadPlayer", function(ply, steamid, uid)
	local ip = TK.AM:GetIP(ply)
	ply.uid = uid
    ply.tk_cache = {}
	
	PlayerData[uid] = TK.DB:MakePlayerData()
    
    ply:SetNWString("TKName", ply:Name())
	ply:SetNWInt("TKPlaytime", 0)
    ply:SetNWInt("TKScore", 0)

	MySQL.MakePriorityQuery(TK.DB:FormatSelectQuery("server_ban_data", {"idx"}, {"steamid = %s OR ip = %s LIMIT 1", steamid, ip}), function(data, ply, steamid, uid, ip)
		if !IsValid(ply) then return end
		if !data[1] then
			MySQL.Msg("[TK] Loading Player Data - ".. ply:Name() .." - ".. steamid)
			MySQL.LoadPlayerData(ply, steamid, ip, uid)
		else
			MySQL.Msg("[TK] Banned Player Attempted  To Join - ".. ply:Name() .. " - ".. steamid)
			game.ConsoleCommand("banid 5 " .. steamid .. "\n")
			game.ConsoleCommand("kickid " .. steamid .. " You are Banned from this server!\n")
		end
	end, ply, steamid, uid, ip)
end)

hook.Add("PlayerDisconnected", "TKDisUpdate", function(ply)
	if !IsValid(ply) then return end
    local data = TK.DB:GetPlayerData(ply, "player_info")
    local update = {}
    for k,v in pairs(ply.tk_cache) do
        table.insert(update, {k, data[k] + v})
    end
    
    TK.DB:MakeQuery(TK.DB:FormatUpdateQuery("player_info", update, {"steamid = %s", ply:SteamID()}))
	
	PlayerData[ply:GetNWString("UID")] = nil
end)
///--- ---\\\