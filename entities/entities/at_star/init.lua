AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self.atmosphere.name = "Star"
    self.atmosphere.priority = 1
end

function ENT:IsStar()
    return true
end