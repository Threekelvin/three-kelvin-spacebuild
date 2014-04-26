
TK.UP = TK.UP or {}

function TK.UP:GrowTree(tree)
    for id,data in pairs(self[tree]) do
        data.id = id
        for k,v in pairs(data.req or {}) do
            data.req[k] = self[tree][v]
        end
    end
end

hook.Add("Initialize", "TKUP", function()
    TK.UP:GrowTree("life_support")
    TK.UP:GrowTree("ship")
    TK.UP:GrowTree("mining")
    TK.UP:GrowTree("weapons")
end)

hook.Add("OnReloaded", "TKUP", function()
    TK.UP:GrowTree("life_support")
    TK.UP:GrowTree("ship")
    TK.UP:GrowTree("mining")
    TK.UP:GrowTree("weapons")
end)
