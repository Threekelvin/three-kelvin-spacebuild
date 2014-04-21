
TK.MapSetup = TK.MapSetup or {
    Atmospheres = {},
    MapEntities = {},
    SpawnPoints = {},
    Resources   = {},
}

local function ShouldSpawn(cluster)
    if table.Count(cluster.Ents) >= cluster.Size then return false end
    if CurTime() < cluster.NSpawn then return false end
    return true
end

local function SpawnAsteroid(cluster, pos)
    local ent = ents.Create(cluster.Class)
    ent:SetPos(pos)
    ent:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
    ent:Spawn()
    ent.GetField = function()
        return cluster.Ents or {}
    end
    ent:CallOnRemove("UpdateList", function()
        cluster.Ents[ent:EntIndex()] = nil
    end)
    
    cluster.Ents[ent:EntIndex()] = ent
    cluster.NSpawn = CurTime() + 90 * (table.Count(cluster.Ents) / cluster.Size) + 5
end

local function SpawnCrystal(cluster, pos, ang)
    local ent = ents.Create(cluster.Class)
    ent:SetPos(pos)
    ent:SetAngles(ang)
    ent:Spawn()
    ent.GetField = function()
        return cluster.Ents or {}
    end
    ent:CallOnRemove("UpdateList", function()
        cluster.Ents[ent:EntIndex()] = nil
    end)
    
    cluster.Ents[ent:EntIndex()] = ent
    cluster.NSpawn = CurTime() + 90 * (table.Count(cluster.Ents) / cluster.Size) + 5
end

local function FindFieldPos(cluster)
    local pos = Vector(math.random(0, cluster.Radius), 0, 0)
    local ang = Angle(0, 0, 0)
    pos:Rotate(Angle(math.random(0, 360), math.random(0, 360), 0))
    pos = pos + cluster.Pos
    
    for _,ent in pairs(TK:FindInSphere(pos, 805)) do
        if IsValid(ent) and IsValid(ent:GetPhysicsObject()) and !ent.IsAtmosphere then
            return false
        end
    end
    
    return pos, ang
end

local function FindBeltPos(cluster)
    local pos = Vector(cluster.Radius, 0, 0)
    local ang = Angle(0, 0, 0)
    pos:Rotate(Angle(0, math.random(0, 360), 0))
    pos:Rotate(cluster.Ang)
    pos = pos + cluster.Pos

    for _,ent in pairs(TK:FindInSphere(pos, 805)) do
        if IsValid(ent) and IsValid(ent:GetPhysicsObject()) and !ent.IsAtmosphere then
            return false
        end
    end
    
    return pos, ang
end

local function FindSurfacePos(cluster)
    local pos = Vector(math.random(0, cluster.Radius), 0, 0)
    local ang = Angle(0, 0, 0)
    pos:Rotate(Angle(0,math.random(0, 360), 0))
    pos = pos + cluster.Pos + Vector(0, 0, 250)
    
    local td = {
        start = pos,
        endpos = pos - Vector(0, 0, 500),
        mask = MASK_NPCWORLDSTATIC
    }

    local trace =  util.TraceLine(td)
    if !trace.HitWorld then return false end
    if trace.StartSolid then return false end

    for _,ent in pairs(TK:FindInSphere(trace.HitPos, 500)) do
        if IsValid(ent) and ent:GetClass() == cluster.Class then
            return false
        end
    end
    
    return trace.HitPos, (trace.HitNormal:Angle() + Angle(90, 0, 0))
end

hook.Add("Tick", "TK_Resource_Spawning", function()
    for _,res in pairs(TK.MapSetup.Resources) do
        for _,cluster in pairs(res) do
            if !ShouldSpawn(cluster) then continue end
            if cluster.Type == "Field" then
                local pos, ang = FindFieldPos(cluster)
                if pos then
                    SpawnAsteroid(cluster, pos)
                end
            elseif cluster.Type == "Belt" then
                local pos, ang = FindBeltPos(cluster)
                if pos then
                    SpawnAsteroid(cluster, pos)
                end
            elseif cluster.Type == "Surface" then
                local pos, ang = FindSurfacePos(cluster)
                if pos then
                    SpawnCrystal(cluster, pos, ang)
                end
            end
        end
    end
end)