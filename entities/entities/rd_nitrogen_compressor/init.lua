AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:SetNWBool("Generator", true)
	self:AddResource("nitrogen", 0, true)
	self:AddSound("l", 3, 65)
	
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
	
	local env = self:GetEnv()
	if !env:IsPlanet() || !env:HasResource("nitrogen") then self:TurnOff() return end
    if !self:Work() then return end
    
	local nitrogen = self.data.nitrogen * self.mult * env:GetResourcePercent("nitrogen") / 100 * eff
	self:SupplyResource("nitrogen", nitrogen)
	WireLib.TriggerOutput(self, "Output", nitrogen)
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end