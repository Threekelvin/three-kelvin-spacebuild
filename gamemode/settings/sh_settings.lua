
TK.Settings = TK.Settings || {}

TK.Settings.Term = {Pos = Vector(0,0,0), Size = 0}

TK.Settings.PlyMdls = {
    ["models/applejack_player.mdl"] =           {rank = 2},
    ["models/applengineer_player.mdl"] =        {rank = 2},
    ["models/bonbon_player.mdl"] =              {rank = 2},
    ["models/celestia.mdl"] =                   {rank = 2},
    ["models/colgate_player.mdl"] =             {rank = 2},
    ["models/daringdoo_player.mdl"] =           {rank = 2},
    ["models/derpyhooves_player.mdl"] =         {rank = 2},
    ["models/derpyhooves_dress_player.mdl"] =   {rank = 2},
    ["models/fluttershy_player.mdl"] =          {rank = 2},
    ["models/googlechrome_player.mdl"] =        {rank = 2},
    ["models/luna_player.mdl"] =                {sid = {"STEAM_0:1:21860684"}},
    ["models/lyra_player.mdl"] =                {rank = 2},
    ["models/pinkiepie_player.mdl"] =           {sid = {"STEAM_0:0:4832636"}},
    ["models/rainbowdash_player.mdl"] =         {rank = 2},
    ["models/rainbowscout_player.mdl"] =        {rank = 2},
    ["models/raindrops_player.mdl"] =           {rank = 2},
    ["models/rarity_player.mdl"] =              {rank = 2},
    ["models/daringdoo_player.mdl"] =           {rank = 2},
    ["models/trixie_player.mdl"] =              {rank = 2},
    ["models/trixienodress_player.mdl"] =       {rank = 2},
    ["models/twilightsparkle_player.mdl"] =     {rank = 2},
    ["models/vinyl_goggles_player.mdl"] =       {rank = 2},
    ["models/vinyl_player.mdl"] =               {rank = 2},
    ["models/player/engineer_suit.mdl"] =       {rank = 2},
    ["models/player/security_suit.mdl"] =       {rank = 2}
}

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