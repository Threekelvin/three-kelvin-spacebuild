include('shared.lua')

local Mat1 = Material("straw/strawtile_diffuse")

function ENT:Draw()
	
    local scale = Vector(1.22, 1.22, 0)
    local mat = Matrix()
    mat:Scale(scale)
    
	self:EnableMatrix("RenderMultiply", mat)
    
	render.MaterialOverride(Mat1)
	self:DrawModel()
    
    scale = Vector(1.22,1.22,0.5)
	mat = Matrix()
    mat:Scale(scale)
    
	self:EnableMatrix("RenderMultiply", mat)
	render.MaterialOverride(nil)
	self:DrawModel()
end