TK.TD = TK.TD || {}

function TK.TD:ResearchCost(ply, dir, idx)
	if !IsValid(ply) then return 0 end
	local upgrades = TK.DB:GetPlayerData(ply, "terminal_upgrades_".. dir)
	local lvl = upgrades[idx] + 1
	local data = TK.TD.ResearchData[dir][idx]
	if lvl > data.maxlvl then 
		return 0
	else
		return math.Round(data.cost[1] * data.cost[2] * lvl)
	end
end

function TK.TD:Ore(ply, res)
	if !IsValid(ply) then return 0 end
	local upgrades = TK.DB:GetPlayerData(ply, "terminal_upgrades_ref")
	
	if res == "asteroid_ore" then
		return 1 + (1 * ((upgrades.r1 * 5) + (upgrades.r4 * 10) + (upgrades.r7 * 15)) / 100)
	elseif res == "raw_tiberium" then
		return 15 + (15 * ((upgrades.r3 * 10) + (upgrades.r8 * 5) + (upgrades.r9 * 15)) / 100)
	end
	return 0
end

function TK.TD:Refine(ply, res)
	if !IsValid(ply) then return 0 end
	local upgrades = TK.DB:GetPlayerData(ply, "terminal_upgrades_ref")
	
	if res == "asteroid_ore" then
		return 100 + (100 * ((upgrades.r2 * 5) + (upgrades.r4 * 5) + (upgrades.r5 * 10) + (upgrades.r8 * 10)) / 100)
	elseif res == "raw_tiberium" then
		return 10 + (10 * ((upgrades.r3 * 5) + (upgrades.r5 * 10) + (upgrades.r6 * 10) + (upgrades.r7 * 5)) / 100)
	end
	return 0
end