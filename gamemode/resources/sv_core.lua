TK.RD = TK.RD or {}
TK.RD.ent_table = {}
TK.RD.net_table = {}
TK.RD.res_table = {}
--/--- Client Sync ---\\\
util.AddNetworkString("TKRD_DNet")
util.AddNetworkString("TKRD_KNet")
util.AddNetworkString("TKRD_DEnt")
util.AddNetworkString("TKRD_KEnt")
util.AddNetworkString("TKRD_MEnt")

local function SendNet(ply, netid, netdata)
net.Start("TKRD_DNet")
net.WriteInt(netid, 16)
net.WriteTable(netdata)
net.Send(ply)
end

local function SendKillNet(netid)
net.Start("TKRD_KNet")
net.WriteInt(netid, 16)
net.Broadcast()
end

local function SendEnt(ply, entid, entdata)
net.Start("TKRD_DEnt")
net.WriteInt(entid, 16)
net.WriteTable(entdata)
net.Send(ply)
end

local function SendKillEnt(entid)
net.Start("TKRD_KEnt")
net.WriteInt(entid, 16)
net.Broadcast()
end

local function RequestData(ply, cmd, arg)
    if not IsValid(ply) then return end
    local plyid = ply:UserID()

    if arg[1] == "Net" then
        local netid = tonumber(arg[2])
        local netdata = TK.RD.net_table[netid]
        if not netdata then return end
        if netdata.update[plyid] then return end
        SendNet(ply, netid, netdata)
        netdata.update[plyid] = true
    elseif arg[1] == "Ent" then
        local entid = tonumber(arg[2])
        local entdata = TK.RD.ent_table[entid]
        if not entdata then return end
        if entdata.update[plyid] then return end
        SendEnt(ply, entid, entdata)
        entdata.update[plyid] = true
    end
end

concommand.Add("TKRD_RequestData", RequestData)

--/--- ---\\\
--/--- Register Entities ---\\\
local function RegisterEnt(ent)
    local entid = ent:EntIndex()
    if TK.RD.ent_table[entid] and TK.RD.ent_table[entid].ent == ent then return end

    TK.RD.ent_table[entid] = {
        netid = 0,
        powergrid = 0,
        resources = {},
        data = {},
        update = {},
        ent = ent
    }
end

local function RegisterNet(node)
    local netid = table.insert(TK.RD.net_table, {
        powergrid = 0,
        resources = {},
        entities = {},
        update = {},
        node = node
    })

    node:SetNetID(netid)
    node.netdata = TK.RD.net_table[netid]
end

function TK.RD:Register(ent)
    if not IsValid(ent) then return end
    ent.IsTKRD = true

    if ent:GetClass() == "rd_node" then
        RegisterNet(ent)
        ent.IsNode = true
    else
        RegisterEnt(ent)
    end
end

function TK.RD:RemoveEnt(ent)
    ent:Unlink()
    SendKillEnt(ent:EntIndex())
    self.ent_table[ent:EntIndex()] = nil
end

function TK.RD:RemoveNet(ent)
    ent:Unlink()
    SendKillNet(ent:GetNetID())
    self.net_table[ent.netid] = nil
end

concommand.Add("TKRD_EntCmd", function(ply, cmd, arg)
    local ent = Entity(tonumber(arg[1]))
    if not IsValid(ent) or not ent.IsTKRD then return end
    if not ent:CPPICanUse(ply) then return end
    local command, arguments = "", {}

    for k, v in ipairs(arg) do
        if k == 2 then
            command = v
        else
            table.insert(arguments, v)
        end
    end

    ent:DoCommand(ply, command, arguments)
end)

--/--- ---\\\
--/--- Functions ---\\\
local function ValidAmount(amt)
    amt = math.floor(amt or 0)

    return amt < 0 and 0 or amt
end

function TK.RD:AddResource(idx, name)
    idx = tostring(idx)
    name = tostring(name) or idx
    self.res_table[idx] = name
    util.AddNetworkString(idx)
