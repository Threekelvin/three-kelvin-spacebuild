include('shared.lua')

local function Add(array, data)
	array[array.idx] = data
	array.idx = array.idx + 1
end

function ENT:Draw()
	self:DrawModel()
	if Wire_Render then Wire_Render(self) end
	
	if !self:GetOverlay() then return end
	if (self:GetPos() - LocalPlayer():GetPos()):LengthSqr() > 262144 then return end
	if LocalPlayer():GetEyeTrace().Entity != self then return end
	
	local entdata = self:GetEntTable()
	local res, gen = {}, {}
	for k,v in pairs(entdata.res) do
		if v.gen then
			gen[TK.RD.GetResourceName(k)] = k
		else
			res[TK.RD.GetResourceName(k)] = k
		end
	end
	local owner , uid = self:CPPIGetOwner()
	local name = "World"
	if IsValid(owner) then
		name = owner:Name()
	elseif uid then
		name = "Disconnected"
	end 
	
	local OverlayText = {self.PrintName, "\n", idx = 3}
	if entdata.netid == 0 then
		Add(OverlayText, "Not Connected\n")
	else
		Add(OverlayText, "Network ")
		Add(OverlayText, entdata.netid)
		Add(OverlayText, "\n")
	end
	Add(OverlayText, "Owner: ")
	Add(OverlayText, name)
	Add(OverlayText, "\n")
	if self:GetPowered() then
		Add(OverlayText, "Status: ")
		Add(OverlayText, self:GetActive() && (self:GetIdle() && "Idle" || "On") || "Off")
		Add(OverlayText, "\n")
	end
	if table.Count(res) > 0 then
		Add(OverlayText, "\nResources:\n")
		for k,v in pairs(res) do
			Add(OverlayText, k)
			Add(OverlayText, ": ")
			Add(OverlayText, self:GetResourceAmount(v))
			Add(OverlayText, "/")
			Add(OverlayText, self:GetResourceCapacity(v))
			Add(OverlayText, "\n")
		end
	end
	if table.Count(gen) > 0 then
		Add(OverlayText, "\nGenerates:\n")
		for k,v in pairs(gen) do
			Add(OverlayText, k)
			Add(OverlayText, ": ")
			Add(OverlayText, self:GetResourceAmount(v))
			Add(OverlayText, "/")
			Add(OverlayText, self:GetResourceCapacity(v))
			Add(OverlayText, "\n")
		end
	end
	
	OverlayText[OverlayText.idx - 1] = "\n"
	OverlayText.idx = nil
	AddWorldTip(nil, table.concat(OverlayText, ""), nil, self:LocalToWorld(self:OBBCenter()))
end

function ENT:Think()

end

function ENT:DoMenu()

end

function ENT:DoCommand(cmd, ...)
	RunConsoleCommand("TKRD_EntCmd", self:EntIndex(), cmd, unpack(arg))
end

function ENT:GetEntTable()
	return TK.RD.GetEntTable(self:EntIndex())
end

function ENT:GetResourceAmount(idx)
	return TK.RD.GetEntResourceAmount(self, idx)
end

function ENT:GetUnitResourceAmount(idx)
	return TK.RD.GetUnitResourceAmount(self, idx)
end

function ENT:GetResourceCapacity(idx)
	return TK.RD.GetEntResourceCapacity(self, idx)
end

function ENT:GetUnitResourceCapacity(idx)
	return TK.RD.GetUnitResourceCapacity(self, idx)
end
