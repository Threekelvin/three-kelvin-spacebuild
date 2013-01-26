
local Build = {}
Build.partdata = list.Get("SBEP_PartAssemblyData")
Build.elevators = {"ESML", "ELRG", "MOD1x1e", "MOD3x2e"}
Build.docks = {"LRC1", "LRC2", "LRC3", "LRC4", "LRC5","LRC6"}
Build.search = {}
Build.snaped = {}
Build.moving = {}

///--- Functions ---\\\
function Build.CanPickUp(ply, ent)
	local entid = ent:EntIndex()
	if IsValid(ent:GetParent()) then return end
	if !Build.partdata[ent:GetModel()] then return false end
	if Build.search[entid] then return false end
	if Build.snaped[entid] then return false end
	if Build.moving[entid] then return false end
	return true
end

function Build.CanAttach(ent, ply, eir)
	if ent == eir then return false end
    if ent.SLIsGhost || eir.SLIsGhost then return false end
	if !eir:CPPICanTool(ply, "none") then return false end
	return true
end

function Build.Match(ap1, ap2)
	local t1, t2 = ap1.type, ap2.type
	if table.HasValue(Build.docks, t1) then
		if t1 == Build.docks[1] && t2 == Build.docks[2] then return true end
		if t1 == Build.docks[2] && t2 == Build.docks[1] then return true end
		if t1 == Build.docks[3] && t2 == Build.docks[4] then return true end
		if t1 == Build.docks[4] && t2 == Build.docks[3] then return true end
		if t1 == Build.docks[5] && t2 == Build.docks[6] then return true end
		if t1 == Build.docks[6] && t2 == Build.docks[5] then return true end
		return false
	else
		return t1 == t2
	end
end

function Build.CheckPoints(ent, entdata, eir)
	local eirdata = Build.partdata[eir:GetModel()]
	if !eirdata then return end

	local point1, point2, dist
	for _,ap1 in pairs(entdata) do
		for _,ap2 in pairs(eirdata) do
			if Build.Match(ap1, ap2) then
				local length = (ent:LocalToWorld(ap1.pos) - eir:LocalToWorld(ap2.pos)):LengthSqr()
				if !dist || length < dist then
					dist = length
					point1, point2 = ap1, ap2
				end
			end
		end
	end
	
	if dist && dist < 5625 then
		return point1, point2
	end
end

function Build.GetOptions(ply)
	local data = {}
	data.enable = ply:GetInfoNum("3k_sbep_build_mode_enabled", 0)
	data.skinmatch = ply:GetInfoNum("3k_sbep_build_mode_skinmatch", 0)
	return data
end

function Build.AttachProps(ent, point1, eir, point2)
	ent:GetPhysicsObject():EnableMotion(false)
	eir:GetPhysicsObject():EnableMotion(false)
	
	local pos = Vector(point1.pos.x, point1.pos.y, point1.pos.z)
	local ang = point2.dir - point1.dir
	if table.HasValue(Build.elevators, point1.type) then
		ang = ang + Angle(180,0,0)
	else
		ang = ang + Angle(0,180,0)
	end
	pos:Rotate(ang)
	
	ent:SetPos(eir:LocalToWorld(point2.pos - pos))
	ent:SetAngles(eir:LocalToWorldAngles(ang))
end

function Build.OnPickUp(ply, ent)
	if ply:GetInfoNum("3k_sbep_build_mode_enabled", 0) == 0 then return end
	if !Build.CanPickUp(ply, ent) then return end
	local Cgroup = ent:GetCollisionGroup()
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	
	Build.search[ent:EntIndex()] = {ent, Cgroup, ply}
end

