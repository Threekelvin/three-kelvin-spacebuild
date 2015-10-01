

TK.MapSetup.MapEntities = {
    [1] = {
        ent = "tk_terminal",
        pos = Vector(9415, 10040, 811),
        ang = Angle(0,-90,0)
    },
    [2] = {
        ent = "tk_teleporter",
        pos = Vector(7340,-11125,-9232),
        ang = Angle(-90,0,180)
    },
}


TK.MapSetup.SpawnPoints = {
    [1] = Vector(7366, -11104, -9234),
}


TK.MapSetup.Resources = {
    tk_asteroid = {
        [1] = {
            Pos = Vector(-3823,-7555,5000),
            Ang = Angle(0, 0, 0),
            Type = "Field",
            Radius = 5000,
            Size = 20,
            Ents = {},
            NSpawn = 0,
            Class = "tk_asteroid",
        },
    },
    tk_tiberium_crystal = {
        [1] = {
            Pos = Vector(10661,7280,-8834),
            Ang = Angle(0, 0, 0),
            Type = "Surface",
            Radius = 1000,
            Size = 8,
            Ents = {},
            NSpawn = 0,
            Class = "tk_tiberium_crystal",
        },
        [2] = {
            Pos = Vector(7292,10758,-8854),
            Ang = Angle(0, 0, 0),
            Type = "Surface",
            Radius = 1000,
            Size = 8,
            Ents = {},
            NSpawn = 0,
            Class = "tk_tiberium_crystal",
        }
    },
}
