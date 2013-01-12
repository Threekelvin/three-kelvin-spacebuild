
TK.DB = TK.DB || {}

function TK.DB:MakePlayerData()
	local data = {}
	data.player_info = {
		name = "",
		playtime = 0,
		rank = 1,
		score = 0,
		credits = 0,
        exp = 0,
		email = ""
	}
	data.player_team = {
		team = 1,
		team_rank = 1,
		joined = 0,
		team1_points = 0,
		team2_points = 0,
		team3_points = 0,
		team4_points = 0
	}
    data.player_loadout = {
        mining_1_item = 0,
        mining_1_locked = 0,
        mining_2_item = 0,
        mining_2_locked = 1,
        mining_3_item = 0,
        mining_3_locked = 1,
        mining_4_item = 0,
        mining_4_locked = 1,
        mining_5_item = 0,
        mining_5_locked = 1,
        mining_6_item = 0,
        mining_6_locked = 1,
        storage_1_item = 0,
        storage_1_locked = 0,
        storage_2_item = 0,
        storage_2_locked = 1,
        storage_3_item = 0,
        storage_3_locked = 1,
        storage_4_item = 0,
        storage_4_locked = 1,
        storage_5_item = 0,
        storage_5_locked = 1,
        storage_6_item = 0,
        storage_6_locked = 1,
        weapon_1_item = 0,
        weapon_1_locked = 0,
        weapon_2_item = 0,
        weapon_2_locked = 1,
        weapon_3_item = 0,
        weapon_3_locked = 1,
        weapon_4_item = 0,
        weapon_4_locked = 1,
        weapon_5_item = 0,
        weapon_5_locked = 1,
        weapon_6_item = 0,
        weapon_6_locked = 1
    }
    data.player_inventory = {
        inventory = {}
    }
	data.terminal_setting = {
		auto_refine_ore = 0,
		auto_refine_tib = 0,
		refine_started = 0,
		refine_length = 0
	}
	data.terminal_storage = {
		oxygen = 0,
		carbon_dioxide = 0,
		nitrogen = 0,
		liquid_nitrogen = 0,
		hydrogen = 0,
		water = 0,
		asteroid_ore = 0,
		raw_tiberium = 0
	}
	data.terminal_refinery = {
		asteroid_ore = 0,
		raw_tiberium = 0
	}
	data.terminal_upgrades_ore = {
		r1 = 0,
		r2 = 0,
		r3 = 0,
		r4 = 0,
		r5 = 0,
		r6 = 0,
		r7 = 0,
		r8 = 0,
		r9 = 0,
		r10 = 0,
		r11 = 0,
		r12 = 0
	}
	data.terminal_upgrades_tib = {
		r1 = 0,
		r2 = 0,
		r3 = 0,
		r4 = 0,
		r5 = 0,
		r6 = 0,
		r7 = 0,
		r8 = 0,
		r9 = 0
	}
	data.terminal_upgrades_ref = {
		r1 = 0,
		r2 = 0,
		r3 = 0,
		r4 = 0,
		r5 = 0,
		r6 = 0,
		r7 = 0,
		r8 = 0,
		r9 = 0
	}
	
	return data
end