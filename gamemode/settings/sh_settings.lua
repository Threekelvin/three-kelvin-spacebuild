
TK.TerminalPlanet = {Pos = Vector(0,0,0), Size = 0}

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