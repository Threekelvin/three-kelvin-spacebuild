AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local Sounds = {}
Sounds.Loop = Sound("ambient/levels/citadel/zapper_loop2.wav")
Sounds.Send1 = Sound("ambient/levels/citadel/weapon_disintegrate1.wav")
Sounds.Send2 = Sound("ambient/levels/citadel/weapon_disintegrate2.wav")
Sounds.Send3 = Sound("ambient/levels/citadel/weapon_disintegrate3.wav")
Sounds.Send4 = Sound("ambient/levels/citadel/weapon_disintegrate4.wav")

function ENT:Initialize()
	self.Entity:SetModel("models/Slyfo/sat_rtankstand.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_NONE)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end
	
	self.Storage = {}
end

function ENT:Slot1Pos()
	return self:LocalToWorld(self:OBBCenter() + Vector(10, 18.5, 10))
end

function ENT:Slot2Pos()
	return self:LocalToWorld(self:OBBCenter() + Vector(10, -18.5, 10))
end

function ENT:SendResources(ent)
	if !IsValid(ent) then return end
	ParticleEffectAttach("steam_large_01", PATTACH_ABSORIGIN_FOLLOW, ent, 0)
	
	local ZapLoop = CreateSound(ent, Sounds.Loop)
	ZapLoop:SetSoundLevel(75)
	ZapLoop:Play()
	function ent:OnRemove()
		self.BaseClass.OnRemove(self)
		ZapLoop:Stop()
	end
	
	timer.Simple(5, function()
		if !IsValid(ent) then return end
		
		ParticleEffectAttach("striderbuster_attach", PATTACH_ABSORIGIN_FOLLOW, ent, 0)
		timer.Simple(0.5, function()
			if !IsValid(ent) then return end
			local owner, uid = ent:CPPIGetOwner()
			if !IsValid(owner) then
				self:EmitSound(Sounds["Send"..math.random(1, 4)], 75, 100)
				ent:Remove()
				return
			end
			
			ent:Unlink()
			local Tib = ent:GetResourceAmount("raw_tiberium")
			local storage = TK.DB:GetPlayerData(owner, "terminal_storage")
			TK.DB:UpdatePlayerData(owner, "terminal_storage", {raw_tiberium = math.floor((storage.raw_tiberium || 0) + Tib)})
			
			self:EmitSound(Sounds["Send"..math.random(1, 4)], 75, 100)
			ent:Remove()
		end)
	end)
end

function ENT:Touch(ent)
	if !IsValid(ent) || IsValid(ent:GetParent()) then return end
	if ent:GetClass() != "tk_tib_storage" || !ent:IsPlayerHolding() || Tib:IsInfected(ent) then return end
    local owner = ent:CPPIGetOwner()
    if !IsValid(owner) || owner:GetPos():Distance(ent:GetPos()) > 500 then return end
	if IsValid(self.Storage.Slot1) && IsValid(self.Storage.Slot2) then return end
	
	if (ent:GetPos():Distance(self:Slot1Pos()) < ent:GetPos():Distance(self:Slot2Pos()) && !IsValid(self.Storage.Slot1)) || IsValid(self.Storage.Slot2) then
		self.Storage.Slot1 = ent
		ent:Unlink()
		ent:SetPos(self:Slot1Pos())
		ent:SetAngles(self:GetAngles())
		local phys = ent:GetPhysicsObject()
		constraint.Weld(ent, self, 0, 0, 0, true)
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
		ent:SetParent(self)
		self:SendResources(ent)
	else
		self.Storage.Slot2 = ent
		ent:Unlink()
		ent:SetPos(self:Slot2Pos())
		ent:SetAngles(self:GetAngles())
		local phys = ent:GetPhysicsObject()
		constraint.Weld(ent, self, 0, 0, 0, true)
		if phys:IsValid() then
			phys:EnableMotion(false)
		end
		ent:SetParent(self)
		self:SendResources(ent)
	end
end