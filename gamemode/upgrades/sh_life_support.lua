
TK.UP = TK.UP or {}

TK.UP.life_support = {
    [1] = {
        name = "Generators",
        data = {gen = 1},
        levels = 5,
        parent = {}
    },
    [2] = {
        name = "Solar Panel Output",
        data = {solar = 2},
        levels = 5,
        parent = {1}
    },
    [3] = {
        name = "Unlock Medium",
        data = {solar_med = 1},
        levels = 1,
        parent = {2}
    },
    [4] = {
        name = "Unlock Large",
        data = {solar_lrg = 1},
        levels = 1,
        parent = {3}
    }
}