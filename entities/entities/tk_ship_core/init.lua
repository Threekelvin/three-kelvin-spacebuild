AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local GH = GravHull
local pairs = pairs
local table = table
local math = math

local function EnvPrioritySort(a, b)
    if a.atmosphere.priority == b.atmosphere.priority then
        return a.atmosphere.radius < b.atmosphere.radius
    end
    return a.atmosphere.priority < b.atmosphere.priority
end

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self.ghd = true
    
    self.atmosphere = {}
    
    self.atmosphere.name        = "Ship"
    self.atmosphere.sphere      = false
    self.atmosphere.noclip      = false
    self.atmosphere.combat      = true
    self.atmosphere.priority    = 2
    self.atmosphere.radius      = 0
    self.atmosphere.gravity     = 1
    self.atmosphere.windspeed   = 0
    self.atmosphere.tempcold    = 290
    self.atmosphere.temphot     = 290
    self.atmosphere.resources   = {}
    
    self:SetNWBool("Generator", true)
    self:AddResource("oxygen", 0)
    self:AddResource("nitrogen", 0)
    
    self.Inputs = WireLib.CreateInputs(self, {"Activate", "Disable GHD"})
    self.Outputs = WireLib.CreateOutputs(self, {"Shield", "Max Shield", "Armor", "Max Armor", "Hull", "Max Hull"})

    self.hull = {}
    self.hull_size = 0
    self.brushes = {}
end

function ENT:TriggerInput(iname, value)
    if iname == "Activate" then
        if value != 0 then
            self:TurnOn()
        else
            self:TurnOff()
        end
    elseif iname == "Disable GHD" then
        if value != 0 then
            self:TurnOff()
            self.ghd = false
        else
            self:TurnOff()
            self.ghd = true
        end
    end
end

function ENT:IsLargeHull(ent)
    if ent:BoundingRadius() < 135 then return false end
    if ent.IsTKRD then return false end
    return true
end

function ENT:AddHull(ent, addBrush)
    if !ent.tk_env || !ent.tk_dmg then return end
    if IsValid(ent.tk_env.core) || IsValid(ent.tk_dmg.core) then return end
    ent.tk_env.core = self
    ent.tk_dmg.core = self
    self.hull[ent] = ent
    
    for k,v in pairs(ent.tk_dmg.stats) do
        self.tk_dmg.total[k] = self.tk_dmg.total[k] + v
    end
    
    ent:CallOnRemove("TKSC", function()
        self:RemoveHull(ent)
    end)
    
    if !self:IsLargeHull(ent) then return end
    self.hull_size = self.hull_size + 1
    self:SendUpdate(ent, true)
    
    if !addBrush then return end
    local brush = ents.Create("at_brush")
    brush.env = self
    brush.parent = ent
    brush:Spawn()
    
    self.brushes[ent] = brush
end

function ENT:RemoveHull(ent)
    ent.tk_env.core = nil
    ent.tk_dmg.core = nil
    self.hull[ent] = nil
    
    ent.tk_dmg.stats.shield = 0
    ent.tk_dmg.stats.armor = ent.tk_dmg.stats.armor * (self.tk_dmg.total.armor / self.tk_dmg.total.armor_max)
    ent.tk_dmg.stats.hull = ent.tk_dmg.stats.hull * (self.tk_dmg.total.hull / self.tk_dmg.total.hull_max)
    
    for k,v in pairs(ent.tk_dmg.stats) do
        self.tk_dmg.total[k] = self.tk_dmg.total[k] - v
    end
    
    self.tk_dmg.total.shield = self.tk_dmg.total.shield - (ent.tk_dmg.stats.shield_max * self.tk_dmg.total.shield / (self.tk_dmg.total.shield_max + ent.tk_dmg.stats.shield_max))
    
    if IsValid(self.brushes[ent]) then
        self.brushes[ent]:Remove()
    end
    self.brushes[ent] = nil
    
    ent:RemoveCallOnRemove("TKSC")
    
    if !self:IsLargeHull(ent) then return end
    self.hull_size = self.hull_size - 1
    self:SendUpdate(ent, false)
end

function ENT:OnRemove()
    self.BaseClass.OnRemove(self)
    
    for k,v in pairs(self.hull) do
        self:RemoveHull(v)
    end
end

