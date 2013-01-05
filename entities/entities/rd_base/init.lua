AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local SoundLib = {}
SoundLib.a = {
	Sound("ambient/machines/thumper_startup1.wav"),
	Sound("vehicles/apc/apc_start_loop3.wav"),
	Sound("buttons/button1.wav"),
	Sound("misc/hologram_start.wav"),
	Sound("vehicles/crane/crane_magnet_switchon.wav"),
	Sound("ambient/levels/citadel/advisor_leave.wav")
}
SoundLib.l = {
	Sound("ambient/machines/refinery_loop_1.wav"),
	Sound("ambient/machines/pump_loop_1.wav"),
	Sound("ambient/machines/turbine_loop_1.wav"),
	Sound("vehicles/diesel_loop2.wav"),
	Sound("vehicles/airboat/fan_blade_idle_loop1.wav"),
	Sound("vehicles/apc/apc_idle1.wav"),
	Sound("ambient/machines/combine_shield_touch_loop1.wav"),
	Sound("misc/hologram_move.wav"),
	Sound("ambient/levels/citadel/datatransmission02_loop.wav")
}
SoundLib.s = {
	Sound("ambient/machines/thumper_shutdown1.wav"),
	Sound("vehicles/airboat/fan_motor_shut_off1.wav"),
	Sound("vehicles/apc/apc_shutdown.wav"),
	Sound("misc/hologram_stop.wav"),
	Sound("ambient/machines/spindown.wav")
}
SoundLib.d = {
	Sound("ambient/machines/zap1.wav"),
	Sound("ambient/machines/zap2.wav"),
	Sound("ambient/machines/zap3.wav"),
	Sound("misc/hologram_malfunction.wav"),
	Sound("ambient/machines/catapult_throw.wav")
}

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	
	local phys = self:GetPhysicsObject()
	if IsValid(phys) then
		phys:Wake()
	end
	
	self.data = {}
	self.soundlib = {
		[0] = CreateSound(self, SoundLib.d[5])
	}
	self.Mult = 1
	self.Mute = false
	self.IsActive = false
	self.IsIdle = false
	
	TK.RD.Register(self)
	self:SetSkin(self.data.skin || 0)
	self:SetNWBool("Actived", false)
	self:SetNWBool("Idle", false)
	self:SetNWBool("Powered", false)
	self:SetNWBool("Overlay", true)
	
	self.WireDebugName = self.PrintName
end

function ENT:OnRemove()
	for k,v in pairs(self.soundlib || {}) do
		v:Stop()
	end
	
	TK.RD.RemoveEnt(self)
	
	if WireLib then WireLib.Remove(self) end
end

function ENT:AddSound(lib, idx, vol, ptc, str)
	local id = 0
	if str then
		id = table.insert(self.soundlib, CreateSound(self, Sound(str)))
	else
		if !SoundLib[lib] || !SoundLib[lib][idx] then return 0 end
		id = table.insert(self.soundlib, CreateSound(self, SoundLib[lib][idx]))
	end
	
	if vol then
		self.soundlib[id]:SetSoundLevel(tonumber(vol) || 100)
	end
	
	if ptc then
		self.soundlib[id]:ChangePitch(tonumber(ptc) || 100)
	end
	return id
end

function ENT:SoundPitch(id, pitch)
	if !self.soundlib[id] then return end
	self.soundlib[id]:ChangePitch(tonumber(pitch) || 100)
end

function ENT:SoundLevel(id, level)
	if !self.soundlib[id] then return end
	self.soundlib[id]:SetSoundLevel(tonumber(level) || 65)
end

function ENT:SoundPlay(id)
	if self.Mute then return end
	if !self.soundlib[id] then return end
	if self.soundlib[id]:IsPlaying() then
		self.soundlib[id]:Stop()
	end
	self.soundlib[id]:Play()
end

function ENT:SoundStop(id)
	if !self.soundlib[id] then return end
	self.soundlib[id]:Stop()
end

function ENT:SetActive(bool)
	self.IsActive = tobool(bool)
	self:SetNWBool("Actived", self.IsActive)
end

function ENT:SetIdle(bool)
	self.IsIdle = tobool(bool)
	self:SetNWBool("Idle", self.IsIdle)
end

function ENT:SetPowered(bool)
	self:SetNWBool("Powered", tobool(bool))
end

function ENT:SetOverlay(bool)
	self:SetNWBool("Overlay", tobool(bool))
end

function ENT:TurnOn()
	if self.IsActive || !self:IsLinked() then return end
	self:SetActive(true)
end

function ENT:TurnOff()
	if !self.IsActive then return end
	self:SetActive(false)
end

function ENT:Idle()
	if self.IsIdle then return end
	self:SetIdle(true)
end

function ENT:Work()
	if !self.IsIdle then return end
	self:SetIdle(false)
end

function ENT:Use(ply)
	if !IsValid(ply) || !ply:IsPlayer() then return end
	if self.IsActive then
		self:TurnOff()
	else
		self:TurnOn()
	end
end

function ENT:DoMenu(ply)
	if !IsValid(ply) || !ply:IsPlayer() then return end
	net.Start("TKRD_MEnt")
		net.WriteEntity(self)
	net.Send(ply)
end

function ENT:DoCommand(ply, cmd, arg)

end

function ENT:DoThink()

end

function ENT:NewNetwork(netid)

end

function ENT:UpdateValues()

end

function ENT:AddResource(idx, max, gen)
	return TK.RD.EntAddResource(self, idx, max, gen)
end

function ENT:IsLinked()
	return TK.RD.IsLinked(self)
end

function ENT:Link(netid)
	return TK.RD.Link(self, netid)
end

function ENT:Unlink()
	return TK.RD.Unlink(self)
end

function ENT:GetEntTable()
	return TK.RD.GetEntTable(self:EntIndex())
end

function ENT:SupplyResource(idx, amt)
	return TK.RD.EntSupplyResource(self, idx, amt)
end

function ENT:ConsumeResource(idx, amt)
	return TK.RD.EntConsumeResource(self, idx, amt)
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