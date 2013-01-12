
TK.DB = TK.DB || {}

local Queries = {
	create = {
		server_ban_data = [[CREATE TABLE IF NOT EXISTS 
		server_ban_data(
			idx INT PRIMARY KEY AUTO_INCREMENT,
			steamid VARCHAR(20),
			ip VARCHAR(40),
			name VARCHAR(127),
			start_time INT NOT NULL,
			ban_length INT,
			reason LONGTEXT,
			admin_name VARCHAR(127),
			admin_steamid VARCHAR(20),
			admin_ip VARCHAR(40),
			removed TINYINT DEFAULT 0,
			remove_time INT,
			remove_reason LONGTEXT,
			remove_admin_name VARCHAR(127),
			remove_admin_steamid VARCHAR(20),
			remove_admin_ip VARCHAR(40)
		)]],
		
		server_globalchat = [[CREATE TABLE IF NOT EXISTS
		server_globalchat(
			msg_idx INT PRIMARY KEY AUTO_INCREMENT,
			msg_created INT,
			msg_conection_id INT DEFAULT 0,
			msg_key TINYINT DEFAULT 0,
			msg_origin VARCHAR(127),
			msg_recipient VARCHAR(127),
			msg_flag TINYINT DEFAULT 0,
			msg_data VARCHAR(127),
			sender_rank TINYINT DEFAULT 1,
			sender_faction TINYINT DEFAULT 1,
			sender_name VARCHAR(127)
		)]],
		
		player_record = [[CREATE TABLE IF NOT EXISTS
		player_record(
			steamid VARCHAR(20) NOT NULL PRIMARY KEY,
			ip VARCHAR(40) NOT NULL,
			uniqueid VARCHAR(10) NOT NULL
		)]],
		
		player_info = [[CREATE TABLE IF NOT EXISTS
		player_info(
			steamid VARCHAR(20) NOT NULL PRIMARY KEY,
			name VARCHAR(127) NOT NULL,
			playtime INT DEFAULT 0,
			rank TINYINT DEFAULT 1,
			score FLOAT DEFAULT 0,
			credits FLOAT DEFAULT 0,
            exp FLOAT DEFAULT 0,
			email LONGTEXT
		)]],
		
		player_team = [[CREATE TABLE IF NOT EXISTS
		player_team(
			steamid VARCHAR(20) NOT NULL PRIMARY KEY,
			team TINYINT DEFAULT 1,
			team_rank TINYINT DEFAULT 1,
			joined INT DEFAULT 0,
			team1_points FLOAT DEFAULT 0,
			team2_points FLOAT DEFAULT 0,
			team3_points FLOAT DEFAULT 0,
			team4_points FLOAT DEFAULT 0
		)]],

        player_loadout = [[CREATE TABLE IF NOT EXISTS
        player_loadout(
            steamid VARCHAR(20) NOT NULL PRIMARY KEY,
            mining_1_item INT DEFAULT 0,
            mining_1_locked TINYINT DEFAULT 0,
            mining_2_item INT DEFAULT 0,
            mining_2_locked TINYINT DEFAULT 1,
            mining_3_item INT DEFAULT 0,
            mining_3_locked TINYINT DEFAULT 1,
            mining_4_item INT DEFAULT 0,
            mining_4_locked TINYINT DEFAULT 1,
            mining_5_item INT DEFAULT 0,
            mining_5_locked TINYINT DEFAULT 1,
            mining_6_item INT DEFAULT 0,
            mining_6_locked TINYINT DEFAULT 1,
            storage_1_item INT DEFAULT 0,
            storage_1_locked TINYINT DEFAULT 0,
            storage_2_item INT DEFAULT 0,
            storage_2_locked TINYINT DEFAULT 1,
            storage_3_item INT DEFAULT 0,
            storage_3_locked TINYINT DEFAULT 1,
            storage_4_item INT DEFAULT 0,
            storage_4_locked TINYINT DEFAULT 1,
            storage_5_item INT DEFAULT 0,
            storage_5_locked TINYINT DEFAULT 1,
            storage_6_item INT DEFAULT 0,
            storage_6_locked TINYINT DEFAULT 1,
            weapon_1_item INT DEFAULT 0,
            weapon_1_locked TINYINT DEFAULT 0,
            weapon_2_item INT DEFAULT 0,
            weapon_2_locked TINYINT DEFAULT 1,
            weapon_3_item INT DEFAULT 0,
            weapon_3_locked TINYINT DEFAULT 1,
            weapon_4_item INT DEFAULT 0,
            weapon_4_locked TINYINT DEFAULT 1,
            weapon_5_item INT DEFAULT 0,
            weapon_5_locked TINYINT DEFAULT 1,
            weapon_6_item INT DEFAULT 0,
            weapon_6_locked TINYINT DEFAULT 1
        )]],
        
        player_inventory = [[CREATE TABLE IF NOT EXISTS
        player_inventory(
            steamid VARCHAR(20) NOT NULL PRIMARY KEY,
            inventory LONGBLOB NOT NULL
        )]],
        
		player_donation = [[CREATE TABLE IF NOT EXISTS
		player_donation(
			idx INT PRIMARY KEY AUTO_INCREMENT,
			steamid VARCHAR(20) NOT NULL,
			time INT NOT NULL,
			amount INT
		)]],
		
		terminal_setting = [[CREATE TABLE IF NOT EXISTS
		terminal_setting(
			steamid VARCHAR(20) NOT NULL PRIMARY KEY,
			auto_refine_ore TINYINT DEFAULT 0,
			auto_refine_tib TINYINT DEFAULT 0,
			refine_started INT DEFAULT 0,
			refine_length INT DEFAULT 0
		)]],
		
		terminal_storage = [[CREATE TABLE IF NOT EXISTS
		terminal_storage(
			steamid VARCHAR(20) NOT NULL PRIMARY KEY,
			oxygen INT DEFAULT 0,
			carbon_dioxide INT DEFAULT 0,
			nitrogen INT DEFAULT 0,
			liquid_nitrogen INT DEFAULT 0,
			hydrogen INT DEFAULT 0,
			water INT DEFAULT 0,
			asteroid_ore INT DEFAULT 0,
			raw_tiberium INT DEFAULT 0
		)]],
		
		terminal_refinery = [[CREATE TABLE IF NOT EXISTS
		terminal_refinery(
			steamid VARCHAR(20) NOT NULL PRIMARY KEY,
			asteroid_ore INT DEFAULT 0,
			raw_tiberium INT DEFAULT 0
		)]],
		
		terminal_upgrades_ore = [[CREATE TABLE IF NOT EXISTS
		terminal_upgrades_ore(
			steamid VARCHAR(20) NOT NULL PRIMARY KEY,
			r1 TINYINT DEFAULT 0,
			r2 TINYINT DEFAULT 0,
			r3 TINYINT DEFAULT 0,
			r4 TINYINT DEFAULT 0,
			r5 TINYINT DEFAULT 0,
			r6 TINYINT DEFAULT 0,
			r7 TINYINT DEFAULT 0,
			r8 TINYINT DEFAULT 0,
			r9 TINYINT DEFAULT 0,
			r10 TINYINT DEFAULT 0,
			r11 TINYINT DEFAULT 0,
			r12 TINYINT DEFAULT 0
		)]],
		
		terminal_upgrades_tib = [[CREATE TABLE IF NOT EXISTS
		terminal_upgrades_tib(
			steamid VARCHAR(20) NOT NULL PRIMARY KEY,
			r1 TINYINT DEFAULT 0,
			r2 TINYINT DEFAULT 0,
			r3 TINYINT DEFAULT 0,
			r4 TINYINT DEFAULT 0,
			r5 TINYINT DEFAULT 0,
			r6 TINYINT DEFAULT 0,
			r7 TINYINT DEFAULT 0,
			r8 TINYINT DEFAULT 0,
			r9 TINYINT DEFAULT 0
		)]],
		
		terminal_upgrades_ref = [[CREATE TABLE IF NOT EXISTS
		terminal_upgrades_ref(
			steamid VARCHAR(20) NOT NULL PRIMARY KEY,
			r1 TINYINT DEFAULT 0,
			r2 TINYINT DEFAULT 0,
			r3 TINYINT DEFAULT 0,
			r4 TINYINT DEFAULT 0,
			r5 TINYINT DEFAULT 0,
			r6 TINYINT DEFAULT 0,
			r7 TINYINT DEFAULT 0,
			r8 TINYINT DEFAULT 0,
			r9 TINYINT DEFAULT 0
		)]]
	},
	
	insert = {
		server_ban_data = true,
		server_globalchat = true,
		player_record = true,
		player_info = true,
		player_team = true,
        player_loadout = true,
        player_inventory = true,
		terminal_setting = true,
		terminal_storage = true,
		terminal_refinery = true,
		terminal_upgrades_ore = true,
		terminal_upgrades_tib = true,
		terminal_upgrades_ref = true
	},
	
	select = {
		server_ban_data = true,
		server_globalchat = true,
		player_record = true,
		player_info = true,
		player_team = true,
        player_loadout = true,
        player_inventory = true,
		terminal_setting = true,
		terminal_storage = true,
		terminal_refinery = true,
		terminal_upgrades_ore = true,
		terminal_upgrades_tib = true,
		terminal_upgrades_ref = true
	},
	
	update = {
		server_ban_data = true,
		player_record = true,
		player_info = true,
		player_team = true,
        player_loadout = true,
        player_inventory = true,
		terminal_setting = true,
		terminal_storage = true,
		terminal_refinery = true,
		terminal_upgrades_ore = true,
		terminal_upgrades_tib = true,
		terminal_upgrades_ref = true
	},
    
    json = {
        player_inventory = {"inventory"}
    }
}