function ENT:TurnOn()
    if self:GetActive() || !self:IsLinked() then return end
    self.hull_size = 0
    
    if self.ghd then
        GH.RegisterHull(self, 0)
        GH.UpdateHull(self, self:GetUp())
        
        for k,v in pairs(GH.SHIPS[self].Welds || {}) do
            self:AddHull(v)
        end
        
        self:SetActive(true)
    else
        for k,v in pairs(self:GetConstrainedEntities()) do
            self:AddHull(v, true)
        end

        self:SetActive(true)
    end
    
    self.atmosphere.resources = {}
    self:UpdateOutputs()
end

function ENT:TurnOff()
    if !self:GetActive() then return end
    self:SetActive(false)
    
    if self.ghd then GH.UnHull(self) end
    for k,v in pairs(self.hull) do
        self:RemoveHull(v)
    end
    
    self.hull_size = 0
    self:UpdateOutputs()
end

function ENT:DoThink(eff)
    if !self:GetActive() then return end
    
    local env = TK.AT:GetSpace()
    local conents = self.ghd && (GH.SHIPS[self].Welds || self:GetConstrainedEntities()) || self:GetConstrainedEntities()
    
    for k,v in pairs(conents) do
        if self.hull[k] then continue end
        self:AddHull(v, !self.ghd)
        self:UpdateOutputs()
    end
    
    for k,v in pairs(self.hull) do
        if conents[k] then continue end
        if !IsValid(v) then
            self.hull[k] = nil
            continue
        end
        self:RemoveHull(v)
        self:UpdateOutputs()
    end
    
    local rate = 5 * self.hull_size
    self.data.power = -rate
    
    if !self:Work() then return end
    rate = rate * 1 / math.Max(eff, 0.1)

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
    
    self.tk_dmg.total.shield = math.Clamp(self.tk_dmg.total.shield + self:GetPowerGrid(), 0, self.tk_dmg.total.shield_max)
    WireLib.TriggerOutput(self, "Shield", self.tk_dmg.total.shield)
end

function ENT:NewNetwork(netid)
    if netid == 0 then
        self:TurnOff()
    end
end

function ENT:UpdateValues()

end

function ENT:UpdateOutputs()
    WireLib.TriggerOutput(self, "Shield",       self.tk_dmg.total.shield)
    WireLib.TriggerOutput(self, "Max Shield",   self.tk_dmg.total.shield_max)
    WireLib.TriggerOutput(self, "Armor",        self.tk_dmg.total.armor)
    WireLib.TriggerOutput(self, "Max Armor",    self.tk_dmg.total.armor_max)
    WireLib.TriggerOutput(self, "Hull",         self.tk_dmg.total.hull)
    WireLib.TriggerOutput(self, "Max Hull",     self.tk_dmg.total.hull_max)
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

function ENT:GetRadius2()
    return 0
end

function ENT:GetGravity()
    return self.atmosphere.gravity
end

function ENT:GetVolume()
    return 0
end

function ENT:Sunburn()
    return false
end

function ENT:HasResource(res)
    return self.atmosphere.resources[res] && self.atmosphere.resources[res] > 0
end

function ENT:CanNoclip()
    return self.atmosphere.noclip
end

function ENT:CanCombat()
    return self.atmosphere.combat
end

function ENT:GetResourcePercent(res)
    return self.atmosphere.resources[res] || 0
end

function ENT:InAtmosphere(pos)
    if !self:GetActive() then return false end
    
    if self.ghd then
        return GH.PointInShip(self, pos)
    end
    
    for k,v in pairs(self.brushes) do
        if !IsValid(v) then continue end
        local cen, min, max = v:GetPos(), v:GetCollisionBounds()
        if pos.x < cen.x + min.x && pos.x > cen.x + max.x && pos.y < cen.y + min.y && pos.y > cen.y + max.y && pos.z < cen.z + min.z && pos.z > cen.z + max.z then
            return true
        end
    end
    return false
end

function ENT:DoGravity(ent)
    if !IsValid(ent) || !ent.tk_env || ent.tk_env.nogravity then return end
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

///--- Shield Render ---\\\
util.AddNetworkString("TKCore")

function ENT:SendUpdate(ent, isHull, ply)
    net.Start("TKCore")
        net.WriteEntity(ent)
        net.WriteBit(isHull)
    net.Send(ply || player.GetAll())
end

hook.Add("PlayerInitialSpawn", "TKCore", function(ply)
    timer.Simple(5, function()
        for _,ent in pairs(ents.FindByClass("tk_ship_core")) do
            if !ent:GetActive() then continue end
            for _,hull in pairs(ent.hull) do
                if !ent:IsLargeHull(hull) then continue end
                ent:SendUpdate(hull, true, ply)
            end
        end
    end)
end)