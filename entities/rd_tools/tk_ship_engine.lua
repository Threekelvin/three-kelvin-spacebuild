
TOOL.Category    = "Ship Parts"
TOOL.Name        = "Ship Engine"
TOOL.Limit       = 1
TOOL.Data        = {}
TOOL.DefaultModel = "models/punisher239/punisher239_reactor_small.mdl"
TOOL.Link = {}
TOOL.Last = 0

function TOOL:SelectModel()
    local str = self:GetClientInfo("model")
    if !util.IsValidModel(str) then return self.DefaultModel end
    return str
end

function TOOL:RightClick(trace)
    if CurTime() < self.Last + 0.1 then return end
    self.Last = CurTime()
    
    if !IsValid(trace.Entity) then return end
    if trace.Entity:IsVehicle() then
        self.Link.Pod = trace.Entity
        if IsValid(self.Link.Engine) then
            if SERVER then
                if self.Link.Engine.Pod then self.Link.Engine.Pod.Engine = nil end
                self.Link.Engine.Pod = self.Link.Pod
                self.Link.Pod.Engine = self.Link.Engine
            else
                GAMEMODE:AddNotify("Engine and pod linked", NOTIFY_HINT, 5)
            end
            self.Link = {}
        elseif CLIENT then
            GAMEMODE:AddNotify("Select Engine to link", NOTIFY_HINT, 5)
        end
    elseif trace.Entity:GetClass() == "tk_ship_engine" then
        self.Link.Engine = trace.Entity
        if IsValid(self.Link.Pod) then
            if SERVER then
                if self.Link.Engine.Pod then self.Link.Engine.Pod.Engine = nil end
                self.Link.Engine.Pod = self.Link.Pod
                self.Link.Pod.Engine = self.Link.Engine
            else
                GAMEMODE:AddNotify("Engine and pod linked", NOTIFY_HINT, 5)
            end
            self.Link = {}
        elseif CLIENT then
            GAMEMODE:AddNotify("Select Pod to link", NOTIFY_HINT, 5)
        end
    end
end

function TOOL:Reload(trace)
    if SERVER then return end
    if !IsValid(trace.Entity) then return false end
    RunConsoleCommand("tk_ship_engine_model", trace.Entity:GetModel())
    return true
end

if SERVER then return end

language.Add("tool.tk_ship_engine.0", "Left Click: Spawn a "..TOOL.Name.."      Reload: Select Model")