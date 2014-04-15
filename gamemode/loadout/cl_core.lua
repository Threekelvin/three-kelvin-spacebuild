
TK.LO = TK.LO or {}

net.Receive("TKLO_Ent", function()
    local ent = net.ReadEntity()
    local name = net.ReadString()
    if !IsValid(ent) then return end
    ent.PrintName = name
end)