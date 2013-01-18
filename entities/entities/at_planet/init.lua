AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.atmosphere.name = "Planet"
	
	self.atmosphere.noclip 	= true
	self.atmosphere.sunburn = false
	self.atmosphere.wind 	= true
	
	self.atmosphere.priority	= 3
	self.atmosphere.gravity 	= 1
	self.atmosphere.windspeed 	= 0
	self.atmosphere.tempcold 	= 290
	self.atmosphere.temphot 	= 290

    self.atmosphere.resources 	= {}
	
	timer.Create(tostring(self).."_windspeed", 10, 0, function()
		if self.atmosphere.wind then
			self.atmosphere.windspeed = math.random(0, 100)
		end
	end)
end

function ENT:IsPlanet()
	return true
end