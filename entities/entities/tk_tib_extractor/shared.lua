
DEFINE_BASECLASS("rd_base")

ENT.Category = "3K Spacebuild"
ENT.PrintName = "3K Tiberium Extractor"
ENT.Author = "Ghost400"

ENT.Spawnable = false
ENT.AdminSpawnable = false

game.AddParticles("particles/medicgun_beam_blue_trail")
game.AddParticles("particles/medicgun_beam_red_invunglow")
game.AddParticles("particles/medicgun_beam_attrib_overheal")
game.AddParticles("particles/medicgun_beam_attrib_healing")

function ENT:GetCrystal()
	return self:GetNWInt("crystal", 0)
end