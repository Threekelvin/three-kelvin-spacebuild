
TOOL.Category	= "Ship Parts"
TOOL.Name		= "Ship Engine"
TOOL.Limit		= 1
TOOL.Data		= {}
TOOL.DefaultModel = "models/punisher239/punisher239_reactor_small.mdl"

function TOOL:SelectModel()
    local str = self:GetClientInfo("model")
    if !util.IsValidModel(str) then return self.DefaultModel end
    return str
end

function TOOL:Reload(trace)
    if SERVER then return end
    if !IsValid(trace.Entity) then return false end
    RunConsoleCommand("tk_ship_engine_model", trace.Entity:GetModel())
    return true
end