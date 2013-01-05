AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.ambient = 290
	self.heat = 290
	
	self:SetPowered(true)
	self:AddResource("energy", 0, true)
	self:AddResource("nitrogen", 0, true)
	self:AddResource("hydrogen", 0)
	self:AddResource("liquid_nitrogen", 0)
	self:AddSound("a", 6, 75)
	self:AddSound("l", 9, 100)
	self:AddSound("s", 1, 75)
	
	WireLib.CreateInputs(self, {"On", "Mute"})
	WireLib.CreateOutputs(self, {"On", "Heat", "Output"})
end

function ENT:Think()
	local env = self:GetEnv()
	self.ambient = env:DoTemp(self)
	self.heat = math.floor(self.heat + 0.01 * (self.ambient - self.heat))
	WireLib.TriggerOutput(self, "Heat", self.heat)
	
	if self.heat > 3000 then
		self:Remove()
	end
	
	self:NextThink(CurTime() + 1)
	return true
end

function ENT:TurnOn()
	if self.IsActive || !self:IsLinked() then return end
	self:SetActive(true)
	self:SoundPlay(1)
	self:SoundPlay(2)
	self:SoundStop(3)
	WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
	if !self.IsActive then return end
	self:SetActive(false)
	self:SoundStop(1)
	self:SoundStop(2)
	self:SoundPlay(3)
	WireLib.TriggerOutput(self, "On", 0)
	WireLib.TriggerOutput(self, "Output", 0)
end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		if value != 0 then
			self:TurnOn()
		else
			self:TurnOff()
		end
	elseif iname == "Mute" then
		self.Mute = tobool(value)
	end
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
	
	local hydrogen = self:ConsumeResource("hydrogen", self.data.hydrogen)
	if hydrogen <= 0 then self:Idle() return end
	local energy = math.floor((hydrogen * 300) * (self.ambient / self.heat))
	self.heat = math.floor(self.heat + (self.data.heat * hydrogen / self.data.hydrogen))
	if self.heat > self.ambient then
		local excess = self.heat - self.ambient
		local nitrogen = self:ConsumeResource("liquid_nitrogen", excess)
		
		self.heat = self.heat - nitrogen
		self:SupplyResource("nitrogen", nitrogen)
	end
	
	self:SupplyResource("energy", energy)
	WireLib.TriggerOutput(self, "Output", energy)
	
	self:Work()
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end