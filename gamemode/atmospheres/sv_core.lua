TK.AT = TK.AT or {}
TK.AT.Suns = {}
TK.AT.Stars = {}
TK.AT.Ships = {}
TK.AT.Planets = {}
--/--- Flags ---\\\
ATMOSPHERE_SUNBURN = 2
--/--- ---\\\
--/--- SPAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACE ---\\\
local Space = {}
Space.atmosphere = {}
Space.atmosphere.name = "Space"
Space.atmosphere.sphere = true
Space.atmosphere.noclip = false
Space.atmosphere.combat = true
Space.atmosphere.priority = 4
Space.atmosphere.radius = 0
Space.atmosphere.gravity = 0
Space.atmosphere.windspeed = 0
Space.atmosphere.tempcold = 3
Space.atmosphere.temphot = 3
Space.atmosphere.resources = {}

function Space:HasFlag(id)
    return bit.band(id, self.atmosphere.flags) == id
end

function Space:IsStar()
    return false
end

function Space:IsShip()
    return false
end

function Space:IsPlanet()
    return false
end

function Space:IsSpace()
    return true
end

function Space:GetName()
    return self.atmosphere.name
end

function Space:GetRadius()
    return 0
end

function Space:GetRadius2()
    return 0
end

function Space:GetGravity()
    return self.atmosphere.gravity
end

function Space:GetVolume()
    return 0
end

function Space:Sunburn()
    return false
end

function Space:HasResource(res)
    return false
end

function Space:CanNoclip()
    return false
end

function Space:CanCombat()
    return true
end

function Space:GetResourcePercent(res)
    return 0
end

function Space:CheckEntity(ent)
end

function Space:InAtmosphere(pos)
    return true
end

function Space:DoGravity(ent)
    if not IsValid(ent) or not ent.tk_env or ent.tk_env.nogravity then return end
    local phys = ent:GetPhysicsObject()
    if not IsValid(phys) then return end
    local grav = self.atmosphere.gravity
    if ent.tk_env.gravity == grav then return end
    local bool = grav > 0
    phys:EnableGravity(bool)
    phys:EnableDrag(bool)
    ent:SetGravity(grav + 0.001)
    ent.tk_env.gravity = grav
end

function Space:InSun(ent)
    if not IsValid(ent) then return false end
    local pos = ent:LocalToWorld(ent:OBBCenter())

    for k, v in pairs(TK.AT:GetSuns()) do
        local trace = {}
        trace.start = pos - (pos - v):GetNormal() * 2048
        trace.endpos = pos
        trace.filter = {ent,  ent:GetParent()}
        local tr = util.TraceLine(trace)
        if not tr.Hit then return true end
    end

    return false
end

function Space:DoTemp(ent)
    if not IsValid(ent) then return 3, false end

    return 3, self:InSun(ent)
end

function Space:IsValid()
    return true
end

