AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local ModelList = {
    ["models/mandrac/asteroid/pyroxveld1.mdl"] = {
        children = {
            [1] = "models/mandrac/asteroid/pyroxveld2.mdl",
            [2] = "models/mandrac/asteroid/pyroxveld2.mdl",
            [3] = "models/mandrac/asteroid/pyroxveld2.mdl",
            [4] = "models/mandrac/asteroid/pyroxveld3.mdl",
            [5] = "models/mandrac/asteroid/pyroxveld3.mdl"
        },
        health = 200
    },
    ["models/mandrac/asteroid/pyroxveld4.mdl"] = {
        children = {
            [1] = "models/mandrac/asteroid/pyroxveld2.mdl",
            [2] = "models/mandrac/asteroid/pyroxveld2.mdl",
            [3] = "models/mandrac/asteroid/pyroxveld3.mdl"
        },
        health = 120
    },
    ["models/mandrac/asteroid/rock3.mdl"] = {
        children = {
            [1] = "models/mandrac/asteroid/rock2.mdl",
            [2] = "models/mandrac/asteroid/rock2.mdl",
            [3] = "models/mandrac/asteroid/rock4.mdl",
            [4] = "models/mandrac/asteroid/rock4.mdl",
            [5] = "models/mandrac/asteroid/rock4.mdl"
        },
        health = 200
    },
    ["models/mandrac/asteroid/rock5.mdl"] = {
        children = {
            [1] = "models/mandrac/asteroid/rock2.mdl",
            [2] = "models/mandrac/asteroid/rock4.mdl",
            [3] = "models/mandrac/asteroid/rock4.mdl"
        },
        health = 120
    }
}

function ENT:GetField()
    return {}
end

function ENT:Initialize()
    local mdl_table, model = table.Random(ModelList)
    self:SetModel(model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_VPHYSICS)
    self.health = mdl_table.health
    self.max_health = mdl_table.health
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Wake()
    end
end

function ENT:GetRoidPos(ent)
    local rad, ran_vec = self:BoundingRadius() * 0.75

    while true do
        ran_vec = self:LocalToWorld(self:OBBCenter()) + Vector(math.random(-rad, rad), math.random(-rad, rad), math.random(-rad, rad))
        local td = {}
        td.start = ran_vec
        td.endpos = ran_vec
        td.filter = self
        td.mins = ent:OBBMins()
        td.maxs = ent:OBBMaxs()
        local trace = util.TraceHull(td)
        if not trace.Hit then break end
    end

    return ran_vec
end

function ENT:Split()
    for k, v in pairs(ModelList[self:GetModel()].children) do
        local ent = ents.Create("tk_magnetite_ore")
        ent:SetModel(v)
        ent:SetPos(self:GetRoidPos(ent))
        ent:SetAngles(Angle(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)))
        ent:Spawn()
        local phys = ent:GetPhysicsObject()
        phys:AddVelocity(Vector(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(-10, 10)))
        phys:AddAngleVelocity(Vector(math.Rand(-2, 2), math.Rand(-2, 2), math.Rand(-2, 2)))
    end

    SafeRemoveEntity(self)
end

function ENT:Mine(dmg)
    self.health = self.health - dmg
    if self.health >= 0 then return end
    self:Split()
end
