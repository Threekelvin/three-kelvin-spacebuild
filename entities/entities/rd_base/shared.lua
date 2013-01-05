
DEFINE_BASECLASS("base_wire_entity")

ENT.Category = "3K Spacebuild"
ENT.PrintName = "3K RD Base Ent"
ENT.Author = "Ghost400"

ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:GetActive()
	return self:GetNWBool("Actived", false)
end

function ENT:GetIdle()
	return self:GetNWBool("Idle", false)
end

function ENT:GetPowered()
	return self:GetNWBool("Powered", false)
end

function ENT:GetOverlay()
	return self:GetNWBool("Overlay", true)
end