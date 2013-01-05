AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

local CurTime = CurTime
local IsValid = IsValid
local pairs = pairs
local table = table
local math = math

local function Extract_Bit(bit, field)
	if not bit or not field then return false end
	local retval = 0
	if ((field <= 7) and (bit <= 4)) then
		if (field >= 4) then
			field = field - 4
			if (bit == 4) then return true end
		end
		if (field >= 2) then
			field = field - 2
			if (bit == 2) then return true end
		end
		if (field >= 1) then
			field = field - 1
			if (bit == 1) then return true end
		end
	end
	return false
end

local function EnvPrioritySort(a, b)
	if a.atmosphere.priority == b.atmosphere.priority then
		return a.atmosphere.radius < b.atmosphere.radius
	end
	return a.atmosphere.priority < b.atmosphere.priority
end

function ENT:Initialize()
	self:DefaultAtmosphere()
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
	self:PhysicsSetup()
	
	self.outside = {}
	self.inside = {}
end

function ENT:StartTouch(ent)
	if !ent.auenv then return end
	if self.atmosphere.sphere then
		if (ent:GetPos() - self:GetPos()):LengthSqr() <= self.atmosphere.radius * self.atmosphere.radius then
			self.inside[ent:EntIndex()] = ent
			
			local oldenv = ent:GetEnv()
			table.insert(ent.auenv.envlist, self)
			table.sort(ent.auenv.envlist, EnvPrioritySort)
			local newenv = ent:GetEnv()
			
			if oldenv != newenv then
				newenv:DoGravity(ent)
				gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
			end
		else
			self.outside[ent:EntIndex()] = ent
		end
	else
		self.inside[ent:EntIndex()] = ent
		
		local oldenv = ent:GetEnv()
		table.insert(ent.auenv.envlist, self.auenv.ship)
		table.sort(ent.auenv.envlist, EnvPrioritySort)
		local newenv = ent:GetEnv()
		
		if oldenv != newenv then
			newenv:DoGravity(ent)
			gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
		end
	end
end

function ENT:EndTouch(ent)
	if !ent.auenv then return end
	local entid = ent:EntIndex()
	
	if self.inside[entid] == ent then
		local oldenv = ent:GetEnv()
		for k,v in pairs(ent.auenv.envlist) do
			if v == self then
				table.remove(ent.auenv.envlist, k)
				break
			end
		end
		local newenv = ent:GetEnv()
		
		if oldenv != newenv then
			newenv:DoGravity(ent)
			gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
		end
	end
	
	self.outside[entid] = nil
	self.inside[entid] = nil
end

function ENT:Think()
	if self.atmosphere.sphere then
		local radius = self:GetRadius() * self:GetRadius()
		for idx,ent in pairs(self.outside) do
			if IsValid(ent) then
				if (ent:GetPos() - self:GetPos()):LengthSqr() <= radius then
					self.outside[idx] = nil
					self.inside[idx] = ent
					
					local oldenv = ent:GetEnv()
					table.insert(ent.auenv.envlist, self)
					table.sort(ent.auenv.envlist, EnvPrioritySort)
					local newenv = ent:GetEnv()
					
					if oldenv != newenv then
						newenv:DoGravity(ent)
						gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
					end
				end
			else
				self.outside[idx] = nil
			end
		end
		
		for idx,ent in pairs(self.inside) do
			if IsValid(ent) then
				if (ent:GetPos() - self:GetPos()):LengthSqr() > radius then
					self.outside[idx] = ent
					self.inside[idx] = nil
					
					local oldenv = ent:GetEnv()
					for k,v in pairs(ent.auenv.envlist) do
						if v == self then
							table.remove(ent.auenv.envlist, k)
							break
						end
					end
					local newenv = ent:GetEnv()
					
					if oldenv != newenv then
						newenv:DoGravity(ent)
						gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
					end
				end
			else
				self.inside[idx] = nil
			end
		end
	end

	self:NextThink(CurTime() + 1)
	return true
end

function ENT:OnRemove()
	for idx,ent in pairs(self.inside) do
		if IsValid(ent) then
			local oldenv = ent:GetEnv()
			for k,v in pairs(ent.auenv.envlist) do
				if v == self then
					table.remove(ent.auenv.envlist, k)
					break
				end
			end
			local newenv = ent:GetEnv()
			
			if oldenv != newenv then
				newenv:DoGravity(ent)
				gamemode.Call("OnAtmosphereChange", ent, oldenv, newenv)
			end
		end
	end
end

