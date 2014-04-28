
local PP = {}
PP.EntList = {}
PP.EntCVar = {}

hook.Add("PhysgunPickup", "TKPP_Phys", function(ply, ent)
    local eid = ent:EntIndex()
    if PP.EntList[eid] and PP.EntList[eid] != ent then 
        PP.EntList[eid] = nil
        PP.EntCVar = nil
    end
    if PP.EntList[eid] then return false end
    
    PP.EntList[eid] = ent
    
    if ent:IsPlayer() then
        PP.EntCVar[eid] = {
            move = ent:GetMoveType()
        }
        
        ent:SetMoveType(MOVETYPE_NOCLIP)
    end
end)

hook.Add("PhysgunDrop", "TKPP_Phys", function(ply, ent)
    local eid = ent:EntIndex()
    if ent:IsPlayer() then
        if ent:GetEnv():CanNoclip() then
            ent:SetMoveType(PP.EntCVar[eid].move)
        else
            ent:SetMoveType(MOVETYPE_WALK)
        end
    end
    
    PP.EntList[eid] = nil
    PP.EntCVar[eid] = nil
end)

hook.Add("OnAtmosphereChange", "TKPP_Phys", function(ent, old, new)
    if not ent:IsPlayer() then return end
    if PP.EntList[ent:EntIndex()] and PP.EntList[ent:EntIndex()] == ent then return false end
end)