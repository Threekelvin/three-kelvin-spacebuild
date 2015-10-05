TK.LO = TK.LO or {}

TK.LO.asteroid = {
    basic_laser = {
        ent = "tk_asteroid_laser",
        mdl = "models/props_phx/life_support/crylaser_small.mdl",
        name = "Basic Asteroid Laser",
        view = Vector(18, 18, 18),
        data = {
            kilowatt = -10,
            asteroid = 1,
            range = 125
        },
        slot = "mining",
        cost = {}
    },
    standard_laser = {
        ent = "tk_asteroid_laser",
        mdl = "models/props_phx/life_support/crylaser_small.mdl",
        name = "Standard Asteroid Laser",
        view = Vector(18, 18, 18),
        data = {
            kilowatt = -20,
            asteroid = 2,
            range = 250
        },
        slot = "mining",
        cost = {}
    },
    advanced_laser = {
        ent = "tk_asteroid_laser",
        mdl = "models/props_phx/life_support/crylaser_small.mdl",
        name = "Advanced Asteroid Laser",
        view = Vector(18, 18, 18),
        data = {
            kilowatt = -40,
            asteroid = 4,
            range = 500
        },
        slot = "mining",
        cost = {}
    },
    experimental_laser = {
        ent = "tk_asteroid_laser",
        mdl = "models/props_phx/life_support/crylaser_small.mdl",
        name = "Experimental Asteroid Laser",
        view = Vector(18, 18, 18),
        data = {
            kilowatt = -80,
            asteroid = 8,
            range = 750
        },
        slot = "mining",
        cost = {}
    },
    basic_storage = {
        ent = "tk_asteroid_storage",
        mdl = "models/mandrac/ore_container/ore_small.mdl",
        name = "Basic Asteroid Storage",
        view = Vector(79, 79, 79),
        data = {
            asteroid = 300
        },
        slot = "storage",
        cost = {}
    },
    standard_storage = {
        ent = "tk_asteroid_storage",
        mdl = "models/mandrac/ore_container/ore_medium.mdl",
        name = "Standard Asteroid Storage",
        view = Vector(98, 98, 98),
        data = {
            asteroid = 900
        },
        slot = "storage",
        cost = {}
    },
    advanced_storage = {
        ent = "tk_asteroid_storage",
        mdl = "models/mandrac/ore_container/ore_large_half.mdl",
        name = "Advanced Asteroid Storage",
        view = Vector(90, 90, 90),
        data = {
            asteroid = 2700
        },
        slot = "storage",
        cost = {}
    },
    experimental_storage = {
        ent = "tk_asteroid_storage",
        mdl = "models/mandrac/ore_container/ore_large.mdl",
        name = "Experimental Asteroid Storage",
        view = Vector(108, 108, 108),
        data = {
            asteroid = 8100
        },
        slot = "storage",
        cost = {}
    }
}