function Build.OnDrop(ply, ent)
	local entid = ent:EntIndex()
	
	if Build.search[entid] then
		ent:SetCollisionGroup(Build.search[entid][2])
	end
	Build.search[entid] = nil
	
	if Build.snaped[entid] then
		local plydata = Build.GetOptions(ply)
		local eir = Build.snaped[entid][4]
		ent:SetCollisionGroup(Build.snaped[entid][2])
		
		if IsValid(eir) then
			if plydata.skinmatch != 0 then
				local skins1, skins2 = ent:SkinCount(), eir:SkinCount()
				if skins1 == skins2 then
					ent:SetSkin(eir:GetSkin())
				elseif skins1 > skins2 then
					ent:SetSkin(eir:GetSkin() * 2)
				else
					ent:SetSkin(math.floor(eir:GetSkin() / 2))
				end
			end
		end
	end
	Build.snaped[entid] = nil
	
	if Build.moving[entid] then
		ent:SetCollisionGroup(Build.moving[entid][2])
	end
	Build.moving[entid] = nil
end

function Build.OnReload(ply, ent)
	local entid = ent:EntIndex()
	
	if Build.search[entid] then
		if Build.search[entid][3] != ply then return end
		Build.moving[entid] = Build.search[entid]
		Build.search[entid] = nil
		return false
	elseif Build.snaped[entid] then
		if Build.snaped[entid][3] != ply then return end
		Build.moving[entid] = Build.snaped[entid]
		Build.snaped[entid] = nil
		
		local phys = ent:GetPhysicsObject()
		if !IsValid(phys) then return false end
		phys:EnableMotion(true)
		phys:Wake()
		phys:SetVelocity(Vector(0,0,-1))
		return false
	elseif Build.moving[entid] then
		if Build.moving[entid][3] != ply then return end
		Build.search[entid] = Build.moving[entid]
		Build.moving[entid] = nil
		return false
	end
end

function Build.KeyRelease(ply, ent, key)
	if key != IN_USE then return end
	local data = Build.snaped[ent:EntIndex()]
	if !data then return end
	if ply != data[3] then return end
	if !table.HasValue(Build.elevators, data[5]) then return end
	
	ent:SetAngles(ent:LocalToWorldAngles(Angle(0,90,0)))
end

function Build.Tick()
	for idx,tbl in pairs(Build.search) do
		local ent, ply = tbl[1], tbl[3]
		if IsValid(ent) && IsValid(ply) then
			local entdata = Build.partdata[ent:GetModel()]
			for _,eir in pairs(TK:FindInSphere(ent:LocalToWorld(ent:OBBCenter()), ent:BoundingRadius())) do
				if Build.CanAttach(ent, ply, eir) then
					local point1, point2 = Build.CheckPoints(ent, entdata, eir)
					if point1 && point2 then
						tbl[4] = eir
						tbl[5] = point1.type
						Build.snaped[idx] = tbl
						Build.search[idx] = nil
						Build.AttachProps(ent, point1, eir, point2)
						return
					end
				end
			end
		else
			Build.search[idx] = nil
		end
	end
end
///--- ---\\\

///--- Hooks ---\\\
hook.Add("PhysgunPickup", "TK_SBEPBuild", function(ply, ent)
	local valid, status = pcall(Build.OnPickUp, ply, ent)
	if !valid then print(status) return end
end)

hook.Add("PhysgunDrop", "TK_SBEPBuild", function(ply, ent)
	local valid, status = pcall(Build.OnDrop, ply, ent)
	if !valid then print(status) return end
end)

hook.Add("OnPhysgunReload", "TK_SBEPBuild", function(wep, ply)
	local ent = ply:GetEyeTrace().Entity
	if !IsValid(ent) then return end
	
	local valid, status = pcall(Build.OnReload, ply, ent)
	if !valid then print(status) return end
    return status
end)

hook.Add("KeyRelease", "TK_SBEPBuild", function(ply, key)
	local ent = ply:GetEyeTrace().Entity
	if !IsValid(ent) then return end
	
	local valid, status = pcall(Build.KeyRelease, ply, ent, key)
	if !valid then print(status) return end
end)

hook.Add("Tick", "TK_SBEPBuild", function()
	local valid, status = pcall(Build.Tick)
	if !valid then print(status) return end
end)
///--- ---\\\