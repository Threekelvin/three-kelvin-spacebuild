
///--- umsg Pool ---\\\
umsg.PoolString("3k_Secure")
umsg.PoolString("3k_terminal_refinery_start")
umsg.PoolString("3k_terminal_refinery_finish")
///--- ---\\\

///--- Resources ---\\\
local function storageToNode(ply, uid, arg)
	local Node, res, amt = Entity(tonumber(arg[1])), arg[2], tonumber(arg[3])
	if !IsValid(Node) || Node:CPPIGetOwner() != ply then return end
	if !Node.IsTKRD || !Node.IsNode then print("error", Node) return end
	if (Node:GetPos() - TK.TerminalPlanet.Pos):LengthSqr() > TK.TerminalPlanet.Size then return end
	local storage = TK.DB:GetPlayerData(ply, "terminal_storage")
	if !storage[res] then return end
	if storage[res] < amt then return end
	
	local amt = Node:SupplyResource(res, amt)
	if amt <= 0 then return end

	TK.DB:UpdatePlayerData(ply, "terminal_storage", {res, storage[res] - amt})
end

local function NodeTostorage(ply, uid, arg)
	local Node, res, amt = Entity(tonumber(arg[1])), arg[2], tonumber(arg[3])
	if !IsValid(Node) || Node:CPPIGetOwner() != ply then return end
	if !Node.IsTKRD || !Node.IsNode then return end
    if !table.HasValue(TerminalData.Resources, res) then return end
	if (Node:GetPos() - TK.TerminalPlanet.Pos):LengthSqr() > TK.TerminalPlanet.Size then return end
	local storage = TK.DB:GetPlayerData(ply, "terminal_storage")
	storage[res] = storage[res] || 0

	local amt = Node:ConsumeResource(res, amt)
	if amt <= 0 then return end
	
	TK.DB:UpdatePlayerData(ply, "terminal_storage", {res, math.floor(storage[res] + amt)})
end
///--- ---\\\

///--- Refinery ---\\\
local function StartRefine(ply, res)
	local storage, newstorage = TK.DB:GetPlayerData(ply, "terminal_storage"), {}
	local refinery, newrefinery = TK.DB:GetPlayerData(ply, "terminal_refinery"), {}
	local settings = TK.DB:GetPlayerData(ply, "terminal_setting")
	local newtime = 0
	
	for k,v in pairs(res) do
		if storage[k] then
			if storage[k] >= v then
				table.insert(newstorage, {k, storage[k] - v})
				table.insert(newrefinery, {k, refinery[k] + v})
				newtime = newtime + (v / TerminalData:Refine(ply, k))
			end
		end
	end
	
	if newtime > 0 then
		TK.DB:UpdatePlayerData(ply, "terminal_storage", unpack(newstorage))
		TK.DB:UpdatePlayerData(ply, "terminal_refinery", unpack(newrefinery))
		
		if settings.refine_length == 0 then
			newtime = math.floor(newtime)
			TK.DB:UpdatePlayerData(ply, "terminal_setting", {"refine_started", true}, {"refine_length", newtime})
		else
			newtime = math.floor(newtime + settings.refine_length)
			TK.DB:UpdatePlayerData(ply, "terminal_setting", {"refine_length", newtime})
		end
		
		umsg.Start("3k_terminal_refinery_start", ply)
			umsg.Bool(true)
		umsg.End()
	end
end

local function AutoRefine(ply)
	local storage, res = TK.DB:GetPlayerData(ply, "terminal_storage"), {}
	local settings = TK.DB:GetPlayerData(ply, "terminal_setting")
	
	if tobool(settings.auto_refine_ore) && storage["asteroid_ore"] then
		local amount = math.floor(600 * TerminalData:Refine(ply, "asteroid_ore"))
		if storage["asteroid_ore"] >= amount then
			res["asteroid_ore"] = amount
			return res
		end
	end
	
	if tib == 1 && storage["raw_tiberium"] then
		local amount = math.floor(600 * TerminalData:Refine(ply, "raw_tiberium"))
		if storage["raw_tiberium"] >= amount then
			res["raw_tiberium"] = amount
			return res
		end
	end

	return res
end

