
DEFINE_BASECLASS("base_wire_entity")

ENT.Category = "3K Spacebuild"
ENT.PrintName = "3K RD Base Ent"
ENT.Author = "Ghost400"

ENT.Spawnable = false
ENT.AdminSpawnable = false


function ENT:GetActive()
    return self:GetNWBool("Active", false)
end

function ENT:IsGenerator()
    return self:GetNWBool("Generator", false)
end