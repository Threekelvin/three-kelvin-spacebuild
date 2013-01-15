
TK.TD = TK.TD || {}

local Upgrades = {
    ingan_gain_medium = {
        name = "InGaN Gain Medium",
        category = "asteroid",
        bonus = "+5% Mining Yield",
        data = {yield = 0.05},
        maxlvl = 5,
        cost = 1,
        pos = {1, 1}
    },
    min_parallax_colli = {
        name = "Minimum Parallax Collimator",
        category = "asteroid",
        bonus = "+1% Maximum Mining Range\n+5% Mining Yield",
        data = {range = 0.01, yield = 0.05},
        maxlvl = 5,
        cost = 1,
        pos = {1, 2}
    },
    beam_waist_reduc = {
        name = "Beam Waist Reduction",
        category = "asteroid",
        bonus = "+10% Mining Yield\n+1% Energy Efficiency",
        data = {yield = 0.1, power = 0.01},
        maxlvl = 5,
        cost = 1,
        pos = {1, 3}
    },
    uhv_flash_lamp = {
        name = "Ultra High Voltage Flash Lamp",
        category = "asteroid",
        bonus = "+0.5% Maximum Mining Range\n+5% Mining Yield",
        data = {range = 0.005, yield = 0.05},
        maxlvl = 5,
        cost = 1,
        pos = {2, 1},
        req = {"ingan_gain_medium", "min_parallax_colli"}
    },
    passive_cooling = {
        name = "Passive Cooling",
        category = "asteroid",
        bonus = "+1% Energy Efficiency ",
        data = {power = 0.01},
        maxlvl = 5,
        cost = 1,
        pos = {2, 2},
        req = {"min_parallax_colli", "beam_waist_reduc"}
    },
    quantum_pump_timing = {
        name = "Quantum Pump Timing",
        category = "asteroid",
        bonus = "+0.5%Maximum Mining Range\n+0.5% Energy Efficiency",
        data = {range = 0.005, power = 0.005},
        maxlvl = 5,
        cost = 1,
        pos = {2, 3},
        req = {"min_parallax_colli", "beam_waist_reduc"}
    },
    unity_reflector = {
        name = "Unity Reflector",
        category = "asteroid",
        bonus = "+0.5% Maximum Mining Range\n+10% Mining Yield",
        data = {range = 0.005, yield = 0.1},
        maxlvl = 5,
        cost = 1,
        pos = {3, 1},
        req = {"uhv_flash_lamp", "passive_cooling"}
    },
    kers = {
        name = "K.E.R.S",
        category = "asteroid",
        bonus = "+0.15% Energy Efficiency",
        data = {power = 0.015},
        maxlvl = 5,
        cost = 1,
        pos = {3, 2},
        req = {"passive_cooling"}
    },
    gain_medium_compress = {
        name = "Gain Medium Compression",
        category = "asteroid",
        bonus = "+1% Maximum Mining Range\n+15% Mining Yield\n+0.1% Energy Efficiency",
        data = {range = 0.01, yield = 0.15, power = 0.001},
        maxlvl = 5,
        cost = 1,
        pos = {3, 3},
        req = {"passive_cooling", "quantum_pump_timing"}
    },
    binary_pack_algor = {
        name = "Binary Packing Algorithm",
        category = "asteroid",
        bonus = "+15% Storage Capacity",
        data = {capacity = 0.15},
        maxlvl = 5,
        cost = 1,
        pos = {1, 4},
    },
    cnf_structure = {
        name = "Carbon Nanofiber Structure",
        category = "asteroid",
        bonus = "+15% Storage Capacity",
        data = {capacity = 0.15},
        maxlvl = 5,
        cost = 1,
        pos = {2, 4},
        req = {"binary_pack_algor"}
    },
    relative_dim_stabil = {
        name = "Relative Dimensional Stabilizer",
        category = "asteroid",
        bonus = "+20% Storage Capacity",
        data = {capacity = 0.2},
        maxlvl = 5,
        cost = 1,
        pos = {3, 4},
        req = {"cnf_structure", "quantum_pump_timing"}
    },
    doppler_offset_detun = {
        name = "Doppler Offset Detuning",
        category = "tiberium",
        bonus = "+10% Mining Yield",
        data = {yield = 0.1},
        maxlvl = 5,
        cost = 1,
        pos = {1, 1},
    },
    shock_echo_shield = {
        name = "Shockwave Echo Shielding",
        category = "tiberium",
        bonus = "+5% Mining Yield\n+1% Energy Efficiency",
        data = {yield = 0.05, power = 0.01},
        maxlvl = 5,
        cost = 1,
        pos = {1, 2},
    },
    active_feed_analysis = {
        name = "Active Feedback Analysis",
        category = "tiberium",
        bonus = "+1% Energy Efficiency",
        data = {power = 0.1},
        maxlvl = 5,
        cost = 1,
        pos = {2, 1},
        req = {"doppler_offset_detun", "shock_echo_shield"}
    },
    inc_sig_amp = {
        name = "Increased Signal Amplification",
        category = "tiberium",
        bonus = "+10% Mining Yield",
        data = {yield = 0.1},
        maxlvl = 5,
        cost = 1,
        pos = {2, 2},
        req = {"doppler_offset_detun", "shock_echo_shield"}
    },
    adv_reverb_mapping = {
        name = "Adv Reverberation Mapping",
        category = "tiberium",
        bonus = "+25% Mining Yield",
        data = {yield = 0.25},
        maxlvl = 5,
        cost = 1,
        pos = {3, 1},
        req = {"active_feed_analysis", "inc_sig_amp"}
    },
    adpat_echo_cancel = {
        name = "Adaptive Echo Cancellation",
        category = "tiberium",
        bonus = "+1% Energy Efficiency",
        data = {power = 0.01},
        maxlvl = 5,
        cost = 1,
        pos = {3, 2},
        req = {"inc_sig_amp"}
    },
    tib_liquidation = {
        name = "Tiberium Liquidation",
        category = "tiberium",
        bonus = "+15% Storage Capacity",
        data = {capacity = 0.15},
        maxlvl = 5,
        cost = 1,
        pos = {1, 3},
    },
    graded_rad_shield = {
        name = "Graded-Z Radiation Shielding",
        category = "tiberium",
        bonus = "+15% Storage Capacity",
        data = {capacity = 0.15},
        maxlvl = 5,
        cost = 1,
        pos = {2, 3},
        req = {"shock_echo_shield", "tib_liquidation"}
    },
    inter_tib_storage = {
        name = "Intermodel Tiberium Storage",
        category = "tiberium",
        bonus = "+20% Storage Capacity",
        data = {capacity = 0.2},
        maxlvl = 5,
        cost = 1,
        pos = {3, 3},
        req = {"graded_rad_shield"}
    },
    blast_furnace = {
        name = "Blast Furnace",
        category = "refinery",
        bonus = "+5% Credits Per Asteroid Ore",
        data = {cpore = 0.05},
        maxlvl = 5,
        cost = 1,
        pos = {1, 1},
        icon = "blast furnace"
    },
    nano_hopper = {
        name = "Nanofiber Hopper",
        category = "refinery",
        bonus = "+5% Asteroid Ore Refining Speed",
        data = {orers = 0.05},
        maxlvl = 5,
        cost = 1,
        pos = {1, 2},
        icon = "nanofiber hopper"
    },
    non_static_heads = {
        name = "Non-Static Machine Heads",
        category = "refinery",
        bonus = "+10% Credits Per Raw Tiberium\n+5% Raw Tiberium Refining Speed",
        data = {cptib = 0.1, tibrs = 0.05},
        maxlvl = 5,
        cost = 1,
        pos = {1, 3},
        icon = "machine heads"
    },
    arc_furnace = {
        name = "Arc Furnace",
        category = "refinery",
        bonus = "+10% Credits Per Asteroid Ore\n+5% Asteroid Ore Refining Speed",
        data = {cpore = 0.1, orers = 0.05},
        maxlvl = 5,
        cost = 1,
        pos = {2, 1},
        req = {"blast_furnace", "nano_hopper"},
        icon = "arc furnace"
    },
    mag_conveyor = {
        name = "Magnetic Conveyor",
        category = "refinery",
        bonus = "+10% Asteroid Ore Refining Speed\n+10% Raw Tiberium Refining Speed",
        data = {orers = 0.1, tibrs = 0.1},
        maxlvl = 5,
        cost = 1,
        pos = {2, 2},
        req = {"nano_hopper"},
        icon = "magnetic conveyor"
    },
    sonic_pulse_macer = {
        name = "Sonic Pulse Macerator",
        category = "refinery",
        bonus = "+10% Raw Tiberium Refining Speed",
        data = {tibrs = 0.1},
        maxlvl = 5,
        cost = 1,
        pos = {2, 3},
        req = {"non_static_heads"},
        --icon = ""
    },
    plasma_tor_furnace = {
        name = "Plasma Toroid Furnace",
        category = "refinery",
        bonus = "+15% Credits Per Asteroid Ore\n+5% Raw Tiberium Refining Speed",
        data = {cpore = 0.15, tibrs = 0.05},
        maxlvl = 5,
        cost = 1,
        pos = {3, 1},
        req = {"arc_furnace", "mag_conveyor"},
        icon = "plasma furnace"
    },
    relativ_centrifuge = {
        name = "Relativistic Centrifuge",
        category = "refinery",
        bonus = "+10% Asteroid Ore Refining Speed\n+5% Credits Per Raw Tiberium",
        data = {orers = 0.1, cptib = 0.05},
        maxlvl = 5,
        cost = 1,
        pos = {3, 2},
        req = {"mag_conveyor", "sonic_pulse_macer"},
        icon = "relativistic centrifuge"
    },
    bec_casting = {
        name = "BEC Casting",
        category = "refinery",
        bonus = "+15% Credits Per Raw Tiberium",
        data = {cptib = 0.15},
        maxlvl = 5,
        cost = 1,
        pos = {3, 3},
        req = {"sonic_pulse_macer"},
        --icon = ""
    }
}

function TK.TD:GetUpgradeCat(str)
    local upgrades = {}
    for k,v in pairs(Upgrades) do
        if v.category != str then continue end
        upgrades[k] = v
    end
    
    return upgrades
end

function TK.TD:GetUpgrade(str)
    return Upgrades[str] || {}
end

if SERVER then
    function TK.TD:GetUpgradeStats(ply, str)
        local upgrades = TK.DB:GetPlayerData(ply, "terminal_upgrades")
        local stats = {}
        
        for id,up in pairs(self:GetUpgradeCat(str)) do
            for k,v in pairs(up.data) do
                stats[k] = (stats[k] || 0) + v * upgrades[id]
            end
        end
        
        return stats
    end
else
    function TK.TD:GetUpgradeStats(str)
        local upgrades = TK.DB:GetPlayerData("terminal_upgrades")
        local stats = {}
        
        for id,up in pairs(self:GetUpgradeCat(str)) do
            for k,v in pairs(up.data) do
                stats[k] = (stats[k] || 0) + v * upgrades[id]
            end
        end
        
        return stats
    end
end