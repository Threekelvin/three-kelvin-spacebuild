
TK.HEV = TK.HEV || {}

TK.HEV.Sounds = {
	Sound("fvox/health_dropping.wav"),
	Sound("fvox/health_dropping2.wav"),
	Sound("fvox/health_critical.wav"),
	Sound("fvox/near_death.wav"),
	Sound("fvox/minor_lacerations.wav"),
	Sound("fvox/minor_fracture.wav"),
	Sound("fvox/major_lacerations.wav"),
	Sound("fvox/major_fracture.wav"),
	Sound("fvox/internal_bleeding.wav")
}

local HEVData = {
    energy = 600,
    energymax = 600,
    water = 600,
    watermax = 600,
    oxygen = 600,
    oxygenmax = 600,
    temp = 290,
    airper = 5
}

function TK.HEV:GetData()
    return table.Copy(HEVData)
end

net.Receive("TKLS_Ply", function()
	local data = net.ReadTable()
    for k,v in pairs(data) do
        HEVData[k] = v
    end
end)