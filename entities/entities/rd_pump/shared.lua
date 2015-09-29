DEFINE_BASECLASS("rd_base")
ENT.Category = "3K Spacebuild"
ENT.PrintName = "Resource Pump"
ENT.Author = "Ghost400"

function ENT:GetLinked()
    return self:GetNWInt("Linked", 0)
end

function ENT:GetRange()
    return self:GetNWInt("Range", 0)
end
