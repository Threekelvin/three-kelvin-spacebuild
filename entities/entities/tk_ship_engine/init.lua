AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local math = math

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
    self.MaxThrust = 100
    self.RadMax = 15
    self.RadMin = 5
    self.Ents = {}
    
    self:SetNWBool("Generator", true)
    
    self.Inputs = WireLib.CreateInputs(self, 
    {"Activate", "Thrust [VECTOR]", "AngThrust [ANGLE]", "AimAngle [ANGLE]", "Rotate [ANGLE]", "Level", "MaxThrust"})
end

function ENT:OnRemove()
	self.BaseClass.OnRemove(self)
	
    for k,v in pairs(self.Ents) do
        if !IsValid(v) then continue end
        self:ResetGravity(v)
    end
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
        self.AngThrust = Angle(value.x, value.y, value.z)
        self.Aim = false
    elseif iname == "AimAngle" then
        self.AimAngle = Angle(value.x, value.y, value.z)
        self.Aim = true
    elseif iname == "Rotate" then
        self.RotateAng = Angle(value.x, value.y, value.z)
    elseif iname == "Level" then
        self.ShouldLevel = tobool(value)
    elseif iname == "MaxThrust" then
        self.MaxThrust = 50
    end
end

function ENT:DisableGravity(ent)
     local phys = ent:GetPhysicsObject()
    if !IsValid(phys) then return end
    
    ent.tk_env.nogravity = true
    phys:EnableGravity(false)
    phys:EnableDrag(false)
    
    phys:EnableMotion(true)
    phys:Wake()
end

function ENT:ResetGravity(ent)
    local phys = ent:GetPhysicsObject()
    if !IsValid(phys) then return end
    
    ent.tk_env.nogravity = nil
    ent.tk_env.gravity = -1
    local env = ent:GetEnv()
    env:DoGravity(ent)
    
    phys:EnableMotion(false)
    phys:Wake()
end

function ENT:TurnOn()
	if self:GetActive() || !self:IsLinked() then return end
    self:SetActive(true)
    
    self.Ents = self:GetConstrainedEntities()
    for k,v in pairs(self.Ents) do
       self:DisableGravity(v)
    end
end

function ENT:TurnOff()
	if !self:GetActive() then return end
	self:SetActive(false)
    
    for k,v in pairs(self.Ents) do
        if !IsValid(v) then continue end
        self:ResetGravity(v)
    end
end

function ENT:DoThink(eff)
	if !self:GetActive() then return end
    self.Eff = eff
    
    local conents = self:GetConstrainedEntities()
    for k,v in pairs(conents) do
        if self.Ents[k] then continue end
        self:DisableGravity(v)
    end
    
    for k,v in pairs(self.Ents) do
        if !IsValid(v) || conents[k] then continue end
        self:ResetGravity(v)
    end

    self.Ents = conents
	self.data.power = table.Count(self.Ents) * (-5 * self.MaxThrust / 100)
    if !self:Work() then return end
end

function ENT:Think()
    if !self:GetActive() then return end
    local parent = IsValid(self:GetParent()) && self:GetParent() || self
    local pos, ang = parent:GetPos(), parent:GetAngles() + self.RotateAng
    local propcount = table.Count(self.Ents)
    
    local vec = Vector(self.Thrust.x * self.MaxThrust, self.Thrust.y * self.MaxThrust * 0.25, self.Thrust.z * self.MaxThrust * 0.25) * self.Eff
    local Thrust,_ = LocalToWorld(vec, Angle(0,0,0), pos, ang)
    Thrust = Thrust - pos
    
    for _,ent in pairs(self.Ents) do
        if !IsValid(ent) then continue end
        local phys = ent:GetPhysicsObject()
        if !IsValid(phys) then continue end
        phys:SetVelocity(Thrust)
        phys:AddAngleVelocity(phys:GetAngleVelocity() * -1)
    end
    
    local AngThrust
    if self.Aim then
        AngThrust = self.AimAngle - ang
    else
        AngThrust = self.AngThrust
    end
    
    if self.ShouldLevel then
        AngThrust = Angle(-ang.p, AngThrust.y, -ang.r)
    end
    
    local Mult = math.Max(self.RadMax - (0.2 * propcount), self.RadMin)
    AngThrust = Vector((AngThrust.r + 180) % 360 - 180, (AngThrust.p + 180) % 360 - 180, (AngThrust.y + 180) % 360 - 180)
    AngThrust = Vector(
        math.abs(AngThrust.x) < Mult && math.floor(AngThrust.x) || (AngThrust.x / math.abs(AngThrust.x) * Mult),
        math.abs(AngThrust.y) < Mult && math.floor(AngThrust.y) || (AngThrust.y / math.abs(AngThrust.y) * Mult),
        math.abs(AngThrust.z) < Mult && math.floor(AngThrust.z) || (AngThrust.z / math.abs(AngThrust.z) * Mult)
    )
    
    local phys = parent:GetPhysicsObject()
    phys:AddAngleVelocity(AngThrust * self.Eff)
    
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