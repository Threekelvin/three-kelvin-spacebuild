include('shared.lua')

local function Add(array, data)
	array[array.idx] = data
	array.idx = array.idx + 1
end

function ENT:Draw()
	self:DrawModel()

	local size = self:OBBMaxs() - self:OBBMins()
	local width, height = 0.8*size.x, 0.7*size.y
	local pos = self:LocalToWorld( self:OBBCenter() + 0.5*Vector( -width, height, size.z-0.75 ) )
	local scale = 10.0
	cam.Start3D2D( pos, self:GetAngles(), 1.0/scale )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 0, 0, width*scale, height*scale )
		surface.SetFont( "Trebuchet22" )
		surface.SetTextColor( 200, 200, 200, 255 )
		surface.SetTextPos( 15, 15 )
		surface.DrawText( "BEEP BOOP: I am a robot\nrobot\nROBOT\nROOOOOBBBOOOOTTT" )
	cam.End3D2D()

	if (self:GetPos() - LocalPlayer():GetPos()):LengthSqr() > 262144 then return end
	if LocalPlayer():GetEyeTrace().Entity != self then return end

	local netdata = self:GetNetTable()
	local owner , uid = self:CPPIGetOwner()
	local name = "World"
	if IsValid(owner) then
		name = owner:Name()
	elseif uid then
		name = "Disconnected"
	end

	local OverlayText = {self.PrintName, "\nNetwork ", self:GetNetID(), "\nOwner: ", name, "\nRange: ", self:GetRange(), "\n", idx = 9}

	if table.Count(netdata.res) > 0 then
		Add(OverlayText, "\nResources:\n")
		for k,v in pairs(netdata.res) do
			Add(OverlayText, TK.RD.GetResourceName(k))
			Add(OverlayText, ": ")
			Add(OverlayText, v.cur)
			Add(OverlayText, "/")
			Add(OverlayText, v.max)
			Add(OverlayText, "\n")
		end
	end

	OverlayText.idx = nil

	AddWorldTip(nil, table.concat(OverlayText, ""), nil, self:LocalToWorld(self:OBBCenter()))
end

function ENT:GetNetTable()
	return TK.RD.GetNetTable(self:GetNetID())
end

function ENT:GetResourceAmount(idx)
	return TK.RD.GetNetResourceAmount(self:GetNetID(), idx)
end

function ENT:GetUnitResourceAmount(idx)
	return 0
end

function ENT:GetResourceCapacity(idx)
	return TK.RD.GetNetResourceCapacity(self:GetNetID(), idx)
end

function ENT:GetUnitResourceCapacity(idx)
	return 0
end