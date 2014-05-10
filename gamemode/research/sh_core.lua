
TK.UP = TK.UP or {}
TK.UP.lists = {
    "life_support",
    "ship",
    "mining",
    "weapons",
}

function TK.UP:GrowTree(tree)
    for id,data in pairs(self[tree]) do
        data.id = id
        data.cost = data.cost or {m = 0, t = 0, q = 0, r = 0}
        for k,v in pairs(data.req or {}) do
            data.req[k] = self[tree][v]
        end
    end
end

hook.Add("Initialize", "TKUP", function()
    for k,v in pairs(TK.UP.lists) do
        TK.UP:GrowTree(v)
    end
end)

hook.Add("OnReloaded", "TKUP", function()
    for k,v in pairs(TK.UP.lists) do
        TK.UP:GrowTree(v)
    end
end)