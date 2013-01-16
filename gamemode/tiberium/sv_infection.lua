
Tib = {}
local Contraptions = {}

function Tib:IsInfected(ent)
	if ent.TibInfect != nil then return true end
	return false
end

local function BlackList(ent)
	if ent:IsPlayer() then return false end
	if ent:IsNPC() then return false end
	if ent:IsWeapon() then return false end
	
	local class = ent:GetClass()
	if class == "gmod_ghost" then return false end
	if class == "prop_door_rotating" then return false end
	if class == "predicted_viewmodel" then return false end
	if class == "phys_magnet" then return true end
	if string.Left(class, 4) == "env_" then return false end
	if string.Left(class, 5) == "info_" then return false end
	if string.Left(class, 5) == "func_" then return false end
	if string.Left(class, 5) == "phys_" then return false end
	if string.Left(class, 6) == "logic_" then return false end
	return true
end

local function CanInfect(ent)
	if !IsValid(ent) then return false end
	if ent:GetNWString("UID", "none") == "none" then return false end
	if Tib:IsInfected(ent) then return false end
	return BlackList(ent)
end

local function ScanNetwork(netid, entlist)
	local node = TK.RD:GetNetTable(netid).node
	if IsValid(node) then
		if !entlist[node:EntIndex()] then
			entlist[node:EntIndex()] = node
			for k,v in pairs(constraint.GetAllConstrainedEntities(node) || {}) do
				entlist[v:EntIndex()] = v
			end
		end
		
		for k,v in pairs(TK.RD:GetConnectedEnts(netid)) do
			if !entlist[v:EntIndex()] then
				entlist[v:EntIndex()] = b
				for l,b in pairs(constraint.GetAllConstrainedEntities(v) || {}) do
					entlist[b:EntIndex()] = b
				end
			end
		end
	end
end

local function ScanForEntities(ent)
	local entities = constraint.GetAllConstrainedEntities(ent) || {}
	local entlist = {}
	local nets = {0}
	
	for k,v in pairs(entities) do
		entlist[v:EntIndex()] = v
	end
	
	for k,v in pairs(entlist) do
		if !v.IsTKRD || v.IsNode then continue end
        local netid = v:GetEntTable().netid
        if !table.HasValue(nets, netid) then
            table.insert(nets, netid)
            ScanNetwork(netid, entlist)
            
            for l,b in pairs(TK.RD:GetConnectedEnts(netid)) do
                if !table.HasValue(nets, b) then
                    table.insert(nets, b)
                    ScanNetwork(b, entlist)
                end
            end
        end
	end
	return entlist
end

local function GetContraption(ent)
	local idx = table.insert(Contraptions, ScanForEntities(ent))
	
	for k,v in pairs(Contraptions[idx]) do
		if !CanInfect(v) then
			Contraptions[idx][k] = nil
		else
			if v:GetClass() == "tk_tib_storage" then
				v.TibContraption = {}
				Tib:Infect(v)
			else
				v.TibContraption = Contraptions[idx]
			end
		end
	end
	return Contraptions[idx]
end

local function SpawnInfetion(ent)
	if ent:BoundingRadius() < 35 then return end
    
    local pos = Vector(1,1,1) * (ent:BoundingRadius() + 250)
    pos:Rotate(Angle(math.random(-180,180), math.random(-180,180), math.random(-180,180)))
    local tracedata = {}
    tracedata.start = ent:LocalToWorld(ent:OBBCenter() + pos)
    tracedata.endpos = ent:LocalToWorld(ent:OBBCenter())
    local trace = util.TraceLine(tracedata)
    
    if IsValid(trace.Entity) && (Tib:IsInfected(trace.Entity) || ent.TibContraption[trace.Entity:EntIndex()] == trace.Entity) then
        local inf = ents.Create("tk_tib_infection")
        inf:SetPos(trace.HitPos)
        inf:SetAngles(trace.HitNormal:Angle() + Angle(90,0,0))
        inf:Spawn()
        inf:SetParent(trace.Entity)
    end
end

local function GarbageCollection()
	for k,v in pairs(Contraptions) do
		local Valid = false
		for l,b in pairs(v) do
			if !Valid && CanInfect(b) then
				Valid = true
			end
		end
		if !Valid then Contraptions[k] = nil end
	end
end

local function InfectionThink(ent, contraption)
	if contraption then
		local Valid = false
		
		for k,v in pairs(contraption) do
			if CanInfect(v) then
				Valid = true
				Tib:Infect(v)
				break
			end
		end
		
		if !Valid then
			GarbageCollection()
		end
	end
	
	if !IsValid(ent) then return end

	local factor = math.Clamp(ent:BoundingRadius() / 100, 1, 3)
	if ent.TibInfect > factor then
		local fxdata = EffectData()
		fxdata:SetOrigin(ent:GetPos())
		util.Effect("tib_die", fxdata, true)
		
		if ent:IsVehicle() then
			local driver = ent:GetDriver()
			if IsValid(driver) && driver:IsPlayer() then
				driver:ExitVehicle()
			end
		end
		SafeRemoveEntity(ent)
	else
		ent.TibInfect = ent.TibInfect + 1
		SpawnInfetion(ent)
		timer.Simple(math.random(5, 10) * factor, function() InfectionThink(ent, contraption) end)
	end
end

function Tib:Infect(ent)
	if !CanInfect(ent) then return end
	ent.TibInfect = 0
	if !ent.TibContraption then
		ent.TibContraption = GetContraption(ent)
	end
	
	local factor = math.Clamp(ent:BoundingRadius() / 100, 1, 3)
	SpawnInfetion(ent)
	timer.Simple(math.random(5, 10) * factor, function() InfectionThink(ent, ent.TibContraption) end)
end

function Tib:InfectBlast(ent, radius)
	for k,v in pairs(ents.FindInSphere(ent:GetPos(), radius)) do
		Tib:Infect(v)
	end
end