TK.LO = TK.LO or {}
TK.LO.default = 0
TK.LO.limits = {}
TK.LO.entities = {}
util.AddNetworkString("TKLO_Ent")

function TK.LO:CheckLimit(ply, item_id)
    if self:GetCount(ply, item_id) >= self:GetLimit(ply, item_id) then
        ply:LimitHit(item_id)

        return false
    end

    return true
end

function TK.LO:SetLimit(ply, item_id, limit)
    if not IsValid(ply) then return end
    self.limits[ply.uid] = self.limits[ply.uid] or {}
    self.limits[ply.uid][item_id] = limit or self.default
end

function TK.LO:ResetLimits(ply)
    for k, v in pairs(self.limits[ply.uid] or {}) do
        self.limits[ply.uid][k] = 0
    end
end

function TK.LO:GetLimit(ply, item_id)
    if not IsValid(ply) then return end
    self.limits[ply.uid] = self.limits[ply.uid] or {}

    return self.limits[ply.uid][item_id] or self.default
end

function TK.LO:GetCount(ply, item_id)
    if not IsValid(ply) then return end
    self.entities[ply.uid] = self.entities[ply.uid] or {}
    self.entities[ply.uid][item_id] = self.entities[ply.uid][item_id] or {}
    local tab = self.entities[ply.uid][item_id]
    local c = 0

    for k, v in pairs(tab) do
        if IsValid(v) then
            c = c + 1
        else
            tab[k] = nil
        end
    end

    return c
end

function TK.LO:Cull(ply, item_id)
    local c = self:GetCount(ply, item_id) - self:GetLimit(ply, item_id)
    if c <= 0 then return end

    for _, ent in pairs(self.entities[ply.uid][item_id]) do
        if c == 0 then break end
        SafeRemoveEntity(ent)
        c = c - 1
    end
end

function TK.LO:UpdateLimits(ply, data)
    self:ResetLimits(ply)

    for k, v in pairs(data) do
        self:SetLimit(ply, v, self:GetLimit(ply, v) + 1)
    end

    for id, item in pairs(list.Get("tk_loadout")) do
        self:Cull(ply, id)
    end
end

function TK.LO:AddCount(ply, item_id, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    self.entities[ply.uid] = self.entities[ply.uid] or {}
    self.entities[ply.uid][item_id] = self.entities[ply.uid][item_id] or {}
    table.insert(self.entities[ply.uid][item_id], ent)
    self:GetCount(ply, item_id)

    ent:CallOnRemove("GetCountUpdate", function()
        TK.LO:GetCount(ply, item_id)
    end)
end

function TK.LO.MakeEntity(ply, data, item_id)
    if not IsValid(ply) or not TK.LO:CheckLimit(ply, item_id) then return end
    local item = TK.LO:GetItem(item_id)
    if not item then return end
    local ent = ents.Create(item.ent)
    ent:SetModel(item.mdl)
    ent:SetPos(data.Pos)
    ent:SetAngles(data.Angle)
    ent.item_id = item_id
    ent.data = item.data
    ent.PrintName = item.name
    ent:Spawn()

    timer.Simple(0.1, function()
        net.Start("TKLO_Ent")

        net.WriteTable({
            [ent:EntIndex()] = item.name
        })

        net.Broadcast()
    end)

    TK.LO:AddCount(ply, item_id, ent)

    return ent
end

hook.Add("Initialize", "TKLO", function()
    local reg = {}

    for id, item in pairs(list.Get("tk_loadout")) do
        if reg[item.ent] then continue end
        duplicator.RegisterEntityClass(item.ent, TK.LO.MakeEntity, "Data", "item_id")
        reg[item.ent] = true
    end
end)

hook.Add("TKDB_Player_Data", "TKLO", function(ply, dbtable, idx, data)
    if dbtable ~= "player_terminal_loadout" or idx ~= "loadout" then return end
    TK.LO:UpdateLimits(ply, data)
end)

hook.Add("PlayerInitialSpawn", "TKLO", function(ply)
    local data = TK.DB:GetPlayerData(ply, "player_terminal_loadout").loadout
    TK.LO:UpdateLimits(ply, data)
    local ent_names = {}

    for _, ply_tbl in pairs(TK.LO.entities) do
        for _, items in pairs(ply_tbl) do
            for _, ent in pairs(items) do
                ent_names[ent:EntIndex()] = ent.PrintName
            end
        end
    end

    net.Start("TKLO_Ent")
    net.WriteTable(ent_names)
    net.Broadcast()
end)
