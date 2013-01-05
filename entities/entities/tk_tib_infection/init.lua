AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/tiberium/tiberium_crystal3.mdl")
	self.Entity:SetNotSolid(true)
	self.Entity:SetMaterial("models/tiberium_g")
	self.Entity:SetColor(Color(0, math.random(130, 170), 0, 255))
end

function ENT:Think()
	if !IsValid(self:GetParent()) then
		self:Remove()
	end
end