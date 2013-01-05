
TK.AT = {}
TK.AT.NextUpdate = 0
TK.AT.IsSpacebuild = false

local Suns = {}
local Stars = {}
local Ships = {}
local Planets = {}
local MapData
local Space

local function LoadMapData()
	local map = game.GetMap()
	if !file.Exists("TKSB/Atmospheres/"..map..".txt", "DATA") then return end
	MapData = util.KeyValuesToTable(file.Read("TKSB/Atmospheres/"..map..".txt")) || {}
end

local function RegisterSpace()
	print("------ Registering Space ------")
	Space = ents.Create("at_space")
	Space:SetPos(Vector(0,0,0))
	Space:Spawn()
	print(Space, "Created")
	print("-------------------------------")
end

local function DecodeKeyValues(values)
	local cat, data = "none", {}
	if values.Case01 == "planet" then
		cat = "planet"
		data["radius"] = tonumber(values.Case02)
		data["gravity"] = tonumber(values.Case03)
		data["tempcold"] = tonumber(values.Case05)
		data["temphot"] = tonumber(values.Case06)
		data["oxygen"] = 20
		data["carbon_dioxide"] = 5
		data["nitrogen"] = 70
		data["hydrogen"] = 5
		data["name"] = "Planet"
		data["flags"] = tonumber(values.Case16)
		data["sphere"] = 1
		data["static"] = 0
		data["noclip"] = 1
	elseif values.Case01 == "planet2" then
		cat = "planet"
		data["radius"] = tonumber(values.Case02)
		data["gravity"] = tonumber(values.Case03)
		data["tempcold"] = tonumber(values.Case06)
		data["temphot"] = tonumber(values.Case07)
		data["oxygen"] = tonumber(values.Case09)
		data["carbon_dioxide"] = tonumber(values.Case10)
		data["nitrogen"] = tonumber(values.Case11)
		data["hydrogen"] = tonumber(values.Case12)
		data["name"] = values.Case13
		data["flags"] = tonumber(values.Case08)
		data["sphere"] = 1
		data["static"] = 0
		data["noclip"] = 1
	elseif values.Case01 == "cube" then
		cat = "planet"
		data["radius"] = tonumber(values.Case02)
		data["gravity"] = tonumber(values.Case03)
		data["tempcold"] = tonumber(values.Case06)
		data["temphot"] = tonumber(values.Case07)
		data["oxygen"] = tonumber(values.Case09)
		data["carbon_dioxide"] = tonumber(values.Case10)
		data["nitrogen"] = tonumber(values.Case11)
		data["hydrogen"] = tonumber(values.Case12)
		data["name"] = values.Case13
		data["flags"] = tonumber(values.Case08)
		data["sphere"] = 0
		data["static"] = 0
		data["noclip"] = 1
	elseif values.Case01 == "star" then
		cat = "star"
		data["radius"] = tonumber(values.Case02)
		data["tempcold"] = 1000
		data["temphot"] = 1000
		data["name"] = "Star"
		data["noclip"] = 0
	elseif values.Case01 == "star2" then
		cat = "star"
		data["radius"] = tonumber(values.Case02)
		data["tempcold"] = tonumber(values.Case03)
		data["temphot"] = tonumber(values.Case04)
		data["name"] = values.Case06
		data["noclip"] = 0
	end
	
	return cat, data
end

local function RegisterAtmospheres()
	print("--- Registering Atmospheres ---")
	if MapData then
		print("------ Loading From File ------")
		for k,v in pairs(MapData) do
			if v.cat == "planet" then
				local planet = ents.Create("at_planet")
				planet:SetPos(Vector(v.x, v.y, v.z))
				planet:Spawn()
				planet:SetAtomsphere(v.data)
				print(planet, "Created")
				TK.AT.IsSpacebuild = true
			elseif v.cat == "star" then
				local star = ents.Create("at_star")
				star:SetPos(Vector(v.x, v.y, v.z))
				star:Spawn()
				star:SetAtomsphere(v.data)
				print(star, "Created")
				TK.AT.IsSpacebuild = true
				table.insert(Suns, Vector(v.x, v.y, v.z))
			end
		end
	else
		print("------- Loading From Map ------")
		MapData = {}
		
		for _,ent in pairs(ents.FindByClass("logic_case")) do
			local cat, data = DecodeKeyValues(ent:GetKeyValues())	
			local pos = ent:GetPos()
			
			if cat == "planet" then
				local planet = ents.Create("at_planet")
				planet:SetPos(pos)
				planet:Spawn()
				planet:SetAtomsphere(data)
				print(planet, "Created")
				TK.AT.IsSpacebuild = true
				
				table.insert(MapData, {cat = "planet", x = pos.x, y = pos.y, z = pos.z, data = data})
			elseif cat == "star" then
				local star = ents.Create("at_star")
				star:SetPos(pos)
				star:Spawn()
				star:SetAtomsphere(data)
				print(star, "Created")
				TK.AT.IsSpacebuild = true
				table.insert(Suns, pos)
				table.insert(MapData, {cat = "star", x = pos.x, y = pos.y, z = pos.z, data = data})
			end
		end
		
		file.Write("TKSB/Atmospheres/"..game.GetMap()..".txt", util.TableToKeyValues(MapData))
	end
	print("-------------------------------")
