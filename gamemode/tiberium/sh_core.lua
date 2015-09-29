TK.TI = TK.TI or {}
game.AddParticles("particles/medicgun_attrib.pcf")
game.AddParticles("particles/medicgun_beam.pcf")
game.AddParticles("particles/electrical_fx.pcf")

TK.TI.Settings = {
    [1] = {
        limit = 0,
        model = "models/tiberium/tiberium_crystal3.mdl",
        delay = 0
    },
    [2] = {
        limit = 3,
        model = "models/tiberium/tiberium_crystal1.mdl",
        delay = 180
    },
    [3] = {
        limit = 3,
        model = "models/tiberium/tiberium_parent.mdl",
        delay = 180
    },
    [4] = {
        limit = 2,
        model = "models/tiberium/tiberium_crystal2.mdl",
        delay = 360
    }
}
