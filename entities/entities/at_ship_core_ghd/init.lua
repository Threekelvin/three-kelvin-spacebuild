AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local GH = GravHull

local function EnvPrioritySort(a, b)
	if a.atmosphere.priority == b.atmosphere.priority then
		return a.atmosphere.radius < b.atmosphere.radius
	end
	return a.atmosphere.priority < b.atmosphere.priority
end

function ENT:Initialize()
	self.BaseClass.Initialize(self)
	
	self.atmosphere = {}
	
	self.atmosphere.name = "Ship"
	
	self.atmosphere.sphere	= false
	self.atmosphere.noclip 	= false
	self.atmosphere.sunburn	= false
	self.atmosphere.wind 	= false
	
	self.atmosphere.priority	= 2
	self.atmosphere.radius 		= 0
	self.atmosphere.gravity 	= 1
	self.atmosphere.windspeed 	= 0
	self.atmosphere.tempcold	= 290
	self.atmosphere.temphot		= 290
	
	self.atmosphere.resources 	= {}
	
	self:SetNWBool("Generator", true)
	self:AddResource("oxygen", 0)
	self:AddResource("nitrogen", 0)
end

function ENT:OnRemove()
    self:TurnOff()
	self.BaseClass.OnRemove(self)
end

function ENT:TurnOn()
	if self:GetActive() || !self:IsLinked() then return end
	
	GH.RegisterHull(self, 0)
    GH.UpdateHull(self)
	self:SetActive(true)
    
    local env = self:GetEnv()
    self.atmosphere.resources = table.Copy(env.atmosphere.resources)
end

function ENT:TurnOff()
	if !self:GetActive() then return end
    GH.UnHull(self)
	self:SetActive(false)
end

function ENT:DoThink(eff)
	if !self:GetActive() then return end
    if !GH.SHIPS[self] then return end
    
	local env
	local size = table.Count(GH.SHIPS[self].Welds)
    local rate = 5 * size
    
    self.data.power = -rate
    if !self:Work() then return end
    rate = rate * math.min(1 / eff, 5)

    self.atmosphere.resources.oxygen = self.atmosphere.resources.oxygen || 0
    self.atmosphere.resources.oxygen = math.max(self.atmosphere.resources.oxygen - 1, 0)
    self.atmosphere.resources.nitrogen = self.atmosphere.resources.nitrogen || 0
    self.atmosphere.resources.nitrogen = math.max(self.atmosphere.resources.nitrogen - 1, 0)
    
    for k,v in pairs(self.atmosphere.resources) do
        if k == "oxygen" then
            if v > 20 then
                self.atmosphere.resources[k] = math.floor(v - 1)
            elseif v < 20 then
                local o2 = self:ConsumeResource("oxygen", rate)
                self.atmosphere.resources[k] = math.floor(v + (v < 19 && 2 || 1) * o2 / rate)
            end
        elseif k == "nitrogen" then
            if v > 80 then
                self.atmosphere.resources[k] = math.floor(v - 1)
            elseif v < 80 then
                local n2 = self:ConsumeResource("nitrogen", rate)
                self.atmosphere.resources[k] = math.floor(v + (v < 79 && 2 || 1) * n2 / rate)
            end
        elseif v > 0 then
            self.atmosphere.resources[k] = math.floor(v - 1)
        else
            self.atmosphere.resources[k] = nil
        end
    end
	
	for k,v in ipairs(self.tk_env.envlist) do
		if v != self then
			env = v
			break
		end
	end
	
	self.atmosphere.noclip = env.atmosphere.noclip
    self.atmosphere.tempcold = 290 - (290 - env.atmosphere.tempcold) * (1 - eff)
    self.atmosphere.temphot = 290 - (290 - env.atmosphere.temphot) * (1 - eff)
end

function ENT:NewNetwork(netid)
	if netid == 0 then
		self:TurnOff()
	end
end

function ENT:UpdateValues()

end

function ENT:IsStar()
	return false
end

function ENT:IsShip()
	return true
end

function ENT:IsPlanet()
	return false
end

function ENT:IsSpace()
	return false
end

function ENT:GetRadius()
	return 0
end

function ENT:GetVolume()
	return 0
end

function ENT:HasResource(res)
    return self.atmosphere.resources[res] && self.atmosphere.resources[res] > 0
end

function ENT:GetResourcePercent(res)
    return self.atmosphere.resources[res] || 0
end

function ENT:InAtmosphere(pos)
    if !self:GetActive() then return false end
	
	return GH.PointInShip(self, pos)
end

function ENT:DoGravity(ent)
	if !IsValid(ent) || !ent.tk_env then return end
	local phys = ent:GetPhysicsObject()
	if !IsValid(phys) then return end

	local grav = self.atmosphere.gravity
	if !ent.tk_env.gravity != grav then
		local bool = grav > 0
		phys:EnableGravity(bool)
		phys:EnableDrag(bool)
		ent:SetGravity(grav + 0.0001)
		ent.tk_env.gravity = grav
	end
end

function ENT:InSun(ent)
	if !IsValid(ent) then return false end
	local pos = ent:LocalToWorld(ent:OBBCenter())
	for k,v in pairs(TK.AT:GetSuns()) do
		local trace = {}
		trace.start = pos - (pos - v):GetNormal() * 2048
		trace.endpos = pos
		trace.filter = {ent, ent:GetParent()}
		local tr = util.TraceLine(trace)
		if !tr.Hit then
			return true
		end
	end
	return false
end

function ENT:DoTemp(ent)
	if !IsValid(ent) then return 3, false end

	if self:InSun(ent) then
		return self.atmosphere.temphot, true
	end
	return self.atmosphere.tempcold, false
end

hook.Add("EnterShip", "Ship Core", function(p, e, g)
    if !p.tk_env || !e:IsShip() then return end
    
    local oldenv = p:GetEnv()
	table.insert(p.tk_env.envlist, e)
	table.sort(p.tk_env.envlist, EnvPrioritySort)
	local newenv = p:GetEnv()
	
	if oldenv != newenv then
		newenv:DoGravity(p)
		gamemode.Call("OnAtmosphereChange", p, oldenv, newenv)
	end
end)

hook.Add("ExitShip", "Ship Core", function(p, e, g)
    if !p.tk_env || !e:IsShip() then return end
    
    local oldenv = p:GetEnv()
    for k,v in pairs(p.tk_env.envlist) do
        if v == e then
            table.remove(p.tk_env.envlist, k)
            break
        end
    end
    local newenv = p:GetEnv()
    
    if oldenv != newenv then
        newenv:DoGravity(p)
        gamemode.Call("OnAtmosphereChange", p, oldenv, newenv)
    end
end)