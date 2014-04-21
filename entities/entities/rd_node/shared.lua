
DEFINE_BASECLASS("rd_base")

ENT.Category = "3K Spacebuild"
ENT.PrintName = "Resource Node"
ENT.Author = "Ghost400"



function ENT:GetNetID()
    return self:GetNWInt("NetID", 0)
end

function ENT:GetRange()
    return self:GetNWInt("Range", 0)
end