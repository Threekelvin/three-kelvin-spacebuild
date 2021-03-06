AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
    self.BaseClass.Initialize(self)
    self:SetRange(self.data.range)
end

function ENT:DoMenu(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    net.Start("TKRD_MEnt")
    net.WriteEntity(self)
    net.Send(ply)
end

function ENT:DoCommand(ply, cmd, arg)
end

function ENT:SetNetID(netid)
    self:SetNWInt("NetID", netid)
    self.netid = netid
end

function ENT:SetRange(val)
    self:SetNWInt("Range", val)
    self.range = val
    self.rangesqr = val * val
end

function ENT:GetNetTable()
    return self.netdata
end

function ENT:Unlink()
    return TK.RD:Unlink(self)
end

function ENT:SupplyResource(idx, amt)
    return TK.RD:NetSupplyResource(self.netid, idx, amt)
end

function ENT:ConsumeResource(idx, amt)
    return TK.RD:NetConsumeResource(self.netid, idx, amt)
end

function ENT:GetPowerGrid()
    return TK.RD:GetNetPowerGrid(self.netid)
end

function ENT:GetResourceAmount(idx)
    return TK.RD:GetNetResourceAmount(self.netid, idx)
end

function ENT:GetUnitPowerGrid()
    return 0
end

function ENT:GetUnitResourceAmount(idx)
    return 0
end

function ENT:GetResourceCapacity(idx)
    return TK.RD:GetNetResourceCapacity(self.netid, idx)
end

function ENT:GetUnitResourceCapacity(idx)
    return 0
end

function ENT:Think()
    local produce, consume = 1, 1

    for k, v in pairs(self.netdata.entities) do
        if not IsValid(v) then
            self.netdata.entities[k] = nil
            continue
        end

        if (v:GetPos() - self:GetPos()):LengthSqr() > self.rangesqr then
            v:Unlink()
            v:SoundPlay(0)
        else
            local kilowatt = v:GetUnitPowerGrid()

            if kilowatt > 0 then
                produce = produce + kilowatt
            else
                consume = consume - kilowatt
            end
        end
    end

    local efficiency = produce == 1 and 0 or math.min((produce / consume) ^ 2, 1)

    for k, v in pairs(self.netdata.entities) do
        local valid, info = pcall(v.DoThink, v, efficiency)

        if not valid then
            print(info)
        end
    end

    for k, v in pairs(self.netdata.entities) do
        local valid, info = pcall(v.DoPostThink, v)

        if not valid then
            print(info)
        end
    end

    if not self.netdata.update.network then
        self.netdata.update.network = true

        for k, v in pairs(self.netdata.entities) do
            local valid, info = pcall(v.UpdateValues, v)

            if not valid then
                print(info)
            end
        end
    end

    self:NextThink(CurTime() + 1)

    return true
end

function ENT:OnRemove()
    TK.RD:RemoveNet(self)
end

function ENT:Use()
end

function ENT:SetActive(val)
end

function ENT:TurnOn()
end

function ENT:TurnOff()
end

function ENT:Work()
end

function ENT:PreEntityCopy()
    local info = {}

    for k, v in pairs(self.netdata.entities) do
        table.insert(info, v:EntIndex())
    end

    if table.Count(info) == 0 then return end
    duplicator.StoreEntityModifier(self, "TKRDInfo", info)
end

function ENT:PostEntityPaste(ply, ent, entlist)
    if not self.EntityMods or not self.EntityMods.TKRDInfo then return end
    local TKRDInfo = self.EntityMods.TKRDInfo

    for k, v in ipairs(TKRDInfo or {}) do
        local ent2 = entlist[v]

        if IsValid(ent2) and ent2.IsTKRD then
            ent2:Link(self.netid)
        end
    end

    self.EntityMods.TKRDInfo = nil
end
