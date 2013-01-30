AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')


function ENT:Initialize()
	self.BaseClass.Initialize(self)
    self.Inputs = WireLib.CreateInputs(self, {"Activate", "Thrust", "AngThrust", "Level", "Freeze", "MaxThrust"}, {"Number", "Vector", "Angle"})
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	
end

function ENT:TriggerInput(iname, value)
    if iname == "Activate" then

	end
end

function ENT:TurnOn()
	if self:GetActive() || !self:IsLinked() then return end
    self:SetActive(true)
end

function ENT:TurnOff()
	if !self:GetActive() then return end
	self:SetActive(false)
end

function ENT:DoThink(eff)
	if !self:GetActive() then return end
    
	
    if !self:Work() then return end
   
end

function ENT:Think()

end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end