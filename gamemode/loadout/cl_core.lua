
TK.LO = TK.LO or {}

net.Receive("TKLO_Ent", function()
    local names = net.ReadTable()
    for k,v in pairs(names) do
        local ent = Entity(k)
        if !IsValid(ent) then continue end
        ent.PrintName = v
    end
end)

function TK.LO:SlotLocked(slot)
    if string.match(slot, "[%w]+$") != "1" then return true end
    
    return false
end