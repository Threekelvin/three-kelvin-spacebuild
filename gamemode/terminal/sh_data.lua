TerminalData = TerminalData || {}

TerminalData.Resources = {"asteroid_ore", "raw_tiberium", "oxygen", "nitrogen", "carbon_dioxide", "hydrogen", "water", "liquid_nitrogen"}

TerminalData.ResearchData = {
	["ore"] = {
		["r1"] = {
			name = "InGaN Gain Medium",
			bonus = "+5% Mining Yield",
			maxlvl = 100,
			cost = {10000, 1.2},
			pos = {1, 1}
		},
		["r2"] = {
			name = "Minimum Parallax Collimator",
			bonus = "+1% Maximum Mining Range\n+5% Mining Yield",
			maxlvl = 100,
			cost = {10000, 1.2},
			pos = {1, 2}
		},
		["r3"] = {
			name = "Beam Waist Reduction",
			bonus = "+10% Mining Yield\n+0.05% Energy Efficiency",
			maxlvl = 100,
			cost = {10000, 1.2},
			pos = {1, 3}
		},
		["r4"] = {
			name = "Ultra High Voltage Flash Lamp",
			bonus = "+0.5% Maximum Mining Range\n+5% Mining Yield",
			maxlvl = 100,
			cost = {1212000, 1.2},
			pos = {2, 1},
			req = {"r1", "r2"}
		},
		["r5"] = {
			name = "Passive Cooling",
			bonus = "+0.1% Energy Efficiency ",
			maxlvl = 100,
			cost = {1212000, 1.2},
			pos = {2, 2},
			req = {"r2"}
		},
		["r6"] = {
			name = "Quantum Pump Timing",
			bonus = "+0.5%Maximum Mining Range\n+0.05% Energy Efficiency",
			maxlvl = 100,
			cost = {1212000, 1.2},
			pos = {2, 3},
			req = {"r2", "r3"}
		},
		["r7"] = {
			name = "Unity Reflector",
			bonus = "+0.5% Maximum Mining Range\n+10% Mining Yield",
			maxlvl = 100,
			cost = {146894400, 1.2},
			pos = {3, 1},
			req = {"r4"}
		},
		["r8"] = {
			name = "K.E.R.S",
			bonus = "+0.15% Energy Efficiency",
			maxlvl = 100,
			cost = {146894400, 1.2},
			pos = {3, 2},
			req = {"r5"}
		},
		["r9"] = {
			name = "Gain Medium Compression",
			bonus = "+1% Maximum Mining Range\n+15% Mining Yield\n+0.05% Energy Efficiency",
			maxlvl = 100,
			cost = {146894400, 1.2},
			pos = {3, 3},
			req = {"r5", "r6"}
		},
		["r10"] = {
			name = "Binary Packing Algorithm",
			bonus = "+15% Storage Capacity",
			maxlvl = 100,
			cost = {10000, 1.2},
			pos = {1, 4},
		},
		["r11"] = {
			name = "Carbon Nanofiber Structure",
			bonus = "+15% Storage Capacity",
			maxlvl = 100,
			cost = {1212000, 1.2},
			pos = {2, 4},
			req = {"r10"}
		},
		["r12"] = {
			name = "Relative Dimensional Stabilizer",
			bonus = "+20% Storage Capacity",
			maxlvl = 100,
			cost = {146894400, 1.2},
			pos = {3, 4},
			req = {"r11", "r6"}
		}
	},
	["tib"] = {
		["r1"] = {
			name = "Doppler Offset Detuning",
			bonus = "+10% Mining Yield",
			maxlvl = 100,
			cost ={10000, 1.2},
			pos = {1, 1},
		},
		["r2"] = {
			name = "Shockwave Echo Shielding",
			bonus = "+5% Mining Yield\n+0.1% Energy Efficiency",
			maxlvl = 100,
			cost ={10000, 1.2},
			pos = {1, 2},
		},
		["r3"] = {
			name = "Active Feedback Analysis",
			bonus = "+0.1% Energy Efficiency",
			maxlvl = 100,
			cost = {1212000, 1.2},
			pos = {2, 1},
			req = {"r1"}
		},
		["r4"] = {
			name = "Increased Signal Amplification",
			bonus = "+10% Mining Yield",
			maxlvl = 100,
			cost = {1212000, 1.2},
			pos = {2, 2},
			req = {"r1", "r2"}
		},
		["r5"] = {
			name = "Adv Reverberation Mapping",
			bonus = "+25% Mining Yield",
			maxlvl = 100,
			cost = {146894400, 1.2},
			pos = {3, 1},
			req = {"r3", "r4"}
		},
		["r6"] = {
			name = "Adaptive Echo Cancellation",
			bonus = "+0.1% Energy Efficiency",
			maxlvl = 100,
			cost = {146894400, 1.2},
			pos = {3, 2},
			req = {"r4"}
		},
		["r7"] = {
			name = "Tiberium Liquidation",
			bonus = "+15% Storage Capacity",
			maxlvl = 100,
			cost ={10000, 1.2},
			pos = {1, 3},
		},
		["r8"] = {
			name = "Graded-Z Radiation Shielding",
			bonus = "+15% Storage Capacity",
			maxlvl = 100,
			cost ={1212000, 1.2},
			pos = {2, 3},
			req = {"r2", "r7"}
		},
		["r9"] = {
			name = "Intermodel Tiberium Storage",
			bonus = "+20% Storage Capacity",
			maxlvl = 100,
			cost ={146894400, 1.2},
			pos = {3, 3},
			req = {"r8"}
		}
	},
	["ref"] = {
		["r1"] = {
			name = "Blast Furnace",
			bonus = "+5% Credits Per Ore",
			maxlvl = 100,
			cost = {10000, 1.2},
			pos = {1, 1},
			icon = "blast furnace"
		},
		["r2"] = {
			name = "Nanofiber Hopper",
			bonus = "+5% Ore Refining Speed",
			maxlvl = 100,
			cost = {10000, 1.2},
			pos = {1, 2},
			icon = "nanofiber hopper"
		},
		["r3"] = {
			name = "Non-Static Machine Heads",
			bonus = "+10% Credits Per Tiberium\n+5% Tiberium Refining Speed",
			maxlvl = 100,
			cost = {10000, 1.2},
			pos = {1, 3},
			icon = "machine heads"
		},
		["r4"] = {
			name = "Arc Furnace",
			bonus = "+10% Credits per Ore\n+5% Ore Refining Speed",
			maxlvl = 100,
			cost = {1212000, 1.2},
			pos = {2, 1},
			req = {"r1", "r2"},
			icon = "arc furnace"
		},
		["r5"] = {
			name = "Magnetic Conveyor",
			bonus = "+10% Ore Refining Speed\n+10% Tiberium Refining Speed",
			maxlvl = 100,
			cost = {1212000, 1.2},
			pos = {2, 2},
			req = {"r2"},
			icon = "magnetic conveyor"
		},
		["r6"] = {
			name = "Sonic Pulse Macerator",
			bonus = "+10% Tiberium Refining Speed",
			maxlvl = 100,
			cost = {1212000, 1.2},
			pos = {2, 3},
			req = {"r3"},
			--icon = ""
		},
		["r7"] = {
			name = "Plasma Toroid Furnace",
			bonus = "+15% Credits per Ore\n+5% Tiberium Refining Speed",
			maxlvl = 100,
			cost = {146894400, 1.2},
			pos = {3, 1},
			req = {"r4", "r5"},
			icon = "plasma furnace"
		},
		["r8"] = {
			name = "Relativistic Centrifuge",
			bonus = "+10% Ore Refining Speed\n+5% Credits per Tiberium",
			maxlvl = 100,
			cost = {146894400, 1.2},
			pos = {3, 2},
			req = {"r5", "r6"},
			icon = "relativistic centrifuge"
		},
		["r9"] = {
			name = "BEC Casting",
			bonus = "+15% Credits per Tib",
			maxlvl = 100,
			cost = {146894400, 1.2},
			pos = {3, 3},
			req = {"r6"},
			--icon = ""
		}
	}
}