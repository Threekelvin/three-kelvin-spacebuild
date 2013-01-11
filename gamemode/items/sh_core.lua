
TK.IL = {}

local Items = {
    mining = {
        {
            idx = 1,
            name = "Basic Asteroid Mining Laser",
            mdl = "models/props_phx/life_support/crylaser_small.mdl",
            r = 19,
            buy = 10000,
            sell = 7500,
            data = {}
        },
        {
            idx = 2,
            name = "Basic Tiberium Extractor",
            mdl = "models/techbot/sonic_thingy.mdl",
            r = 28,
            buy = 10000,
            sell = 7500,
            data = {}
        },
    },
    storage = {
        {
            idx = 3,
            name = "Basic Asteroid Ore Storage",
            mdl = "models/slyfo/nacshortsleft.mdl",
            r = 73,
            buy = 10000,
            sell = 7500,
            data = {}
        },
        {
            idx = 4,
            name = "Basic Raw Tiberium Storage",
            mdl = "models/slyfo/sat_resourcetank.mdl",
            r = 47,
            buy = 10000,
            sell = 7500,
            data = {}
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
    
    return {}
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