function ENT:DefaultAtmosphere()
	if self.atmosphere then return end
	self.atmosphere = {}
	
	self.atmosphere.name = "Atmosphere"
	
	self.atmosphere.sphere	= true
	self.atmosphere.noclip 	= false
	self.atmosphere.sunburn	= false
	self.atmosphere.wind 	= false
	self.atmosphere.static 	= false
	
	self.atmosphere.priority	= 5
	self.atmosphere.radius 		= 0
	self.atmosphere.gravity 	= 0
	self.atmosphere.pressure 	= 0
	self.atmosphere.windspeed 	= 0
	self.atmosphere.tempcold	= 3
	self.atmosphere.temphot		= 3
	
	self.atmosphere.resources 	= {}
	self.atmosphere.resources.empty = 100
	self.atmosphere.resources.oxygen = 0
	self.atmosphere.resources.carbon_dioxide = 0
	self.atmosphere.resources.nitrogen = 0
	self.atmosphere.resources.hydrogen = 0
	self.atmosphere.percent = {}
	self.atmosphere.percent.empty = 100
	self.atmosphere.percent.oxygen = 0
	self.atmosphere.percent.carbon_dioxide = 0
	self.atmosphere.percent.nitrogen = 0
	self.atmosphere.percent.hydrogen = 0
end

function ENT:PhysicsSetup()
	local radius = self:GetRadius()
	if radius <= 0 then return end
	local min, max = Vector(-radius,-radius,-radius), Vector(radius,radius,radius)
	
	self:PhysicsInitBox(min, max)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Wake()
	end

	self:DrawShadow(false)
	self:SetTrigger(true)
	self:SetNotSolid(true)
	self:SetCollisionBounds(min, max)
end

function ENT:IsStar()
	return false
end

function ENT:IsShip()
	return false
end

function ENT:IsPlanet()
	return false
end

function ENT:IsSpace()
	return false
end

function ENT:GetRadius()
	return self.atmosphere.radius
end

function ENT:GetVolume()
	if self.atmosphere.sphere then
		return math.floor(((4/3) * math.pi * self.atmosphere.radius ^ 3) * 0.001)
	else
		return math.floor((self.atmosphere.radius ^ 3) * 0.001)
	end
end

function ENT:GetAtmosphereResource(res)
	return self.atmosphere.resources[res] || 0
end

function ENT:GetBaseAtmospherePercent(res)
	return self.atmosphere.percent[res] || 0
end

function ENT:GetTrueAtmospherePercent(res)
	if !self.atmosphere.resources[res] then return 0 end
	return (self.atmosphere.resources[res] / self:GetVolume()) * 100
end

function ENT:SetAtomsphere(data)
	self:DefaultAtmosphere()
	self:SetATRadius(data["radius"])
	self:SetATGravity(data["gravity"])
	self:SetATTempurature(data["tempcold"], data["temphot"])
	self:SetATAir(data["oxygen"], data["carbon_dioxide"], data["nitrogen"], data["hydrogen"])
	self:SetATName(data["name"])
	self:SetATFlags(data["flags"])
	self:SetATSphere(data["sphere"])
	self:SetATStatic(data["static"])
	self:SetATNoclip(data["noclip"])
end

function ENT:SetATRadius(num)
	num = tonumber(num)
	if !num || self.atmosphere.radius == num then return end
	self.atmosphere.radius = num
	self:PhysicsSetup()
	self:FixAir()
end

function ENT:SetATGravity(num)
	num = tonumber(num)
	if !num then return end
	self.atmosphere.gravity = num
end

function ENT:SetATTempurature(tpc, tph)
	tpc, tph = tonumber(tpc), tonumber(tph)
	if !tpc then return end
	self.atmosphere.tempcold = tpc
	self.atmosphere.temphot = tph || tpc
end

function ENT:SetATAir(oxygen, carbon_dioxide, nitrogen, hydrogen)
	if oxygen then
		self.atmosphere.percent.oxygen = oxygen
		self.atmosphere.resources.oxygen = math.floor(self:GetVolume() * oxygen * 0.01)
	end
	if carbon_dioxide then
		self.atmosphere.percent.carbon_dioxide = carbon_dioxide
		self.atmosphere.resources.carbon_dioxide = math.floor(self:GetVolume() * carbon_dioxide * 0.01)
	end
	if nitrogen then
		self.atmosphere.percent.nitrogen = nitrogen
		self.atmosphere.resources.nitrogen = math.floor(self:GetVolume() * nitrogen * 0.01)
	end
	if hydrogen then
		self.atmosphere.percent.hydrogen = hydrogen
		self.atmosphere.resources.hydrogen = math.floor(self:GetVolume() * hydrogen * 0.01)
	end
	self:FixAir()
end

function ENT:SetATName(str)
	str = tostring(str)
	if !str then return end
	self.atmosphere.name = str
end

function ENT:SetATFlags(num)
	num = tonumber(num)
	if !num then return end
	self.atmosphere.sunburn = Extract_Bit(2, num)
end

function ENT:SetATSphere(bool)
	if bool == nil then return end
	self.atmosphere.sphere = tobool(bool)
end

function ENT:SetATStatic(bool)
	if bool == nil then return end
	self.atmosphere.static = tobool(bool)
