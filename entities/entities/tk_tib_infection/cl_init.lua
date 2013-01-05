include('shared.lua')
local OutlineDang = Material("models/alyx/emptool_glow")

function ENT:Initialize()
	self.MdlScaleMax = math.Rand(0.1, 0.5)
	self.MdlScale = 0
end

function ENT:Draw()
	self:DrawModel()
    
    local scale = Vector(self.MdlScale, self.MdlScale, self.MdlScale) * 1.1
    local mat = Matrix()
    mat:Scale(scale)
	
	self:EnableMatrix("RenderMultiply", mat)
	render.MaterialOverride(OutlineDang)
	self:DrawModel()
    
    scale = Vector(self.MdlScale, self.MdlScale, self.MdlScale)
	mat = Matrix()
    mat:Scale(scale)
	
    self:EnableMatrix("RenderMultiply", mat)
	render.MaterialOverride(nil)
	self:SetModelScale(1, 0)
end

function ENT:DrawTranslucent()
	self:Draw()
end

function ENT:Think()
	if self.MdlScale < self.MdlScaleMax then
		self.MdlScale = self.MdlScale + 0.0002
	end
end
