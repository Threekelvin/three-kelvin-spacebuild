
DEFINE_BASECLASS("gmod_base")

ENT.Category = "3K Spacebuild"
ENT.PrintName = "Resource Node"
ENT.Author = "Ghost400"

ENT.Spawnable = false
ENT.AdminSpawnable = false

function ENT:GetNetID()
	return self:GetNWInt("NetID", 0)
end

function ENT:GetRange()
	return self:GetNWInt("Range", 0)
end