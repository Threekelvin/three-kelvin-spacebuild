
TK.UP = TK.UP or {}

function TK.UP:GetUpgradeTable(tree)
    return self[tree]
end

function TK.UP:GetUpgradeLevels(tree, id)
    return self[tree][id].levels
end

function TK.UP:GetPlayerUpgradeLevel(tree, id)
    local p_d = self:GetPlayerData("player_upgrades_".. tree)
    return p_d.id or 0
end