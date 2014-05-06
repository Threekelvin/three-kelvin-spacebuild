
TK.TD = TK.TD or {}

local Icons = {
    ["default"]             = Material("icon64/default.png"),
    ["kilojoules"]          = Material("icon64/energy.png"),
    ["water"]               = Material("icon64/water.png"),
    ["steam"]               = Material("icon64/steam.png"),
    ["oxygen"]              = Material("icon64/oxygen.png"),
    ["hydrogen"]            = Material("icon64/hydrogen.png"),
    ["nitrogen"]            = Material("icon64/nitrogen.png"),
    ["liquid_nitrogen"]     = Material("icon64/nitrogen.png"),
    ["heavy_water"]         = Material("icon64/heavy_water.png"),
    ["carbon_dioxide"]      = Material("icon64/carbon_dioxide.png"),
    ["magnetite"]           = Material("icon64/asteroid_ore.png"),
}

function TK.TD:GetIcon(str)
    return Icons[str] or Icons["default"]
end