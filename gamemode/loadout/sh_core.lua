TK.LO = TK.LO or {}
-- Time to "rebuild" a loadout entity before it can be respawned.
TK.LO.RebuildTime = 0
TK.LO.lists = {"magnetite",  "tiberium"}

TK.LO.Categories = {
    [1] = {
        idx = "magnetite",
        name = "Magnetite Mining",
        icon = "icon16/money_pound.png"
    },
    [2] = {
        idx = "tiberium",
        name = "Tiberium Mining",
        icon = "icon16/money_pound.png"
    }
}

function TK.LO:GetItem(item_id)
    if item_id == "" then return {} end
    local tbl = string.match(item_id, "^[%w]+")
    if not table.HasValue(self.lists, tbl) then return {} end
    local item = string.match(item_id, tbl .. "_([%w_]+)")

    return self[tbl][item] or {}
end

function TK.LO:IsSlot(item_id, slot)
    local item = self:GetItem(item_id)

    return item.slot == slot
end

function TK.LO:GrowTree(tree)
    for id, data in pairs(self[tree]) do
        data.id = tree .. "_" .. id
        if not util.IsValidModel(data.mdl) then continue end
        util.PrecacheModel(data.mdl)
    end
end

hook.Add("Initialize", "TKLO", function()
    for k, v in pairs(TK.LO.lists) do
        TK.LO:GrowTree(v)
    end
end)

hook.Add("OnReloaded", "TKLO", function()
    for k, v in pairs(TK.LO.lists) do
        TK.LO:GrowTree(v)
    end
end)
