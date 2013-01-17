AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')


function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:SetNWBool("Generator", true)
	
	self.Inputs = Wire_CreateInputs(self, {"On"})
	self.Outputs = Wire_CreateOutputs(self, {"On", "Remaining", "Max"})
end

function ENT:TurnOn()
	if self:GetActive() || !self:IsLinked() then return end
	self:SetActive(true)
	WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
	if !self:GetActive() then return end
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

function ENT:DoThink(eff)
	if !self:GetActive() then return end
	if !self:Work() then return end
    eff = eff == 1
	
	local trace = util.QuickTrace(self:LocalToWorld(Vector(0,0,30)), self:GetUp() * 1000, self)
	
	if IsValid(trace.Entity) then
		local ent = trace.Entity
		if ent:GetClass() == "tk_roid" then
            local ore = eff && ent.Ore || math.random(0, 10000)
			WireLib.TriggerOutput(self, "Remaining", ore)
			WireLib.TriggerOutput(self, "Max", eff && ent.MaxOre || math.max(math.random(0, 10000), ore))
			return
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