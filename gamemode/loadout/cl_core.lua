TK.LO = TK.LO or {}

net.Receive("TKLO_Ent", function()
    local names = net.ReadTable()

    for k, v in pairs(names) do
        local ent = Entity(k)
        if not IsValid(ent) then continue end
        ent.PrintName = v
    end
end)
