AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetPowered(true)
	self:AddResource("energy", 0)
	self:AddResource("nitrogen", 0, true)
	self:AddSound("l", 3, 65)
	
	WireLib.CreateInputs(self, {"On", "Multiplier", "Mute"})
	WireLib.CreateOutputs(self, {"On", "N2Output"})
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
	WireLib.TriggerOutput(self, "N2Output", 0)
end

function ENT:Idle()
	if self.IsIdle then return end
	self:SetIdle(true)
	WireLib.TriggerOutput(self, "N2Output", 0)
end

function ENT:DoThink()
	if !self.IsActive then return end
	
	local env = self:GetEnv()
	if !env:IsPlanet() then self:Idle() return end
	local energy = self:GetResourceAmount("energy")
	local nitrogen = math.min(env:GetAtmosphereResource("nitrogen"), self.data.nitrogen * self.Mult)
	
	if nitrogen <= 0 then self:Idle() return end
	if energy < nitrogen * self.data.energy then self:Idle() return end
	
	self:ConsumeResource("energy", nitrogen * self.data.energy)
	nitrogen = env:ConsumeAtmosphere("nitrogen", nitrogen)
	
	self:SupplyResource("nitrogen", nitrogen)
	WireLib.TriggerOutput(self, "N2Output", nitrogen)
	
	self:Work()
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end