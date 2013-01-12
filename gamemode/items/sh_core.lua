
TK.IL = {}

local Items = {
    mining = {
        {
            idx = 1,
            name = "Basic Asteroid Mining Laser",
            class = "tk_ore_laser",
            mdl = "models/props_phx/life_support/crylaser_small.mdl",
            data = {},
            r = 19,
            buy = 10000,
            sell = 7500
        },
        {
            idx = 2,
            name = "Basic Tiberium Extractor",
            class = "tk_tib_extractor",
            mdl = "models/techbot/sonic_thingy.mdl",
            data = {},
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
            data = {},
            r = 73,
            buy = 10000,
            sell = 7500
        },
        {
            idx = 4,
            name = "Basic Raw Tiberium Storage",
            class = "tk_tib_storage",
            mdl = "models/slyfo/sat_resourcetank.mdl",
            data = {},
            r = 47,
            buy = 10000,
            sell = 7500,
        }
    },
    weapon = {
    
    }
}

function TK.IL:GetItem(id)
    for _,slot in pairs(Items) do
        for k,v in pairs(slot) do
            if v.idx != tonumber(id) then continue end
            return v
        end
    end
    
    return false
end

function TK.IL:GetSlotItems(idx)
    return Items[idx]
end

function TK.IL:IsSlot(idx, id)
    for k,v in pairs(Items[idx]) do
        if v.idx == tonumber(id) then return true end
    end
    return false
end