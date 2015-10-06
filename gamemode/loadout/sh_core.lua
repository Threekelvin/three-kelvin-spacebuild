TK.LO = TK.LO or {}
-- Time to "rebuild" a loadout entity before it can be respawned.
TK.LO.RebuildTime = 0

TK.LO.slots = {
    mining = {
        name = "Mining Equipment",
        slots = 4,
        z = 1
    },
    storage = {
        name = "Mining Storage",
        slots = 4,
        z = 2
    },
    life_support = {
        name = "Life Support",
        slots = 4,
        z = 3
    },
    generator = {
        name = "Power Generation",
        slots = 4,
        z = 4
    },
    subsystem = {
        name = "Ship Subsystems",
        slots = 4,
        z = 5
    },
    engine = {
        name = "Ship Engines",
        slots = 4,
        z = 6
    }
}

local function LoadItems()
    for _, lua in pairs(file.Find(GM.FolderName .. "/gamemode/loadout/items/*.lua", "LUA")) do
        local path = GM.FolderName .. "/gamemode/loadout/items/" .. lua

        if SERVER then
            AddCSLuaFile(path)
            include(path)
        else
            include(path)
        end
    end
end

function TK.LO:GetItem(item_id)
    if item_id == "" then return {} end
    local items = list.Get("tk_loadout")

    return items[item_id] or {}
end

function TK.LO:IsSlot(item_id, slot)
    local item = self:GetItem(item_id)

    return item.slot == slot
end

function TK.LO:IsItem(item_id)
    local items = list.Get("tk_loadout")

    return items[item_id] and true or false
end

function TK.LO:Precache()
    for id, item in pairs(list.Get("tk_loadout")) do
        if not util.IsValidModel(item.mdl) then continue end
        util.PrecacheModel(item.mdl)
    end
end

hook.Add("Initialize", "TKLO", function()
    TK.LO:Precache()
end)

hook.Add("OnReloaded", "TKLO", function()
    TK.LO:Precache()
end)

LoadItems()
