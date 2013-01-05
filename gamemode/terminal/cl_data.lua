TerminalData = TerminalData || {}

function TerminalData:ResearchCost(dir, idx)
	local upgrades = TK.DB:GetPlayerData("terminal_upgrades_".. dir)
	local lvl = upgrades[idx] + 1
	local data = TerminalData.ResearchData[dir][idx].cost
	return math.Round(data[1] * data[2] * lvl)
end

function TerminalData:Ore(res)
	local upgrades = TK.DB:GetPlayerData("terminal_upgrades_ref")
	
	if res == "asteroid_ore" then
		return 1 + (1 * ((upgrades.r1 * 5) + (upgrades.r4 * 10) + (upgrades.r7 * 15)) / 100)
	elseif res == "raw_tiberium" then
		return 15 + (15 * ((upgrades.r3 * 10) + (upgrades.r8 * 5) + (upgrades.r9 * 15)) / 100)
	end
	return 0
end

function TerminalData:Refine(res)
	local upgrades = TK.DB:GetPlayerData("terminal_upgrades_ref")
	
	if res == "asteroid_ore" then
		return 100 + (100 * ((upgrades.r2 * 5) + (upgrades.r4 * 5) + (upgrades.r5 * 10) + (upgrades.r8 * 10)) / 100)
	elseif res == "raw_tiberium" then
		return 10 + (10 * ((upgrades.r3 * 5) + (upgrades.r5 * 10) + (upgrades.r6 * 10) + (upgrades.r7 * 5)) / 100)
	end
	return 0
end

TerminalData.Icons = {
	["default"] = Material("icon64/default.png"),
	["energy"] = Material("icon64/energy.png"),
	["water"] = Material("icon64/water.png"),
	["steam"] = Material("icon64/steam.png"),
	["oxygen"] = Material("icon64/oxygen.png"),
	["hydrogen"] = Material("icon64/hydrogen.png"),
	["nitrogen"] = Material("icon64/nitrogen.png"),
	["liquid_nitrogen"] = Material("icon64/nitrogen.png"),
	["heavy_water"] = Material("icon64/heavy_water.png"),
	["carbon_dioxide"] = Material("icon64/carbon_dioxide.png"),
	["asteroid_ore"] = Material("icon64/asteroid_ore.png"),
	["raw_tiberium"] = Material("icon64/raw_tiberium.png"),
	["arc furnace"] = Material("icon64/arc_furnace.png"),
	["blast furnace"] = Material("icon64/blast_furnace.png"),
	["machine heads"] = Material("icon64/machine_heads.png"),
	["magnetic conveyor"] = Material("icon64/magnetic_conveyor.png"),
	["nanofiber hopper"] = Material("icon64/nanofiber_hopper.png"),
	["plasma furnace"] = Material("icon64/plasma_furnace.png"),
	["relativistic centrifuge"] = Material("icon64/relativistic_centrifuge.png"),
}