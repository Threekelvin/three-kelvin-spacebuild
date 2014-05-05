
TK.LO = TK.LO or {}

TK.LO.magnetite = {
    basic_laser = {
        ent = "tk_magnetite_laser",
        mdl = "models/props_phx/life_support/crylaser_small.mdl",
        name = "Basic Magnetite Laser",
        view = Vector(18, 18, 18),
        data = {kilowatt = -10, magnetite = 1, range = 125},
        slot = "mining",
        cost = {t = 0, m = 0, q = 0, r = 0}
    },
    standard_laser = {
        ent = "tk_magnetite_laser",
        mdl = "models/props_phx/life_support/crylaser_small.mdl",
        name = "Standard Magnetite Laser",
        view = Vector(18, 18, 18),
        data = {kilowatt = -20, magnetite = 2, range = 250},
        slot = "mining",
        cost = {t = 0, m = 0, q = 0, r = 0}
    },
    advanced_laser = {
        ent = "tk_magnetite_laser",
        mdl = "models/props_phx/life_support/crylaser_small.mdl",
        name = "Advanced Magnetite Laser",
        view = Vector(18, 18, 18),
        data = {kilowatt = -40, magnetite = 4, range = 500},
        slot = "mining",
        cost = {t = 0, m = 0, q = 0, r = 0}
    },
    experimental_laser = {
        ent = "tk_magnetite_laser",
        mdl = "models/props_phx/life_support/crylaser_small.mdl",
        name = "Experimental Magnetite Laser",
        view = Vector(18, 18, 18),
        data = {kilowatt = -80, magnetite = 8, range = 750},
        slot = "mining",
        cost = {t = 0, m = 0, q = 0, r = 0}
    },
    basic_storage = {
        ent = "tk_magnetite_storage",
        mdl = "models/mandrac/ore_container/ore_small.mdl",
        name = "Basic Magnetite Storage",
        view = Vector(79, 79, 79),
        data = {magnetite = 300},
        slot = "storage",
        cost = {t = 0, m = 0, q = 0, r = 0}
    },
    standard_storage = {
        ent = "tk_magnetite_storage",
        mdl = "models/mandrac/ore_container/ore_medium.mdl",
        name = "Standard Magnetite Storage",
        view = Vector(98, 98, 98),
        data = {magnetite = 900},
        slot = "storage",
        cost = {t = 0, m = 0, q = 0, r = 0}
    },
    advanced_storage = {
        ent = "tk_magnetite_storage",
        mdl = "models/mandrac/ore_container/ore_large_half.mdl",
        name = "Advanced Magnetite Storage",
        view = Vector(90, 90, 90),
        data = {magnetite = 2700},
        slot = "storage",
        cost = {t = 0, m = 0, q = 0, r = 0}
    },
    experimental_storage = {
        ent = "tk_magnetite_storage",
        mdl = "models/mandrac/ore_container/ore_large.mdl",
        name = "Experimental Magnetite Storage",
        view = Vector(108, 108, 108),
        data = {magnetite = 8100},
        slot = "storage",
        cost = {t = 0, m = 0, q = 0, r = 0}
    }
}