local function EndRefine(ply)
	local refinery, newrefinery = TK.DB:GetPlayerData(ply, "terminal_refinery"), {}
	local info = TK.DB:GetPlayerData(ply, "player_info")
	local score, credits = info.score, info.credits
	
	for k,v in pairs(refinery) do
		if v > 0 then
			local value = TerminalData:Ore(ply, k)
			table.insert(newrefinery, {k, 0})
			score = score + (v * value * 0.125)
			credits = credits + (v * value)
		end
	end

	if score > 0 then
		score = math.floor(score)
		credits = math.floor(credits)
		
		TK.DB:UpdatePlayerData(ply, "player_info", {"score", score}, {"credits", credits})
		
		local res = AutoRefine(ply)
		if table.Count(res) == 0 then
			TK.DB:UpdatePlayerData(ply, "terminal_refinery", unpack(newrefinery))
			TK.DB:UpdatePlayerData(ply, "terminal_setting", {"refine_started", 0}, {"refine_length", 0})
			umsg.Start("3k_terminal_refinery_finish", ply)
			umsg.End()
		else
			local storage, newstorage = TK.DB:GetPlayerData(ply, "terminal_storage"), {}
			local newtime = 0
			
			for k,v in pairs(res) do
				if storage[k] >= v then
					table.insert(newstorage, {k, storage[k] - v})
					table.insert(newrefinery, {k, v})
					newtime = newtime + (v / TerminalData:Refine(ply, k))
				end
			end
			
			TK.DB:UpdatePlayerData(ply, "terminal_storage", unpack(newstorage))
			TK.DB:UpdatePlayerData(ply, "terminal_refinery", unpack(newrefinery))
			TK.DB:UpdatePlayerData(ply, "terminal_setting", {"refine_started", true}, {"refine_length", newtime})
			
			umsg.Start("3k_terminal_refinery_start", ply)
				umsg.Bool(true)
			umsg.End()
		end

	end
end

hook.Add("Initialize", "TKRefinery", function()
	timer.Create("TKRefinery", 10, 0, function()
		for k,v in pairs(player.GetAll()) do
			local settings = TK.DB:GetPlayerData(v, "terminal_setting")
			local complete = settings.refine_started + settings.refine_length
			if complete > 0 then
				if TK.DB:OSTime() >= complete then
					EndRefine(v)
				end
			else
				local res = AutoRefine(v)
				if table.Count(res) != 0 then
					StartRefine(v, res)
				end
			end
		end
	end)
end)

local function Refine(ply, uid, arg)
	StartRefine(ply, {[arg[1]] = tonumber(arg[2])})
end

local function RefineAll(ply, uid, arg)
	local storage, res = TK.DB:GetPlayerData(ply, "terminal_storage"), {}
	res["asteroid_ore"] = storage["asteroid_ore"] || 0
	res["raw_tiberium"] = storage["raw_tiberium"] || 0
	
	StartRefine(ply, res)
end

local function CancelRefine(ply, uid, arg)
	local storage, newstorage = TK.DB:GetPlayerData(ply, "terminal_storage"), {}
	local refinery, newrefinery = TK.DB:GetPlayerData(ply, "terminal_refinery"), {}
	
	for k,v in pairs(refinery) do
		table.insert(newstorage, {k, storage[k] + v})
		table.insert(newrefinery, {k, 0})
	end

	TK.DB:UpdatePlayerData(ply, "terminal_storage", unpack(newstorage))
	TK.DB:UpdatePlayerData(ply, "terminal_refinery", unpack(newrefinery))
	TK.DB:UpdatePlayerData(ply, "terminal_setting", {"refine_started", 0}, {"refine_length", 0})
	
	umsg.Start("3k_terminal_refinery_start", ply)
		umsg.Bool(false)
	umsg.End()
end

local function ToggleAutoRefine(ply, uid, arg)
	local settings = TK.DB:GetPlayerData(ply, "terminal_setting")
	if arg[1] == "asteroid_ore" then
		TK.DB:UpdatePlayerData(ply, "terminal_setting", {"auto_refine_ore", !tobool(settings.auto_refine_ore) && 1 || 0})
	elseif arg[1] == "raw_tiberium" then
		TK.DB:UpdatePlayerData(ply, "terminal_setting", {"auto_refine_tib", !tobool(settings.auto_refine_tib) && 1 || 0})
	end
