
TKDM = {}

local constraint = constraint
local table = table
local CurTime = CurTime
local IsValid = IsValid
local pairs = pairs

local DMG_KINETIC = 1
local DMG_EXPLOSIVE = 2
local DMG_PLASMA = 3
local DMG_LASER = 4

local function CheckContraption(ent)
	if !IsValid(ent) || !ent.audmg then return 0, 0, 0, 0 end
	if CurTime() >= ent.audmg.update then
		ent.audmg.contraption = constraint.GetAllConstrainedEntities(ent)
		ent.audmg.update = CurTime() + 1
	end
	local entlist = {}
	local num, shield, armor, hull = 0, 0, 0, 0
	for k,v in pairs(ent.audmg.contraption) do
		if IsValid(v) then
			entlist[v:EntIndex()] = v
			num = num + 1
			shield = shield + v.audmg.shield
			armor = armor + v.audmg.armor
			hull = hull + v.audmg.hull
		end
	end
	ent.audmg.contraption = entlist
	return num, shield, armor, hull
end

local function DestroyEnt(ent)
	SafeRemoveEntity(ent)
	return true
end

function TKDM.DoDamage(ent, dmg, typ)
	if !IsValid(ent) || !ent.audmg then return false end
	if ent:IsPlayer() || ent:IsNPC() then
		ent:TakeDamage(dmg)
		return true
	end
	
	local num, shield, armor, hull = CheckContraption(ent)
	local ds, da, dh = 0, 0, 0
	if !typ || typ == DMG_KINETIC then
		ds = math.min(dmg * 0.5, sheild)
		dmg = dmg - ds
		da = math.min(dmg * 0.5, armor)
		dmg = dmg - da
		dh = math.min(dmg, hull)
		dmg = dmg - dh
	elseif typ == DMG_EXPLOSIVE then
		ds = math.min(dmg * 0.25, sheild)
		dmg = dmg - ds
		da = math.min(dmg * 0.75, armor)
		dmg = dmg - da
		dh = math.min(dmg, hull)
		dmg = dmg - dh
	elseif typ == DMG_PLASMA then
		ds = math.min(dmg, sheild)
		dmg = dmg - ds
		da = math.min(dmg * 0.5, armor)
		dmg = dmg - da
		dh = math.min(dmg * 0.5, hull)
		dmg = dmg - dh
	elseif typ == DMG_LASER then
		ds = math.min(dmg * 0.75, sheild)
		dmg = dmg - ds
		da = math.min(dmg * 0.75, armor)
		dmg = dmg - da
		dh = math.min(dmg * 0.5, hull)
		dmg = dmg - dh
	end
	
	if hull <= dh then
		for k,v in pairs(ent.audmg.contraption) do
			DestroyEnt(v)
		end
	else
		ds = ds / num; da = da / num; dh = dh / num
		for k,v in pairs(ent.audmg.contraption) do
			v.audmg.shield = v.audmg.shield - ds
			v.audmg.armor = v.audmg.armor - da
			v.audmg.hull = v.audmg.hull - dh
		end
	end
	return true
end

function TKDM.DoBlastDamage(pos, rad, dmg, typ)
	for k,v in pairs(ents.FindInSphere(pos, rad)) do
		TKDM.DoDamage(v, dmg * (1 - v:GetPos():Distance(pos) / rad), typ)
	end
end

hook.Add("Initialize", "TKDM", function()
	local Spawn = _R.Entity.Spawn
	function _R.Entity:Spawn()
		Spawn(self)
		local phys = self:GetPhysicsObject()
		if !IsValid(phys) then return end
		local vol = (phys:GetVolume() || 0) * 0.001
		self.audmg = self.audmg || {}
		self.audmg.maxshield = vol * 0.25
		self.audmg.shield = self.audmg.maxshield
		self.audmg.maxarmor = vol * 0.5
		self.audmg.armor = self.audmg.maxarmor
		self.audmg.maxhull = vol * 0.25
		self.audmg.hull = self.audmg.maxhull
		self.audmg.contraption = {self}
		self.audmg.update = 0
	end
end)