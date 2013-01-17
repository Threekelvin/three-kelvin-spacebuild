AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self:AddResource("oxygen", 0)
	self:AddResource("water", 0)
end

function ENT:TurnOn()

end

function ENT:TurnOff()

end

function ENT:Use(ply, caller)
	if !ply:IsPlayer() then return end
	if !ply.tk_hev then return end
    ply:AddhevRes("energy", ply.tk_hev.energymax - ply.tk_hev.energy)
	ply:AddhevRes("water", self:ConsumeResource("water", ply.tk_hev.watermax - ply.tk_hev.water))
	ply:AddhevRes("oxygen", self:ConsumeResource("oxygen", ply.tk_hev.oxygenmax - ply.tk_hev.oxygen))
end

function ENT:DoThink()

end

function ENT:NewNetwork(netid)

end

function ENT:UpdateValues()

end