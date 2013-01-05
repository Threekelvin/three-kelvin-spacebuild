include('shared.lua')

function ENT:Draw()
	local ply = self:GetParent()
	if !IsValid(ply) then return end
	
	self:SetRenderOrigin(ply:GetPos() + Vector(0,0,90))
	self:SetRenderAngles(Angle(0,SysTime() * 50,0))
	self:DrawModel()
end