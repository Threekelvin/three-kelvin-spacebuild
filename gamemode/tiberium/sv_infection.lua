TK.TI = TK.TI or {}
local Contraptions = {}

function TK.TI:IsInfected(ent)
    if ent.TibInfect ~= nil then return true end

    return false
end

local function BlackList(ent)
    if ent:IsPlayer() then return false end
    if ent:IsNPC() then return false end
    if ent:IsWeapon() then return false end
    if ent.SLIsGhost then return false end
    local class = ent:GetClass()
    if class == "gmod_ghost" then return false end
    if class == "prop_door_rotating" then return false end
    if class == "predicted_viewmodel" then return false end
    if string.match(class, "^phys_") then return false end
    if string.match(class, "^logic_") then return false end

    return true
end

local function CanInfect(ent)
    if not IsValid(ent) then return false end
    if not ent:UID() then return false end
    if TK.TI:IsInfected(ent) then return false end

    return BlackList(ent)
end

local function ScanNetwork(netid, entlist)
    local node = TK.RD:GetNetTable(netid).node

    if IsValid(node) then
        if not entlist[node:EntIndex()] then
            entlist[node:EntIndex()] = node

            for k, v in pairs(node:GetConstrainedEntities()) do
                entlist[v:EntIndex()] = v
            end
        end

        for k, v in pairs(TK.RD:GetConnectedEnts(netid)) do
            if not entlist[v:EntIndex()] then
                entlist[v:EntIndex()] = v

                for l, b in pairs(v:GetConstrainedEntities()) do
                    entlist[b:EntIndex()] = b
                end
            end
        end
    end
end

local function ScanForEntities(ent)
    local entities = constraint.GetAllConstrainedEntities(ent)
    local entlist = {}
    local nets = {0}

    for k, v in pairs(entities) do
        entlist[v:EntIndex()] = v
    end

    for k, v in pairs(entlist) do
        if not v.IsTKRD or v.IsNode then continue end
        local netid = v:GetEntTable().netid

        if not table.HasValue(nets, netid) then
            table.insert(nets, netid)
            ScanNetwork(netid, entlist)

            for l, b in pairs(TK.RD:GetConnectedEnts(netid)) do
                if not table.HasValue(nets, b) then
                    table.insert(nets, b)
                    ScanNetwork(b, entlist)
                end
            end
        end
    end

    return entlist
end

local function GetContraption(ent)
    local idx = table.insert(Contraptions, ScanForEntities(ent))

    for k, v in pairs(Contraptions[idx]) do
        if not CanInfect(v) then
            Contraptions[idx][k] = nil
        else
            if v:GetClass() == "tk_tiberium_storage" then
                v.tk_tib = {}
                TK.TI:Infect(v)
            else
                v.tk_tib = Contraptions[idx]
            end
        end
    end

    return Contraptions[idx]
end

local function GarbageCollection()
    for k, v in pairs(Contraptions) do
        local Valid = false

        for l, b in pairs(v) do
            if not Valid and CanInfect(b) then
                Valid = true
            end
        end

        if not Valid then
            Contraptions[k] = nil
        end
    end
end

local function SpawnCrystal(ent)
    if not IsValid(ent) or not IsValid(ent:GetPhysicsObject()) then return end

    for i = 0,  10 do
        local radius = ent:BoundingRadius() * 1.25
        local point1 = ent:LocalToWorld(ent:OBBCenter() + Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1)) * radius)
        local point2 = ent:NearestPoint(point1)
        local td = {}
        td.start = point1
        td.endpos = point2 + (point2 - point1):GetNormal() * radius
        local trace = util.TraceLine(td)
        if trace.StartSolid then continue end
        if not IsValid(trace.Entity) or not TK.TI:IsInfected(trace.Entity) then continue end
        if ent.tk_tib[trace.Entity:EntIndex()] ~= trace.Entity then continue end
        local crystal = ents.Create("tk_tiberium_infection")
        crystal:SetPos(trace.HitPos)
        crystal:SetAngles(trace.HitNormal:Angle() + Angle(90, 0, 0))
        crystal:Spawn()
        crystal:SetParent(trace.Entity)

        return
    end
end

local function InfectionThink(ent, contraption)
    if contraption then
        local Valid = false

        for k, v in pairs(contraption) do
            if CanInfect(v) then
                Valid = true
                TK.TI:Infect(v)
                break
            end
        end

        if not Valid then
            GarbageCollection()
        end
    end

    if not IsValid(ent) then return end
    local factor = math.Clamp(ent:BoundingRadius() / 100, 1, 3)

    if ent.TibInfect > factor then
        local fxdata = EffectData()
        fxdata:SetOrigin(ent:GetPos())
        util.Effect("tib_die", fxdata, true)

        if ent:IsVehicle() then
            local driver = ent:GetDriver()

            if IsValid(driver) and driver:IsPlayer() then
                driver:ExitVehicle()
            end
        end

        SafeRemoveEntity(ent)
    else
        ent.TibInfect = ent.TibInfect + 1
        SpawnCrystal(ent)

        timer.Simple(math.random(5, 10) * factor, function()
            InfectionThink(ent, contraption)
        end)
    end
end

function TK.TI:Infect(ent)
    if not CanInfect(ent) then return end
    ent.TibInfect = 0

    if not ent.tk_tib then
        ent.tk_tib = GetContraption(ent)
    end

    local factor = math.Clamp(ent:BoundingRadius() / 100, 1, 3)
    SpawnCrystal(ent)

    timer.Simple(math.random(5, 10) * factor, function()
        InfectionThink(ent, ent.tk_tib)
    end)
end

function TK.TI:InfectBlast(ent, radius)
    for k, v in pairs(TK:FindInSphere(ent:GetPos(), radius)) do
        self:Infect(v)
    end
end
