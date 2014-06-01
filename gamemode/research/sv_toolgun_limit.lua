
TK.UP = TK.UP or {}
TK.UP.default = 2
TK.UP.limits = {}
TK.UP.limits_default = {}
TK.UP.entities = {}

function TK.UP:CheckLimit(ply, class)
    if self:GetCount(ply, class) >= self:GetLimit(ply, class) then ply:LimitHit(class) return false end
    return true
end

function TK.UP:SetLimit(ply, class, limit)
    if not IsValid(ply) then return end
    self.limits[ply.uid] = self.limits[ply.uid] or {}
    self.limits[ply.uid][class] = limit or self.default
end

function TK.UP:SetDefaultLimit(class, limit)
    self.limits_default[class] = limit
end

function TK.UP:GetLimit(ply, class)
    if  not IsValid(ply) then return end
    self.limits[ply.uid] = self.limits[ply.uid] or {}
    return self.limits[ply.uid][class] or self.limits_default[class]
end

function TK.UP:GetCount(ply, class)
    if not IsValid(ply) then return end
    self.entities[ply.uid] = self.entities[ply.uid] or {}
    self.entities[ply.uid][class] = self.entities[ply.uid][class] or {}
    
    local tab = self.entities[ply.uid][class]
    local c = 0
    
    for k,v in pairs(tab) do
        if IsValid(v) then
            c = c + 1
        else
            tab[k] = nil
        end
    end

    ply:SetNWInt("Count.".. class, c)
    return c
end

function TK.UP:AddCount(ply, class, ent)
    if not IsValid(ply) or not IsValid(ent) then return end
    self.entities[ply.uid] = self.entities[ply.uid] or {}
    self.entities[ply.uid][class] = self.entities[ply.uid][class] or {}
    
    table.insert(self.entities[ply.uid][class], ent)
    self:GetCount(ply, class)
	
    ent:CallOnRemove("GetCountUpdate", function(ent, ply, class) TK.UP:GetCount(ply, class) end, ply, class)
end

function TK.UP.MakeEntity(ply, data)
    if not IsValid(ply) or not TK.UP:CheckLimit(ply, data.Class) then return end
    local ent_data = TK.UP:GetEntData(ply, data.Class)
    if not TK.UP:HasSize(ply, data.Class, ent_data[data.Model].size or "small") then return end
    
    local ent = ents.Create(data.Class)
    ent:SetModel(data.Model)
    ent:SetPos(data.Pos)
    ent:SetAngles(data.Angle)
    ent.data = ent_data[data.Model]
    ent:Spawn()
    
    TK.UP:AddCount(ply, data.Class, ent)
    return ent
end