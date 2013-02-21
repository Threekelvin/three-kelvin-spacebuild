
TK.LO = TK.LO || {}
TK.LO.SpawnedEnts = {}
TK.LO.BuildingEnts = {}

net.Receive("TKLO_Ent", function()
    local ent = net.ReadEntity()
    local name = net.ReadString()
    local id = net.ReadInt(32)
    if !IsValid(ent) then return end
    ent.PrintName = name
    
    local uid = LocalPlayer():UID()
    ent:CallOnRemove("loadout", function(ent, uid)
        for k,v in pairs(TK.LO.SpawnedEnts[uid] || {}) do
            if v == ent then
                TK.LO.SpawnedEnts[uid][k] = nil
                TK.LO.BuildingEnts[uid] = TK.LO.BuildingEnts[uid] || {}
                table.insert(TK.LO.BuildingEnts[uid], {['id']=id, ['time']=CurTime()+TK.LO.RebuildTime})
            end
        end
        TK.LO.SpawnList:Populate()
    end, uid)
    TK.LO.SpawnedEnts[uid] = TK.LO.SpawnedEnts[uid] || {}
    table.insert(TK.LO.SpawnedEnts[uid], ent)
end)