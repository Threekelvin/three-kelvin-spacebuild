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
    self.Outputs = WireLib.CreateOutputs(self, {"On",  "Name [STRING]",  "Temperature",  "Gravity",  "Resources [TABLE]"})
end

function ENT:TurnOn()
    if self:GetActive() or not self:IsLinked() then return end
    self:SetActive(true)
    WireLib.TriggerOutput(self, "On", 1)
end

function ENT:TurnOff()
    if not self:GetActive() then return end
    self:SetActive(false)
    WireLib.TriggerOutput(self, "On", 0)
    WireLib.TriggerOutput(self, "Name", "")
    WireLib.TriggerOutput(self, "Temperature", 0)
    WireLib.TriggerOutput(self, "Gravity", 0)

    WireLib.TriggerOutput(self, "Resources", {
        n = {},
        ntypes = {},
        s = {},
        stypes = {},
        size = 0
    })
end

function ENT:TriggerInput(iname, value)
    if iname == "On" then
        if value ~= 0 then
            self:TurnOn()
        else
            self:TurnOff()
        end
    end
end

function ENT:DoThink(eff)
    if not self:GetActive() then return end
    if not self:Work() then return end
    eff = eff == 1
    local env = self:GetEnv()
    local entdata = self:GetEntTable()

    if entdata.data.id ~= env.atmosphere.name then
        entdata.data.id = env.atmosphere.name
        WireLib.TriggerOutput(self, "Name", env.atmosphere.name)
        entdata.update = {}
    end

    local temp = eff and env:DoTemp(self) or 0

    if entdata.data.temp ~= temp then
        entdata.data.temp = temp
        WireLib.TriggerOutput(self, "Temperature", temp)
        entdata.update = {}
    end

    local gravity = eff and env.atmosphere.gravity or 0

    if entdata.data.gravity ~= gravity then
        entdata.data.gravity = gravity
        WireLib.TriggerOutput(self, "Gravity", temp)
        entdata.update = {}
    end

    local data = {
        n = {},
        ntypes = {},
        s = {},
        stypes = {},
        size = 0
    }

    local size, update = 0, false

    for k, v in pairs(env.atmosphere.resources) do
        local val = eff and v or 0

        if not entdata.data.resources[k] or entdata.data.resources[k] ~= val then
            entdata.data.resources[k] = val
            entdata.update = {}
            update = true
        end

        data.s[k] = val
        data.stypes[k] = "n"
        size = size + 1
    end

    if update then
        data.size = size
        WireLib.TriggerOutput(self, "Resources", data)
    end

    for k, v in pairs(entdata.data.resources) do
        if not env.atmosphere.resources[k] then
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
