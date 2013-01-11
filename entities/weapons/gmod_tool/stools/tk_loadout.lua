TOOL.Category		= "Mining"
TOOL.Name			= "Loadout"
TOOL.Command		= nil
TOOL.ConfigName		= nil
TOOL.Tab = "3K Spacebuild"

if CLIENT then
	language.Add("tool.tk_loadout.name", "Player Loadout Tool")
	language.Add("tool.tk_loadout.desc", "Use to Spawn Items From Your Loadout")
	language.Add("tool.tk_loadout.0", "Left Click:    Right Click:    Reload:")
else

end

function TOOL:LeftClick(trace)

end

function TOOL:RightClick(trace)

end

function TOOL:Reload(trace)

end

function TOOL:Think()

end

function TOOL.BuildCPanel(CPanel)

end