
TK.TD = TK.TD || {}

local Icons = {
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
	["relativistic centrifuge"] = Material("icon64/relativistic_centrifuge.png")
}

function TK.TD:GetIcon(str)
    return Icons[str] || Icons["default"]
end