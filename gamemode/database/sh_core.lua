
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
		captcha = "",
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
	data.terminal_upgrades = {
		ingan_gain_medium = 0,
		min_parallax_colli = 0,
		beam_waist_reduc = 0,
		uhv_flash_lamp = 0,
		passive_cooling = 0,
		quantum_pump_timing = 0,
		unity_reflector = 0,
		kers = 0,
		gain_medium_compress = 0,
		binary_pack_algor = 0,
		cnf_structure = 0,
		relative_dim_stabil = 0,
		doppler_offset_detun = 0,
		shock_echo_shield = 0,
		active_feed_analysis = 0,
		inc_sig_amp = 0,
		adv_reverb_mapping = 0,
		adpat_echo_cancel = 0,
		tib_liquidation = 0,
		graded_rad_shield = 0,
		inter_tib_storage = 0,
		blast_furnace = 0,
		nano_hopper = 0,
		non_static_heads = 0,
		arc_furnace = 0,
		mag_conveyor = 0,
		sonic_pulse_macer = 0,
		plasma_tor_furnace = 0,
		relativ_centrifuge = 0,
		bec_casting = 0
	}
	
	return data
end