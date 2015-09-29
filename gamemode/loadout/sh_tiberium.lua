TK.LO = TK.LO or {}

TK.LO.tiberium = {
    basic_extractor = {
        ent = "tk_tiberium_extractor",
        mdl = "models/slyfo/finfunnel.mdl",
        name = "Basic Tiberium Extractor",
        view = Vector(18, 18, 18),
        data = {
            kilowatt = -10,
            tiberium = 1,
            range = 75
        },
        slot = "mining",
        cost = {
            t = 0,
            m = 2000,
            q = 0,
            r = 0
        }
    },
    standard_extractor = {
        ent = "tk_tiberium_extractor",
        mdl = "models/slyfo/finfunnel.mdl",
        name = "Standard Tiberium Extractor",
        view = Vector(18, 18, 18),
        data = {
            kilowatt = -20,
            tiberium = 2,
            range = 75
        },
        slot = "mining",
        cost = {
            t = 0,
            m = 0,
            q = 0,
            r = 0
        }
    },
    advanced_extractor = {
        ent = "tk_tiberium_extractor",
        mdl = "models/slyfo/finfunnel.mdl",
        name = "Advanced Tiberium Extractor",
        view = Vector(18, 18, 18),
        data = {
            kilowatt = -40,
            tiberium = 4,
            range = 75
        },
        slot = "mining",
        cost = {
            t = 0,
            m = 0,
            q = 0,
            r = 0
        }
    },
    experimental_extractor = {
        ent = "tk_tiberium_extractor",
        mdl = "models/slyfo/finfunnel.mdl",
        name = "Experimental Tiberium Extractor",
        view = Vector(18, 18, 18),
        data = {
            kilowatt = -80,
            tiberium = 8,
            range = 75
        },
        slot = "mining",
        cost = {
            t = 0,
            m = 0,
            q = 0,
            r = 0
        }
    },
    basic_storage = {
        ent = "tk_tiberium_storage",
        mdl = "models/slyfo/sat_resourcetank.mdl",
        name = "Basic Tiberium Storage",
        view = Vector(79, 79, 79),
        data = {
            tiberium = 300
        },
        slot = "storage",
        cost = {
            t = 0,
            m = 2000,
            q = 0,
            r = 0
        }
    },
    standard_storage = {
        ent = "tk_tiberium_storage",
        mdl = "models/slyfo/sat_resourcetank.mdl",
        name = "Standard Tiberium Storage",
        view = Vector(98, 98, 98),
        data = {
            tiberium = 900
        },
        slot = "storage",
        cost = {
            t = 0,
            m = 0,
            q = 0,
            r = 0
        }
    },
    advanced_storage = {
        ent = "tk_tiberium_storage",
        mdl = "models/slyfo/sat_resourcetank.mdl",
        name = "Advanced Tiberium Storage",
        view = Vector(90, 90, 90),
        data = {
            tiberium = 2700
        },
        slot = "storage",
        cost = {
            t = 0,
            m = 0,
            q = 0,
            r = 0
        }
    },
    experimental_storage = {
        ent = "tk_tiberium_storage",
        mdl = "models/slyfo/sat_resourcetank.mdl",
        name = "Experimental Tiberium Storage",
        view = Vector(108, 108, 108),
        data = {
            tiberium = 8100
        },
        slot = "storage",
        cost = {
            t = 0,
            m = 0,
            q = 0,
            r = 0
        }
    }
}