end

function TK.RD:SetPower(ent, power)
    if not ent.IsTKRD or ent.IsNode then return end
    power = tonumber(power or 0)
    local entdata = self.ent_table[ent:EntIndex()]
    local prepower = entdata.powergrid
    if prepower == power then return end
    entdata.powergrid = power
    entdata.update = {}
    if entdata.netid == 0 then return end
    local netdata = self.net_table[entdata.netid]
    netdata.powergrid = netdata.powergrid + entdata.powergrid - prepower
    netdata.update = {}
end

function TK.RD:IsLinked(ent)
    if not ent.IsTKRD then return false end
    local entdata = self.ent_table[ent:EntIndex()]

    return entdata.netid > 0
end

function TK.RD:Link(ent, netid)
    if not ent.IsTKRD or ent.IsNode then return false end
    local entdata = self.ent_table[ent:EntIndex()]
    local netdata = self.net_table[netid]
    if entdata.netid == netid then return false end
    if not netdata then return false end
    self:Unlink(ent, true)
    netdata.powergrid = netdata.powergrid + entdata.powergrid

    for k, v in pairs(entdata.resources) do
        if v.max > 0 then
            netdata.resources[k] = netdata.resources[k] or {
                cur = 0,
                max = 0
            }

            netdata.resources[k].cur = netdata.resources[k].cur + v.cur
            netdata.resources[k].max = netdata.resources[k].max + v.max
        end
    end

    local idx = 0

    for k, v in pairs(netdata.entities) do
        idx = k > idx and k or idx
    end

    table.insert(netdata.entities, idx + 1, ent)
    entdata.netid = netid
    entdata.update = {}
    netdata.update = {}
    local valid, info = pcall(ent.NewNetwork, ent, netid)

    if not valid then
        print(info)
    end

    return true
end

function TK.RD:Unlink(ent, relink)
    if not ent.IsTKRD then return false end

    if ent.IsNode then
        for k, v in pairs(ent.netdata.entities) do
            self:Unlink(v)
        end

        entlist = nil
    else
        local entdata = self.ent_table[ent:EntIndex()]
        if entdata.netid == 0 then return false end
        local netdata = self.net_table[entdata.netid]
        if not netdata then return false end
        netdata.powergrid = netdata.powergrid - entdata.powergrid

        for k, v in pairs(entdata.resources) do
            if v.max > 0 then
                netdata.resources[k].cur = netdata.resources[k].cur - v.cur
                netdata.resources[k].max = netdata.resources[k].max - v.max

                if netdata.resources[k].max == 0 then
                    netdata.resources[k] = nil
                end
            end
        end

        for k, v in pairs(netdata.entities) do
            if v == ent then
                netdata.entities[k] = nil
                break
            end
        end

        entdata.netid = 0
        entdata.update = {}
        netdata.update = {}

        if not relink then
            local valid, info = pcall(ent.NewNetwork, ent, 0)

            if not valid then
                print(info)
            end
        end
    end

    return true
end

