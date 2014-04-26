
TK.UP = TK.UP or {}

TK.UP.life_support = {
    ///--- Generators ---\\\
    gen_out = {
        name = "Generators",
        info = "",
        upgrade = {["gen_out"] = 1},
        levels = 10,
        vec = {x = 1, y = 1}
    },
    solar_out = {
        name = "Solar Panel Output",
        info = "",
        upgrade = {["sol_out"] = 2},
        levels = 5,
        req = {"gen_out"},
        vec = {x = 2, y = 1}
    },
    solar_med = {
        name = "Medium Solar Panel",
        info = "",
        upgrade = {["sol_med"] = 1},
        levels = 1,
        req = {"solar_out"},
        vec = {x = 3, y = 1}
    },
    solar_lrg = {
        name = "Large Solar Panel",
        info = "",
        upgrade = {["sol_lrg"] = 1},
        levels = 1,
        req = {"solar_med"},
        vec = {x = 4, y = 1}
    },
    solar_3nd = {
        name = "3rd Solar Panel",
        info = "",
        upgrade = {["sol_3rd"] = 1},
        levels = 1,
        req = {"solar_lrg"},
        vec = {x = 5, y = 1}
    },
    solar_4th = {
        name = "4th Solar Panel",
        info = "",
        upgrade = {["sol_4th"] = 1},
        levels = 1,
        req = {"solar_3nd"},
        vec = {x = 6, y = 1}
    },
    wind_out = {
        name = "Wind Turbine Output",
        info = "",
        upgrade = {["wnd_out"] = 2},
        levels = 5,
        req = {"gen_out"},
        vec = {x = 2, y = 2}
    },
    wind_med = {
        name = "Medium Wind Turbine",
        info = "",
        upgrade = {["wnd_med"] = 1},
        levels = 1,
        req = {"wind_out"},
        vec = {x = 3, y = 2}
    },
    wind_lrg = {
        name = "Large Wind Turbine",
        info = "",
        upgrade = {["wnd_lrg"] = 1},
        levels = 1,
        req = {"wind_med"},
        vec = {x = 4, y = 2}
    },
    wind_3nd = {
        name = "3rd Wind Turbine",
        info = "",
        upgrade = {["wnd_3rd"] = 1},
        levels = 1,
        req = {"wind_lrg"},
        vec = {x = 5, y = 2}
    },
    wind_4th = {
        name = "4th Wind Turbine",
        info = "",
        upgrade = {["wnd_4th"] = 1},
        levels = 1,
        req = {"wind_3nd"},
        vec = {x = 6, y = 2}
    },
    fusn_out = {
        name = "Fusion Reactor Output",
        info = "",
        upgrade = {["fus_out"] = 2},
        levels = 5,
        req = {"gen_out"},
        vec = {x = 2, y = 3}
    },
    heat_trf = {
        name = "Heat Transfer",
        info = "",
        upgrade = {["fus_htt"] = 2},
        levels = 5,
        req = {"fusn_out"},
        vec = {x = 3, y = 3}
    },
    fuel_eff = {
        name = "Fuel Efficiency",
        info = "",
        upgrade = {["fus_fef"] = 2},
        levels = 5,
        req = {"fusn_out"},
        vec = {x = 3, y = 4}
    },
    fusn_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["fus_med"] = 1},
        levels = 1,
        req = {"heat_trf", "fuel_eff"},
        vec = {x = 4, y = 3}
    },
    fusn_pwr = {
        name = "Fusion Power",
        info = "",
        upgrade = {["fus_pwr"] = 2},
        levels = 5,
        req = {"fusn_med"},
        vec = {x = 5, y = 3}
    },
    fusn_exp = {
        name = "Reactor Containment",
        info = "",
        upgrade = {["fus_exp"] = 5},
        levels = 5,
        req = {"fusn_med"},
        vec = {x = 5, y = 4}
    },
    fusn_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["fus_lrg"] = 1},
        levels = 1,
        req = {"fusn_pwr", "fusn_exp"},
        vec = {x = 6, y = 3}
    },
    
    ///--- Compressors ---\\\
    cmp_out = {
        name = "Compressors",
        info = "",
        upgrade = {["cmp_out"] = 1},
        levels = 10,
        vec = {x = 1, y = 6}
    },
    // CO2
    co2_out = {
        name = "CO2 Output",
        info = "",
        upgrade = {["co2_out"] = 2},
        levels = 5,
        req = {"cmp_out"},
        vec = {x = 2, y = 6}
    },
    co2_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["co2_med"] = 1},
        levels = 1,
        req = {"co2_out"},
        vec = {x = 3, y = 6}
    },
    co2_eff = {
        name = "Compressor Efficiency",
        info = "",
        upgrade = {["co2_eff"] = 2},
        levels = 5,
        req = {"co2_med"},
        vec = {x = 4, y = 6}
    },
    co2_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["co2_lrg"] = 1},
        levels = 1,
        req = {"co2_eff"},
        vec = {x = 5, y = 6}
    },
    co2_mul = {
        name = "Compressor Over-clocker",
        info = "",
        upgrade = {["co2_ovr"] = 1},
        levels = 1,
        req = {"co2_lrg"},
        vec = {x = 6, y = 6}
    },
    // N2
    n2_out = {
        name = "N2 Output",
        info = "",
        upgrade = {["n2_out"] = 2},
        levels = 5,
        req = {"cmp_out"},
        vec = {x = 2, y = 7}
    },
    n2_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["n2_med"] = 1},
        levels = 1,
        req = {"n2_out"},
        vec = {x = 3, y = 7}
    },
    n2_eff = {
        name = "Compressor Efficiency",
        info = "",
        upgrade = {["n2_eff"] = 2},
        levels = 5,
        req = {"n2_med"},
        vec = {x = 4, y = 7}
    },
    n2_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["n2_lrg"] = 1},
        levels = 1,
        req = {"n2_eff"},
        vec = {x = 5, y = 7}
    },
    n2_mul = {
        name = "Compressor Over-clocker",
        info = "",
        upgrade = {["n2_ovr"] = 1},
        levels = 1,
        req = {"n2_lrg"},
        vec = {x = 6, y = 7}
    },
    // H2
    h2_out = {
        name = "H2 Output",
        info = "",
        upgrade = {["h2_out"] = 2},
        levels = 5,
        req = {"cmp_out"},
        vec = {x = 2, y = 8}
    },
    h2_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["h2_med"] = 1},
        levels = 1,
        req = {"h2_out"},
        vec = {x = 3, y = 8}
    },
    h2_eff = {
        name = "Compressor Efficiency",
        info = "",
        upgrade = {["h2_eff"] = 2},
        levels = 5,
        req = {"h2_med"},
        vec = {x = 4, y = 8}
    },
    h2_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["h2_lrg"] = 1},
        levels = 1,
        req = {"h2_eff"},
        vec = {x = 5, y = 8}
    },
    h2_mul = {
        name = "Compressor Over-clocker",
        info = "",
        upgrade = {["h2_ovr"] = 1},
        levels = 1,
        req = {"h2_lrg"},
        vec = {x = 6, y = 8}
    },
    // O2
    o2_out = {
        name = "O2 Output",
        info = "",
        upgrade = {["o2_out"] = 2},
        levels = 5,
        req = {"cmp_out"},
        vec = {x = 2, y = 9}
    },
    o2_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["o2_med"] = 1},
        levels = 1,
        req = {"o2_out"},
        vec = {x = 3, y = 9}
    },
    o2_eff = {
        name = "Compressor Efficiency",
        info = "",
        upgrade = {["o2_eff"] = 2},
        levels = 5,
        req = {"o2_med"},
        vec = {x = 4, y = 9}
    },
    o2_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["o2_lrg"] = 1},
        levels = 1,
        req = {"o2_eff"},
        vec = {x = 5, y = 9}
    },
    o2_mul = {
        name = "Compressor Over-clocker",
        info = "",
        upgrade = {["o2_ovr"] = 1},
        levels = 1,
        req = {"o2_lrg"},
        vec = {x = 6, y = 9}
    },
    // H2O Elec
    h2o_elc_out = {
        name = "H2O Electrolyzer Output",
        info = "",
        upgrade = {["h2o_elc_out"] = 2},
        levels = 5,
        req = {"cmp_out"},
        vec = {x = 2, y = 10}
    },
    h2o_elc_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["h2o_elc_med"] = 1},
        levels = 1,
        req = {"h2o_elc_out"},
        vec = {x = 3, y = 10}
    },
    h2o_elc_eff = {
        name = "Compressor Efficiency",
        info = "",
        upgrade = {["h2o_elc_eff"] = 2},
        levels = 5,
        req = {"h2o_elc_med"},
        vec = {x = 4, y = 10}
    },
    h2o_elc_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["h2o_elc_lrg"] = 1},
        levels = 1,
        req = {"h2o_elc_eff"},
        vec = {x = 5, y = 10}
    },
    h2o_elc_mul = {
        name = "Compressor Over-clocker",
        info = "",
        upgrade = {["h2o_elc_ovr"] = 1},
        levels = 1,
        req = {"h2o_elc_lrg"},
        vec = {x = 6, y = 10}
    },
    // H2O Pump
    h2o_pmp_out = {
        name = "H2O Pump Output",
        info = "",
        upgrade = {["h2o_pmp_out"] = 2},
        levels = 5,
        req = {"cmp_out"},
        vec = {x = 2, y = 11}
    },
    h2o_pmp_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["h2o_pmp_med"] = 1},
        levels = 1,
        req = {"h2o_pmp_out"},
        vec = {x = 3, y = 11}
    },
    h2o_pmp_eff = {
        name = "Compressor Efficiency",
        info = "",
        upgrade = {["h2o_pmp_eff"] = 2},
        levels = 5,
        req = {"h2o_pmp_med"},
        vec = {x = 4, y = 11}
    },
    h2o_pmp_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["h2o_pmp_lrg"] = 1},
        levels = 1,
        req = {"h2o_pmp_eff"},
        vec = {x = 5, y = 11}
    },
    h2o_pmp_mul = {
        name = "Compressor Over-clocker",
        info = "",
        upgrade = {["h2o_pmp_ovr"] = 1},
        levels = 1,
        req = {"h2o_pmp_lrg"},
        vec = {x = 6, y = 11}
    },
     // LN2
    ln2_out = {
        name = "LN2 Output",
        info = "",
        upgrade = {["ln2_out"] = 2},
        levels = 5,
        req = {"cmp_out"},
        vec = {x = 2, y = 12}
    },
    ln2_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["ln2_med"] = 1},
        levels = 1,
        req = {"ln2_out"},
        vec = {x = 3, y = 12}
    },
    ln2_eff = {
        name = "Compressor Efficiency",
        info = "",
        upgrade = {["ln2_eff"] = 2},
        levels = 5,
        req = {"ln2_med"},
        vec = {x = 4, y = 12}
    },
    ln2_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["ln2_lrg"] = 1},
        levels = 1,
        req = {"ln2_eff"},
        vec = {x = 5, y = 12}
    },
    ln2_mul = {
        name = "Compressor Over-clocker",
        info = "",
        upgrade = {["ln2_ovr"] = 1},
        levels = 1,
        req = {"ln2_lrg"},
        vec = {x = 6, y = 12}
    },
    
    ///--- Storage ---\\\
    str_cap = {
        name = "Storage",
        info = "",
        upgrade = {["str_cap"] = 1},
        levels = 10,
        vec = {x = 1, y = 14}
    },
    // Battery
    bat_cap = {
        name = "Battery Capacity",
        info = "",
        upgrade = {["bat_cap"] = 2},
        levels = 5,
        req = {"str_cap"},
        vec = {x = 2, y = 14}
    },
    bat_str_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["bat_med"] = 1},
        levels = 1,
        req = {"bat_cap"},
        vec = {x = 3, y = 14}
    },
    bat_cap_2 = {
        name = "Battery Capacity",
        info = "",
        upgrade = {["bat_cap_2"] = 1},
        levels = 5,
        req = {"bat_str_med"},
        vec = {x = 4, y = 14}
    },
    bat_str_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["bat_lrg"] = 1},
        levels = 1,
        req = {"bat_cap_2"},
        vec = {x = 5, y = 14}
    },
    bat_cap_3 = {
        name = "Battery Capacity",
        info = "",
        upgrade = {["bat_cap_3"] = 2},
        levels = 5,
        req = {"bat_str_lrg"},
        vec = {x = 6, y = 14}
    },
    // CO2
    co2_cap = {
        name = "CO2 Capacity",
        info = "",
        upgrade = {["co2_cap"] = 2},
        levels = 5,
        req = {"str_cap"},
        vec = {x = 2, y = 15}
    },
    co2_str_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["co2_med"] = 1},
        levels = 1,
        req = {"co2_cap"},
        vec = {x = 3, y = 15}
    },
    co2_cap_2 = {
        name = "CO2 Capacity",
        info = "",
        upgrade = {["co2_cap_2"] = 1},
        levels = 5,
        req = {"co2_str_med"},
        vec = {x = 4, y = 15}
    },
    co2_str_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["co2_lrg"] = 1},
        levels = 1,
        req = {"co2_cap_2"},
        vec = {x = 5, y = 15}
    },
    co2_cap_3 = {
        name = "CO2 Capacity",
        info = "",
        upgrade = {["co2_cap_3"] = 2},
        levels = 5,
        req = {"co2_str_lrg"},
        vec = {x = 6, y = 15}
    },
    // N2
    n2_cap = {
        name = "N2 Capacity",
        info = "",
        upgrade = {["n2_cap"] = 2},
        levels = 5,
        req = {"str_cap"},
        vec = {x = 2, y = 16}
    },
    n2_str_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["n2_med"] = 1},
        levels = 1,
        req = {"n2_cap"},
        vec = {x = 3, y = 16}
    },
    n2_cap_2 = {
        name = "N2 Capacity",
        info = "",
        upgrade = {["n2_cap_2"] = 1},
        levels = 5,
        req = {"n2_str_med"},
        vec = {x = 4, y = 16}
    },
    n2_str_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["n2_lrg"] = 1},
        levels = 1,
        req = {"n2_cap_2"},
        vec = {x = 5, y = 16}
    },
    n2_cap_3 = {
        name = "N2 Capacity",
        info = "",
        upgrade = {["n2_cap_3"] = 2},
        levels = 5,
        req = {"n2_str_lrg"},
        vec = {x = 6, y = 16}
    },
    // H2
    h2_cap = {
        name = "H2 Capacity",
        info = "",
        upgrade = {["h2_cap"] = 2},
        levels = 5,
        req = {"str_cap"},
        vec = {x = 2, y = 17}
    },
    h2_str_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["h2_med"] = 1},
        levels = 1,
        req = {"h2_cap"},
        vec = {x = 3, y = 17}
    },
    h2_cap_2 = {
        name = "H2 Capacity",
        info = "",
        upgrade = {["h2_cap_2"] = 1},
        levels = 5,
        req = {"h2_str_med"},
        vec = {x = 4, y = 17}
    },
    h2_str_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["h2_lrg"] = 1},
        levels = 1,
        req = {"h2_cap_2"},
        vec = {x = 5, y = 17}
    },
    h2_cap_3 = {
        name = "H2 Capacity",
        info = "",
        upgrade = {["h2_cap_3"] = 2},
        levels = 5,
        req = {"h2_str_lrg"},
        vec = {x = 6, y = 17}
    },
    // O2
    o2_cap = {
        name = "O2 Capacity",
        info = "",
        upgrade = {["o2_cap"] = 2},
        levels = 5,
        req = {"str_cap"},
        vec = {x = 2, y = 18}
    },
    o2_str_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["o2_med"] = 1},
        levels = 1,
        req = {"o2_cap"},
        vec = {x = 3, y = 18}
    },
    o2_cap_2 = {
        name = "O2 Capacity",
        info = "",
        upgrade = {["o2_cap_2"] = 1},
        levels = 5,
        req = {"o2_str_med"},
        vec = {x = 4, y = 18}
    },
    o2_str_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["o2_lrg"] = 1},
        levels = 1,
        req = {"o2_cap_2"},
        vec = {x = 5, y = 18}
    },
    o2_cap_3 = {
        name = "O2 Capacity",
        info = "",
        upgrade = {["o2_cap_3"] = 2},
        levels = 5,
        req = {"o2_str_lrg"},
        vec = {x = 6, y = 18}
    },
    // H2O
    h2o_cap = {
        name = "H2O Capacity",
        info = "",
        upgrade = {["h2o_cap"] = 2},
        levels = 5,
        req = {"str_cap"},
        vec = {x = 2, y = 19}
    },
    h2o_str_med = {
        name = "Unlock Medium",
        info = "",
        upgrade = {["h2o_med"] = 1},
        levels = 1,
        req = {"h2o_cap"},
        vec = {x = 3, y = 19}
    },
    h2o_cap_2 = {
        name = "H2O Capacity",
        info = "",
        upgrade = {["h2o_cap_2"] = 1},
        levels = 5,
        req = {"h2o_str_med"},
        vec = {x = 4, y = 19}
    },
    h2o_str_lrg = {
        name = "Unlock Large",
        info = "",
        upgrade = {["h2o_lrg"] = 1},
        levels = 1,
        req = {"h2o_cap_2"},
        vec = {x = 5, y = 19}
    },
    h2o_cap_3 = {
        name = "H2O Capacity",
        info = "",
        upgrade = {["h2o_cap_3"] = 2},
        levels = 5,
        req = {"h2o_str_lrg"},
        vec = {x = 6, y = 19}
    },
}