end
///--- ---\\\

///--- Market ---\\\

///--- ---\\\

///--- Research ---\\\
local function AddResearch(ply, uid, arg)
	local dir, idx = arg[1], arg[2]
	local upgrades = TK.DB:GetPlayerData(ply, "terminal_upgrades_".. dir)
	local data = TerminalData.ResearchData[dir][idx]
	local cost = TerminalData:ResearchCost(ply, dir, idx)
	local info = TK.DB:GetPlayerData(ply, "player_info")
	
	if cost == 0 || info.credits < cost then return end
	for k,v in pairs(data.req || {}) do
		if upgrades[v] != TerminalData.ResearchData[dir][v].maxlvl then
			return 
		end
	end


	TK.DB:UpdatePlayerData(ply, "terminal_upgrades_".. dir, {idx, upgrades[idx] + 1})
	TK.DB:UpdatePlayerData(ply, "player_info", {"credits", credits - cost})
	
	if dir == "ore" then
		TK:UpdateDeviceData(ply, 1)
	elseif dir == "tib" then
		TK:UpdateDeviceData(ply, 2)
	end
end
///--- ---\\\

///--- Terminal ConCommand ---\\\
local SecureInfo = {}

local function CanCall(ply)
	for k,v in pairs(ents.FindByClass("tk_terminal")) do
		if (ply:GetPos() - v:GetPos()):LengthSqr() < 22500 then
			return true
		end
	end
	return false
end

concommand.Add("3k_secure_ping", function(ply, cmd, arg)
	if !IsValid(ply) then return end 
	local uid = ply:GetNWString("UID")
	
	if !CanCall(ply) then ErrorNoHalt(ply:Name().." Can Not Call - "..cmd.." - "..table.concat(arg, " ").."\n") return end
	
	math.randomseed(SysTime())
	local one, two, three = math.random(-32767, 32767), math.random(-32767, 32767), math.random(-32767, 32767)
	SecureInfo[uid] = SecureInfo[uid] || {}
	table.insert(SecureInfo[uid], {util.CRC(one + two - three), arg[1] || ""})
	
	umsg.Start("3k_Secure", ply)
		umsg.Short(one)
		umsg.Long(two)
		umsg.Short(three)
	umsg.End()
end)

concommand.Add("3k_term", function(ply, cmd, arg)
	if !IsValid(ply) then return end
	local uid = ply:GetNWString("UID")
	local pass, command = arg[1], arg[2]
	
	if pass != SecureInfo[uid][1][1] then 
		ErrorNoHalt(ply:Name().." Bad Password - "..table.concat(arg, " ").."\n") 
		return
	end
	
	if command != SecureInfo[uid][1][2] then 
		ErrorNoHalt(ply:Name().." Bad Command - "..table.concat(arg, " ").."\n") 
		table.remove(SecureInfo[uid], 1)
		return 
	end
	
	table.remove(SecureInfo[uid], 1)
	if !CanCall(ply) then 
		ErrorNoHalt(ply:Name().." Can Not Call - "..cmd.." - "..table.concat(arg, " ").."\n") 
		return 
	end
	
	table.remove(arg, 2)
	table.remove(arg, 1)
	
	if command == "storagetonode" then
		storageToNode(ply, uid, arg)
	elseif command == "nodetostorage" then
		NodeTostorage(ply, uid, arg)
	elseif command == "refine" then
		Refine(ply, uid, arg)
	elseif command == "refineall" then
		RefineAll(ply, uid, arg)
	elseif command == "cancelrefine" then
		CancelRefine(ply, uid, arg)
	elseif command == "toggleautorefine" then
		ToggleAutoRefine(ply, uid, arg)
	elseif command == "addresearch" then
		AddResearch(ply, uid, arg)
	elseif command == "acceptapp" then
		AcceptApp(ply, uid, arg)
	elseif command == "rejectapp" then
		RejectApp(ply, uid, arg)
	elseif command == "getmembers" then
		GetMembers(ply, uid, arg)
	else
		ErrorNoHalt(ply:Name().." ["..ply:SteamID().."] used unknown command: "..command.."    args: "..table.concat(arg, " ").."\n")
	end
end)
///--- ---\\\