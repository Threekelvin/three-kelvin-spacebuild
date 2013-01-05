AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/hunter/tubes/circle4x4.mdl")
	self.Entity:SetNotSolid(true)
	self.Entity:SetMaterial("models/shadertest/predator")
	self.Entity:SetColor(Color(0,255,0,255))

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
end
