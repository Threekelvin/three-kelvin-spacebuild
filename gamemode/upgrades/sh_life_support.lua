
TK.UP = TK.UP or {}

TK.UP.life_support = {
    gen_out = {
        name = "Generators",
        upgrade = {["gen_out"] = 1},
        levels = 10
    },
    solar_out = {
        name = "Solar Panel Output",
        upgrade = {["sol_out"] = 2},
        levels = 5,
        req = {"gen_out"}
    },
    solar_med = {
        name = "Medium Solar Panel",
        upgrade = {["sol_med"] = 1},
        levels = 1,
        req = {"solar_out"}
    },
    solar_lrg = {
        name = "Large Solar Panel",
        upgrade = {["sol_lrg"] = 1},
        levels = 1,
        req = {"solar_med"}
    },
    solar_3nd = {
        name = "3rd Solar Panel",
        upgrade = {["sol_3rd"] = 1},
        levels = 1,
        req = {"solar_lrg"}
    },
    solar_4th = {
        name = "4th Solar Panel",
        upgrade = {["sol_4th"] = 1},
        levels = 1,
        req = {"solar_3nd"}
    },
    wind_out = {
        name = "Wind Turbine Output",
        upgrade = {["wnd_out"] = 2},
        levels = 5,
        req = {"gen_out"}
    }
}