function TK.RD:EntAddResource(ent, idx, max, gen)
    if not ent.IsTKRD then return false end
    local entdata = self.ent_table[ent:EntIndex()]
    max = ValidAmount(max)
    if entdata.resources[idx] and entdata.resources[idx].max == max then return false end

    if entdata.netid ~= 0 then
        local netid = entdata.netid
        local netdata = self.net_table[netid]

        if entdata.resources[idx] then
            local diff = max - entdata.resources[idx].max

            if entdata.resources[idx].cur > max then
                local left = entdata.resources[idx].cur - max
                entdata.resources[idx].cur = max
                entdata.resources[idx].max = max
                entdata.resources[idx].gen = tobool(gen)

                if not netdata.resources[idx] then
                    netdata.resources[idx] = {}
                    netdata.resources[idx].cur = 0
                    netdata.resources[idx].max = 0
                end

                netdata.resources[idx].max = netdata.resources[idx].max + diff

                if netdata.resources[idx].cur > netdata.resources[idx].max then
                    netdata.resources[idx].cur = netdata.resources[idx].max
                else
                    TK.RD:NetSupplyResource(netid, idx, left)
                end
            else
                entdata.resources[idx].max = max
                entdata.resources[idx].gen = tobool(gen)

                if not netdata.resources[idx] then
                    netdata.resources[idx] = {}
                    netdata.resources[idx].cur = 0
                    netdata.resources[idx].max = 0
                end

                netdata.resources[idx].max = netdata.resources[idx].max + diff
            end
        else
            entdata.resources[idx] = {}
            entdata.resources[idx].cur = 0
            entdata.resources[idx].max = max
            entdata.resources[idx].gen = tobool(gen)

            if not netdata.resources[idx] then
                netdata.resources[idx] = {}
                netdata.resources[idx].cur = 0
                netdata.resources[idx].max = 0
            end

            netdata.resources[idx].max = netdata.resources[idx].max + max
        end

        netdata.update = {}
        entdata.update = {}
    else
        if entdata.resources[idx] then
            if entdata.resources[idx].cur > max then
                entdata.resources[idx].cur = max
                entdata.resources[idx].max = max
                entdata.resources[idx].gen = tobool(gen)
            else
                entdata.resources[idx].max = max
                entdata.resources[idx].gen = tobool(gen)
            end
        else
            entdata.resources[idx] = {}
            entdata.resources[idx].cur = 0
            entdata.resources[idx].max = max
            entdata.resources[idx].gen = tobool(gen)
        end

        entdata.update = {}
        ent:UpdateValues()
    end

    return true
end

function TK.RD:NetSupplyResource(netid, idx, amt)
    local netdata = self.net_table[netid]
    local iamt = ValidAmount(amt)
    if not netdata or iamt == 0 then return 0 end
    if not netdata.resources[idx] then return 0 end

    if netdata.resources[idx].cur + iamt > netdata.resources[idx].max then
        iamt = netdata.resources[idx].max - netdata.resources[idx].cur
        netdata.resources[idx].cur = netdata.resources[idx].max
        netdata.update = {}
    else
        netdata.resources[idx].cur = netdata.resources[idx].cur + iamt
        netdata.update = {}
    end

    local left = iamt

    for _, ent in SortedPairs(netdata.entities) do
        local entdata = self.ent_table[ent:EntIndex()]

        if entdata.resources[idx] and entdata.resources[idx].cur < entdata.resources[idx].max then
            if entdata.resources[idx].cur + left > entdata.resources[idx].max then
                left = left - (entdata.resources[idx].max - entdata.resources[idx].cur)
                entdata.resources[idx].cur = entdata.resources[idx].max
                entdata.update = {}
            else
                entdata.resources[idx].cur = entdata.resources[idx].cur + left
                entdata.update = {}
                left = 0
                break
            end
        end
    end

    return iamt
end

function TK.RD:EntSupplyResource(ent, idx, amt)
    if not ent.IsTKRD then return 0 end
    local iamt = ValidAmount(amt)
    if iamt == 0 then return 0 end
    local entdata = self.ent_table[ent:EntIndex()]

    if entdata.netid ~= 0 then
        iamt = self:NetSupplyResource(entdata.netid, idx, iamt)
    else
        if not entdata.resources[idx] then return 0 end

        if entdata.resources[idx].cur + iamt > entdata.resources[idx].max then
            iamt = entdata.resources[idx].max - entdata.resources[idx].cur
            entdata.resources[idx].cur = entdata.resources[idx].max
        else
            entdata.resources[idx].cur = entdata.resources[idx].cur + iamt
        end

        entdata.update = {}
        ent:UpdateValues()
    end

    return iamt
end

