TOOL.Category		= "Construction"
TOOL.Name			= "#Weight Tool"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar["set"] = "1"

local Weight = {}

if CLIENT then
	language.Add("tool.weight.name", "Weight Tool")
	language.Add("tool.weight.desc", "Set the weight")
	language.Add("tool.weight.0", "Primary: Set   Secondary: Copy   Reload: Reset")
	language.Add("tool.weight.set", "Weight:")
	language.Add("tool.weight_set.desc", "Set the weight")
end

local function SetMass(ply, ent, data)
	if CLIENT then return end
	if !data.Mass then return end
	local mass = math.Clamp(data.Mass, 0.0001, 50000)
	
	local physobj = ent:GetPhysicsObject()
	if IsValid(physobj) then physobj:SetMass(mass) end
	duplicator.StoreEntityModifier(ent, "mass", {Mass = mass})
end

duplicator.RegisterEntityModifier("mass", SetMass)

local function CanSetWeight(trace)
	if !IsValid(trace.Entity) then return false end
	if trace.Entity:IsPlayer() then return false end
	if SERVER and !IsValid(trace.Entity:GetPhysicsObject()) then return false end
	return true
end

function TOOL:LeftClick(trace)
	if CLIENT then return CanSetWeight(trace) end
	if !CanSetWeight(trace) then return false end
	local ent = trace.Entity
	
	if !Weight[ent:GetModel()] then 
		Weight[ent:GetModel()] = ent:GetPhysicsObject():GetMass() 
	end
	
	local mass = tonumber(self:GetClientInfo("set"))
	
	SetMass(nil, ent, {Mass = mass})
	return true
end

function TOOL:RightClick( trace )
	if CLIENT then return CanSetWeight(trace) end
	if !CanSetWeight(trace) then return false end
	
	local mass = trace.Entity:GetPhysicsObject():GetMass()
	self:GetOwner():ConCommand("weight_set "..mass);
	return true
end

function TOOL:Reload(trace)
	if CLIENT then return CanSetWeight(trace) end
	if !CanSetWeight(trace) then return false end
	
	local ply = self:GetOwner()
	local mass = Weight[trace.Entity:GetModel()]
	if !mass then return end
	
	SetMass(nil, trace.Entity, {Mass = mass})
	return true
end

function TOOL:Think()
	if CLIENT then return end
	local ply = self:GetOwner()
	local weapon = ply:GetActiveWeapon()
	if !IsValid(weapon) || weapon:GetClass() != "gmod_tool" then return end
	if ply:GetInfo("gmod_toolmode") != "weight" then return end
	local trace = ply:GetEyeTrace()
	if !CanSetWeight(trace) then return end
	ply:SetNWFloat("Mass", trace.Entity:GetPhysicsObject():GetMass())
end

function TOOL.BuildCPanel( cp )
	cp:AddControl( "Header", { Text = "#Tool_weight_name", Description	= "#Tool_weight_desc" }  )

	local params = { Label = "#Presets", MenuButton = 1, Folder = "weight", Options = {}, CVars = {} }
	
	params.Options.default = { weight_set = 3 }
	table.insert( params.CVars, "weight_set" )
	
	cp:AddControl("ComboBox", params )
	cp:AddControl("Slider", { Label = "#Tool_weight_set", Type = "Numeric", Min = "0", Max = "50000", Command = "weight_set" } )
end

if CLIENT then
	hook.Add("HUDPaint", "WeightToolTip", function()
		local ply = LocalPlayer()
		local weapon = ply:GetActiveWeapon()
		if !IsValid(weapon) || weapon:GetClass() != "gmod_tool" then return end
		if ply:GetInfo("gmod_toolmode") != "weight" then return end
		
		local trace = ply:GetEyeTrace()
		if !CanSetWeight(trace) then return end
		
		local mass = ply:GetNWFloat("Mass", 0)
		AddWorldTip(nil, "Weight: "..mass, nil, trace.Entity:LocalToWorld(trace.Entity:OBBCenter()))
	end)
end






