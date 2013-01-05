AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetPowered(true)
	self:AddResource("energy", 0)
	self:AddResource("nitrogen", 0)
	self:AddResource("liquid_nitrogen", 0, true)
	self:AddSound("l", 2, 65)
	
	WireLib.CreateInputs(self, {"On", "Multiplier", "Mute"})
	WireLib.CreateOutputs(self, {"On", "LN2Output"})
end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		if value != 0 then
			self:TurnOn()
		else
			self:TurnOff()
		end
	elseif iname == "Multiplier" then
		self.Multiplier = math.max(0, value)
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
	WireLib.TriggerOutput(self, "LN2Output", 0)
end

function ENT:Idle()
	if self.IsIdle then return end
	self:SetIdle(true)
	WireLib.TriggerOutput(self, "LN2Output", 0)
end

function ENT:DoThink()
	if !self.IsActive then return end

	local energy = self:GetResourceAmount("energy")
	local liquid_nitrogen = math.min(self:GetResourceAmount("nitrogen"), self.data.liquid_nitrogen * self.Mult)
	
	if liquid_nitrogen <= 0 then self:Idle() return end
	if energy < liquid_nitrogen * self.data.energy then self:Idle() return end
	
	self:ConsumeResource("energy", liquid_nitrogen * self.data.energy)
	liquid_nitrogen = self:ConsumeResource("nitrogen", liquid_nitrogen)
	
	self:SupplyResource("liquid_nitrogen", liquid_nitrogen)
	WireLib.TriggerOutput(self, "LN2Output", liquid_nitrogen)
	
	self:Work()
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end