function TK.RD:NetConsumeResource(netid, idx, amt)
    local netdata = self.net_table[netid]
    local iamt = ValidAmount(amt)
    if not netdata or iamt == 0 then return 0 end
    if not netdata.resources[idx] then return 0 end

    if iamt > netdata.resources[idx].cur then
        iamt = netdata.resources[idx].cur
        netdata.resources[idx].cur = 0
        netdata.update = {}
    else
        netdata.resources[idx].cur = netdata.resources[idx].cur - iamt
        netdata.update = {}
    end

    local left = iamt

    for _, ent in SortedPairs(netdata.entities, true) do
        local entdata = self.ent_table[ent:EntIndex()]

        if entdata.resources[idx] and entdata.resources[idx].cur > 0 then
            if left > entdata.resources[idx].cur then
                left = left - entdata.resources[idx].cur
                entdata.resources[idx].cur = 0
                entdata.update = {}
            else
                entdata.resources[idx].cur = entdata.resources[idx].cur - left
                entdata.update = {}
                left = 0
                break
            end
        end
    end

    if left ~= 0 then
        print("TKRD ERROR 2", netid, idx, left)
        PrintTable(netdata)
        print("---")
    end

    return iamt
end

function TK.RD:EntConsumeResource(ent, idx, amt)
    if not ent.IsTKRD then return 0 end
    local iamt = ValidAmount(amt)
    if iamt == 0 then return 0 end
    local entdata = self.ent_table[ent:EntIndex()]

    if entdata.netid ~= 0 then
        iamt = self:NetConsumeResource(entdata.netid, idx, iamt)
    else
        if not entdata.resources[idx] then return 0 end

        if iamt > entdata.resources[idx].cur then
            iamt = entdata.resources[idx].cur
            entdata.resources[idx].cur = 0
        else
            entdata.resources[idx].cur = entdata.resources[idx].cur - iamt
        end

        entdata.update = {}
        ent:UpdateValues()
    end

    return iamt
end

function TK.RD:GetNetPowerGrid(netid)
    local netdata = self.net_table[netid]
    if not netdata then return 0 end

    return netdata.powergrid or 0
end

function TK.RD:GetNetResourceAmount(netid, idx)
    local netdata = self.net_table[netid]
    if not netdata then return 0 end
    if not netdata.resources[idx] then return 0 end

    return netdata.resources[idx].cur
end

function TK.RD:GetEntPowerGrid(ent)
    local entdata = self.ent_table[ent:EntIndex()]

    if entdata.netid ~= 0 then
        local netdata = self.net_table[entdata.netid]

        return netdata.powergrid or 0
    else
        return entdata.powergrid or 0
    end
end

function TK.RD:GetEntResourceAmount(ent, idx)
    if not ent.IsTKRD then return 0 end
    local entdata = self.ent_table[ent:EntIndex()]

    if entdata.netid ~= 0 then
        local netdata = self.net_table[entdata.netid]
        if not netdata.resources[idx] then return 0 end

        return netdata.resources[idx].cur
    else
        if not entdata.resources[idx] then return 0 end

        return entdata.resources[idx].cur
    end
end

function TK.RD:GetUnitPowerGrid(ent)
    if not ent.IsTKRD then return 0 end
    local entdata = self.ent_table[ent:EntIndex()]

    return entdata.powergrid or 0
end

function TK.RD:GetUnitResourceAmount(ent, idx)
    if not ent.IsTKRD then return 0 end
    local entdata = self.ent_table[ent:EntIndex()]
    if not entdata.resources[idx] then return 0 end

    return entdata.resources[idx].cur
end

function TK.RD:GetNetResourceCapacity(netid, idx)
    local netdata = self.net_table[netid]
    if not netdata then return 0 end
    if not netdata.resources[idx] then return 0 end

    return netdata.resources[idx].max
end

function TK.RD:GetEntResourceCapacity(ent, idx)
    if not ent.IsTKRD then return 0 end
    local entdata = self.ent_table[ent:EntIndex()]

    if entdata.netid ~= 0 then
        local netdata = self.net_table[entdata.netid]
        if not netdata.resources[idx] then return 0 end

        return netdata.resources[idx].max
    else
        if not entdata.resources[idx] then return 0 end

        return entdata.resources[idx].max
    end
