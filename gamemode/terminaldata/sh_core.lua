
TK.TD = TK.TD || {}

TK.TD.Settings = {
    upgrade_base = 10000,
    asteroid_price = 0.05,
    asteroid_refine = 50,
    tiberium_price = 0.5,
    tiberium_refine = 5
}

local Resources = {
    "asteroid_ore",
    "raw_tiberium",
    "oxygen",
    "nitrogen",
    "carbon_dioxide",
    "hydrogen",
    "water",
    "liquid_nitrogen"
}

function TK.TD:AcceptResource(res)
    return table.HasValue(Resources, res)
end

if SERVER then
    function TK.TD:ResearchCost(ply, idx)
        if !IsValid(ply) then return 0 end
        local upgrades = TK.DB:GetPlayerData(ply, "terminal_upgrades")
        local lvl = upgrades[idx] + 1
        local data =  TK.TD:GetUpgrade(idx)
        if lvl > data.maxlvl then 
            return 0
        else
            return math.Round(TK.TD.Settings.upgrade_base * data.cost * lvl)
        end
    end

    function TK.TD:Ore(ply, res)
        if !IsValid(ply) then return 0 end
        local stats = self:GetUpgradeStats(ply, "refinery")
        if res == "asteroid_ore" then
            return self.Settings.asteroid_price + (self.Settings.asteroid_price * stats.cpore)
        elseif res == "raw_tiberium" then
            return self.Settings.tiberium_price + (self.Settings.tiberium_price * stats.cptib)
        end
        return 0
    end

    function TK.TD:Refine(ply, res)
        if !IsValid(ply) then return 0 end
        local stats = self:GetUpgradeStats(ply, "refinery")
        if res == "asteroid_ore" then
            return self.Settings.asteroid_refine + (self.Settings.asteroid_refine * stats.orers)
        elseif res == "raw_tiberium" then
            return self.Settings.tiberium_refine + (self.Settings.tiberium_refine * stats.tibrs)
        end
        return 0
    end
else
    function TK.TD:ResearchCost(idx)
        local upgrades = TK.DB:GetPlayerData("terminal_upgrades")
        local lvl = upgrades[idx] + 1
        local data =  self:GetUpgrade(idx)
        if lvl > data.maxlvl then 
            return 0
        else
            return math.Round(self.Settings.upgrade_base * data.cost * lvl)
        end
    end

    function TK.TD:Ore(res)
        local stats = self:GetUpgradeStats("refinery")
        if res == "asteroid_ore" then
            return self.Settings.asteroid_price + (self.Settings.asteroid_price * stats.cpore)
        elseif res == "raw_tiberium" then
            return self.Settings.tiberium_price + (self.Settings.tiberium_price * stats.cptib)
        end
        return 0
    end

    function TK.TD:Refine(res)
        local stats = self:GetUpgradeStats("refinery")
        if res == "asteroid_ore" then
            return self.Settings.asteroid_refine + (self.Settings.asteroid_refine * stats.orers)
        elseif res == "raw_tiberium" then
            return self.Settings.tiberium_refine + (self.Settings.tiberium_refine * stats.tibrs)
        end
        return 0
    end
end