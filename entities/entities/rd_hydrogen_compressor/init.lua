AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetPowered(true)
	self:AddResource("energy", 0)
	self:AddResource("hydrogen", 0, true)
	self:AddSound("l", 3, 65)
	
	WireLib.CreateInputs(self, {"On", "Multiplier", "Mute"})
	WireLib.CreateOutputs(self, {"On", "H2Output"})
end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		if value != 0 then
			self:TurnOn()
		else
			self:TurnOff()
		end
	elseif iname == "Multiplier" then
		self.Mult = math.max(1, value)
	elseif iname == "Mute" then
		self.Mute = tobool(value)
	end
end

function ENT:TurnOn()
	if self.IsActive || !self:IsLinked() then return end
	self:SetActive(true)
	self:SoundPlay(1)
	WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
	if !self.IsActive then return end
	self:SetActive(false)
	self:SoundStop(1)
	WireLib.TriggerOutput(self, "On", 0)
	WireLib.TriggerOutput(self, "H2Output", 0)
end

function ENT:Idle()
	if self.IsIdle then return end
	self:SetIdle(true)
	WireLib.TriggerOutput(self, "H2Output", 0)
end

function ENT:DoThink()
	if !self.IsActive then return end
	
	local env = self:GetEnv()
	if !env:IsPlanet() then self:Idle() return end
	local energy = self:GetResourceAmount("energy")
	local hydrogen = math.min(env:GetAtmosphereResource("hydrogen"), self.data.hydrogen * self.Mult)
	
	if hydrogen <= 0 then self:Idle() return end
	if energy < hydrogen * self.data.energy then self:Idle() return end
	
	self:ConsumeResource("energy", hydrogen * self.data.energy)
	hydrogen = env:ConsumeAtmosphere("hydrogen", hydrogen)
	
	self:SupplyResource("hydrogen", hydrogen)
	WireLib.TriggerOutput(self, "H2Output", hydrogen)
	
	self:Work()
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end