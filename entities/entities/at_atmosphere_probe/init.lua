
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include("shared.lua")

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    local entdata = self:GetEntTable()
    entdata.data.id = "Space"
    entdata.data.temp = 3
    entdata.data.gravity = 0
    entdata.data.oxygen = 0
    entdata.data.carbon_dioxide = 0
    entdata.data.nitrogen = 0
    entdata.data.hydrogen = 0
    entdata.update = {}
    
    self.Inputs = WireLib.CreateInputs(self, {"On"})
    self.Outputs = WireLib.CreateOutputs(self, {"On"})
end

function ENT:TurnOn()
    if self.IsActive || !self:IsLinked() then return end
    self:SetActive(true)
    WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
    if !self.IsActive then return end
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

function ENT:DoThink()
    if !self.IsActive then return end
    if self:GetResourceAmount("energy") < 100 then self:TurnOff() return end
    self:ConsumeResource("energy", 100)
    
    local env = self:GetEnv()
    local entdata = self:GetEntTable()
    
    if entdata.data.id != env.atmosphere.name then
        entdata.data.id = env.atmosphere.name
        entdata.update = {}
    end
    
    local temp = env:DoTemp(self)
    if entdata.data.temp != temp then
        entdata.data.temp = temp
        entdata.update = {}
    end
    
    if entdata.data.gravity != env.atmosphere.gravity then
        entdata.data.gravity = env.atmosphere.gravity
        entdata.update = {}
    end
    
    local oxygen = math.Round(env:GetTrueAtmospherePercent("oxygen"), 3)
    if entdata.data.oxygen != oxygen then
        entdata.data.oxygen = oxygen
        entdata.update = {}
    end
    
    local carbon_dioxide = math.Round(env:GetTrueAtmospherePercent("carbon_dioxide"), 3)
    if entdata.data.carbon_dioxide != carbon_dioxide then
        entdata.data.carbon_dioxide = carbon_dioxide
        entdata.update = {}
    end
    
    local nitrogen = math.Round(env:GetTrueAtmospherePercent("nitrogen"), 3)
    if entdata.data.nitrogen != nitrogen then
        entdata.data.nitrogen = nitrogen
        entdata.update = {}
    end
    
    local hydrogen = math.Round(env:GetTrueAtmospherePercent("hydrogen"), 3)
    if entdata.data.hydrogen != hydrogen then
        entdata.data.hydrogen = hydrogen
        entdata.update = {}
    end
end

function ENT:NewNetwork(netid)
    if netid == 0 then
        self:TurnOff()
    end
end

function ENT:UpdateValues()

end