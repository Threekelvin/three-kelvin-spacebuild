include('shared.lua')

local function Add(array, data)
	array[array.idx] = data
	array.idx = array.idx + 1
end

function ENT:Draw()
	self:DrawModel()
	
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