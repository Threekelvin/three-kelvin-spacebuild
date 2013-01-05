AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetPowered(true)
	self:AddResource("energy", 0)
	self:AddResource("water", 0)
	self:AddResource("steam", 0, true)
	self.Multiplier = 1
	self.Mute = false
	
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
		self.Multiplier = math.max(0, value)
	elseif iname == "Mute" then
		self.Mute = tobool(value)
	end
end

function ENT:TurnOn()
	if self.IsActive || !self:IsLinked() then return end
	self:SetActive(true)
	WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
	if !self.IsActive then return end
	self:SetActive(false)
	WireLib.TriggerOutput(self, "On", 0)
	WireLib.TriggerOutput(self, "Output", 0)
end

function ENT:Idle()
	if self.IsIdle then return end
	self:SetIdle(true)
	WireLib.TriggerOutput(self, "Output", 0)
end

function ENT:DoThink()
	if !self.IsActive then return end

	local energy = self:GetResourceAmount("energy")
	local steam = math.min(self:GetResourceAmount("water"), self.data.steam * self.Mult)
	
	if steam <= 0 then self:Idle() return end
	if energy < steam * self.data.energy then self:Idle() return end
	
	self:ConsumeResource("energy", steam * self.data.energy)
	steam = self:ConsumeResource("water", steam)
	
	self:SupplyResource("steam", steam)
	WireLib.TriggerOutput(self, "Output", steam)
	
	self:Work()
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end