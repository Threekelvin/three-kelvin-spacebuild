
TK.SpawnPoints = {}
TK.RoidFields = {}
TK.TibFields = {}
TK.Atmospheres = {}
TK.Ents = {}
TK.SpawnedEnts = {}
	
if string.find(game.GetMap(), "twinsuns") then
	TK.SpawnPoints = {
		[1] = Vector(-7848, -11093, 5),
		[2] = Vector(-10740, 13045, 90),
		[3] = Vector(9330, -5670, -8380),
		[4] = Vector(-9440, -8050, -605)
	}
	TK.RoidFields = {
		[1] = {
			Pos = Vector(-10364,2585,-750),
			NextSpawn = 0,
			Ents = {}
		}
	}
	TK.TibFields = {
		[1] = {
			Pos = Vector(9789,-11173,-8191),
			NextSpawn = 0,
			Ents = {}
		},
		[2] = {
			Pos = Vector(8842,-8718,-8379),
			NextSpawn = 0,
			Ents = {}
		},
		[3] = {
			Pos = Vector(11364,-9239,-8383),
			NextSpawn = 0,
			Ents = {}
		}
	}
	TK.Ents = {
		[1] = {
			ent = "tk_terminal",
			pos = Vector(-10901.2890625,13251.693359375,-131),
			ang = Angle(0,-90,0)
		},
		[2] = {
			ent = "tk_terminal",
			pos = Vector(-10573.942382813,13251.6015625,-131),
			ang = Angle(0,-90,0)
		},
		[3] = {
			ent = "tk_teleporter",
			pos = Vector(-10739.974609375,13043.944335938,-131),
			ang = Angle(-90,90,180)
		},
		[4] = {
			ent = "tk_teleporter",
			pos = Vector(-7809.0546875,-7081.5864257813,65.417282104492),
			ang = Angle(-90,90,180)
		},
		[5] = {
			ent = "tk_tib_refinery",
			pos = Vector(9796.064453125,-6192.962890625,-8382.5),
			ang = Angle(0,-90,0)
		},
		[6] = {
			ent = "tk_tib_transporter",
			pos = Vector(9741.5957,-6069.1631,-8328.6387),
			ang = Angle(90,90,180)
		},
		[7] = {
			ent = "tk_tib_transporter",
			pos = Vector(9836.1182,-6069.3633,-8329.2793),
			ang = Angle(90,90,180)
		},
		[8] = {
			ent = "tk_teleporter",
			pos = Vector(9331.7813, -5668.2642, -8380.5850),
			ang = Angle(-90,-135,180)
		},
		[9] = {
			ent = "prop_physics",
			model = "models/Slyfo/refinery_large.mdl",
			pos = Vector(9302.6719, -5697.8823, -8383.5820),
			ang = Angle(0,-135,0)
		},
        [10] = {
            ent = "gmod_playx",
			model = "models/dav0r/camera.mdl",
            color = Color(255, 255, 255, 1),
            notsolid = true,
			pos = Vector(-10735, 13060, -45),
			ang = Angle(0,90,0)
        }
	}
elseif string.find(game.GetMap(), "forlorn") then
	TK.SpawnPoints = {
		[1] = Vector(7400, -11150, -9233),
		[2] = Vector(9420, 10910, 830),
		[3] = Vector(11710, 9760, -8847),
		[4] = Vector(9300, 9040, 45)
	}
	TK.RoidFields = {
		[1] = {
			Pos = Vector(-3823,-7555,5000),
			NextSpawn = 0,
			Ents = {}
		}
	}
	TK.TibFields = {
		[1] = {
			Pos = Vector(10661,7280,-8834),
			NextSpawn = 0,
			Ents = {}
		},
		[2] = {
			Pos = Vector(7633,7487,-8907),
			NextSpawn = 0,
			Ents = {}
		},
		[3] = {
			Pos = Vector(7292,10758,-8854),
			NextSpawn = 0,
			Ents = {}
		},
	}
	TK.Ents = {
		[1] = {
			ent = "tk_teleporter",
			pos = Vector(7396.1724,-11156.1953,-9233),
			ang = Angle(-90,0,180)
		},
		[2] = {
			ent = "tk_teleporter",
			pos = Vector(9419.0381,10842.2344,831),
			ang = Angle(-90,-90,180)
		},
		[3] = {
			ent = "tk_teleporter",
			pos = Vector(11709.0938,9760.1543,-8847.0000),
			ang = Angle(-90,0,180)
		},
		[4] = {
			ent = "tk_tib_refinery",
			pos = Vector(11060.9980,12041.9189,-8861.4541),
			ang = Angle(0,-135,0)
		},
		[5] = {
			ent = "tk_tib_transporter",
			pos = Vector(11110.4336,12168.7705,-8809.4561),
			ang = Angle(90,45,180)
		},
		[6] = {
			ent = "tk_tib_transporter",
			pos = Vector(11177.4346,12101.8418,-8809.4551),
			ang = Angle(90,45,180)
		},
		[7] = {
			ent = "tk_terminal",
			pos = Vector(9650.8428,10223.4795,829.9915),
			ang = Angle(0,116,0)
		},
		[8] = {
			ent = "tk_terminal",
			pos = Vector(9134.9795,10233.0244,829.9916),
			ang = Angle(0,66,0)
		},
        [9] = {
            ent = "gmod_playx",
			model = "models/dav0r/camera.mdl",
            color = Color(255, 255, 255, 1),
            notsolid = true,
			pos = Vector(9467, 9060, 611),
			ang = Angle(0,0,180)
        }
	}
