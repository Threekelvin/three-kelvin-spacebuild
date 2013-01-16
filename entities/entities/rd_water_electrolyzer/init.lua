AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetNWBool("Generator", true)
	self:AddResource("water", 0)
	self:AddResource("hydrogen", 0, true)
	self:AddResource("oxygen", 0, true)
	self:AddSound("l", 2, 65)
	
	WireLib.CreateInputs(self, {"On", "Multiplier", "Mute"})
	WireLib.CreateOutputs(self, {"On", "Output"})
end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		if value != 0 then
			self:TurnOn()
		else
			self:TurnOff()
		end
	elseif iname == "Multiplier" then
		self.mult = math.max(0, value)
	elseif iname == "Mute" then
		self.mute = tobool(value)
	end
end

function ENT:TurnOn()
	if self:GetActive() || !self:IsLinked() then return end
	self:SetActive(true)
	self:SoundPlay(1)
	WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
	if !self:GetActive() then return end
	self:SetActive(false)
    self:SetPower(0)
	self:SoundStop(1)
	WireLib.TriggerOutput(self, "On", 0)
	WireLib.TriggerOutput(self, "Output", 0)
end

function ENT:DoThink(eff)
	if !self:GetActive() then return end

	local water = math.min(self:GetResourceAmount("water"), self.data.water * self.mult * eff)
	
	if water <= 0 then self:TurnOff() return end
    if !self:Work() then return end
	
	water = self:ConsumeResource("water", water)
	self:SupplyResource("oxygen", water / 2)
	self:SupplyResource("hydrogen", water)
	WireLib.TriggerOutput(self, "O2Output", water)
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end