end

local function RegisterSuns()
	print("------- Registering Suns ------")
	for k,v in ipairs(ents.FindByClass("env_sun")) do
		if IsValid(v) then
			table.insert(Suns, v:GetPos())
			print(v, "Found")
		end
	end
	
	if #Suns == 0 then
		table.insert(Suns, Vector(0,0,50000))
		print("No Sun Found, Default Added")
	end
	print("-------------------------------")
end

local function HEVSound(ply, idx, amt)
	if !IsValid(ply) || !ply:Alive() then return end
	if ply.hev.sound > CurTime() then return end
	ply.hev.sound = CurTime() + 10
	umsg.Start("TKAT_HEV", ply)
		umsg.Char(idx)
		umsg.Short(math.Clamp(amt || 0, 0, 32767))
	umsg.End()
end

local function EnvPrioritySort(a, b)
	if a.atmosphere.priority == b.atmosphere.priority then
		return a.atmosphere.radius < b.atmosphere.radius
	end
	return a.atmosphere.priority < b.atmosphere.priority
end

function TK.AT.GetSpace()
	return Space
end

function TK.AT.GetPlanets()
	return Planets
end

function TK.AT.GetShips()
	return Ships
end

function TK.AT.GetStars()
	return Stars
end

function TK.AT.GetSuns()
	return Suns
end

function TK.AT.GetAtmosphereOnPos(pos)
	local env = Space
	for k,v in pairs(Stars) do
		if IsValid(v) then
			if EnvPrioritySort(v, env) && v:InAtmosphere(pos) then
				env = v
			end
		end
	end
	
	for k,v in pairs(Ships) do
		if IsValid(v) then
			if EnvPrioritySort(v, env) && v:InAtmosphere(pos) then
				env = v
			end
		end
	end
	
	for k,v in pairs(Planets) do
		if IsValid(v) then
			if EnvPrioritySort(v, env) && v:InAtmosphere(pos) then
				env = v
			end
		end
	end
	
	return env
end

hook.Add("Initialize", "TK.AT", function()
	GAMEMODE.OnAtmosphereChange = function()
	end
	
	local CleanUpMap = game.CleanUpMap
	function game.CleanUpMap(bool, filters)
		filters = filters || {}
		table.insert(filters, "at_space")
		table.insert(filters, "at_planet")
		table.insert(filters, "at_star")
		CleanUpMap(bool, filters)
	end
	
	local Spawn = _R.Entity.Spawn
	function _R.Entity:Spawn()
		Spawn(self)
		if !self:GetPhysicsObject():IsValid() then return end
		if self:GetClass() == "at_brush" then return end
		self.auenv = {}
		self.auenv.envlist = {Space}
		self.auenv.gravity = -1
		self:GetEnv():DoGravity(self)
	end
	
	function _R.Entity:GetEnv()
		return self.auenv.envlist[1] || Space
	end
	
	function _R.Player:AddhevRes(res, amt)
		if res == "energy" then
			self.hev.energy = math.min(self.hev.energy + amt, self.hev.energymax)
		elseif res == "water" then
			self.hev.water = math.min(self.hev.water + amt, self.hev.watermax)
		elseif res == "oxygen" then
			self.hev.oxygen = math.min(self.hev.oxygen + amt, self.hev.oxygenmax)
		end
	end
end)

hook.Add("InitPostEntity", "TK.AT", function()
	print("---- TK Atmospheres Loading ---")
	LoadMapData()	
	RegisterSpace()
	RegisterAtmospheres()
	RegisterSuns()
	print("---- TK Atmospheres Loaded ----")
	
	if !TK.AT.IsSpacebuild then
		print("------ Not Spacebuild Map -----")
		hook.Remove("EntitySpawned", "TK.AT")
		hook.Remove("PlayerInitialSpawn", "TK.AT")
		hook.Remove("PlayerSpawn", "TK.AT")
		hook.Remove("PlayerNoClip", "TK.AT")
		hook.Remove("SetupMove", "TK.AT")
		hook.Remove("EntityTakeDamage", "TK.AT")
		print("--- TK Atmospheres Disabled ---")
	end
end)

hook.Add("PlayerInitialSpawn", "TK.AT", function(ply)
	ply.auenv = {}
	ply.auenv.envlist = {Space}
	ply.auenv.gravity = -1
	ply:GetEnv():DoGravity(ply)
end)

hook.Add("EntitySpawned", "TK.AT", function(ent)
	local class = ent:GetClass()
	if class == "at_planet" then
		table.insert(Planets, ent)
	elseif class == "at_star" then
		table.insert(Stars, ent)
	elseif class == "at_atmosphere_regulator" then
		table.insert(Ships, ent)
	end
end)