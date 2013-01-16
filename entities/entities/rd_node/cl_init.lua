include('shared.lua')

local function Add(array, data)
	array[array.idx] = data
	array.idx = array.idx + 1
end

function ENT:Draw()
	self:DrawModel()
    if (self:GetPos() - LocalPlayer():GetPos()):LengthSqr() > 262144 then return end
    
	local netdata = self:GetNetTable()
	local owner , uid = self:CPPIGetOwner()
	local name = "World"
	if IsValid(owner) then
		name = owner:Name()
	elseif uid then
		name = "Disconnected"
	end

	local OverlayText = {self.PrintName, "\nNetwork ", self:GetNetID(), "\nOwner: ", name, "\nRange: ", self:GetRange(), "\n", idx = 9}
    Add(OverlayText, "\nPower Grid: ")
    
    netdata.powergrid = netdata.powergrid || 0
    if netdata.powergrid > 0 then
        Add(OverlayText, "+")
        Add(OverlayText, netdata.powergrid)
        Add(OverlayText, "MW")
    else
        Add(OverlayText, netdata.powergrid)
        Add(OverlayText, "MW")
    end

	if table.Count(netdata.res) > 0 then
		Add(OverlayText, "\n\nResources:\n\n")
		for k,v in pairs(netdata.res) do
			Add(OverlayText, TK.RD:GetResourceName(k))
			Add(OverlayText, ": ")
			Add(OverlayText, v.cur)
			Add(OverlayText, "/")
			Add(OverlayText, v.max)
			Add(OverlayText, "\n")
		end
	end

	OverlayText.idx = nil

	local ScreenText = string.Explode( "\n", table.concat( OverlayText ) )
	local size = self:OBBMaxs() - self:OBBMins()
	local width, height = 0.8*size.x, 0.7*size.y
	local pos = self:LocalToWorld( self:OBBCenter() + 0.5*Vector( -width, height, size.z-0.75 ) )
	local scale = 10.0
	local line
	cam.Start3D2D( pos, self:GetAngles(), 1.0/scale )
		surface.SetDrawColor( 0, 0, 0, 255 )
		surface.DrawRect( 0, 0, width*scale, height*scale )
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetFont( "Trebuchet24" )
		local xOffset,yOffset = surface.GetTextSize( "Test string, please ignore." )
		for i=1,#ScreenText do
			line = ScreenText[i]
			surface.SetTextPos( 15 + 0.5*width*scale*( ( i + 1 )%2 ), 15 + math.floor( 0.5*( i - 1 ) )*yOffset ) 
			surface.DrawText( line )
		end
	cam.End3D2D()
end

function ENT:GetNetTable()
	return TK.RD:GetNetTable(self:GetNetID())
end

function ENT:GetResourceAmount(idx)
	return TK.RD:GetNetResourceAmount(self:GetNetID(), idx)
end

function ENT:GetUnitResourceAmount(idx)
	return 0
end

function ENT:GetResourceCapacity(idx)
	return TK.RD:GetNetResourceCapacity(self:GetNetID(), idx)
end

function ENT:GetUnitResourceCapacity(idx)
	return 0
end