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
    self.mult = 1
	self.mute = false
    self.next_use = 0
    self.data = {}
	
	TK.RD:Register(self)
	self:SetSkin(self.data.skin || 0)
	self:SetNWBool("Active", false)
    self:SetNWBool("Generator", false)
	
	self.WireDebugName = self.PrintName
end

function ENT:OnRemove()
	for k,v in pairs(self.soundlib || {}) do
		v:Stop()
	end
	
	TK.RD:RemoveEnt(self)
	
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
	if self.mute then return end
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

function ENT:SetActive(val)
    val = tobool(val)
    self:SetNWBool("Active", val)
    if val then return end
    self:SetPower(0)
end

function ENT:Work()
    if !self:GetActive() then return false end
    if self:GetUnitPowerGrid() != self.data.power * self.mult then
        self:SetPower(self.data.power * self.mult)
        return false
    end
    
    return true
end

function ENT:TurnOn()
	if self:GetActive() || !self:IsLinked() then return end
    self:SetActive(true)
end

function ENT:TurnOff()
	if !self:GetActive() then return end
    self:SetActive(false)
end

function ENT:Use(ply)
	if !IsValid(ply) || !ply:IsPlayer() then return end
    if !self:CPPICanUse(ply) then return end
    if self.next_use > CurTime() then return end
    self.next_use = CurTime() + 1
    
	if self:GetActive() then
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

function ENT:DoThink(eff)

end

function ENT:NewNetwork(netid)

end

function ENT:UpdateValues()

end

function ENT:PreEntityCopy()
    if WireLib then
        WireLib.BuildDupeInfo(self)
    end
end

function ENT:PostEntityPaste(ply, ent, info, GetEntByID)
    if WireLib then
        WireLib.ApplyDupeInfo(ply, ent, info, GetEntByID)
    end
end


function ENT:AddResource(idx, max, gen)
	return TK.RD:EntAddResource(self, idx, max, gen)
end

function ENT:SetPower(power)
    return TK.RD:SetPower(self, power)
end

function ENT:IsLinked()
	return TK.RD:IsLinked(self)
end

function ENT:Link(netid)
	return TK.RD:Link(self, netid)
end

function ENT:Unlink()
	return TK.RD:Unlink(self)
end

function ENT:GetEntTable()
	return TK.RD:GetEntTable(self:EntIndex())
end

function ENT:SupplyResource(idx, amt)
	return TK.RD:EntSupplyResource(self, idx, amt)
end

function ENT:ConsumeResource(idx, amt)
	return TK.RD:EntConsumeResource(self, idx, amt)
end

function ENT:GetPowerGrid()
    return TK.RD:GetEntPowerGrid(self)
end

function ENT:GetResourceAmount(idx)
	return TK.RD:GetEntResourceAmount(self, idx)
end

function ENT:GetUnitPowerGrid()
    return TK.RD:GetUnitPowerGrid(self)
end

function ENT:GetUnitResourceAmount(idx)
	return TK.RD:GetUnitResourceAmount(self, idx)
end

function ENT:GetResourceCapacity(idx)
	return TK.RD:GetEntResourceCapacity(self, idx)
end

function ENT:GetUnitResourceCapacity(idx)
	return TK.RD:GetUnitResourceCapacity(self, idx)
end