AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

local ModelList = {
    ["models/mandrac/asteroid/pyroxveld1.mdl"] = {
        children = {
            [1] = "models/mandrac/asteroid/pyroxveld2.mdl",
            [2] = "models/mandrac/asteroid/pyroxveld2.mdl",
            [3] = "models/mandrac/asteroid/pyroxveld2.mdl",
            [4] = "models/mandrac/asteroid/pyroxveld3.mdl",
            [5] = "models/mandrac/asteroid/pyroxveld3.mdl",
        },
        health = 200
    },
    ["models/mandrac/asteroid/pyroxveld4.mdl"] = {
        children = {
            [1] = "models/mandrac/asteroid/pyroxveld2.mdl",
            [2] = "models/mandrac/asteroid/pyroxveld2.mdl",
            [3] = "models/mandrac/asteroid/pyroxveld3.mdl",
        },
        health = 120
    },
    ["models/mandrac/asteroid/rock3.mdl"] = {
        children = {
            [1] = "models/mandrac/asteroid/rock2.mdl",
            [2] = "models/mandrac/asteroid/rock2.mdl",
            [3] = "models/mandrac/asteroid/rock4.mdl",
            [4] = "models/mandrac/asteroid/rock4.mdl",
            [5] = "models/mandrac/asteroid/rock4.mdl",
        },
        health = 200
    },
    ["models/mandrac/asteroid/rock5.mdl"] = {
        children = {
            [1] = "models/mandrac/asteroid/rock2.mdl",
            [2] = "models/mandrac/asteroid/rock4.mdl",
            [3] = "models/mandrac/asteroid/rock4.mdl",
        },
        health = 120
    },
}

function ENT:GetField()
    return {}
end

function ENT:GetStartModel()
    local ran, num = math.random(1, table.Count(ModelList)), 1
    
    for k,v in pairs(ModelList) do
        if ran == num then
            return k
        else
            num = num + 1
        end
    end
    
    return table.GetFirstKey(ModelList)
end

function ENT:Initialize()
    self:SetModel(self:GetStartModel())
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self.health = ModelList[self:GetModel()].health
    self.max_health = ModelList[self:GetModel()].health
    
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Wake()
    end
end

function ENT:Split(laser)
    local rad = self:BoundingRadius() * 0.5
    local dir = laser:Up()
    
    for k,v in pairs(ModelList[self:GetModel()].children) do
        local ent = ents.Create("tk_magnetite_ore")
        ent:SetModel(v)
        local ran_vec = Vector(math.random(-rad, rad), math.random(-rad, rad), math.random(-rad, rad))
        ent:SetPos(self:GetMassCenter() + ran_vec)
        ent:SetAngles(Angle(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)))
        ent:SetVelocity((dir + dir * math.Rand(0.5, 1.5)) * 100)
    end
    
    SafeRemoveEntity(self)
end