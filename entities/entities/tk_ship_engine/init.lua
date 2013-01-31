AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
    self.data = {}
    self.Thrust = Vector(0, 0, 0)
    self.AngThrust = Angle(0, 0, 0)
    self.ShouldLevel = false
    self.ShouldFreeze = false
    self.MaxThrust = 50
    self.Ents = {self}
    
    self.Inputs = WireLib.CreateInputs(self, 
    {"Activate",    "Thrust",   "AngThrust",    "AimAngle", "Level",    "Freeze",   "MaxThrust"}, 
    {"NORMAL",      "VECTOR",   "ANGLE",        "ANGLE",    "NORMAL",   "NORMAL",   "NORMAL"})
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	
end

function ENT:TriggerInput(iname, value)
    if iname == "Activate" then
        if tobool(value) then
            self:TurnOn()
        else
            self:TurnOff()
        end
	elseif iname == "Thrust" then
    
    elseif iname == "AngThrust" then
    
    elseif iname == "Level" then
        self.ShouldLevel = tobool(value)
    elseif iname == "Freeze" then
        self.ShouldFreeze = tobool(value)
    elseif iname == "MaxThrust" then
    
    end
end

function ENT:TurnOn()
	if self:GetActive() || !self:IsLinked() then return end
    self:SetActive(true)
    
    self.Ents = self:GetConstrainedEntities()
end

function ENT:TurnOff()
	if !self:GetActive() then return end
	self:SetActive(false)
    
    if self.ShouldFreeze then
        for k,v in pairs(self.Ents) do
            if !IsValid(v) then continue end
            local phys = v:GetPhysicsObject()
            if !IsValid(phys) then continue end
            phys:EnableMotion(false)
            phys:Wake()
        end
    end
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