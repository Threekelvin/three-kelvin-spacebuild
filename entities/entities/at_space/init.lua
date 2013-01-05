AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self:DefaultAtmosphere()
	self.atmosphere.name = "Space"
	
	self.atmosphere.noclip 	= false
	self.atmosphere.sunburn	= false
	self.atmosphere.wind 	= false
	self.atmosphere.static 	= true
	
	self.atmosphere.priority	= 4
	self.atmosphere.radius 		= 0
	self.atmosphere.gravity 	= 0
	self.atmosphere.windspeed 	= 0
	self.atmosphere.tempcold	= 3
	self.atmosphere.temphot		= 3
end

function ENT:StartTouch()

end

function ENT:EndTouch()

end

function ENT:Think()

end

function ENT:OnRemove()

end

function ENT:IsSpace()
	return true
end

function ENT:GetRadius()
	return 0
end

function ENT:GetVolume()
	return 1
end

function ENT:GetResourceAmount(res)
	return 0
end

function ENT:GetResourcePercent(res)
	return 0
end

function ENT:GetTrueResourcePercent(res)
	return 0
end

function ENT:DoTemp(ent)
	if !IsValid(ent) then return 3, false end

	return 3, self:InSun(ent)
end