local function StopInjection(data, noquotes)
	if data == nil then return "" end
	
	if data == true then
		data = "UNIX_TIMESTAMP()"
	elseif data == false then
		data = "CONNECTION_ID()"
	elseif type(data) == "number" then
		data = SQLStr(data, true)
	else
		data = SQLStr(data, noquotes && true || false)
	end
	
	return data
end

local function ShouldJson(dbtable, index)
    if !Queries.json[dbtable] then return false end
    if !Queries.json[dbtable][index] then return false end
    return true
end

function TK.DB:GetCreateQueries()
	local data = {}
	for k,v in pairs(Queries.create) do
		table.insert(data, v)
	end
	return data
end

function TK.DB:FormatInsertQuery(dbtable, values)
	if !Queries.insert[dbtable] then return end
	if !values || #values == 0 then return end
	
	local query_idx = {"INSERT INTO ", dbtable, "("}
	local query_values = {"VALUES("}
	for _,data in pairs(values) do
		table.insert(query_idx, StopInjection(data[1], true))
		table.insert(query_idx, ", ")
		
		table.insert(query_values, StopInjection(data[2]))
		table.insert(query_values, ", ")
	end
	
	query_idx[#query_idx] = ") "
	query_values[#query_values] = ")"
	return table.concat(query_idx, "") .. table.concat(query_values, "")
end

function TK.DB:FormatSelectQuery(dbtable, values, where, order)
	if !Queries.insert[dbtable] then return end
	if !where || #where == 0 then return end
	
	local query = {"SELECT "}
	if !values || #values == 0 then
		table.insert(query, "*")
		table.insert(query, ", ")
	else
		for _,data in pairs(values) do
			table.insert(query, StopInjection(data, true))
			table.insert(query, ", ")
		end
	end
	
	query[#query] = " FROM ".. dbtable .."  WHERE "
	local str = where[1]
	table.remove(where, 1)
	for k,v in pairs(where) do
		where[k] = StopInjection(v)
	end
	table.insert(query, string.format(str, unpack(where)))
	
	if order then
		table.insert(query, " ORDER BY ")
		for _,data in pairs(order) do
			table.insert(query, StopInjection(data, true))
			table.insert(query, ", ")
		end
		query[#query] = nil
	end
	
	return table.concat(query, "")
end

function TK.DB:FormatUpdateQuery(dbtable, values, where)
	if !Queries.update[dbtable] then return end
	if !values || #values == 0 then return end
	if !where || #where == 0 then return end

	
	local query = {"UPDATE ", dbtable, " SET "}
	for _,data in pairs(values) do
		table.insert(query, StopInjection(data[1], true) .." = ".. StopInjection(ShouldJson(dbtable, data[1]) && util.TableToJSON(data[2]) || data[2]))
		table.insert(query, ", ")
	end
	
	query[#query] = " WHERE "
	local str = where[1]
	table.remove(where, 1)
	for k,v in pairs(where) do
		where[k] = StopInjection(v)
	end
	table.insert(query, string.format(str, unpack(where)))
	table.insert(query, " LIMIT 1")
	return table.concat(query, "")
end