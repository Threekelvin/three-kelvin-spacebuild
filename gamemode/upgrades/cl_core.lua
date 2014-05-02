
TK.UP = TK.UP or {}

function TK.UP:GetUpgradeTable(tree)
    return self[tree]
end

function TK.UP:GetUpgradeData()
    local data = {}
    for _,idx in pairs(self.lists) do
        table.Merge(data, TK.DB:GetPlayerData("player_upgrades_".. idx))
    end
    return data
end

function TK.UP:HasSize(class, size)
    if not size or size == "small" then return true end
    local data = self:GetUpgradeData()
    
    return data[class .."_".. size] and true or false
end
