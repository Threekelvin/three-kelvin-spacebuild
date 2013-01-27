
TK.TerminalPlanet = {Pos = Vector(0,0,0), Size = 0}

TK.PlyModels = {
    ["models/applejack_player.mdl"] = {rank = 2},
    ["models/bonbon_player.mdl"] = {rank = 2},
    ["models/colgate_player.mdl"] = {rank = 2},
    ["models/derpyhooves_player.mdl"] = {rank = 2},
    ["models/fluttershy_player.mdl"] = {rank = 2},
    ["models/luna_player.mdl"] = {rank = 2, sid = {"STEAM_0:1:21860684"}},
    ["models/lyra_player.mdl"] = {rank = 2},
    ["models/pinkiepie_player.mdl"] = {rank = 2, sid = {"STEAM_0:0:4832636"}},
    ["models/rainbowdash_player.mdl"] = {rank = 2},
    ["models/raindrops_player.mdl"] = {rank = 2},
    ["models/rarity_player.mdl"] = {rank = 2},
    ["models/trixie_player.mdl"] = {rank = 2},
    ["models/trixienodress_player.mdl"] = {rank = 2},
    ["models/twilightsparkle_player.mdl"] = {rank = 2},
    ["models/vinyl_goggles_player.mdl"] = {rank = 2},
    ["models/vinyl_player.mdl"] = {rank = 2}
}

if game.GetMap() == "sb_twinsuns_fixed" then
	TK.TerminalPlanet = {
		Pos = Vector(-10738,12687,125),
		Size = 1638400
	}
elseif game.GetMap() == "sb_forlorn_sb3_r3" then
	TK.TerminalPlanet = {
		Pos = Vector(9414,9882,392),
		Size = 6760000
	}
elseif game.GetMap() == "sb_lostinspace" then
	TK.TerminalPlanet = {
		Pos = Vector(5846,6553,-8713),
		Size = 1638400
	}
end