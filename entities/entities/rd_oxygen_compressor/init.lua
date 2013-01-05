AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetPowered(true)
	self:AddResource("energy", 0)
	self:AddResource("oxygen", 0, true)
	self:AddSound("l", 3, 65)
	
	WireLib.CreateInputs(self, {"On", "Multiplier", "Mute"})
	WireLib.CreateOutputs(self, {"On", "O2Output"})
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
	WireLib.TriggerOutput(self, "O2Output", 0)
end

function ENT:Idle()
	if self.IsIdle then return end
	self:SetIdle(true)
	WireLib.TriggerOutput(self, "O2Output", 0)
end

function ENT:DoThink()
	if !self.IsActive then return end
	
	local env = self:GetEnv()
	if !env:IsPlanet() then self:Idle() return end
	local energy = self:GetResourceAmount("energy")
	local oxygen = math.min(env:GetAtmosphereResource("oxygen"), self.data.oxygen * self.Mult)

	if oxygen <= 0 then self:Idle() return end
	if energy < oxygen * self.data.energy then self:Idle() return end
	
	self:ConsumeResource("energy", oxygen * self.data.energy)
	oxygen = env:ConsumeAtmosphere("oxygen", oxygen)
	
	self:SupplyResource("oxygen", oxygen)
	WireLib.TriggerOutput(self, "O2Output", oxygen)
	
	self:Work()
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end