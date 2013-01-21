
local function ValidAction(self, ent)
	if !validEntity(ent) || ent:IsPlayer() then return false end
	if !E2Lib.isOwner(self, ent) then return false end
	
	return true
end

__e2setcost(5)

///--- Format ---\\\
e2function string format(number num)
	return AU:Format(num)
end

///--- Sequence ---\\\
e2function number entity:sequenceGet()
	if !ValidAction(self, this) then return 0 end
	return this:GetSequence() || 0
end

e2function number entity:sequenceLookUp(string name)
	if !ValidAction(self, this) then return 0 end
	local id = this:LookupSequence(name)
	return id || 0
end

e2function number entity:sequenceDuration(string name)
	if !ValidAction(self, this) then return 0 end
	local id, dur = this:LookupSequence(name)
	return dur || 0
end

e2function void entity:sequenceSet(number id)
	if !ValidAction(self, this) then return end
	this.AutomaticFrameAdvance = true
	this:SetSequence(id)
end

e2function void entity:sequenceReset(number id)
	if !ValidAction(self, this) then return end
	this.AutomaticFrameAdvance = true
	this:ResetSequence(id)
end

e2function void entity:sequenceSetCycle(number frame)
	if !ValidAction(self, this) then return end
	this:SetCycle(frame)
end

e2function void entity:sequenceSetRate(number speed)
	if !ValidAction(self, this) then return end
	this:SetPlaybackRate(speed)
end

e2function void entity:setPoseParameter(string param, number value)
	if !ValidAction(self, this) then return end
	this:SetPoseParameter(param, value)
end

///--- Wirelink ---\\\
local function IsWire(ent)
	if ent.IsWire && ent.IsWire == true then return true end
	if ent.Inputs || ent.Outputs  then return true end
	if ent.inputs || ent.outputs  then return true end
	return false
end

e2function wirelink entity:getWirelink()
	if !ValidAction(self, this) then return end
	if !IsWire(this) then return end
	
	if !this.extended then 
		this.extended = true
		RefreshSpecialOutputs(this) 
	end
	return this
end

e2function number entity:makeWirelink()
	if !ValidAction(self, this) then return 0 end
	if !IsWire(this) then return 0 end
	if this.extended then return 0 end
	
	this.extended = true
	RefreshSpecialOutputs(this)
	return 1
end

e2function number entity:removeWirelink()
	if !ValidAction(self, this) then return 0 end
	if !IsWire(this) then return 0 end
	if !this.extended then return 0 end
	
	this.extended = false
	RefreshSpecialOutputs(this)
	return 1
end

///--- Particles ---\\\
umsg.PoolString("particlebeam")
local sbox_E2_maxParticles = CreateConVar("sbox_E2_maxParticles", "5", FCVAR_ARCHIVE)

local ParticleCount = 0
local ParticleClear = 0
local ParticleBlackList = {"portal_rift_01"}

hook.Add("Think", "ParticleCount", function()
	if CurTime() >= ParticleClear then
		ParticleClear = CurTime() + 1
		ParticleCount = 0
	end
end)

local function ValidParticle(particle)
	if table.HasValue(ParticleBlackList, name) then return false end
	if ParticleCount < sbox_E2_maxParticles:GetInt() then
		ParticleCount = ParticleCount + 1
		return true
	end
	return false
end

e2function void entity:particleCreate(string particle, vector pos, angle ang)
	if !ValidAction(self, this) then return end
	if !ValidParticle(particle) then return end
	ParticleEffect(particle, pos, Angle(ang[1], ang[2], ang[3]), this)
end

e2function	void entity:particleAttach(string particle)
	if !ValidAction(self, this) then return end
	if !ValidParticle(particle) then return end
	ParticleEffectAttach(particle, PATTACH_ABSORIGIN_FOLLOW, this, 0)
end

e2function void entity:particleBeam(string particle, entity ent)
	if !ValidAction(self, this) then return end
	if !ValidAction(self, ent) then return end
	if !ValidParticle(particle) then return end
	
	timer.Simple(0.05, function(particle, this, ent)
		umsg.Start("particlebeam", player.GetAll())
			umsg.String(particle)
			umsg.Short(this:EntIndex())
			umsg.Short(ent:EntIndex())
		umsg.End()
	end, particle, this, ent)
