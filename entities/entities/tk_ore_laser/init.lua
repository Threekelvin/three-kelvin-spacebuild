AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
    
    self.data = {}
	self.data.yield = 0
	self.data.range = 0
	self.data.power = 0
	self:SetNWInt("range", 0)

	self:SetNWBool("Generator", true)
	self:AddResource("asteroid_ore", 0, true)
	self:AddSound("l", 7, 65)
	
	self.Inputs = WireLib.CreateInputs(self, {"On"})
	self.Outputs = WireLib.CreateOutputs(self, {"On", "Output", "Range"})
end

function ENT:TurnOn()
	if self:GetActive() || !self:IsLinked() then return end
    self:SetActive(true)
    WireLib.TriggerOutput(self, "On", 1)
    WireLib.TriggerOutput(self, "Range", self.range)
    self:SoundPlay(1)
end

function ENT:TurnOff()
	if !self:GetActive() then return end
	self:SetActive(false)
	WireLib.TriggerOutput(self, "On", 0)
	WireLib.TriggerOutput(self, "Output", 0)
	WireLib.TriggerOutput(self, "Range", 0)
	self:SoundStop(1)
end

function ENT:TriggerInput(iname, value)
	if iname == "On" then
		if value != 0 then
			self:TurnOn()
		else
			self:TurnOff()
		end
	end
end

function ENT:DoThink(eff)
	if !self:GetActive() then return end
    if !self:Work() then return end
	
	local trace = util.QuickTrace(self:LocalToWorld(Vector(0,0,32)), self:GetUp() * (self.data.range + 32), self)
	if IsValid(trace.Entity) then
		local ent = trace.Entity
		local owner, uid = self:CPPIGetOwner()
		if !IsValid(owner) then return end
		
        local yield = math.floor(self.data.yield * eff)
		if ent:GetClass() == "tk_roid" then

            yield = math.min(yield, ent.Ore)
            yield = self:SupplyResource("asteroid_ore", yield)
            WireLib.TriggerOutput(self, "Output", yield)
            
            owner.tk_cache.score = math.floor((owner.tk_cache.score || 0) + yield * 0.75)
            owner.tk_cache.exp = math.floor((owner.tk_cache.exp || 0) + yield * 0.375)
            
            ent.Ore = ent.Ore - yield
		elseif ent:IsPlayer() || ent:IsNPC() then
			local dmginfo = DamageInfo()
			dmginfo:SetDamage(math.random(5, 25))
			dmginfo:SetDamageType(DMG_RADIATION)
			dmginfo:SetAttacker(self:CPPIGetOwner())
			dmginfo:SetInflictor(self)
			ent:TakeDamageInfo(dmginfo)
		end
	end
	WireLib.TriggerOutput(self, "Output", 0)
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end

function ENT:Update(ply)
	local data = TK.TD:GetItem(self.itemid).data
    local upgrades = TK.TD:GetUpgradeStats(ply, "asteroid")
    
    self.data.yield = data.yield + (data.yield * upgrades.yield)
	self.data.range = data.range + (data.range * upgrades.range)
	self.data.power = data.power - (data.power * upgrades.power)
	self:SetNWInt("range", self.data.range)
end

function ENT:UpdateTransmitState() 
	return TRANSMIT_ALWAYS 
end