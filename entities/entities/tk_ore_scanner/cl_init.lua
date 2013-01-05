include('shared.lua')

local beam = Material("tripmine_laser")

function ENT:Draw()
	self.BaseClass.Draw(self)
	
	if self:GetActive() then
		local trace = util.QuickTrace(self:LocalToWorld(Vector(0,0,30)), self:GetUp() * 1000, self)
		
		render.SetMaterial(beam)
		render.DrawBeam(self:LocalToWorld(Vector(0,0,30)), trace.HitPos, 5, 0, 1, Color(255,255,255))
	end
end