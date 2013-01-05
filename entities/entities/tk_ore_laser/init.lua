AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:LaserPower()
	if self.upgrades then
		local Power = 10 + (10 * ((self.upgrades.r1 * 5) + (self.upgrades.r2 * 5) + (self.upgrades.r3 * 10) + (self.upgrades.r4 * 5) + (self.upgrades.r7 * 10) + (self.upgrades.r9 * 15)) / 100)
		return math.floor(Power)
	else
		return 10
	end
end

function ENT:LaserRange()
	if self.upgrades then
		local Range = 1000 + (1000 * (self.upgrades.r2 + (self.upgrades.r4 * 0.5) + (self.upgrades.r6 * 0.5) + (self.upgrades.r7 * 0.5) + self.upgrades.r9) / 100)
		return math.floor(Range)
	else 
		return 1000
	end	
end

function ENT:LaserEnergy()
	if self.upgrades then
		local Power = self:LaserPower()
		local Energy = Power - (Power * ((self.upgrades.r3 * 0.05) + (self.upgrades.r5 * 0.1) + (self.upgrades.r6 * 0.05) + (self.upgrades.r8 * 0.15) + (self.upgrades.r9 * 0.05)) / 100)
		return math.floor(Energy)
	else
		return 100
	end
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.device = {1, 1}

	self.power = self:LaserPower()
	self.range = self:LaserRange()
	self.energy = self:LaserEnergy()
	self:SetNWInt("range", self.range)

	self:SetPowered(true)
	self:AddResource("energy", 0)
	self:AddResource("asteroid_ore", 0, true)
	self:AddSound("l", 7, 65)
	
	self.Inputs = WireLib.CreateInputs(self, {"On"})
	self.Outputs = WireLib.CreateOutputs(self, {"On", "Output", "Range", "EnergyUsage"})
end

function ENT:TurnOn()
	if self.IsActive || !self:IsLinked() then return end
	if self:GetResourceAmount("energy") > self.energy then
		self:SetActive(true)
		WireLib.TriggerOutput(self, "On", 1)
		WireLib.TriggerOutput(self, "Range", self.range)
		WireLib.TriggerOutput(self, "EnergyUsage", self.energy)
		self:SoundPlay(1)
	end
end

function ENT:TurnOff()
	if !self.IsActive then return end
	self:SetActive(false)
	WireLib.TriggerOutput(self, "On", 0)
	WireLib.TriggerOutput(self, "Output", 0)
	WireLib.TriggerOutput(self, "Range", 0)
	WireLib.TriggerOutput(self, "EnergyUsage", 0)
	self:SoundStop(1)
end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		if value != 0 then
			self:TurnOn()
		else
			self:TurnOff()
		end
	end
end

function ENT:DoThink()
	if !self.IsActive then return end
	
	if self.energy > self:GetResourceAmount("energy") then
		self:TurnOff()
		return true
	end
	
	self:ConsumeResource("energy", self.energy)
	local trace = util.QuickTrace(self:LocalToWorld(Vector(0,0,32)), self:GetUp() * (self.range + 32), self)
	if IsValid(trace.Entity) then
		local ent = trace.Entity
		local owner, uid = self:CPPIGetOwner()
		if !IsValid(owner) then return end
		
		if ent:GetClass() == "tk_roid" then
			if ent.Ore > self.power then
				self:SupplyResource("asteroid_ore", self.power)
				owner.tkstats.score = owner.tkstats.score + (self.power * TerminalData:Ore(owner, "asteroid_ore") * 0.375)
				WireLib.TriggerOutput(self, "Output", self.power)
				ent.Ore = ent.Ore - self.power
			else
				self:SupplyResource("asteroid_ore", ent.Ore)
				owner.tkstats.score = owner.tkstats.score + (ent.Ore * TerminalData:Ore(owner, "asteroid_ore") * 0.375)
				WireLib.TriggerOutput(self, "Output", ent.Ore)
				ent.Ore = 0
			end
		elseif ent:GetClass() == "tk_orestorage" then
			if ent:GetEntTable().netid == self:GetEntTable().netid then return end
			local ore = ent:ConsumeResource("asteroid_ore", self.power)
			self:SupplyResource("asteroid_ore", ore)
			owner.tkstats.score = owner.tkstats.score + (ore * TerminalData:Ore(owner, "asteroid_ore") * 0.375)
			WireLib.TriggerOutput(self, "Output", ore)
		elseif ent:IsPlayer() || ent:IsNPC() then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(math.random(5, 25))
			dmginfo:SetDamageType(DMG_RADIATION)
			dmginfo:SetAttacker(self:CPPIGetOwner())
			dmginfo:SetInflictor(self)
			ent:TakeDamageInfo(dmginfo)
		end
	end
	WireLib.TriggerOutput(self, "Output", 0)
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end

function ENT:Update()
	self.power = self:LaserPower()
	self.range = self:LaserRange()
	self.energy = self:LaserEnergy()
	self:SetNWInt("range", self.range)
end

function ENT:UpdateTransmitState() 
	return TRANSMIT_ALWAYS 
end