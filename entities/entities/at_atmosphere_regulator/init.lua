AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local pairs = pairs
local table = table
local math = math

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self.atmosphere = {}
	
	self.atmosphere.name = "Ship"
	
	self.atmosphere.sphere	= false
	self.atmosphere.noclip 	= false
	self.atmosphere.sunburn	= false
	self.atmosphere.wind 	= false
	self.atmosphere.static 	= false
	
	self.atmosphere.priority	= 2
	self.atmosphere.radius 		= 0
	self.atmosphere.gravity 	= 1
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
	self.atmosphere.percent.empty = 0
	self.atmosphere.percent.oxygen = 20
	self.atmosphere.percent.carbon_dioxide = 5
	self.atmosphere.percent.nitrogen = 70
	self.atmosphere.percent.hydrogen = 5
	
	self:SetPowered(true)
	self:AddResource("energy", 0)
	self:AddResource("oxygen", 0)
	self:AddResource("nitrogen", 0)
	self:AddResource("water", 0)
	
	self.hullents = {}
	self.brushes = {}
	self.volume = 0
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	
	for k,v in pairs(self.brushes) do
		SafeRemoveEntity(v)
	end
end

function ENT:TurnOn()
	if self.IsActive || !self:IsLinked() then return end
	
	local entlist, hull = {}, {}
	local vol = 0
	for k,v in pairs(constraint.GetAllConstrainedEntities(self)) do
		if v:BoundingRadius() > 100 then
			entlist[v:EntIndex()] = v
		end
	end
	
	for k,v in pairs(self.hullents) do
		if entlist[v:EntIndex()] then
			table.insert(hull, v)
			vol = vol + v:GetPhysicsObject():GetVolume()
		end
	end
	
	if #hull == 0 then
		local owner = self:CPPIGetOwner()
		owner:SendLua("GAMEMODE:AddNotify(\"No Props Linked\", NOTIFY_ERROR, 5)")
		return
	end
	
	if self:GetResourceAmount("energy") < #hull * 2500 then return end
	self:ConsumeResource("energy", #hull * 2500)
	self.volume = math.floor(vol * 0.0025)
	self:SetActive(true)
	
	
	for k,v in pairs(hull) do
		local brush = ents.Create("at_brush")
		brush.env = self
		brush:SetPos(v:GetPos())
		brush:SetAngles(v:GetAngles())
		brush:SetParent(v)
		brush:Spawn()
		
		table.insert(self.brushes, brush)
	end
	
	local env = self:GetEnv()
	self.atmosphere.tempcold = env.atmosphere.tempcold
	self.atmosphere.temphot	= self.atmosphere.tempcold
	for k,v in pairs(env.atmosphere.percent) do
		self.atmosphere.resources[k] = self.volume * v * 0.01
	end
end

function ENT:TurnOff()
	if !self.IsActive then return end
	self:SetActive(false)
	
	for k,v in pairs(self.brushes) do
		SafeRemoveEntity(v)
	end
	self.volume = 0
end

function ENT:DoThink()
	if !self.IsActive then return end
	local env
	local size = table.Count(self.brushes)
	local rate = math.max(math.floor(self.volume / 30), 50 * size)
	
	for k,v in ipairs(self.auenv.envlist) do
		if v != self then 
			env = v
			break
		end
	end
	
	self.atmosphere.noclip = env.atmosphere.noclip
	if env.atmosphere.tempcold < 307 then
		self.atmosphere.tempcold = math.floor(self.atmosphere.tempcold + 0.1 * (env.atmosphere.tempcold - self.atmosphere.tempcold))
		self.atmosphere.temphot = self.atmosphere.tempcold
	elseif env.atmosphere.temphot > 273 then
		self.atmosphere.tempcold = math.floor(self.atmosphere.tempcold + 0.1 * (env.atmosphere.temphot - self.atmosphere.tempcold))
		self.atmosphere.temphot = self.atmosphere.tempcold
	end
	
	self.atmosphere.resources.oxygen = math.max(self.atmosphere.resources.oxygen - 5 * size, 0)
	self.atmosphere.resources.carbon_dioxide = math.max(self.atmosphere.resources.carbon_dioxide - 5 * size, 0)
	self.atmosphere.resources.nitrogen = math.max(self.atmosphere.resources.nitrogen - 5 * size, 0)
	self.atmosphere.resources.hydrogen = math.max(self.atmosphere.resources.hydrogen - 5 * size, 0)
	
	if self:GetResourceAmount("energy") < 50 * size then self:TurnOff() return end
	self:ConsumeResource("energy", 50 * size)
	
	if self.atmosphere.tempcold  < 290 then
		local energy = math.ceil((290 - self.atmosphere.tempcold) / 34) * size
		self.atmosphere.tempcold = self.atmosphere.tempcold + (self:ConsumeResource("energy", energy) * 34 / size)
		self.atmosphere.temphot = self.atmosphere.tempcold
	elseif self.atmosphere.temphot > 290 then
		local water = math.ceil((self.atmosphere.tempcold - 290) / 34) * size
		self.atmosphere.tempcold = self.atmosphere.tempcold - (self:ConsumeResource("water", water) * 34 / size)
		self.atmosphere.temphot = self.atmosphere.tempcold
	end

	if self.atmosphere.resources.oxygen / self.volume < 0.2 then
		local oxygen = math.floor(math.min(self.volume * 0.2 - self.atmosphere.resources.oxygen, rate))
		self.atmosphere.resources.oxygen = self.atmosphere.resources.oxygen + self:ConsumeResource("oxygen", oxygen)
	elseif self.atmosphere.resources.oxygen / self.volume > 0.2 then
		local oxygen = math.floor(math.min(self.atmosphere.resources.oxygen - self.volume * 0.2, rate))
		self.atmosphere.resources.oxygen = self.atmosphere.resources.oxygen - oxygen
	end

	if self.atmosphere.resources.carbon_dioxide > 0 then
		local carbon_dioxide = math.floor(math.min(self.atmosphere.resources.carbon_dioxide, rate))
		self.atmosphere.resources.carbon_dioxide = self.atmosphere.resources.carbon_dioxide - carbon_dioxide
	end

	if self.atmosphere.resources.nitrogen / self.volume < 0.8 then
		local nitrogen = math.floor(math.min(self.volume * 0.8 - self.atmosphere.resources.nitrogen, rate))
		self.atmosphere.resources.nitrogen = self.atmosphere.resources.nitrogen + self:ConsumeResource("nitrogen", nitrogen)
	elseif self.atmosphere.resources.nitrogen / self.volume > 0.8 then
		local nitrogen = math.floor(math.min(self.atmosphere.resources.nitrogen - self.volume * 0.8, rate))
		self.atmosphere.resources.nitrogen = self.atmosphere.resources.nitrogen - nitrogen
	end
	
	if self.atmosphere.resources.hydrogen > 0 then
		hydrogen = math.floor(math.min(self.atmosphere.resources.hydrogen, rate))
		self.atmosphere.resources.hydrogen = self.atmosphere.resources.hydrogen - hydrogen
	end
	
	local total = 0
	for k,v in pairs(self.atmosphere.resources) do
		if k != "empty" then
			total = total + v
		end
	end
	
	if total > self.volume then
		self.atmosphere.resources.empty = 0
		print("If this happens too much i will fix it")
	else
		self.atmosphere.resources.empty = self.volume - total
	end
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end

function ENT:IsStar()
	return false
end

function ENT:IsShip()
	return true
end

function ENT:IsPlanet()
	return false
end

function ENT:IsSpace()
	return false
end

function ENT:GetRadius()
	return 0
end

function ENT:GetVolume()
	return self.volume
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

function ENT:InAtmosphere(pos)
	for k,v in pairs(self.brushes) do
		local cen, min, max = v:GetPos(), v:GetCollisionBounds()
		if pos.x < cen.x + min.x && pos.x > cen.x + max.x && pos.y < cen.y + min.y && pos.y > cen.y + max.y && pos.z < cen.z + min.z && pos.z > cen.z + max.z then
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
		return self.atmosphere.temphot, true
	end
	return self.atmosphere.tempcold, false
end

local function ValidAmount(amt)
	amt = math.floor(amt)
	amt = math.max(0, amt)
	return amt
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