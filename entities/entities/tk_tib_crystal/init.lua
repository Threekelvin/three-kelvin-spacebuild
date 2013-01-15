AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local Stages = {
	[1] = {
		limit = 10,
		model = "models/tiberium/tiberium_crystal3.mdl",
		offset = 10,
		delay = 120,
		scale = 1,
	},
	["models/tiberium/tiberium_crystal3.mdl"] = {
		limit = 10,
		model = "models/tiberium/tiberium_crystal1.mdl",
		offset = 0,
		delay = 240,
		scale = 1.1,
	},
	["models/tiberium/tiberium_crystal1.mdl"] = {
		limit = 5,
		model = "models/tiberium/tiberium_crystal2.mdl",
		offset = -10,
		delay = 480,
		scale = 1.5,
	},
	["models/tiberium/tiberium_crystal2.mdl"] = {
		limit = 2,
		model = "models/chipstiks_mining_models/smallbluecrystal/smallbluecrystal.mdl",
		offset = 0,
		delay = -1,
		scale = 2,
	}
}

umsg.PoolString("TKTib")

function ENT:SendStatus()
    umsg.Start("TKTib")
        umsg.Short(self:EntIndex())
        umsg.Bool(self.Stable)
    umsg.End()
end

hook.Add("PlayerInitialSpawn", "TKTib_SendStatus", function(ply)
	for k,v in pairs(ents.FindByClass("tk_tib_crystal")) do
		umsg.Start("TKTib", ply)
            umsg.Short(v:EntIndex())
            umsg.Bool(v.Stable)
        umsg.End()
	end
end)

function ENT:GetField()
	return {}
end

function ENT:Initialize()
	self:SetModel(Stages[1].model)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMaterial("models/tiberium_g")
	self:SetColor(Color(0, math.random(130, 170), 0, 255))
	self:SetPos(self:LocalToWorld(Vector(0,0, Stages[1].offset)))

	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Wake()
		self.MaxTib = math.Round((phys:GetVolume() / 50) * math.Rand(0.75, 1.25))
		self.Tib = self.MaxTib
	else
		self.MaxTib = 0
		self.Tib = 0
	end
	self.TibLast = self.Tib
	self.countleft = 11
	
	self.Stable = true
	self:SendStatus()
	
	self.delay = Stages[1].delay
	self.scale = Stages[1].scale
end

function ENT:StartTouch(ent)
	if !IsValid(ent) then return end
	if self.Stable then
		if math.random(1, 10) == 5 then
			Tib:Infect(ent)
		end
	elseif math.random(1, 3) == 2 then
		Tib:Infect(ent)
	end
end

function ENT:OnRemove()
	local fxdata = EffectData()
	fxdata:SetOrigin(self:GetPos())
	util.Effect("tib_die", fxdata, true)
end

function ENT:Explode()
	Tib:InfectBlast(self, 100 + (self:BoundingRadius() * 2))
	
	local fxdata = EffectData()
	fxdata:SetOrigin(self:GetPos())
	fxdata:SetScale(self.scale)
	util.Effect("tib_explode", fxdata, true)
	self:Remove()
end

function ENT:NextStage()
	local Data = Stages[self:GetModel()]
	local count = 0
	for k,v in pairs(self:GetField()) do
		if v:GetModel() == Data.model then
			count = count + 1
		end
	end
	
	if count >= Data.limit then return end
	
	self:SetModel(Data.model)
	self:PhysicsInit(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:EnableMotion(false)
		phys:Wake()
		self.MaxTib = self.MaxTib + math.Round((phys:GetVolume() / 50) * math.Rand(0.75, 1.25))
	end
	
	self:SetPos(self:LocalToWorld(Vector(0,0, Data.offset)))
	
	self.Tib = self.MaxTib
	self.delay = Data.delay
	self.scale = Data.scale
end

function ENT:Think()
	if self.Tib <= 0 then
		self:Remove()
		return
	end
	
	local Changed = self.Tib - self.TibLast
	self.TibLast = self.Tib
	
	if math.random(1, 250) == 25 then
		self.Stable = false
		self:SendStatus()
		timer.Simple(60, function()
			if !IsValid(self) then return end
            self.Stable = true
            self:SendStatus()
		end)
	end
	
	if Changed == 0 then
		self.countleft = 11
		if self.Stable then
			if self.delay == -1 then
			elseif self.delay > 0 then
				self.delay = self.delay - 1
			else
				if math.random(1, 250) == 15 then
					self:NextStage()
				end
			end
		end
	elseif !self.Stable then
		self.countleft = self.countleft - 1
		if self.countleft <= 0 then
			self:Explode()
		end
	end
	
	for k,v in pairs(player.GetAll()) do
		if !IsValid(v) || !v:Alive() then continue end
        local dist = (self:GetPos() -v:GetPos()):LengthSqr()
        if dist > 1000000 then continue end
        
        local dmginfo = DamageInfo()
        dmginfo:SetDamage(math.ceil(10 * (1 - dist / 1000000)))
        dmginfo:SetDamageType(DMG_RADIATION)
        dmginfo:SetAttacker(self)
        dmginfo:SetInflictor(self)
        v:TakeDamageInfo(dmginfo)
	end
	
	self:NextThink(CurTime() + 1)
	return true
end