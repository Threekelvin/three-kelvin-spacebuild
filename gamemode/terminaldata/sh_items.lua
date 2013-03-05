
TK.TD = TK.TD || {}

local Items = {
    mining = {
        {
            idx = 1,
            name = "Basic Asteroid Mining Laser",
            class = "tk_ore_laser",
            mdl = "models/props_phx/life_support/crylaser_small.mdl",
            data = {yield = 100, range = 1000, power = -50},
            r = 19,
            buy = 10000,
            sell = 7500
        },
        {
            idx = 2,
            name = "Basic Tiberium Extractor",
            class = "tk_tib_extractor",
            mdl = "models/techbot/sonic_thingy.mdl",
            data = {yield = 20, power = -50},
            r = 28,
            buy = 10000,
            sell = 7500
        },
    },
    storage = {
        {
            idx = 3,
            name = "Basic Asteroid Ore Storage",
            class = "tk_ore_storage",
            mdl = "models/slyfo/nacshortsleft.mdl",
            data = {capacity = 10000},
            r = 73,
            buy = 10000,
            sell = 7500
        },
        {
            idx = 4,
            name = "Basic Raw Tiberium Storage",
            class = "tk_tib_storage",
            mdl = "models/slyfo/sat_resourcetank.mdl",
            data = {capacity = 2000},
            r = 47,
            buy = 10000,
            sell = 7500,
        }
    },
    weapon = {
        {
            idx = 5,
            name = "Basic Ballistic Turret",
            class = "tk_turret",
            mdl = "models/techbot/turret/flak/flak_turret.mdl",
            data = {power = 0, bullet = "20mm_cannon"},
            r = 50,
            buy = 100000,
            sell = 7500
        }
    }
}

function TK.TD:GetItem(id)
    for _,slot in pairs(Items) do
        for k,v in pairs(slot) do
            if v.idx != tonumber(id) then continue end
            return v
        end
    end
    
    return false
end

function TK.TD:GetSlotItems(idx)
    return Items[idx]
end

function TK.TD:IsSlot(idx, id)
    for k,v in pairs(Items[idx]) do
        if v.idx == tonumber(id) then return true end
    end
    return false
end