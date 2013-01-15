AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:ExtractorPower()
    
end

function ENT:ExtractorEnergy()
	if self.upgrades then
		local Power = self:ExtractorPower() * 20
		local Energy = Power - (Power * ((self.upgrades.r2 * 0.1) + (self.upgrades.r3 * 0.1) + (self.upgrades.r6 * 0.1)) / 100)
		return math.floor(Energy)
	else
		return 2000
	end
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.device = {2, 1}
	
	self:GetNWInt("crystal", 0)
	self.Stable = true
	self.PowerLevel = 0
	
	self.power = self:ExtractorPower()
	self.energy = self:ExtractorEnergy()
	
	self:SetPowered(true)
	self:AddResource("raw_tiberium", 0, true)
	self:AddResource("energy", 0)
	self:AddSound("a", 4, 75)
	self:AddSound("l", 8, 75)
	self:AddSound("d", 4, 100)
	self:AddSound("s", 4, 75)
	
	self.Inputs = Wire_CreateInputs(self, {"On"})
	self.Outputs = Wire_CreateOutputs(self, {"On", "Output", "EnergyUsage"})
end

function ENT:UpdateTransmitState() 
	return TRANSMIT_ALWAYS 
end

function ENT:TurnOn()
	if self.IsActive || !self:IsLinked() then return end
	if self:GetResourceAmount("energy") > self.energy then
		self:SetActive(true)
		self:SoundPlay(1)
		self:SoundPlay(2)
		self.PowerLevel = 0
		
		WireLib.TriggerOutput(self, "On", 1)
		WireLib.TriggerOutput(self, "EnergyUsage", self.energy)
	end
end

function ENT:TurnOff()
	if !self.IsActive then return end
	self:SetActive()
	self:SoundStop(2)
	self:SoundStop(3)
	self:SoundPlay(4)
	self.PowerLevel = 0
	
	WireLib.TriggerOutput(self, "On", 0)
	WireLib.TriggerOutput(self, "EnergyUsage", 0)
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
		return
	end
	
	local crystal
	self:ConsumeResource("energy", self.energy)
	
	for k,v in pairs(ents.FindInCone(self:GetPos(), self:GetForward(), 100, 45)) do
		if v:GetClass() == "tk_tib_crystal" then
			crystal = v
			break
		end
	end
	
	if IsValid(crystal) then
		local owner, uid = self:CPPIGetOwner()
		if !IsValid(owner) then return end
		
		if self.PowerLevel < 1 then
			self.PowerLevel = self.PowerLevel + (1/15)
		else
			self.PowerLevel = 1
		end
		if self:GetCrystal() != crystal:EntIndex() then
			self:SetNWInt("crystal", crystal:EntIndex())
			self.PowerLevel = 0
		end
		local Speed = math.floor(self.power * self.PowerLevel)
		
		
		if self.Stable != crystal.Stable then
			self.Stable = crystal.Stable
			if self.Stable then
				self:SoundStop(3)
				self:SoundPlay(2)
			else
				self:SoundStop(2)
				self:SoundPlay(3)
			end
		end
		
		if crystal.Tib > Speed then
			self:SupplyResource("raw_tiberium", Speed)
			owner.tkstats.score = owner.tkstats.score + (Speed * TK.TD:Ore(owner, "raw_tiberium") * 0.375)
			WireLib.TriggerOutput(self, "Output", Speed)
			crystal.Tib = crystal.Tib - Speed
		else
			self:SupplyResource("raw_tiberium", crystal.Tib)
			owner.tkstats.score = owner.tkstats.score + (crystal.Tib * TK.TD:Ore(owner, "raw_tiberium") * 0.375)
			WireLib.TriggerOutput(self, "Output", crystal.Tib)
			crystal.Tib = 0
		end
	else
		if self:GetCrystal() != 0 then
			self:SetNWInt("crystal", 0)
			self.Stable = true
			self:SoundStop(3)
			self:SoundPlay(2)
			WireLib.TriggerOutput(self, "Output", 0)
		end
	end
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end

function ENT:Update()
	self.power = self:ExtractorPower()
	self.energy = self:ExtractorEnergy()
end

function ENT:UpdateTransmitState() 
	return TRANSMIT_ALWAYS 
end