--/---   ---\\\
local function DecodeKeyValues(values)
    local cat, data = "none", {}

    if values.Case01 == "planet" then
        cat = "planet"
        data["radius"] = tonumber(values.Case02)
        data["gravity"] = tonumber(values.Case03)
        data["tempcold"] = tonumber(values.Case05)
        data["temphot"] = tonumber(values.Case06)

        data["resources"] = {
            oxygen = 20,
            carbon_dioxide = 5,
            nitrogen = 70,
            hydrogen = 5
        }

        data["name"] = "Planet"
        data["flags"] = tonumber(values.Case16)
        data["sphere"] = 1
        data["noclip"] = 0
        data["combat"] = 1
    elseif values.Case01 == "planet2" then
        cat = "planet"
        data["radius"] = tonumber(values.Case02)
        data["gravity"] = tonumber(values.Case03)
        data["tempcold"] = tonumber(values.Case06)
        data["temphot"] = tonumber(values.Case07)

        data["resources"] = {
            oxygen = tonumber(values.Case09),
            carbon_dioxide = tonumber(values.Case10),
            nitrogen = tonumber(values.Case11),
            hydrogen = tonumber(values.Case12)
        }

        data["name"] = values.Case13
        data["flags"] = tonumber(values.Case08)
        data["sphere"] = 1
        data["noclip"] = 0
        data["combat"] = 1
    elseif values.Case01 == "cube" then
        cat = "planet"
        data["radius"] = tonumber(values.Case02)
        data["gravity"] = tonumber(values.Case03)
        data["tempcold"] = tonumber(values.Case06)
        data["temphot"] = tonumber(values.Case07)

        data["resources"] = {
            oxygen = tonumber(values.Case09),
            carbon_dioxide = tonumber(values.Case10),
            nitrogen = tonumber(values.Case11),
            hydrogen = tonumber(values.Case12)
        }

        data["name"] = values.Case13
        data["flags"] = tonumber(values.Case08)
        data["sphere"] = 0
        data["noclip"] = 0
        data["combat"] = 1
    elseif values.Case01 == "star" then
        cat = "star"
        data["radius"] = tonumber(values.Case02)
        data["tempcold"] = 1000000
        data["temphot"] = 1000000

        data["resources"] = {
            hydrogen = 80,
            helium = 20
        }

        data["name"] = "Star"
        data["noclip"] = 0
        data["combat"] = 1
    elseif values.Case01 == "star2" then
        cat = "star"
        data["radius"] = tonumber(values.Case02)
        data["tempcold"] = 1000000
        data["temphot"] = 1000000

        data["resources"] = {
            hydrogen = 80,
            helium = 20
        }

        data["name"] = values.Case06
        data["noclip"] = 0
        data["combat"] = 1
    end

    return cat, data
end

local function LoadMapData()
    if not TK.MapSetup.Atmospheres or #TK.MapSetup.Atmospheres == 0 then
        print("------- Loading From Map ------")
        TK.MapSetup.Atmospheres = {}

        for _, ent in pairs(ents.FindByClass("logic_case")) do
            local cat, data = DecodeKeyValues(ent:GetKeyValues())
            local pos = ent:GetPos()

            table.insert(TK.MapSetup.Atmospheres, {
                cat = cat,
                x = pos.x,
                y = pos.y,
                z = pos.z,
                data = data
            })
        end

        if not file.Exists("tksb", "DATA") then
            file.CreateDir("tksb")
            file.CreateDir("tksb/atmospheres")
        end

        file.Write("tksb/atmospheres/" .. game.GetMap() .. ".txt", util.TableToKeyValues(TK.MapSetup.Atmospheres))
    end
end

local function RegisterAtmospheres()
    print("--- Registering Atmospheres ---")

    for k, v in pairs(TK.MapSetup.Atmospheres) do
        if v.cat == "planet" then
            local planet = ents.Create("at_planet")
            planet:SetPos(Vector(v.x, v.y, v.z))
            planet:Spawn()
            planet:SetupAtomsphere(v.data)
            print(planet, "Created")
        elseif v.cat == "star" then
            local star = ents.Create("at_star")
            star:SetPos(Vector(v.x, v.y, v.z))
            star:Spawn()
            star:SetupAtomsphere(v.data)
            print(star, "Created")
            table.insert(TK.AT.Suns, Vector(v.x, v.y, v.z))
        end
    end

    print("-------------------------------")
end

local function RegisterSuns()
    print("------- Registering Suns ------")

    for k, v in ipairs(ents.FindByClass("env_sun")) do
        if IsValid(v) then
            table.insert(TK.AT.Suns, v:GetPos())
            print(v, "Found")
        end
    end

    if #TK.AT.Suns == 0 then
        table.insert(TK.AT.Suns, Vector(50000, 50000, 50000))
        print("No Sun Found, Default Added")
    end

    print("-------------------------------")
end

