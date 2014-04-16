
TK.Settings = TK.Settings or {}

TK.Settings.Term = {Pos = Vector(0,0,0), Size = 0}

TK.Settings.Tiberium = {
    [1] = {
        limit = 0,
        model = "models/tiberium/tiberium_crystal3.mdl",
        delay = 0,
    },
    [2] = {
        limit = 3,
        model = "models/tiberium/tiberium_crystal1.mdl",
        delay = 150,
    },
    [3] = {
        limit = 2,
        model = "models/tiberium/tiberium_parent.mdl",
        delay = 150,
    },
    [4] = {
        limit = 3,
        model = "models/tiberium/tiberium_crystal2.mdl",
        delay = 300,
    },
    [5] = {
        limit = 2,
        model = "models/chipstiks_mining_models/smallbluecrystal/smallbluecrystal.mdl",
        delay = 300,
    }
}

if string.find(game.GetMap(), "twinsuns") then
    TK.Settings.Term = {
        Pos = Vector(-10738,12687,125),
        Size = 1638400
    }
elseif string.find(game.GetMap(), "forlorn") then
    TK.Settings.Term = {
        Pos = Vector(9414,9882,392),
        Size = 6760000
    }
elseif string.find(game.GetMap(), "lostinspace") then
    TK.Settings.Term = {
        Pos = Vector(5846,6553,-8713),
        Size = 1638400
    }
elseif string.find(game.GetMap(), "gooniverse") then
    TK.Settings.Term = {
        Pos = Vector(2,0,4620),
        Size = 1254400
    }
end