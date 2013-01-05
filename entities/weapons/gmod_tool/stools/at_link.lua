TOOL.Category		= "Connection"
TOOL.Name			= "Atmosphere Regulator Link Tool"
TOOL.Command		= nil
TOOL.ConfigName		= nil
TOOL.Tab = "3K Spacebuild"
TOOL.Selected = {}
TOOL.SelectedColor = {}

if CLIENT then
	language.Add("tool.at_link.name", "Atmosphere Regulator Link Tool")
	language.Add("tool.at_link.desc", "Use to Link Entities To A Atmosphere Regulator")
	language.Add("tool.at_link.0", "Left Click: Select/Unselect Props    Right Click: Link To Atmosphere Regulator    Reload: Unselect All")
else
	function TOOL:SelectEnt(ent)
		if !IsValid(ent) then return end
		local entid = ent:EntIndex()
		self.Selected[entid] = ent
		self.SelectedColor[entid] = {ent:GetColor()}
		ent:SetColor(0, 200, 0, 200)
	end

	function TOOL:UnselectEnt(ent)
		if !IsValid(ent) then return end
		local entid = ent:EntIndex()
		self.Selected[entid] = nil
		local col = self.SelectedColor[entid]
		ent:SetColor(col[1], col[2], col[3], col[4])
		self.SelectedColor[entid] = nil
	end

	function TOOL:IsEntSelected(ent)
		if !IsValid(ent) then return false end
		if !self.Selected[ent:EntIndex()] then return false end
		return true
	end

	function TOOL:CanSelect(ent)
		if !IsValid(ent) then return false end
		if ent:GetClass() == "at_atmosphere_regulator" then return false end
		if ent:BoundingRadius() < 100 then return false end
		return true
	end
end

function TOOL:LeftClick(trace)
	if !IsValid(trace.Entity) then return end
	if CLIENT then return true end
	local ply = self:GetOwner()
	local ent = trace.Entity
	
	if self:IsEntSelected(ent) then
		self:UnselectEnt(ent)
	elseif self:CanSelect(ent) then
		self:SelectEnt(ent)
	else
		ply:SendLua('GAMEMODE:AddNotify("Can Not Select", NOTIFY_ERROR, 3)')
	end	
	return true
end

function TOOL:RightClick(trace)
	if !IsValid(trace.Entity) then return end
	if CLIENT then return true end
	local ply = self:GetOwner()
	local ent = trace.Entity
	
	if ent:GetClass() != "at_atmosphere_regulator" then 
		ply:SendLua('GAMEMODE:AddNotify("Can Not Link", NOTIFY_ERROR, 3)')
		return
	end
	
	ent.hullents = table.Copy(self.Selected)
	for k,v in pairs(self.Selected) do
		self:UnselectEnt(v)
	end
	
	self.Selected = {}
	self.SelectedColor = {}
	return true
end

function TOOL:Reload(trace)
	if CLIENT then return true end
	for k,v in pairs(self.Selected) do
		self:UnselectEnt(v)
	end
	
	self.Selected = {}
	self.SelectedColor = {}
	return true
end

function TOOL:Think()

end

function TOOL.BuildCPanel(CPanel)

end