
TK.UP = TK.UP or {}

TK.UP.life_support = {
    ///--- Generators ---\\\
    generators_out = {
        name = "Generators",
        info = "",
        levels = 10,
        vec = {x = 1, y = 1}
    },
    rd_solar_panel_out = {
        name = "Solar Panel Output",
        info = "",
        upgrade = {["out"] = 2},
        levels = 5,
        req = {"generators_out"},
        vec = {x = 2, y = 1}
    },
    rd_solar_panel_medium = {
        name = "Medium Solar Panel",
        info = "",
        levels = 1,
        req = {"rd_solar_panel_out"},
        vec = {x = 3, y = 1}
    },
    rd_solar_panel_large = {
        name = "Large Solar Panel",
        info = "",
        levels = 1,
        req = {"rd_solar_panel_medium"},
        vec = {x = 4, y = 1}
    },
    rd_solar_panel_extra = {
        name = "Extra Solar Panel",
        info = "",
        levels = 2,
        req = {"rd_solar_panel_large"},
        vec = {x = 5, y = 1}
    },
    rd_wind_turbine_out = {
        name = "Wind Turbine Output",
        info = "",
        levels = 5,
        req = {"generators_out"},
        vec = {x = 2, y = 2}
    },
    rd_wind_turbine_medium = {
        name = "Medium Wind Turbine",
        info = "",
        levels = 1,
        req = {"rd_wind_turbine_out"},
        vec = {x = 3, y = 2}
    },
    rd_wind_turbine_large = {
        name = "Large Wind Turbine",
        info = "",
        levels = 1,
        req = {"rd_wind_turbine_medium"},
        vec = {x = 4, y = 2}
    },
    rd_wind_turbine_extra = {
        name = "Extra Wind Turbine",
        info = "",
        levels = 2,
        req = {"rd_wind_turbine_large"},
        vec = {x = 5, y = 2}
    },
    rd_fusion_reactor_out = {
        name = "Fusion Reactor Output",
        info = "",
        levels = 5,
        req = {"generators_out"},
        vec = {x = 2, y = 3}
    },
    rd_fusion_reactor_heat = {
        name = "Heat Transfer",
        info = "",
        levels = 5,
        req = {"rd_fusion_reactor_out"},
        vec = {x = 3, y = 3}
    },
    rd_fusion_reactor_fuel = {
        name = "Fuel Efficiency",
        info = "",
        levels = 5,
        req = {"rd_fusion_reactor_out"},
        vec = {x = 3, y = 4}
    },
    rd_fusion_reactor_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_fusion_reactor_heat", "rd_fusion_reactor_fuel"},
        vec = {x = 4, y = 3}
    },
    rd_fusion_reactor_power = {
        name = "Fusion Power",
        info = "",
        levels = 5,
        req = {"rd_fusion_reactor_medium"},
        vec = {x = 5, y = 3}
    },
    rd_fusion_reactor_damage = {
        name = "Reactor Containment",
        info = "",
        levels = 5,
        req = {"rd_fusion_reactor_power"},
        vec = {x = 5, y = 4}
    },
    rd_fusion_reactor_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_fusion_reactor_power", "rd_fusion_reactor_damage"},
        vec = {x = 6, y = 3}
    },
    
    ///--- Compressors ---\\\
    compressors_out = {
        name = "Compressors",
        info = "",
        levels = 10,
        vec = {x = 1, y = 6}
    },
    // CO2
    rd_carbondioxide_compressor_out = {
        name = "CO2 Output",
        info = "",
        levels = 5,
        req = {"compressors_out"},
        vec = {x = 2, y = 6}
    },
    rd_carbondioxide_compressor_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_carbondioxide_compressor_out"},
        vec = {x = 3, y = 6}
    },
    rd_carbondioxide_compressor_power = {
        name = "Compressor Efficiency",
        info = "",
        levels = 5,
        req = {"rd_carbondioxide_compressor_medium"},
        vec = {x = 4, y = 6}
    },
    rd_carbondioxide_compressor_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_carbondioxide_compressor_power"},
        vec = {x = 5, y = 6}
    },
    rd_carbondioxide_compressor_clock = {
        name = "Compressor Over-clocker",
        info = "",
        levels = 1,
        req = {"rd_carbondioxide_compressor_large"},
        vec = {x = 6, y = 6}
    },
    // N2
    rd_nitrogen_compressor_out = {
        name = "N2 Output",
        info = "",
        levels = 5,
        req = {"compressors_out"},
        vec = {x = 2, y = 7}
    },
    rd_nitrogen_compressor_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_nitrogen_compressor_out"},
        vec = {x = 3, y = 7}
    },
    rd_nitrogen_compressor_power = {
        name = "Compressor Efficiency",
        info = "",
        levels = 5,
        req = {"rd_nitrogen_compressor_medium"},
        vec = {x = 4, y = 7}
    },
    rd_nitrogen_compressor_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_nitrogen_compressor_power"},
        vec = {x = 5, y = 7}
    },
    rd_nitrogen_compressor_clock = {
        name = "Compressor Over-clocker",
        info = "",
        levels = 1,
        req = {"rd_nitrogen_compressor_large"},
        vec = {x = 6, y = 7}
    },
    // H2
    rd_hydrogen_compressor_out = {
        name = "H2 Output",
        info = "",
        levels = 5,
        req = {"compressors_out"},
        vec = {x = 2, y = 8}
    },
    rd_hydrogen_compressor_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_hydrogen_compressor_out"},
        vec = {x = 3, y = 8}
    },
    rd_hydrogen_compressor_power = {
        name = "Compressor Efficiency",
        info = "",
        levels = 5,
        req = {"rd_hydrogen_compressor_medium"},
        vec = {x = 4, y = 8}
    },
    rd_hydrogen_compressor_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_hydrogen_compressor_power"},
        vec = {x = 5, y = 8}
    },
    rd_hydrogen_compressor_clock = {
        name = "Compressor Over-clocker",
        info = "",
        levels = 1,
        req = {"rd_hydrogen_compressor_large"},
        vec = {x = 6, y = 8}
    },
    // O2
    rd_oxygen_compressor_out = {
        name = "O2 Output",
        info = "",
        levels = 5,
        req = {"compressors_out"},
        vec = {x = 2, y = 9}
    },
    rd_oxygen_compressor_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_oxygen_compressor_out"},
        vec = {x = 3, y = 9}
    },
    rd_oxygen_compressor_power = {
        name = "Compressor Efficiency",
        info = "",
        levels = 5,
        req = {"rd_oxygen_compressor_medium"},
        vec = {x = 4, y = 9}
    },
    rd_oxygen_compressor_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_oxygen_compressor_power"},
        vec = {x = 5, y = 9}
    },
    rd_oxygen_compressor_clock = {
        name = "Compressor Over-clocker",
        info = "",
        levels = 1,
        req = {"rd_oxygen_compressor_large"},
        vec = {x = 6, y = 9}
    },
    // H2O Elec
    rd_water_electrolyzer_out = {
        name = "H2O Electrolyzer Output",
        info = "",
        levels = 5,
        req = {"compressors_out"},
        vec = {x = 2, y = 10}
    },
    rd_water_electrolyzer_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_water_electrolyzer_out"},
        vec = {x = 3, y = 10}
    },
    rd_water_electrolyzer_power = {
        name = "Compressor Efficiency",
        info = "",
        levels = 5,
        req = {"rd_water_electrolyzer_medium"},
        vec = {x = 4, y = 10}
    },
    rd_water_electrolyzer_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_water_electrolyzer_power"},
        vec = {x = 5, y = 10}
    },
    rd_water_electrolyzer_clock = {
        name = "Compressor Over-clocker",
        info = "",
        levels = 1,
        req = {"rd_water_electrolyzer_large"},
        vec = {x = 6, y = 10}
    },
    // H2O Pump
    rd_water_pump_out = {
        name = "H2O Pump Output",
        info = "",
        levels = 5,
        req = {"compressors_out"},
        vec = {x = 2, y = 11}
    },
    rd_water_pump_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_water_pump_out"},
        vec = {x = 3, y = 11}
    },
    rd_water_pump_power = {
        name = "Compressor Efficiency",
        info = "",
        levels = 5,
        req = {"rd_water_pump_medium"},
        vec = {x = 4, y = 11}
    },
    rd_water_pump_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_water_pump_power"},
        vec = {x = 5, y = 11}
    },
    rd_water_pump_clock = {
        name = "Compressor Over-clocker",
        info = "",
        levels = 1,
        req = {"rd_water_pump_large"},
        vec = {x = 6, y = 11}
    },
     // LN2
    rd_nitrogen_liquifier_out = {
        name = "LN2 Output",
        info = "",
        levels = 5,
        req = {"compressors_out"},
        vec = {x = 2, y = 12}
    },
    rd_nitrogen_liquifier_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_nitrogen_liquifier_out"},
        vec = {x = 3, y = 12}
    },
    rd_nitrogen_liquifier_power = {
        name = "Compressor Efficiency",
        info = "",
        levels = 5,
        req = {"rd_nitrogen_liquifier_medium"},
        vec = {x = 4, y = 12}
    },
    rd_nitrogen_liquifier_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_nitrogen_liquifier_power"},
        vec = {x = 5, y = 12}
    },
    rd_nitrogen_liquifier_clock = {
        name = "Compressor Over-clocker",
        info = "",
        levels = 1,
        req = {"rd_nitrogen_liquifier_large"},
        vec = {x = 6, y = 12}
    },
    
    ///--- Storage ---\\\
    storage_cap = {
        name = "Storage",
        info = "",
        levels = 10,
        vec = {x = 1, y = 14}
    },
    // Battery
    rd_battery_cap1 = {
        name = "Battery Capacity",
        info = "",
        levels = 5,
        req = {"storage_cap"},
        vec = {x = 2, y = 14}
    },
    rd_battery_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_battery_cap1"},
        vec = {x = 3, y = 14}
    },
    rd_battery_cap2 = {
        name = "Battery Capacity",
        info = "",
        levels = 5,
        req = {"rd_battery_medium"},
        vec = {x = 4, y = 14}
    },
    rd_battery_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_battery_cap2"},
        vec = {x = 5, y = 14}
    },
    rd_battery_cap3 = {
        name = "Battery Capacity",
        info = "",
        levels = 5,
        req = {"rd_battery_large"},
        vec = {x = 6, y = 14}
    },
    // CO2
    rd_carbondioxide_storage_cap1 = {
        name = "CO2 Capacity",
        info = "",
        levels = 5,
        req = {"storage_cap"},
        vec = {x = 2, y = 15}
    },
    rd_carbondioxide_storage_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_carbondioxide_storage_cap1"},
        vec = {x = 3, y = 15}
    },
    rd_carbondioxide_storage_cap2 = {
        name = "CO2 Capacity",
        info = "",
        levels = 5,
        req = {"rd_carbondioxide_storage_medium"},
        vec = {x = 4, y = 15}
    },
    rd_carbondioxide_storage_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_carbondioxide_storage_cap2"},
        vec = {x = 5, y = 15}
    },
    rd_carbondioxide_storage_cap3 = {
        name = "CO2 Capacity",
        info = "",
        levels = 5,
        req = {"rd_carbondioxide_storage_large"},
        vec = {x = 6, y = 15}
    },
    // N2
    rd_nitrogen_storage_cap1 = {
        name = "N2 Capacity",
        info = "",
        levels = 5,
        req = {"storage_cap"},
        vec = {x = 2, y = 16}
    },
    rd_nitrogen_storage_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_nitrogen_storage_cap1"},
        vec = {x = 3, y = 16}
    },
    rd_nitrogen_storage_cap2 = {
        name = "N2 Capacity",
        info = "",
        levels = 5,
        req = {"rd_nitrogen_storage_medium"},
        vec = {x = 4, y = 16}
    },
    rd_nitrogen_storage_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_nitrogen_storage_cap2"},
        vec = {x = 5, y = 16}
    },
    rd_nitrogen_storage_cap3 = {
        name = "N2 Capacity",
        info = "",
        levels = 5,
        req = {"rd_nitrogen_storage_large"},
        vec = {x = 6, y = 16}
    },
    // H2
    rd_hydrogen_storage_cap1 = {
        name = "H2 Capacity",
        info = "",
        levels = 5,
        req = {"storage_cap"},
        vec = {x = 2, y = 17}
    },
    rd_hydrogen_storage_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_hydrogen_storage_cap1"},
        vec = {x = 3, y = 17}
    },
    rd_hydrogen_storage_cap2 = {
        name = "H2 Capacity",
        info = "",
        levels = 5,
        req = {"rd_hydrogen_storage_medium"},
        vec = {x = 4, y = 17}
    },
    rd_hydrogen_storage_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_hydrogen_storage_cap2"},
        vec = {x = 5, y = 17}
    },
    rd_hydrogen_storage_cap3 = {
        name = "H2 Capacity",
        info = "",
        levels = 5,
        req = {"rd_hydrogen_storage_large"},
        vec = {x = 6, y = 17}
    },
    // O2
    rd_oxygen_storage_cap1 = {
        name = "O2 Capacity",
        info = "",
        levels = 5,
        req = {"storage_cap"},
        vec = {x = 2, y = 18}
    },
    rd_oxygen_storage_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_oxygen_storage_cap1"},
        vec = {x = 3, y = 18}
    },
    rd_oxygen_storage_cap2 = {
        name = "O2 Capacity",
        info = "",
        levels = 5,
        req = {"rd_oxygen_storage_medium"},
        vec = {x = 4, y = 18}
    },
    rd_oxygen_storage_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_oxygen_storage_cap2"},
        vec = {x = 5, y = 18}
    },
    rd_oxygen_storage_cap3 = {
        name = "O2 Capacity",
        info = "",
        levels = 5,
        req = {"rd_oxygen_storage_large"},
        vec = {x = 6, y = 18}
    },
    // H2O
    rd_water_storage_cap1 = {
        name = "H2O Capacity",
        info = "",
        levels = 5,
        req = {"storage_cap"},
        vec = {x = 2, y = 19}
    },
    rd_water_storage_medium = {
        name = "Unlock Medium",
        info = "",
        levels = 1,
        req = {"rd_water_storage_cap1"},
        vec = {x = 3, y = 19}
    },
    rd_water_storage_cap2 = {
        name = "H2O Capacity",
        info = "",
        levels = 5,
        req = {"rd_water_storage_medium"},
        vec = {x = 4, y = 19}
    },
    rd_water_storage_large = {
        name = "Unlock Large",
        info = "",
        levels = 1,
        req = {"rd_water_storage_cap2"},
        vec = {x = 5, y = 19}
    },
    rd_water_storage_cap3 = {
        name = "H2O Capacity",
        info = "",
        levels = 5,
        req = {"rd_water_storage_large"},
        vec = {x = 6, y = 19}
    },
    
    //-- Node --\\
    rd_node_medium = {
        name = "Medium Resource Node",
        info = "",
        levels = 1,
        vec = {x = 1, y = 21}
    },
    rd_node_large = {
        name = "Large Resource Node",
        info = "",
        levels = 1,
        req = {"rd_node_medium"},
        vec = {x = 2, y = 21}
    },
}