
TK.RD = TK.RD or {}

hook.Add("Initialize", "TK.RD", function()
    TK.RD:AddResource("kilojoules", "Kilojoules")
    TK.RD:AddResource("oxygen", "Oxygen")
    TK.RD:AddResource("carbon_dioxide", "Carbon Dioxide")
    TK.RD:AddResource("nitrogen", "Nitrogen")
    TK.RD:AddResource("hydrogen", "Hydrogen")
    TK.RD:AddResource("liquid_nitrogen", "Liquid Nitrogen")
    TK.RD:AddResource("water", "Water")
    
    TK.RD:AddResource("tiberium", "Tiberium")
    TK.RD:AddResource("magnetite", "Magnetite")
end)