DEFINE_BASECLASS("rd_base")
ENT.Category = "3K Spacebuild"
ENT.PrintName = "3K Tiberium Extractor"
ENT.Author = "Ghost400"

function ENT:GetCrystal()
    return self:GetNWInt("crystal", 0)
end