end

e2function void entity:particleStop()
	if !ValidAction(self, this) then return end
	this:StopParticles()
end

///--- Effects ---\\\
local sbox_E2_maxEffects= CreateConVar("sbox_E2_maxEffects", "5", FCVAR_ARCHIVE)

local EffectCount = 0
local EffectClear = 0
local EffectBlackList = {"ptorpedoimpact", "effect_explosion_scaleable", "nuke_blastwave", "nuke_blastwave_cheap", "nuke_disintegrate", "nuke_effect_air", "nuke_effect_ground", "nuke_vaporize", "warpcore_breach"}

hook.Add("Think", "EffectCount", function()
	if CurTime() >= EffectClear then
		EffectClear = CurTime() + 1
		EffectCount = 0
	end
end)

local function ValidEffect(name)
	if table.HasValue(EffectBlackList, name) then return false end
	if EffectCount < sbox_E2_maxEffects:GetInt() then
		EffectCount = EffectCount + 1
		return true
	end
	return false
end

local function MakeEffect(self, name, origin, start, angle, magnitude, scale)
	local fx = EffectData()
	fx:SetOrigin(origin)
	fx:SetEntity(self)
	if start then fx:SetStart(start) end
	if angle then fx:SetAngle(Angle(angle[1], angle[2], angle[3])) end
	if magnitude then fx:SetMagnitude(magnitude) end
	if scale then fx:SetScale(scale) end
	util.Effect(name, fx)
end

e2function void fx(string effect, vector origin)
	if !ValidEffect(effect) then return end
	MakeEffect(self, effect, origin)
end

e2function void fx(string effect, vector origin, vector start)
	if !ValidEffect(effect) then return end
	MakeEffect(self, effect, origin, start)
end

e2function void fx(string effect, vector origin, vector start, angle ang)
	if !ValidEffect(effect) then return end
	MakeEffect(self, effect, origin, start, ang)
end

e2function void fx(string effect, vector origin, vector start, angle ang, magnitude)
	if !ValidEffect(effect) then return end
	MakeEffect(self, effect, origin, start, ang, magnitude)
end

e2function void fx(string effect, vector origin, vector start, angle ang, magnitude, scale)
	if !ValidEffect(effect) then return end
	MakeEffect(self, effect, origin, start, ang, magnitude, scale)
end

///--- Admin ---\\\
e2function number entity:isVip()
	if !validEntity(this) then return 0 end
	if !this:IsPlayer() then return 0 end
	if this:IsVip() then return 1 else return 0 end
end

e2function number entity:isDJ()
	if !validEntity(this) then return 0 end
	if !this:IsPlayer() then return 0 end
	if this:IsDJ() then return 1 else return 0 end
end

e2function number entity:isModerator()
	if !validEntity(this) then return 0 end
	if !this:IsPlayer() then return 0 end
	if this:IsModerator() then return 1 else return 0 end
end

e2function number entity:isAdmin()
	if !validEntity(this) then return 0 end
	if !this:IsPlayer() then return 0 end
	if this:IsAdmin() then return 1 else return 0 end
end

e2function number entity:isSuperAdmin()
	if !validEntity(this) then return 0 end
	if !this:IsPlayer() then return 0 end
	if this:IsSuperAdmin() then return 1 else return 0 end
end

e2function number entity:isOwner()
	if !validEntity(this) then return 0 end
	if !this:IsPlayer() then return 0 end
	if this:IsOwner() then return 1 else return 0 end
end

///--- 3k ---\\\
e2function number entity:credits()
	if !validEntity(this) || !this:IsPlayer() then return 0 end
	local credits = AU:GetPlayerData(this:GetNWString("UID"), "credits")
	return credits
end

e2function number entity:score()
	if !validEntity(this) || !this:IsPlayer() then return 0 end
	local score = AU:GetPlayerData(this:GetNWString("UID"), "score")
	return score
end