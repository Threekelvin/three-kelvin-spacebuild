AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local ModelList = {
	[1] = "models/ce_ls3additional/asteroids/asteroid_200.mdl",
	[2] = "models/ce_ls3additional/asteroids/asteroid_250.mdl",
	[3] = "models/ce_ls3additional/asteroids/asteroid_300.mdl",
	[4] = "models/ce_ls3additional/asteroids/asteroid_350.mdl",
	[5] = "models/ce_ls3additional/asteroids/asteroid_400.mdl",
	[6] = "models/ce_ls3additional/asteroids/asteroid_450.mdl",
	[7] = "models/ce_ls3additional/asteroids/asteroid_500.mdl"
}

function ENT:GetField()
	return {}
end

function ENT:Initialize()
	self:SetModel(table.Random(ModelList))
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Wake()
		self.MaxOre = math.Round((phys:GetVolume() / 2000) * math.Rand(0.75, 1.25))
		self.Ore = self.MaxOre
	else
		self.MaxOre = 0
		self.Ore = 0
	end
end

function ENT:Think()	
	if !self.Ore || self.Ore <= 0 then
		self:Remove()
	end
	
	self:NextThink(CurTime() + 1)
	return true
end