end

function TK.RD:GetUnitResourceCapacity(ent, idx)
    if not ent.IsTKRD then return 0 end
    local entdata = self.ent_table[ent:EntIndex()]
    if not entdata.resources[idx] then return 0 end

    return entdata.resources[idx].max
end

function TK.RD:GetConnectedEnts(netid)
    local netdata = self.net_table[netid]

    return netdata.entities or {}
end

function TK.RD:GetNetTable(netid)
    return self.net_table[netid] or {}
end

function TK.RD:GetEntTable(entid)
    return self.ent_table[entid] or {}
end

function TK.RD:GetResources()
    local resources = {}

    for k, v in pairs(self.res_table) do
        table.insert(resources, k)
    end

    return resources
end

function TK.RD:IsResource(str)
    return tobool(self.res_table[str])
end

function TK.RD:GetResourceName(idx)
    return self.res_table[idx] or idx
end

--/--- ---\\\
--/--- Vehicles ---\\\
hook.Add("PlayerSpawnedVehicle", "TKRD", function(ply, ent)
    ent.data = {}
    ent.data.kilowatt = 0

    function ent:Work()
        if self:GetUnitPowerGrid() ~= self.data.kilowatt then
            self:SetPower(self.data.kilowatt)

            return false
        end

        return true
    end

    function ent:DoThink(eff)
        ply = self:GetDriver()
        self.data.kilowatt = IsValid(ply) and -1 or 0
        if not self:Work() then return end
        if not IsValid(ply) then return end
        if not ply.tk_hev then return end

        if ply.tk_hev.energy < ply.tk_hev.energymax then
            ply:AddhevRes("energy", 5 * eff)
        end

        if ply.tk_hev.water < ply.tk_hev.watermax then
            ply:AddhevRes("water", self:ConsumeResource("water", 5) * eff)
        end

        if ply.tk_hev.oxygen < ply.tk_hev.oxygenmax then
            ply:AddhevRes("oxygen", self:ConsumeResource("oxygen", 5) * eff)
        end
    end

    function ent:DoPostThink()
    end

    function ent:NewNetwork(netid)
    end

    function ent:UpdateValues()
    end

    function ent:SetPower(kilowatt)
        return TK.RD:SetPower(self, kilowatt)
    end

    function ent:AddResource(idx, max, gen)
        return TK.RD:EntAddResource(self, idx, max, gen)
    end

    function ent:IsLinked()
        return TK.RD:IsLinked(self)
    end

    function ent:Link(netid)
        return TK.RD:Link(self, netid)
    end

    function ent:Unlink()
        return TK.RD:Unlink(self)
    end

    function ent:GetEntTable()
        return TK.RD:GetEntTable(self:EntIndex())
    end

    function ent:SupplyResource(idx, amt)
        return TK.RD:EntSupplyResource(self, idx, amt)
    end

    function ent:ConsumeResource(idx, amt)
        return TK.RD:EntConsumeResource(self, idx, amt)
    end

    function ent:GetPowerGrid()
        return TK.RD:GetEntPowerGrid(self)
    end

    function ent:GetResourceAmount(idx)
        return TK.RD:GetEntResourceAmount(self, idx)
    end

    function ent:GetUnitPowerGrid()
        return TK.RD:GetUnitPowerGrid(self)
    end

    function ent:GetUnitResourceAmount(idx)
        return TK.RD:GetUnitResourceAmount(self, idx)
    end

    function ent:GetResourceCapacity(idx)
        return TK.RD:GetEntResourceCapacity(self, idx)
    end

    function ent:GetUnitResourceCapacity(idx)
        return TK.RD:GetUnitResourceCapacity(self, idx)
    end

    TK.RD:Register(ent)
end)
--/--- ---\\\
