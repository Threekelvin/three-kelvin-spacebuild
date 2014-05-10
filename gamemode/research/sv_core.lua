
TK.UP = TK.UP or {}

function TK.UP:GetUpgradeData(ply)
    local data = {}
    for _,idx in pairs(self.lists) do
        table.Merge(data, TK.DB:GetPlayerData(ply, "player_upgrades_".. idx))
    end
    return data
end

function TK.UP:GetEntData(ply, class)
    local data = ply:GetWeapon("gmod_tool").Tool[class].Data
    return data
end

function TK.UP:HasSize(ply, class, size)
    if not size or size == "small" then return true end
    local data = self:GetUpgradeData(ply)
    
    return data[class .."_".. size] and true or false
end