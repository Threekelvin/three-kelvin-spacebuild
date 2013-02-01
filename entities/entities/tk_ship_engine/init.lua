AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
    self.data = {}
    self.Eff = 0
    self.Aim = false
    self.Thrust = Vector(0, 0, 0)
    self.AngThrust = Angle(0, 0, 0)
    self.AimAngle = Angle(0, 0, 0)
    self.RotateAng = Angle(0, 0, 0)
    self.ShouldLevel = false
    self.ShouldFreeze = false
    self.MaxThrust = 50
    self.Ents = {self}
    
    self:SetNWBool("Generator", true)
    
    self.Inputs = WireLib.CreateInputs(self, 
    {"Activate", "Thrust [VECTOR]", "AngThrust [ANGLE]", "AimAngle [ANGLE]", "Rotate [ANGLE]", "Level", "Freeze", "MaxThrust"})
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
        self.Thrust = value:GetNormal()
    elseif iname == "AngThrust" then
        self.AngThrust = value
        self.Aim = false
    elseif iname == "AimAngle" then
        self.AimAngle = value
        self.Aim = true
    elseif iname == "Rotate" then
        self.RotateAng = value
    elseif iname == "Level" then
        self.ShouldLevel = tobool(value)
    elseif iname == "Freeze" then
        self.ShouldFreeze = tobool(value)
    elseif iname == "MaxThrust" then
        self.MaxThrust = 50
    end
end

function ENT:TurnOn()
	if self:GetActive() || !self:IsLinked() then return end
    self:SetActive(true)
    
    for k,v in pairs(self:GetConstrainedEntities()) do
        if !IsValid(v) then continue end
        local phys = v:GetPhysicsObject()
        if !IsValid(phys) then continue end
        phys:EnableMotion(true)
        phys:Wake()
    end
end

function ENT:TurnOff()
	if !self:GetActive() then return end
	self:SetActive(false)
    
    if self.ShouldFreeze then
        for k,v in pairs(self:GetConstrainedEntities()) do
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
    self.Eff = eff
    self.Ents = self:GetConstrainedEntities()
	self.data.power = table.Count(self.Ents) * (5 * self.MaxThrust / 50)
    if !self:Work() then return end
end

function ENT:Think()
    if !self:GetActive() then return end
    local parent = IsValid(self:GetParent()) && self:GetParent() || self
    
    local Thrust = Vector(self.Thrust.x * self.MaxThrust, self.Thrust.y * self.MaxThrust * 0.25, self.Thrust.z * self.MaxThrust * 0.25) * self.Eff
    Thrust = parent:LocalToWorld(Thrust) - parent:GetPos()
    
    for _,ent in pairs(self.Ents) do
        if !IsValid(ent) then continue end
        local phys = ent:GetPhysicsObject()
        if !IsValid(phys) then continue end
        phys:SetVelocity(Thrust)
        phys:AddAngleVelocity(phys:GetAngleVelocity() * -1)
        
        if self.Aim then
        
        end
    end
    
    self:NextThink(CurTime())
    return true
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end