elseif string.find(game.GetMap(), "lostinspace") then
	TK.SpawnPoints = {
		[1] = Vector(-500, -1500, 2570),
		[2] = Vector(5825, 6525, -8720),
		[3] = Vector(8565, 9210, 8080),
		[4] = Vector(8950, -10550, 9375)
	}
	TK.RoidFields = {
		[1] = {
			Pos = Vector(10478,-2073,3534),
			NextSpawn = 0,
			Ents = {}
		}
	}
	TK.TibFields = {
		[1] = {
			Pos = Vector(9370,12060,7970),
			NextSpawn = 0,
			Ents = {}
		},
		[2] = {
			Pos = Vector(11065,9370,8025),
			NextSpawn = 0,
			Ents = {}
		},
		[3] = {
			Pos = Vector(7970,7290,8065),
			NextSpawn = 0,
			Ents = {}
		}
	}
	TK.Ents = {
		[1] = {
			ent = "tk_teleporter",
			pos = Vector(8949.7,-10559.1,9373.37),
			ang = Angle(-90,0,180)
		},
		[2] = {
			ent = "tk_teleporter",
			pos = Vector(-764.12,-1536.036,2561.354),
			ang = Angle(-90,100,180)
		},
		[3] = {
			ent = "tk_teleporter",
			pos = Vector(8560.947,9194.4189,8076.263),
			ang = Angle(-90,-150,180)
		},
		[4] = {
			ent = "tk_teleporter",
			pos = Vector(5822.72,6527.1,-8719.69),
			ang = Angle(-90,-180,180)
		},
		[5] = {
			ent = "tk_tib_refinery",
			pos = Vector(6910.7270,10420.4521,7920.343),
			ang = Angle(2.27014,3.28921,1.25101)
		},
		[6] = {
			ent = "tk_tib_transporter",
			pos = Vector(6790.50,10364.567,7982.5541),
			ang = Angle(88.5,125.734,122.424)
		},
		[7] = {
			ent = "tk_tib_transporter",
			pos = Vector(6785.8227,10444.6923,7984.265),
			ang = Angle(88.556,125.734,122.424)
		},
		[8] = {
			ent = "tk_terminal",
			pos = Vector(4832.6,6144.11,-8721.35),
			ang = Angle(0,0,0)
		},
		[9] = {
			ent = "tk_terminal",
			pos = Vector(4832.6,6911.449,-8721.35),
			ang = Angle(0,0,0)
		},
        [10] = {
            ent = "gmod_playx",
			model = "models/props_junk/popcan01a.mdl",
            color = Color(255, 255, 255, 1),
            notsolid = true,
			pos = Vector(6875,6530,-8468),
			ang = Angle(0,180,0)
        }
	}
elseif string.find(game.GetMap(), "gooniverse") then
    TK.SpawnPoints = {
		[1] = Vector(-11220, -2630, -8062),
		[2] = Vector(-260, 360, 4625),
		[3] = Vector(10425, -9850, -1860),
	}
    TK.RoidFields = {
		[1] = {
			Pos = Vector(-9483,-683,4404),
			NextSpawn = 0,
			Ents = {}
		}
	}
    TK.TibFields = {
		[1] = {
			Pos = Vector(7725,-8080,-1950),
			NextSpawn = 0,
			Ents = {}
		},
		[2] = {
			Pos = Vector(6968,-12221,-2048),
			NextSpawn = 0,
			Ents = {}
		},
		[3] = {
			Pos = Vector(5218,-10198,-2048),
			NextSpawn = 0,
			Ents = {}
		}
	}
    TK.Ents = {
		[1] = {
			ent = "tk_teleporter",
			pos = Vector(-11217.178711,-2632.302002,-8062.649902),
			ang = Angle(-90,120,180)
		},
        [2] = {
			ent = "tk_teleporter",
			pos = Vector(-258.712555,358.568268,4625.364746),
			ang = Angle(-90,165,180)
		},
        [3] = {
			ent = "tk_terminal",
			pos = Vector(-104.682770,532.243408,4623.640625),
			ang = Angle(0,-75,0)
		},
        [4] = {
			ent = "tk_terminal",
			pos = Vector(-475.378845,432.915527,4624.231934),
			ang = Angle(0,-75,0)
		},
        [5] = {
			ent = "prop_physics",
			model = "models/Slyfo/refinery_large.mdl",
			pos = Vector(10430.161133,-9848.124023,-1865.012695),
			ang = Angle(0,-135,0)
		},
        [6] = {
			ent = "tk_tib_transporter",
			pos = Vector(10160.166992,-9887.300781,-1809.855591),
			ang = Angle(90,45,180)
		},
        [7] = {
			ent = "tk_tib_transporter",
			pos = Vector(10394.168945,-10121.303711,-1809.805786),
			ang = Angle(90,45,180)
		},
        [8] = {
			ent = "tk_teleporter",
			pos = Vector(10426.134766,-9852.023438,-1862.420288),
			ang = Angle(-90,45,180)
		}
    }
end