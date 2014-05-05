
TK.LO = TK.LO or {}
TK.LO.RebuildTime = 0 // Time to "rebuild" a loadout entity before it can be respawned.
TK.LO.lists = {
    "magnetite",
    "quintinite",
    "riddinite",
    "tiberium",
    "weapons",
}

function TK.LO:GetItem(item_id)
    local tbl = string.match(item_id, "^[%w]+")
    local item = string.match(item_id, tbl .."_([%w_]+)")
    return self[tbl][item]
end

function TK.LO:IsSlot(item_id, slot)
    local item = self:GetItem(item_id)
    return item.slot == slot
end

function TK.LO:GrowTree(tree)
    for id,data in pairs(self[tree]) do
        data.id = tree .."_".. id
    end
end

hook.Add("Initialize", "TKLO", function()
    for k,v in pairs(TK.LO.lists) do
        TK.LO:GrowTree(v)
    end
end)

hook.Add("OnReloaded", "TKLO", function()
    for k,v in pairs(TK.LO.lists) do
        TK.LO:GrowTree(v)
    end
end)