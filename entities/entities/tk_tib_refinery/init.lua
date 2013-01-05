AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/Techbot/ref/ref.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
	
	local ent = ents.Create("tk_tib_refinery_liquid")
	ent:SetPos(self:LocalToWorld(Vector(-285,-5,100)))
	ent:SetAngles(self:GetAngles())
	ent:Spawn()
	ent:SetParent(self)
end