TK.DC = TK.DC or {}
local Bullets = {}
DMG_KINETIC = 1
DMG_THERMAL = 2
DMG_EXPLOSIVE = 3

local function LoadBullets()
    print([[///--- TKDC Loading Bullets ---\\\]])
    local JustInCase = BULLET

    for _, lua in pairs(file.Find(GM.FolderName .. "/gamemode/damage/bullets/*.lua", "LUA")) do
        local path = GM.FolderName .. "/gamemode/damage/bullets/" .. lua
        BULLET = {}
        include(path)
        local idx = lua:match("^[%w_ ]+")
        Bullets[idx] = BULLET
        print("TKDC Bullet -", idx, "- Loaded")
    end

    BULLET = JustInCase
    print([[///--- TKDC Loaded All Bullets ---\\\]])
end

function TK.DC:GetBullet(id)
    local bullet = Bullets[id]

    return bullet
end

hook.Add("EntitySpawned", "TKDC", function(ent)
    if ent.Type == "brush" or ent.Type == "point" then return end
    if !IsValid(ent:GetPhysicsObject()) then return end
    if ent:GetMoveType() == 0 then return end
    if ent:IsPlayer() then return end
    local base_hp = math.floor(math.sqrt(ent:GetPhysicsObject():GetVolume() or 0) * 0.5)
    ent.tk_dmg = {}
    ent.tk_dmg.stats = {}
    ent.tk_dmg.stats.hull = base_hp
    ent.tk_dmg.stats.hull_max = base_hp
    ent.tk_dmg.stats.armor = base_hp * 0.5
    ent.tk_dmg.stats.armor_max = base_hp * 0.5
    ent.tk_dmg.stats.shield = 0
    ent.tk_dmg.stats.shield_max = base_hp * 0.75
    if ent:GetClass() ~= "tk_ship_core" then return end
    ent.tk_dmg.total = {}
    ent.tk_dmg.total.hull = 0
    ent.tk_dmg.total.hull_max = 0
    ent.tk_dmg.total.armor = 0
    ent.tk_dmg.total.armor_max = 0
    ent.tk_dmg.total.shield = 0
    ent.tk_dmg.total.shield_max = 0
end)

function TK.DC:CanDamage(ent)
    return ent:GetEnv():CanCombat()
end

function TK.DC:DestoryEnt(ent)
    if !IsValid(ent) or !ent.tk_dmg then return end
    local fxdata = EffectData()
    fxdata:SetEntity(ent)
    util.Effect("dmg_destroy", fxdata)
    SafeRemoveEntityDelayed(ent, 0.2)
end

function TK.DC:DestroyCore(ent)
    if !IsValid(ent) or !ent.tk_dmg then return end
    if ent.tk_dmg ~= ent then return end

    for k, v in pairs(ent.hull) do
        if !IsValid(v) then continue end
        constraint.RemoveAll(v)
        v:SetParent()
        v:SetNotSolid(true)

        timer.Simple(math.random(100, 500) * 0.01, function()
            if !IsValid(v) then return end
            self:DestoryEnt(v)
        end)

        local phys = v:GetPhysicsObject()
        if !IsValid(phys) then continue end
        phys:EnableMotion(true)
        phys:Wake()
        phys:AddVelocity(Vector(math.random(-75, 75), math.random(-75, 75), math.random(-75, 75)))
        phys:AddAngleVelocity(Vector(math.random(-25, 25), math.random(-25, 25), math.random(-25, 25)))
    end

    for k, v in pairs(ents.GetAll()) do
        if v:GetEnv() ~= ent then continue end
        if ent.hull[v] then continue end
        self:DestoryEnt(v)
    end
end

function TK.DC:DmgShield(shield, amt, typ)
    local dmg_max = amt

    if DMG_KINETIC then
        dmg_max = dmg_max * 0.75
    elseif DMG_EXPLOSIVE then
        dmg_max = dmg_max * 0.25
    end

    local dmg = math.min(shield, dmg_max)

    return shield - dmg, dmg / dmg_max
end

function TK.DC:DmgArmor(armor, amt, typ)
    local dmg_max = amt

    if DMG_KINETIC then
        dmg_max = dmg_max * 0.75
    elseif DMG_THERMAL then
        dmg_max = dmg_max * 0.5
    end

    local dmg = math.min(armor, dmg_max)

    return armor - dmg, dmg / dmg_max
end

function TK.DC:DmgHull(hull, amt, typ)
    local dmg_max = amt

    if DMG_KINETIC then
        dmg_max = dmg_max * 0.75
    elseif DMG_THERMAL then
        dmg_max = dmg_max * 0.5
    end

    local dmg = math.min(hull, dmg_max)

    return hull - dmg, dmg / dmg_max
end

function TK.DC:DoDamge(ent, amt, typ)
    if !IsValid(ent) or !ent.tk_dmg then return end
    if !self:CanDamage(ent) then return end
    local useCore = IsValid(ent.tk_dmg.core)
    local stats = useCore and ent.tk_dmg.core.tk_dmg.total or ent.tk_dmg.stats
    local dmg, shield, armor, hull = 1, 0, 0, 0
    shield, dmg = self:DmgShield(stats.shield, amt * dmg, typ)
    armor, dmg = self:DmgArmor(stats.armor, amt * dmg, typ)
    hull, dmg = self:DmgHull(stats.hull, amt * dmg, typ)

    if useCore then
        ent.tk_dmg.core.tk_dmg.total.shield = shield
        ent.tk_dmg.core.tk_dmg.total.armor = armor
        ent.tk_dmg.core.tk_dmg.total.hull = hull
        ent:UpdateOutputs()
    else
        ent.tk_dmg.stats.shield = shield
        ent.tk_dmg.stats.armor = armor
        ent.tk_dmg.stats.hull = hull
    end

    if hull > 0 then return end

    if useCore then
        self:DestroyCore(ent.tk_dmg.core)
    else
        self:DestoryEnt(ent)
    end
end

function TK.DC:DoBlastDamage(pos, rad, amt, typ)
    local hits = TK:FindInSphere(pos, rad)
    local takedmg = {}

    for _, ent in pairs(hits) do
        if !ent.tk_dmg then continue end

        if IsValid(ent.tk_dmg.core) then
            if table.HasValue(takedmg, ent.tk_dmg.core) then continue end
            table.insert(takedmg, ent.tk_dmg.core)
        else
            table.insert(takedmg, ent)
        end
    end

    for k, v in pairs(takedmg) do
        self:DoDamge(v, amt, typ)
    end
end

LoadBullets()
