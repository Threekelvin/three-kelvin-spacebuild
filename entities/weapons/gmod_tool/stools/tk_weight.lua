TOOL.Category = "Construction"
TOOL.Name = "#Weight"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar["set"] = "500"
local Weight = {}

if CLIENT then
    language.Add("tool.tk_weight.name", "Weight Tool")
    language.Add("tool.tk_weight.desc", "Set the weight")
    language.Add("tool.tk_weight.0", "Primary: Set   Secondary: Copy   Reload: Reset")
    language.Add("tool_tk_weight_set", "Weight:")
    language.Add("tool_tk_weight_set_desc", "Set the weight")
end

local function SetMass(ply, ent, data)
    if CLIENT then return end
    if not data.Mass then return end
    local mass = math.Clamp(data.Mass, 1, 50000)
    local physobj = ent:GetPhysicsObject()

    if IsValid(physobj) then
        physobj:SetMass(mass)
    end

    duplicator.StoreEntityModifier(ent, "mass", {
        Mass = mass
    })
end

duplicator.RegisterEntityModifier("mass", SetMass)

local function CanSetWeight(trace)
    if not IsValid(trace.Entity) then return false end
    if trace.Entity:IsPlayer() then return false end
    if SERVER and not IsValid(trace.Entity:GetPhysicsObject()) then return false end

    return true
end

function TOOL:LeftClick(trace)
    if CLIENT then return CanSetWeight(trace) end
    if not CanSetWeight(trace) then return false end
    local ent = trace.Entity

    if not Weight[ent:GetModel()] then
        Weight[ent:GetModel()] = ent:GetPhysicsObject():GetMass()
    end

    local mass = tonumber(self:GetClientInfo("set", 1))

    SetMass(nil, ent, {
        Mass = mass
    })

    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return CanSetWeight(trace) end
    if not CanSetWeight(trace) then return false end
    local ent = trace.Entity
    local mass = ent:GetPhysicsObject():GetMass()
    self:GetOwner():ConCommand("weight_set " .. mass)

    return true
end

function TOOL:Reload(trace)
    if CLIENT then return CanSetWeight(trace) end
    if not CanSetWeight(trace) then return false end
    local ent = trace.Entity
    local mass = Weight[ent:GetModel()]
    if not mass then return end

    SetMass(nil, ent, {
        Mass = mass
    })

    return true
end

function TOOL:Think()
    if CLIENT then return end
    local ply = self:GetOwner()
    local weapon = ply:GetActiveWeapon()
    if not IsValid(weapon) or weapon:GetClass() ~= "gmod_tool" then return end
    if ply:GetInfo("gmod_toolmode") ~= "tk_weight" then return end
    local trace = ply:GetEyeTrace()
    if not CanSetWeight(trace) then return end
    ply:SetNWFloat("Mass", trace.Entity:GetPhysicsObject():GetMass())
end

function TOOL.BuildCPanel(CPanel)
    CPanel:AddControl("header", {
        description = "#tool.tk_weight.desc"
    })

    CPanel:AddControl("slider", {
        label = "#tool_tk_weight_set",
        type = "numeric",
        min = "1",
        max = "50000",
        command = "tk_weight_set"
    })
end

if CLIENT then
    hook.Add("HUDPaint", "WeightToolTip", function()
        local ply = LocalPlayer()
        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or weapon:GetClass() ~= "gmod_tool" then return end
        if ply:GetInfo("gmod_toolmode") ~= "tk_weight" then return end
        local trace = ply:GetEyeTrace()
        if not CanSetWeight(trace) then return end
        local mass = ply:GetNWFloat("Mass", 0)
        AddWorldTip(nil, "Weight: " .. mass, nil, trace.Entity:LocalToWorld(trace.Entity:OBBCenter()))
    end)
end
