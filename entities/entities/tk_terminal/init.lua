AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
util.AddNetworkString("3k_terminal_open")

function ENT:Initialize()
    self:SetModel("models/Tiberium/factory_panel.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()

    if phys:IsValid() then
        phys:Wake()
        phys:EnableMotion(false)
    end
end

function ENT:Use(act, cal)
    if not IsValid(act) or not act:IsPlayer() then return end
    if act:IsAFK() then return end
    net.Start("3k_terminal_open")
    net.WriteEntity(self)
    net.Send(act)
end
