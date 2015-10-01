

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
    tk_asteroid = {
        [1] = {
            Pos = Vector(-9483,-683,4404),
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
            Pos = Vector(7725,-8080,-1950),
            Ang = Angle(0, 0, 0),
            Type = "Surface",
            Radius = 1000,
            Size = 8,
            Ents = {},
            NSpawn = 0,
            Class = "tk_tiberium_crystal",
        },
        [2] = {
            Pos = Vector(5218,-10198,-2048),
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


function TK.MapSetup.Cleanup()
    for k,v in pairs(ents.FindInSphere(Vector(10160, -2365, 10600), 500)) do
        SafeRemoveEntity(v)
    end
end
