AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.Entity:SetModel("models/Tiberium/factory_panel.mdl")
    self.Entity:PhysicsInit(SOLID_VPHYSICS)
    self.Entity:SetMoveType(MOVETYPE_NONE)
    self.Entity:SetSolid(SOLID_VPHYSICS)
    self.Entity:SetUseType(SIMPLE_USE)

    local phys = self.Entity:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:EnableMotion(false)
    end
end

function ENT:Use(act, cal)
    if !IsValid(act) or !act:IsPlayer() then return end
    if act:IsAFK() then return end
    umsg.Start("3k_terminal_open", act)
    umsg.End()
end