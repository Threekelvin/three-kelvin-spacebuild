AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetPowered(true)
	self:AddResource("energy", 0)
	self:AddResource("water", 0, true)
	self:AddSound("l", 4, 75)
	
	WireLib.CreateInputs(self, {"On", "Multiplier", "Mute"})
	WireLib.CreateOutputs(self, {"On", "H2OOutput"})
end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		if value != 0 then
			self:TurnOn()
		else
			self:TurnOff()
		end
	elseif iname == "Multiplier" then
		self.Mult = math.max(0, value)
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
	WireLib.TriggerOutput(self, "H2OOutput", 0)
end

function ENT:Idle()
	if self.IsIdle then return end
	self:SetIdle(true)
	WireLib.TriggerOutput(self, "H2OOutput", 0)
end

function ENT:DoThink()
	if !self.IsActive then return end

	local energy = self:GetResourceAmount("energy")
	local water = self.data.water * self.Mult
	
	if energy < water * self.data.energy then self:Idle() return end
	if TK.RD.WaterLevel(self) < 0.25 then self:TurnOff() return end

	self:ConsumeResource("energy", water * self.data.energy)
	water = self:SupplyResource("water", water)
	WireLib.TriggerOutput(self, "H2OOutput", water)
	
	self:Work()
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end