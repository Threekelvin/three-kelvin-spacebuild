AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    
    self.Storage = {}

    self:SetNWBool("Generator", true)
    self:AddResource("raw_tiberium", 0)
    
    WireLib.CreateInputs(self, {"On"})
    WireLib.CreateOutputs(self, {"On", "raw_tiberium", "Max raw_tiberium"})
    self:UpdateValues()
end

function ENT:Slot1Pos()
    return self:LocalToWorld(self:OBBCenter() + Vector(10, 18.5, 10))
end

function ENT:Slot2Pos()
    return self:LocalToWorld(self:OBBCenter() + Vector(10, -18.5, 10))
end

function ENT:AddStorage(ent)
    if !IsValid(ent) || IsValid(ent:GetParent()) then return end
    if IsValid(self.Storage.Slot1) && IsValid(self.Storage.Slot2) then return end
    local net = self:GetEntTable().netid
    
    if ((ent:GetPos() - self:Slot1Pos()):LengthSqr() < (ent:GetPos() - self:Slot2Pos()):LengthSqr() && !IsValid(self.Storage.Slot1)) || IsValid(self.Storage.Slot2) then
        self.Storage.Slot1 = ent
        constraint.RemoveAll(ent)
        ent:SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
        ent:SetPos(self:Slot1Pos())
        ent:SetAngles(self:GetAngles())
        constraint.Weld(ent, self, 0, 0, 0, true)
        local phys = ent:GetPhysicsObject()
        if phys:IsValid() then
            phys:SetMass(100)
            phys:EnableMotion(true)
            phys:Wake()
        end
        ent:SetParent(self)
        
        if net && net != 0 then
            ent:Link(net)
        end
    else
        self.Storage.Slot2 = ent
        constraint.RemoveAll(ent)
        ent:SetCollisionGroup(COLLISION_GROUP_PUSHAWAY)
        ent:SetPos(self:Slot2Pos())
        ent:SetAngles(self:GetAngles())
        constraint.Weld(ent, self, 0, 0, 0, true)
        local phys = ent:GetPhysicsObject()
        if phys:IsValid() then
            phys:SetMass(100)
            phys:EnableMotion(true)
            phys:Wake()
        end
        ent:SetParent(self)
        
        if net && net != 0 then
            ent:Link(net)
        end
    end
end

function ENT:RemoveStorage()
    if IsValid(self.Storage.Slot1) then
        local ent = self.Storage.Slot1
        ent:SetParent(nil)
        constraint.RemoveAll(ent)
        ent:SetCollisionGroup(COLLISION_GROUP_NONE)
        local phys = ent:GetPhysicsObject()
        if phys:IsValid() then
            phys:SetMass(1000)
            phys:EnableMotion(true)
            phys:Wake()
        end
        ent:SetPos(self:Slot1Pos())
        ent:SetAngles(self:GetAngles())
        ent:Unlink()
        self.Storage.Slot1 = nil
    end
    
    if IsValid(self.Storage.Slot2) then
        local ent = self.Storage.Slot2
        ent:SetParent(nil)
        constraint.RemoveAll(ent)
        ent:SetCollisionGroup(COLLISION_GROUP_NONE)
        local phys = ent:GetPhysicsObject()
        if phys:IsValid() then
            phys:SetMass(1000)
            phys:EnableMotion(true)
            phys:Wake()
        end
        ent:SetPos(self:Slot2Pos())
        ent:SetAngles(self:GetAngles())
        ent:Unlink()
        self.Storage.Slot2 = nil
    end
end

function ENT:TurnOn()
    if !self:GetActive() then
        self:SetActive(true)
        WireLib.TriggerOutput(self, "On", 1)
    end
end

function ENT:TurnOff()
    if self:GetActive() then
        self:SetActive(false)
        WireLib.TriggerOutput(self, "On", 0)
        
        self:RemoveStorage()
    end
end

function ENT:TriggerInput(iname, value)
    if iname == "On" then
        if value != 0  then
            self:TurnOn()
        else
            self:TurnOff()
        end
    end
end

function ENT:Touch(ent)
    if !IsValid(ent) then return end
    if !self:GetActive() || ent:GetClass() != "tk_tib_storage" then return end
    if !self:CPPICanUse(ent:CPPIGetOwner()) then return end
    self:AddStorage(ent)
end

function ENT:DoThink()
    if !self:GetActive() then return end
    if IsValid(self.Storage.Slot1) && IsValid(self.Storage.Slot2) then return end
    
    local owner = self:CPPIGetOwner()
    for k,v in pairs(ents.FindByClass("tk_tib_storage")) do
        if self:LocalToWorld(self:OBBCenter()):Distance(v:LocalToWorld(v:OBBCenter())) < self:BoundingRadius() then
            if !self:CPPICanUse(v:CPPIGetOwner()) then continue end
            self:AddStorage(v)
        end
    end
end


function ENT:UpdateValues()
    WireLib.TriggerOutput(self, "raw_tiberium", self:GetResourceAmount("raw_tiberium"))
    WireLib.TriggerOutput(self, "Max raw_tiberium", self:GetResourceCapacity("raw_tiberium"))
end

function ENT:NewNetwork(netid)
    if IsValid(self.Storage.Slot1) then
        self.Storage.Slot1:Link(netid)
    end
    
    if IsValid(self.Storage.Slot2) then
        self.Storage.Slot2:Link(netid)
    end
    
    self:UpdateValues()
end

function ENT:PreEntityCopy()
    local info = {}
    info = table.Copy(self.Storage)
    for k,v in pairs(info) do
        if IsValid(v) then
            info[k] = v:EntIndex()
        else
            info[k] = nil
        end
    end
    duplicator.StoreEntityModifier(self, "TKTibHolder", info)
end

function ENT:PostEntityPaste(Player, Ent, CreatedEntities)
    if Ent.EntityMods && Ent.EntityMods.TKTibHolder then
        self.Storage = {}
        for k,v in pairs(Ent.EntityMods.TKTibHolder) do
            self.Storage[k] = CreatedEntities[v]
        end
        
        for k,v in pairs(self.Storage) do
            if IsValid(v) then
                self:TurnOn()
                break
            end
        end
    end
end