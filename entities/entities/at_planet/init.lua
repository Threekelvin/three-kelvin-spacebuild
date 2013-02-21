AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self.atmosphere.name = "Planet"
    self.atmosphere.priority = 3
end

function ENT:IsPlanet()
    return true
end