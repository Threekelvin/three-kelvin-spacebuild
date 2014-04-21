

TK.MapSetup.MapEntities = {
    [1] = {
        ent = "tk_terminal",
        pos = Vector(-10998,-2335,-8063),
        ang = Angle(0,0,0)
    },
    [2] = {
        ent = "tk_teleporter",
        pos = Vector(-11217,-2632,-8063),
        ang = Angle(-90,120,180)
    },
}


TK.MapSetup.SpawnPoints = {
    [1] = Vector(-11217,-2632,-8063),
}


TK.MapSetup.Resources = {
    tk_magnetite = {
        [1] = {
            Pos = Vector(-9483,-683,4404),
            Ang = Angle(0, 0, 0),
            Type = "Field",
            Radius = 5000,
            Size = 20,
            Ents = {},
            NSpawn = 0,
            Class = "tk_magnetite",
        },
    },
    tk_quintinite = {
        [1] = {
            Pos = Vector(1536, 7680, -10240),
            Ang = Angle(100, 100, 0),
            Type = "Belt",
            Radius = 3808,
            Size = 4,
            Ents = {},
            NSpawn = 0,
            Class = "tk_quintinite",
        },
    },
    tk_riddinite = {
        [1] = {
            Pos = Vector(9726, 9216, 4360),
            Ang = Angle(-45, 30, 0),
            Type = "Belt",
            Radius = 4832,
            Size = 8,
            Ents = {},
            NSpawn = 0,
            Class = "tk_riddinite",
        },
    },
    tk_tib_crystal = {
        [1] = {
            Pos = Vector(7725,-8080,-1950),
            Ang = Angle(0, 0, 0),
            Type = "Surface",
            Radius = 1000,
            Size = 8,
            Ents = {},
            NSpawn = 0,
            Class = "tk_tib_crystal",
        },
        [2] = {
            Pos = Vector(5218,-10198,-2048),
            Ang = Angle(0, 0, 0),
            Type = "Surface",
            Radius = 1000,
            Size = 8,
            Ents = {},
            NSpawn = 0,
            Class = "tk_tib_crystal",
        }
    },
}


function TK.MapSetup.Cleanup()
    for k,v in pairs(ents.FindInSphere(Vector(10160, -2365, 10600), 500)) do
        SafeRemoveEntity(v)
    end
end