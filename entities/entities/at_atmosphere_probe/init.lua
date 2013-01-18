
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    local entdata = self:GetEntTable()
    entdata.data.id = "Space"
    entdata.data.temp = 3
    entdata.data.gravity = 0
    entdata.data.resources = {}
    entdata.update = {}
    
    self.Inputs = WireLib.CreateInputs(self, {"On"})
    self.Outputs = WireLib.CreateOutputs(self, {"On"})
end

function ENT:TurnOn()
    if self:GetActive()|| !self:IsLinked() then return end
    self:SetActive(true)
    WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
    if !self:GetActive() then return end
    self:SetActive(false)
    WireLib.TriggerOutput(self, "On", 0)
end

function ENT:TriggerInput(iname, value)
    if iname == "On" then
        if value != 0 then
            self:TurnOn()
        else
            self:TurnOff()
        end
    end
end

function ENT:DoThink(eff)
    if !self:GetActive() then return end
    if !self:Work() then return end
    eff = eff == 1
    
    local env = self:GetEnv()
    local entdata = self:GetEntTable()
    
    if entdata.data.id != env.atmosphere.name then
        entdata.data.id = env.atmosphere.name
        entdata.update = {}
    end
    
    local temp = eff && env:DoTemp(self) || "NA"
    if entdata.data.temp != temp then
        entdata.data.temp = temp
        entdata.update = {}
    end
    
    local gravity = eff && env.atmosphere.gravity || "NA"
    if entdata.data.gravity != gravity then
        entdata.data.gravity = gravity
        entdata.update = {}
    end

    for k,v in pairs(env.atmosphere.resources) do
        local val = eff && v || "NA"
        if !entdata.data.resources[k] || entdata.data.resources[k] != val then
            entdata.data.resources[k] = val
            entdata.update = {}
        end
    end
    
    for k,v in pairs(entdata.data.resources) do
        if !env.atmosphere.resources[k] then
            entdata.data.resources[k] = nil
            entdata.update = {}
        end
    end
end

function ENT:NewNetwork(netid)
    if netid == 0 then
        self:TurnOff()
    end
end

function ENT:UpdateValues()

end