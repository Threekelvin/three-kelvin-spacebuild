AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

local ModelList = {
    ["models/mandrac/asteroid/pyroxveld1.mdl"] = {
        children = {
            ["models/mandrac/asteroid/pyroxveld2.mdl"] = {
                spawn_weight = 3,
                base_health = 2570,
                ore_rich = false,
            },
            ["models/mandrac/asteroid/pyroxveld3.mdl"] = {
                spawn_weight = 2,
                base_health = 3410,
                ore_rich = false,
            },
            ["models/mandrac/asteroid/crystal3.mdl"] = {
                spawn_weight = 2,
                base_health = 1080,
                ore_rich = true,
            },
            ["models/mandrac/asteroid/crystal4.mdl"] = {
                spawn_weight = 1,
                base_health = 2140,
                ore_rich = true,
            }
        },
        base_health = 8050,
        spawns = 5
    },
    ["models/mandrac/asteroid/pyroxveld4.mdl"] = {
        children = {
            ["models/mandrac/asteroid/pyroxveld2.mdl"] = {
                spawn_weight = 2,
                base_health = 2570,
                ore_rich = false,
            },
            ["models/mandrac/asteroid/pyroxveld3.mdl"] = {
                spawn_weight = 1,
                base_health = 3410,
                ore_rich = false,
            },
            ["models/mandrac/asteroid/crystal2.mdl"] = {
                spawn_weight = 1,
                base_health = 1830,
                ore_rich = true,
            },
            ["models/mandrac/asteroid/crystal3.mdl"] = {
                spawn_weight = 1,
                base_health = 1080,
                ore_rich = true,
            }
        },
        base_health = 585,
        spawns = 3
    },
    ["models/mandrac/asteroid/rock3.mdl"] = {
        children = {
            ["models/mandrac/asteroid/rock2.mdl"] = {
                spawn_weight = 2,
                base_health = 1160,
                ore_rich = false,
            },
            ["models/mandrac/asteroid/rock4.mdl"] = {
                spawn_weight = 3,
                base_health = 1000,
                ore_rich = false,
            },
            ["models/mandrac/asteroid/geode3.mdl"] = {
                spawn_weight = 3,
                base_health = 1860,
                ore_rich = true,
            },
            ["models/mandrac/asteroid/geode4.mdl"] = {
                spawn_weight = 2,
                base_health = 2250,
                ore_rich = true,
            }
        },
        base_health = 5150,
        spawns = 3
    },
    ["models/mandrac/asteroid/rock5.mdl"] = {
        children = {
            ["models/mandrac/asteroid/rock2.mdl"] = {
                spawn_weight = 1,
                base_health = 1160,
                ore_rich = false,
            },
            ["models/mandrac/asteroid/rock4.mdl"] = {
                spawn_weight = 2,
                base_health = 890,
                ore_rich = false,
            },
            ["models/mandrac/asteroid/geode1.mdl"] = {
                spawn_weight = 1,
                base_health = 1110,
                ore_rich = true,
            }
        },
        base_health = 2280,
        spawns = 2
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
    self.health = mdl_table.base_health
    self.max_health = mdl_table.base_health
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:EnableMotion(false)
        phys:Wake()
    end
end

function ENT:GetRoidPos(ent)
    local rad, ran_vec = self:BoundingRadius() * 0.75
    local limit = 0

    while limit < 25 do
        ran_vec = self:LocalToWorld(self:OBBCenter()) + Vector(math.random(-rad, rad), math.random(-rad, rad), math.random(-rad, rad))
        local td = {}
        td.start = ran_vec
        td.endpos = ran_vec
        td.filter = self
        td.mins = ent:OBBMins()
        td.maxs = ent:OBBMaxs()
        local trace = util.TraceHull(td)
        if not trace.Hit then
            print("limit - ", limit)
            return ran_vec, true
        end
    end

    return self:GetPos(), false
end

function ENT:SpawnChild(mdl)
    local ent = ents.Create("tk_magnetite_ore")
    ent:SetModel(mdl)

    local spawn_pos, is_valid = self:GetRoidPos()
    if not is_valid then
        ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
    end

    ent:SetPos(spawn_pos)
    ent:SetAngles(Angle(math.random(-180, 180), math.random(-180, 180), math.random(-180, 180)))
    ent:Spawn()
    local phys = ent:GetPhysicsObject()
    phys:AddVelocity(Vector(math.Rand(-10, 10), math.Rand(-10, 10), math.Rand(-10, 10)))
    phys:AddAngleVelocity(Vector(math.Rand(-2, 2), math.Rand(-2, 2), math.Rand(-2, 2)))

    local mdl_data = ModelList[self:GetModel()].children[mdl]
    ent.health = mdl_data.base_health
    ent.max_health = mdl_data.base_health
    ent.ore_rich = mdl_data.ore_rich
end

function ENT:Split()
    local random_table = {}

    for k,v in pairs(ModelList[self:GetModel()].children) do
        for i = 1, v.spawn_weight do
            random_table[#random_table] = k
        end
    end

    for i = 1, ModelList[self:GetModel()].spawns do
        self:SpawnChild(random_table[math.random(1, #random_table)])
    end

    SafeRemoveEntity(self)
end

function ENT:Mine(dmg)
    self.health = self.health - dmg
    if self.health >= 0 then return end
    self:Split()
end
