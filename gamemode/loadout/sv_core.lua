TK.LO = TK.LO or {}
TK.LO.default = 0
TK.LO.limits = {}
TK.LO.entities = {}
--[[
util.AddNetworkString("TKLO_Ent")

function TK.LO:CheckLimit(ply, item)
if self:GetCount(ply, item) >= self:GetLimit(ply, item) then ply:LimitHit(item) return false end
return true
end

function TK.LO:SetLimit(ply, item, limit)
if !IsValid(ply) then return end
self.limits[ply.uid] = self.limits[ply.uid] || {}
self.limits[ply.uid][item] = limit || self.default
end

function TK.LO:ResetLimits(ply)
for k,v in pairs(self.limits[ply.uid] || {}) do
self.limits[ply.uid][k] = 0
end
end

function TK.LO:GetLimit(ply, item)
if  !IsValid(ply) then return end
self.limits[ply.uid] = self.limits[ply.uid] || {}
return self.limits[ply.uid][item] || self.default
end

function TK.LO:GetCount(ply, item)
if !IsValid(ply) then return end
self.entities[ply.uid] = self.entities[ply.uid] || {}
self.entities[ply.uid][item] = self.entities[ply.uid][item] || {}

local tab = self.entities[ply.uid][item]
local c = 0

for k,v in pairs(tab) do
if IsValid(v) then
c = c + 1
else
tab[k] = nil
end
end

return c
end

function TK.LO:Cull(ply, item)
local c = self:GetCount(ply, item) - self:GetLimit(ply, item)
if c <= 0 then return end

for _,ent in pairs(self.entities[ply.uid][item]) do
if c == 0 then break end
SafeRemoveEntity(ent)
c = c - 1
end
end

function TK.LO:UpdateLimits(ply, data)
self:ResetLimits(ply)
for k,v in pairs(data) do
self:SetLimit(ply, v, self:GetLimit(ply, v) + 1)
end

for _,root in pairs(self.lists) do
for idx,item in pairs(self[root]) do
local id = root .."_".. idx
self:Cull(ply, id)
end
end
end

function TK.LO:AddCount(ply, item, ent)
if !IsValid(ply) || !IsValid(ent) then return end
self.entities[ply.uid] = self.entities[ply.uid] || {}
self.entities[ply.uid][item] = self.entities[ply.uid][item] || {}

table.insert(self.entities[ply.uid][item], ent)
self:GetCount(ply, item)

ent:CallOnRemove("GetCountUpdate", function(ent, ply, item) TK.LO:GetCount(ply, item) end, ply, item)
end

function TK.LO.MakeEntity(ply, data, item_id)
if !IsValid(ply) || !TK.LO:CheckLimit(ply, item_id) then return end

local item = TK.LO:GetItem(item_id)
if !item then return end

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
net.WriteTable({[ent:EntIndex()] = item.name})
net.Broadcast()
end)

TK.LO:AddCount(ply, item_id, ent)
return ent
end

hook.Add("Initialize", "TKLO", function()
local reg = {}
for _,root in pairs(TK.LO.lists) do
for idx,item in pairs(TK.LO[root]) do
if reg[item.ent] then continue end
duplicator.RegisterEntityClass(item.ent, TK.LO.MakeEntity, "Data", "item_id")
reg[item.ent] = true
end
end
end)

hook.Add("TKDB_Player_Data", "TKLO", function(ply, dbtable, idx, data)
if dbtable != "player_terminal_loadout" || idx != "loadout" then return end
TK.LO:UpdateLimits(ply, data)
end)

hook.Add("PlayerInitialSpawn", "TKLO", function(ply)
local data = TK.DB:GetPlayerData(ply, "player_terminal_loadout").loadout
TK.LO:UpdateLimits(ply, data)

local ent_names = {}
for _,ply_tbl in pairs(TK.LO.entities) do
for _,items in pairs(ply_tbl) do
for _,ent in pairs(items) do
ent_names[ent:EntIndex()] = ent.PrintName
end
end
end

net.Start("TKLO_Ent")
net.WriteTable(ent_names)
net.Broadcast()
end)
]]
