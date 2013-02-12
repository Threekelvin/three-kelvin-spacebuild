
local table = table

TK.DB = TK.DB || {}

local Queries = {
	create = {
		server_ban_data = [[CREATE TABLE IF NOT EXISTS 
		server_ban_data(
			idx INT PRIMARY KEY AUTO_INCREMENT,
            ply_steamid VARCHAR(20),
            ply_ip VARCHAR(40),
            ban_start INT NOT NULL,
            ban_lenght INT NOT NULL,
            ban_reason LONGTEXT,
            ban_lifted BIT DEFAULT 0,
            adm_steamid VARCHAR(20),
            adm_ip VARCHAR(40)
		)]],
		
		server_globalchat = [[CREATE TABLE IF NOT EXISTS
		server_globalchat(
			msg_idx INT PRIMARY KEY AUTO_INCREMENT,
			msg_conection_id INT DEFAULT 0,
			msg_key TINYINT DEFAULT 0,
			msg_origin VARCHAR(127),
			msg_recipient VARCHAR(127),
			msg_flag TINYINT DEFAULT 0,
			msg_data LONGBLOB,
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
            captcha VARCHAR(]]..TK.DB.CaptchaLength..[[),
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
		
		terminal_upgrades = [[CREATE TABLE IF NOT EXISTS
		terminal_upgrades(
			steamid VARCHAR(20) NOT NULL PRIMARY KEY,
			ingan_gain_medium TINYINT DEFAULT 0,
			min_parallax_colli TINYINT DEFAULT 0,
			beam_waist_reduc TINYINT DEFAULT 0,
			uhv_flash_lamp TINYINT DEFAULT 0,
			passive_cooling TINYINT DEFAULT 0,
			quantum_pump_timing TINYINT DEFAULT 0,
			unity_reflector TINYINT DEFAULT 0,
			kers TINYINT DEFAULT 0,
			gain_medium_compress TINYINT DEFAULT 0,
			binary_pack_algor TINYINT DEFAULT 0,
			cnf_structure TINYINT DEFAULT 0,
			relative_dim_stabil TINYINT DEFAULT 0,
            doppler_offset_detun TINYINT DEFAULT 0,
            shock_echo_shield TINYINT DEFAULT 0,
            active_feed_analysis TINYINT DEFAULT 0,
            inc_sig_amp TINYINT DEFAULT 0,
            adv_reverb_mapping TINYINT DEFAULT 0,
            adpat_echo_cancel TINYINT DEFAULT 0,
            tib_liquidation TINYINT DEFAULT 0,
            graded_rad_shield TINYINT DEFAULT 0,
            inter_tib_storage TINYINT DEFAULT 0,
            blast_furnace TINYINT DEFAULT 0,
            nano_hopper TINYINT DEFAULT 0,
            non_static_heads TINYINT DEFAULT 0,
            arc_furnace TINYINT DEFAULT 0,
            mag_conveyor TINYINT DEFAULT 0,
            sonic_pulse_macer TINYINT DEFAULT 0,
            plasma_tor_furnace TINYINT DEFAULT 0,
            relativ_centrifuge TINYINT DEFAULT 0,
            bec_casting TINYINT DEFAULT 0
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
		terminal_upgrades = true,
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
		terminal_upgrades = true,
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
		terminal_upgrades = true,
	},
    
    json = {
        player_inventory = {"inventory"}
    },
    
    dont_sync = {
        captcha = true
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

function TK.DB:DontSync(idx)
    return table.HasValue(Queries.dont_sync, idx)
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
	if !values || table.Count(values) == 0 then return end
	
	local query_idx = {"INSERT INTO ", dbtable, "("}
	local query_values = {"VALUES("}
	for idx,data in pairs(values) do
		table.insert(query_idx, StopInjection(idx, true))
		table.insert(query_idx, ", ")
		
		table.insert(query_values, StopInjection(data))
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
	if !values || table.Count(values) == 0 then
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
	if !values || table.Count(values) == 0 then return end
	if !where || #where == 0 then return end

	
	local query = {"UPDATE ", dbtable, " SET "}
	for idx,data in pairs(values) do
		table.insert(query, StopInjection(idx, true) .." = ".. StopInjection(ShouldJson(dbtable, idx) && util.TableToJSON(data) || data))
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