end

function ENT:SetATNoclip(bool)
	if bool == nil then return end
	self.atmosphere.noclip = tobool(bool)
end

function ENT:FixAir()
	local total = 0
	for k,v in pairs(self.atmosphere.percent) do
		total = total + v
	end
	
	local fix = (total - 100) / table.Count(self.atmosphere.percent)
	if fix > 0 && self.atmosphere.percent.empty > 0 then
		local space = math.min(self.atmosphere.percent.empty, total - 100)
		self.atmosphere.percent.empty = self.atmosphere.percent.empty - space
		fix = (total - 100 - space) / table.Count(self.atmosphere.percent)
	elseif fix < 0 then
		local space = total - 100
		self.atmosphere.percent.empty = self.atmosphere.percent.empty - space
		fix = (total - 100 - space) / table.Count(self.atmosphere.percent)
	end
	
	local vol = self:GetVolume()
	
	for k,v in pairs(self.atmosphere.percent) do
		self.atmosphere.percent[k] = v - fix
		self.atmosphere.resources[k] = math.max(math.floor((self.atmosphere.resources[k] || 0) - vol * fix * 0.01), 0)
	end
end

function ENT:InAtmosphere(pos)
	if self.atmosphere.sphere then
		if (pos - self:GetPos()):LengthSqr() < self:GetRadius() * self:GetRadius() then
			return true
		end
	else
		local cen, rad = self:GetPos(), self:GetRadius()
		if pos.x < cen.x + rad && pos.x > cen.x - rad && pos.y < cen.y + rad && pos.y > cen.y - rad && pos.z < cen.z + rad && pos.z > cen.z - rad then
			return true
		end
	end
	return false
end

function ENT:DoGravity(ent)
	if !IsValid(ent) || !ent.auenv then return end
	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then return end

	local grav = self.atmosphere.gravity
	if !ent.auenv.gravity != grav then
		local bool = grav > 0
		phys:EnableGravity(bool)
		phys:EnableDrag(bool)
		ent:SetGravity(grav + 0.0001)
		ent.auenv.gravity = grav
	end
end

function ENT:InSun(ent)
	if !IsValid(ent) then return false end
	local pos = ent:LocalToWorld(ent:OBBCenter())
    
	for k,v in pairs(TK.AT.GetSuns()) do
		local trace = {}
		trace.start = pos - (pos - v):GetNormal() * 2048
		trace.endpos = pos
		trace.filter = {ent, ent:GetParent()}
		local tr = util.TraceLine(trace)
		if !tr.Hit then
			return true
		end
	end
    
	return false
end

function ENT:DoTemp(ent)
	if !IsValid(ent) then return 3, false end

	if self:InSun(ent) then
		return math.floor(self.atmosphere.temphot + (self.atmosphere.temphot * ((self:GetTrueAtmospherePercent("carbon_dioxide") - self:GetBaseAtmospherePercent("carbon_dioxide")) * 0.01)) * 0.5), true
	end
	return math.floor(self.atmosphere.tempcold + (self.atmosphere.tempcold * ((self:GetTrueAtmospherePercent("carbon_dioxide") - self:GetBaseAtmospherePercent("carbon_dioxide")) * 0.01)) * 0.5), false
end

local function ValidAmount(amt)
	amt = math.floor(amt)
	return amt < 0 && 0 || amt
end

function ENT:SupplyAtmosphere(idx, amt)
	if !self.atmosphere.resources[idx] then return 0 end
	local iamt = ValidAmount(amt)
	if iamt == 0 || self.atmosphere.resources.empty == 0 then return 0 end
	
	if iamt > self.atmosphere.resources.empty then
		iamt = self.atmosphere.resources.empty
		if !self.atmosphere.static then
			self.atmosphere.resources[idx] = self.atmosphere.resources[idx] + iamt
			self.atmosphere.resources.empty = 0
		end
	elseif !self.atmosphere.static then
		self.atmosphere.resources[idx] = self.atmosphere.resources[idx] + iamt
		self.atmosphere.resources.empty = self.atmosphere.resources.empty - iamt
	end
	return iamt
end

function ENT:ConsumeAtmosphere(idx, amt)
	if !self.atmosphere.resources[idx] then return 0 end
	local iamt = ValidAmount(amt)
	if iamt == 0 then return 0 end
	
	if iamt > self.atmosphere.resources[idx] then
		iamt = self.atmosphere.resources[idx]
		if !self.atmosphere.static then
			self.atmosphere.resources[idx] = 0
			self.atmosphere.resources.empty = self.atmosphere.resources.empty - iamt
		end
	elseif !self.atmosphere.static then
		self.atmosphere.resources[idx] = self.atmosphere.resources[idx] - iamt
		self.atmosphere.resources.empty = self.atmosphere.resources.empty + iamt
	end
	return iamt
end