AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self:ResetSequence(self:LookupSequence("rotate"))
	self.windspeed = 0
	self.speed = 0
	
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	
	self:SetPowered(true)
	self:AddResource("energy", 0, true)
	
	WireLib.CreateOutputs(self, {"On", "Output"})
end

function ENT:Think()
	self.speed = self.speed + 0.01 * (self.windspeed - self.speed)
	if self.speed < 0.0005 then self.speed = 0 end
	self:SetPlaybackRate(self.speed)
	self:NextThink(CurTime())
	return true
end

function ENT:TurnOn()
	if self.Active then return end
	self:SetActive(true)
	WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
	if !self.Active then return end
	self:SetActive(false)
	self.windspeed = 0
	WireLib.TriggerOutput(self, "On", 0)
	WireLib.TriggerOutput(self, "Output", 0)
end

function ENT:Use()

end

function ENT:DoThink()
	local env = self:GetEnv()
	if !env.atmosphere.wind then self:TurnOff() return end
	
	self.windspeed = env.atmosphere.windspeed / 100
	local output = math.floor(self.data.energy * self.windspeed)
	if output < 1 then self:TurnOff() return end
	self:TurnOn()
	self:SupplyResource("energy", output)
	WireLib.TriggerOutput(self, "Output", output)
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end