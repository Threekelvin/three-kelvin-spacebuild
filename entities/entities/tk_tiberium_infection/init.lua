AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self:SetNotSolid(true)
    self:SetModel("models/tiberium/tiberium_crystal3.mdl")
    self:SetMaterial("models/tiberium_g")
    self:SetColor(Color(0, math.random(130, 170), 0, 255))
end