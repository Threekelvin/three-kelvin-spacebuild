
TK.DC = TK.DC || {}
local Ships = {}

DMG_KINETIC = 1
DMG_THERMAL = 2
DMG_EXPLOSIVE = 3

local function GarbageCollect()
    for k,v in pairs(Ships) do
        for _,ent in pairs(v.entities) do
            if !IsValid(ent) then v.entities[k] = nil end
            if ent.tk_dmg.ship != v then v.entities[k] = nil end
        end
        
        if table.Count(v.entities) == 0 then
            Ships[k] = nil
        end
    end
end

hook.Add("EntitySpawned", "TKDC", function(ent)
    if ent.Type == "brush" || ent.Type == "point" then return end
    if !IsValid(ent:GetPhysicsObject()) then return end
    if ent:GetMoveType() == 0 then return end
    
    local phys = ent:GetPhysicsObject()
    local vol = math.floor(math.sqrt(phys:GetVolume()) * 0.5)
    
    ent.tk_dmg = {}
    ent.tk_dmg.hull = vol
    ent.tk_dmg.armor = vol * 0.5
    ent.tk_dmg.shield = vol * 0.5
    
    ent:CallOnRemove("TKDC", function(ent)
        if !ent.tk_dmg.ship then return end
        ent.tk_dmg.ship.entities[ent] = nil
    end)
end)

function TK.DC:MakeNewShip(ent)
    local ship = {}
    ship.entities = {[ent] = ent}
    
    ship.hull = {}
    ship.hull.cur = ent.tk_dmg.hull
    ship.hull.max = ent.tk_dmg.hull
    
    ship.armor = {}
    ship.armor.cur = ent.tk_dmg.armor
    ship.armor.max = ent.tk_dmg.armor
    
    ship.shield = {}
    ship.shield.cur = ent.tk_dmg.shield
    ship.shield.max = ent.tk_dmg.shield
    
    ship.update = CurTime()
    
    local idx = table.insert(Ships, ship)
    ent.tk_dmg.ship = Ships[idx]
end

function TK.DC:ShipAddEnt(ship, ent)
    ship.entities[ent] = ent
    ship.hull.cur = ship.hull.cur + ent.tk_dmg.hull
    ship.hull.max = ship.hull.max + ent.tk_dmg.hull
    ship.armor.cur = ship.hull.cur + ent.tk_dmg.armor
    ship.armor.max = ship.hull.max + ent.tk_dmg.armor
    ship.shield.cur = ship.hull.cur + ent.tk_dmg.shield
    ship.shield.max = ship.hull.max + ent.tk_dmg.shield
    
    ent.tk_dmg.ship = ship
end

function TK.DC:MergeShips(main, ...)
    for k,v in pairs({...}) do
        for _,ent in pairs(v.entities) do
            main.entities[ent] = ent
            self:ShipAddEnt(main, ent)
        end
    end
end

function TK.DC:GetShip(ent)
    if !ent.tk_dmg.ship then
        local validships = {}
        for k,v in pairs(ent:GetConstrainedEntities()) do
            if !v.tk_dmg then continue end
            if !v.tk_dmg.ship then continue end
            if table.HasValue(validships, v.tk_dmg.ship) then continue end
            table.insert(validships, v.tk_dmg.ship)
        end
        
        if #validships == 0 then
            self:MakeNewShip(ent)
        elseif #validships > 1 then
            self:MakeNewShip(ent)
            self:MergeShips(ent.tk_dmg.ship, unpack(validships))
        else
            self:ShipAddEnt(validships[1], ent)
        end
    end
    
    return ent.tk_dmg.ship
end

function TK.DC:UpdateShip(ship)

end

function TK.DC:DoDamge(ent, amt, typ)
    if !IsValid(ent) || !ent.tk_dmg then return end
    local Ship = self:GetShip(ent)
end