AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')


function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.device = {1, 3}

	self:SetPowered(true)
	self:AddResource("energy", 0)
	
	self.Inputs = Wire_CreateInputs(self, {"On"})
	self.Outputs = Wire_CreateOutputs(self, {"On", "Remaining", "Max"})
end

function ENT:TurnOn()
	if self.IsActive || !self:IsLinked() then return end
	if self:GetResourceAmount("energy") < 100 then return end
	self:SetActive(true)
	WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
	if !self.IsActive then return end
	self:SetActive(false)
	WireLib.TriggerOutput(self, "On", 0)
	WireLib.TriggerOutput(self, "Remaining", 0)
	WireLib.TriggerOutput(self, "Max", 0)
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
	
	if self:GetResourceAmount("energy") < 100 then
		self:TurnOff()
		return true
	else
		self:ConsumeResource("energy", 100)
	end
	
	local trace = util.QuickTrace(self:LocalToWorld(Vector(0,0,30)), self:GetUp() * 1000, self)
	
	if IsValid(trace.Entity) then
		local ent = trace.Entity
		if ent:GetClass() == "tk_roid" then
			WireLib.TriggerOutput(self, "Remaining", ent.Ore)
			WireLib.TriggerOutput(self, "Max", ent.MaxOre)
			return true
		end
	end
	
	WireLib.TriggerOutput(self, "Remaining", 0)
	WireLib.TriggerOutput(self, "Max", 0)
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:Update()

end