local function EnvPrioritySort(a, b)
    if a.atmosphere.priority == b.atmosphere.priority then return a.atmosphere.radius < b.atmosphere.radius end

    return a.atmosphere.priority < b.atmosphere.priority
end

function TK.AT:GetSpace()
    return Space
end

function TK.AT:GetPlanets()
    return self.Planets
end

function TK.AT:GetShips()
    return self.Ships
end

function TK.AT:GetStars()
    return self.Stars
end

function TK.AT:GetSuns()
    return self.Suns
end

function TK.AT:GetAtmosphereOnPos(pos)
    local env = Space

    for k, v in pairs(TK.AT.Stars) do
        if IsValid(v) then
            if EnvPrioritySort(v, env) and v:InAtmosphere(pos) then
                env = v
            end
        end
    end

    for k, v in pairs(TK.AT.Ships) do
        if IsValid(v) then
            if EnvPrioritySort(v, env) and v:InAtmosphere(pos) then
                env = v
            end
        end
    end

    for k, v in pairs(TK.AT.Planets) do
        if IsValid(v) then
            if EnvPrioritySort(v, env) and v:InAtmosphere(pos) then
                env = v
            end
        end
    end

    return env
end

function TK.AT:ManualCheck(ent)
    if not IsValid(ent) then return end
    local new_env = self:GetAtmosphereOnPos(ent:GetPos())
    local old_env = ent:GetEnv()
    if new_env == old_env then return end
    ent.tk_env.envlist = {new_env}
    new_env:DoGravity(ent)
    gamemode.Call("OnAtmosphereChange", ent, old_env, new_env)
end

util.AddNetworkString("TKAT")

hook.Add("Initialize", "TKAT", function()
    function GAMEMODE:OnAtmosphereChange(ent, old_env, new_env)
    end

    function _R.Entity:OnAtmosphereChange(old_env, new_env)
    end

    function _R.Entity:GetEnv()
        if not self.tk_env then return Space end
        if self:IsPlayer() and self:InVehicle() then return self:GetVehicle():GetEnv() end
        local env = self.tk_env.envlist[1] or Space

        if not IsValid(env) then
            table.remove(self.tk_env.envlist, 1)

            return self:GetEnv()
        end

        return env
    end
end)

hook.Add("InitPostEntity", "TKAT", function()
    print("---- TK Atmospheres Loading ---")
    LoadMapData()
    RegisterAtmospheres()
    RegisterSuns()
    print("---- TK Atmospheres Loaded ----")

    timer.Create("TKAT_wind", 30, 0, function()
        for k, v in pairs(TK.AT.Planets) do
            if not IsValid(v) then continue end
            v.atmosphere.windspeed = math.random(0, 100)
        end
    end)
end)

hook.Add("PlayerInitialSpawn", "TKAT", function(ply)
    ply.tk_env = {}
    ply.tk_env.envlist = {}
    ply.tk_env.gravity = -1
    ply:GetEnv():DoGravity(ply)
end)

hook.Add("EntitySpawned", "TKAT", function(ent)
    local class = ent:GetClass()

    if class == "at_planet" then
        table.insert(TK.AT.Planets, ent)
    elseif class == "at_star" then
        table.insert(TK.AT.Stars, ent)
    elseif class == "tk_ship_core" then
        table.insert(TK.AT.Ships, ent)
    end

    if ent.Type == "brush" or ent.Type == "point" then return end
    if not IsValid(ent:GetPhysicsObject()) then return end
    if ent:GetMoveType() == 0 then return end
    ent.tk_env = {}
    ent.tk_env.envlist = {}
    ent.tk_env.gravity = -1
    ent:GetEnv():DoGravity(ent)
end)

hook.Add("OnAtmosphereChange", "TKAT", function(ent, old_env, new_env)
    ent:OnAtmosphereChange(old_env, new_env)
end)

hook.Add("PhysgunPickup", "TKAT", function(ply, ent)
    if ply:IsAdmin() then return end
    if not ply:GetEnv():IsSpace() then return end

    return false
end)
