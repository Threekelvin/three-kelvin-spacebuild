
TK.PP = TK.PP || {}

TK.PP.BuddySettings = {"Tool Gun", "Grav Gun", "Phys Gun", "Use", "Dupe", "CPPI"}

TK.PP.Settings = {
    ["Tool Gun"] = {
        Prop = {
            User = false,
            Moderator = true,
            Admin = true,
            SuperAdmin = true
        },
        World = {
            User = false,
            Moderator = false,
            Admin = false,
            SuperAdmin = false
        }
    },
    ["Grav Gun"] = {
        Prop = {
            User = false,
            Moderator = true,
            Admin = true,
            SuperAdmin = true
        },
        World = {
            User = false,
            Moderator = false,
            Admin = false,
            SuperAdmin = false
        }
    },
    ["Phys Gun"] = {
        Prop = {
            User = false,
            Moderator = true,
            Admin = true,
            SuperAdmin = true
        },
        World = {
            User = false,
            Moderator = false,
            Admin = false,
            SuperAdmin = false
        },
        Player = {
            User = false,
            Moderator = false,
            Admin = true,
            SuperAdmin = true
        },
    },
    ["Use"] = {
        Prop = {
            User = false,
            Moderator = true,
            Admin = true,
            SuperAdmin = true
        },
        World = {
            User = true,
            Moderator = true,
            Admin = true,
            SuperAdmin = true
        }
    },
    ["Dupe"] = {
        Prop = {
            User = false,
            Moderator = false,
            Admin = false,
            SuperAdmin = false
        },
        World = {
            User = false,
            Moderator = false,
            Admin = false,
            SuperAdmin = false
        }
    },
    ["CleanUp"] = {
        Delay = 300
    }
}

TK.PP.CleanupBlackList = {
    "player",
    "physgun_beam",
    "player_manager",
    "predicted_viewmodel",
    "gmod_ghost"
}

TK.PP.PropBlackList = {
    "models/props_phx/amraam.mdl",
    "models/props_phx/ball.mdl",
    "models/props_phx/cannonball.mdl",
    "models/props_phx/mk-82.mdl",
    "models/props_phx/oildrum001_explosive.mdl",
    "models/props_phx/torpedo.mdl",
    "models/props_phx/ww2bomb.mdl",
    "models/props_phx/misc/flakshell_big.mdl",
    "models/props_c17/oildrum001_explosive.mdl",
    "models/props_explosive/explosive_butane_can.mdl",
    "models/props_explosive/explosive_butane_can02.mdl",
    "models/props_junk/gascan001a.mdl",
    "models/props_phx/misc/potato_launcher_explosive.mdl",
    "models/props_junk/propane_tank001a.mdl",
    "models/space/smallmoon.mdl",
    "models/space/unit_sphere.mdl",
    "models/ce_ls3additional/asteroids/asteroid_200.mdl",
    "models/ce_ls3additional/asteroids/asteroid_250.mdl",
    "models/ce_ls3additional/asteroids/asteroid_300.mdl",
    "models/ce_ls3additional/asteroids/asteroid_350.mdl",
    "models/ce_ls3additional/asteroids/asteroid_400.mdl",
    "models/ce_ls3additional/asteroids/asteroid_450.mdl",
    "models/ce_ls3additional/asteroids/asteroid_500.mdl",
    "models/Tiberium/tiberium_crystal1.mdl",
    "models/Tiberium/tiberium_crystal2.mdl",
    "models/Tiberium/tiberium_crystal3.mdl",
    "models/chipstiks_mining_models/SmallBlueCrystal/smallbluecrystal.mdl",
    "models/chipstiks_mining_models/SmallBlueTower/smallbluetower.mdl",
    "models/ce_miningmodels/mininglasers/laser_mk1_standard.mdl"
}

TK.PP.EntityBlackList = {
    "tk_terminal",
    "tk_tib_crystal",
    "tk_roid",
    "tk_teleporter",
    "tk_tib_transporter",
    "grenade_helicopter",
    "combine_mine",
    "weapon_striderbuster",
    "prop_thumper"
}

TK.PP.BadTools = {
    "wire_winch",
    "wire_hydraulic",
    "slider",
    "hydraulic",
    "winch",
    "muscle"
}