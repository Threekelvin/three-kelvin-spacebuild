AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	self.atmosphere.name = "Star"
	
	self.atmosphere.noclip 	= false
	self.atmosphere.sunburn = false
	self.atmosphere.wind 	= false
	self.atmosphere.static 	= false
	
	self.atmosphere.priority	= 1
	self.atmosphere.gravity 	= 1
	self.atmosphere.windspeed 	= 0
	self.atmosphere.tempcold 	= 1000
	self.atmosphere.temphot 	= 1000

	self.atmosphere.percent.empty = 0
	self.atmosphere.percent.hydrogen = 100
end

function ENT:IsStar()
	return true
end