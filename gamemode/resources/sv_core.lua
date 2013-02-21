
TK.RD = {}
TK.RD.EntityData = {}
local ent_table = {}
local net_table = {}
local res_table = {}

///--- Client Sync ---\\\
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
    if !IsValid(ply) then return end
    local plyid = ply:UserID()
    
    if arg[1] == "Net" then
        local netid = tonumber(arg[2])
        local netdata = net_table[netid]
        if !netdata then return end
        if netdata.update[plyid] then return end
        SendNet(ply, netid, netdata)
        netdata.update[plyid] = true
    elseif arg[1] == "Ent" then
        local entid = tonumber(arg[2])
        local entdata = ent_table[entid]
        if !entdata then return end
        if entdata.update[plyid] then return end
        SendEnt(ply, entid, entdata)
        entdata.update[plyid] = true
    end
end

concommand.Add("TKRD_RequestData", RequestData)
///--- ---\\\

///--- Register Entities ---\\\
local function RegisterEnt(ent)
    if !IsValid(ent) then return end
    local entid = ent:EntIndex()
    if ent_table[entid] && ent_table[entid].ent == ent then return end
    ent_table[entid] = {
        netid = 0,
        powergrid = 0,
        res = {},
        data = {},
        update = {},
        ent = ent
    }
end

local function RegisterNet(node)
    if !IsValid(node) then return end
    local netid = table.insert(net_table, {
        powergrid = 0,
        res = {},
        entities = {},
        update = {},
        node = node
    })
    
    node:SetNetID(netid)
    node.netdata = net_table[netid]
end

function TK.RD:Register(ent, node)
    if !IsValid(ent) then return end
    ent.IsTKRD = true
    
    if node then
        RegisterNet(ent)
        ent.IsNode = true
    else
        RegisterEnt(ent)
    end
    
    if self.EntityData[ent:GetClass()] then
        ent.data = self.EntityData[ent:GetClass()][ent:GetModel()] || {}
    end
end

function TK.RD:RemoveEnt(ent)
    if !IsValid(ent) then return end
    ent:Unlink()
    SendKillEnt(ent:EntIndex())
    ent_table[ent:EntIndex()] = nil
end

function TK.RD:RemoveNet(ent)
    if !IsValid(ent) then return end
    ent:Unlink()
    SendKillNet(ent:GetNetID())
    net_table[ent.netid] = nil
end

concommand.Add("TKRD_EntCmd", function(ply, cmd, arg)
    local ent = Entity(tonumber(arg[1]))
    if !IsValid(ent) || !ent.IsTKRD then return end
    if !ent:CPPICanUse(ply) then return end
    local command, arguments = "", {}
    for k,v in ipairs(arg) do
        if k == 1 then
        
        elseif k == 2 then
            command = v
        else
            table.insert(arguments, v)
        end
    end
    
    ent:DoCommand(ply, command, arguments)
end)
///--- ---\\\

///--- Functions ---\\\
local function ValidAmount(amt)
    amt = math.floor(amt || 0)
    return amt < 0 && 0 || amt
end

function TK.RD:AddResource(idx, name)
    idx = tostring(idx)
    name = tostring(name) || idx
    res_table[idx] = name
    util.AddNetworkString(idx)
end

function TK.RD:SetPower(ent, power)
    if !IsValid(ent) then return end
    if !ent.IsTKRD || ent.IsNode then return end
    power = tonumber(power || 0)
    local entdata = ent_table[ent:EntIndex()]
    local prepower = entdata.powergrid
    if prepower == power then return end
    entdata.powergrid = power
    entdata.update = {}

    if entdata.netid == 0 then return end
    local netdata = net_table[entdata.netid]
    netdata.powergrid = netdata.powergrid + entdata.powergrid - prepower
    netdata.update = {}
end

function TK.RD:IsLinked(ent)
    if !IsValid(ent) || !ent.IsTKRD then return false end
    local entdata = ent_table[ent:EntIndex()]
    return entdata.netid > 0
end

function TK.RD:Link(ent, netid)
    if !IsValid(ent) then return false end
    if !ent.IsTKRD || ent.IsNode then return false end
    local entdata = ent_table[ent:EntIndex()]
    local netdata = net_table[netid]
    if entdata.netid == netid then return false end
    if !netdata then return false end
    
    self:Unlink(ent, true)
    
    netdata.powergrid = netdata.powergrid + entdata.powergrid
    
    for k,v in pairs(entdata.res) do
        if v.max > 0 then
            netdata.res[k] = netdata.res[k] || {cur = 0, max = 0}
            netdata.res[k].cur = netdata.res[k].cur + v.cur
            netdata.res[k].max = netdata.res[k].max + v.max
        end
    end
    
    table.insert(netdata.entities, ent)
    entdata.netid = netid
    entdata.update = {}
    netdata.update = {}
    local valid, info = pcall(ent.NewNetwork, ent, netid)
    if !valid then print(info) end
    return true
end

function TK.RD:Unlink(ent, relink)
    if !IsValid(ent) || !ent.IsTKRD then return false end
    if ent.IsNode then
        local entlist = table.Copy(ent.netdata.entities)
        for k,v in ipairs(entlist) do
            self:Unlink(v)
        end
        entlist = nil
    else
        local entdata = ent_table[ent:EntIndex()]
        if entdata.netid == 0 then return false end
        local netdata = net_table[entdata.netid]
        if !netdata then return false end
        
        netdata.powergrid = netdata.powergrid - entdata.powergrid
        
        for k,v in pairs(entdata.res) do
            if v.max > 0 then
                netdata.res[k].cur = netdata.res[k].cur - v.cur
                netdata.res[k].max = netdata.res[k].max - v.max
                if netdata.res[k].max == 0 then
                    netdata.res[k] = nil
                end
            end
        end

        for k,v in ipairs(netdata.entities) do
            if v == ent then
                table.remove(netdata.entities, k)
                break
            end
        end

        entdata.netid = 0
        entdata.update = {}
        netdata.update = {}
        
        if !relink then
            local valid, info = pcall(ent.NewNetwork, ent, 0)
            if !valid then print(info) end
        end
    end
    return true
end

function TK.RD:EntAddResource(ent, idx, max, gen)
    if !IsValid(ent) || !ent.IsTKRD then return false end
    local entdata = ent_table[ent:EntIndex()]
    max = ValidAmount(max)
    if entdata.res[idx] && entdata.res[idx].max == max then return false end
    
    if entdata.netid != 0 then
        local netid = entdata.netid
        local netdata = net_table[netid]
        if entdata.res[idx] then
            local diff = max - entdata.res[idx].max
            if entdata.res[idx].cur > max then
                local left = entdata.res[idx].cur - max
                entdata.res[idx].cur = max
                entdata.res[idx].max = max
                entdata.res[idx].gen = tobool(gen)
                
                if !netdata.res[idx] then
                    netdata.res[idx] = {}
                    netdata.res[idx].cur = 0
                    netdata.res[idx].max = 0
                end
                
                netdata.res[idx].max = netdata.res[idx].max + diff
                if netdata.res[idx].cur > netdata.res[idx].max then
                    netdata.res[idx].cur = netdata.res[idx].max
                else
                    TK.RD:NetSupplyResource(netid, idx, left)
                end
            else
                entdata.res[idx].max = max
                entdata.res[idx].gen = tobool(gen)
                
                if !netdata.res[idx] then
                    netdata.res[idx] = {}
                    netdata.res[idx].cur = 0
                    netdata.res[idx].max = 0
                end
                
                netdata.res[idx].max = netdata.res[idx].max + diff
            end
        else
            entdata.res[idx] = {}
            entdata.res[idx].cur = 0
            entdata.res[idx].max = max
            entdata.res[idx].gen = tobool(gen)
            
            if !netdata.res[idx] then
                netdata.res[idx] = {}
                netdata.res[idx].cur = 0
                netdata.res[idx].max = 0
            end
            
            netdata.res[idx].max = netdata.res[idx].max + max
        end
        
        netdata.update = {}
        entdata.update = {}
    else
        if entdata.res[idx] then
            if entdata.res[idx].cur > max then
                entdata.res[idx].cur = max
                entdata.res[idx].max = max
                entdata.res[idx].gen = tobool(gen)
            else
                entdata.res[idx].max = max
                entdata.res[idx].gen = tobool(gen)
            end
        else
            entdata.res[idx] = {}
            entdata.res[idx].cur = 0
            entdata.res[idx].max = max
            entdata.res[idx].gen = tobool(gen)
        end
        
        entdata.update = {}
        ent:UpdateValues()
    end
    
    return true
end

function TK.RD:NetSupplyResource(netid, idx, amt)
    local netdata = net_table[netid]
    local iamt = ValidAmount(amt)
    if !netdata || iamt == 0 then return 0 end
    if !netdata.res[idx] then return 0 end
    
    if netdata.res[idx].cur + iamt > netdata.res[idx].max then
        iamt = netdata.res[idx].max - netdata.res[idx].cur
        netdata.res[idx].cur = netdata.res[idx].max
        netdata.update = {}
    else
        netdata.res[idx].cur = netdata.res[idx].cur + iamt
        netdata.update = {}
    end
    
    local left = iamt
    for i = 1, #netdata.entities, 1 do
        local ent = netdata.entities[i]
        local entdata = ent_table[ent:EntIndex()]
        if entdata.res[idx] && entdata.res[idx].cur < entdata.res[idx].max then
            if entdata.res[idx].cur + left > entdata.res[idx].max then
                left = left - (entdata.res[idx].max - entdata.res[idx].cur)
                entdata.res[idx].cur = entdata.res[idx].max
                entdata.update = {}
            else
                entdata.res[idx].cur = entdata.res[idx].cur + left
                entdata.update = {}
                left = 0
                break
            end
        end
    end

    return iamt
end

function TK.RD:EntSupplyResource(ent, idx, amt)
    if !IsValid(ent) || !ent.IsTKRD then return 0 end
    local iamt = ValidAmount(amt)
    if iamt == 0 then return 0 end
    local entdata = ent_table[ent:EntIndex()]
    
    if entdata.netid != 0 then
        iamt = self:NetSupplyResource(entdata.netid, idx, iamt)
    else
        if !entdata.res[idx] then return 0 end
        if entdata.res[idx].cur + iamt > entdata.res[idx].max then
            iamt = entdata.res[idx].max - entdata.res[idx].cur
            entdata.res[idx].cur = entdata.res[idx].max
        else
            entdata.res[idx].cur = entdata.res[idx].cur + iamt
        end
        
        entdata.update = {}
        ent:UpdateValues()
    end
    
    return iamt
end

function TK.RD:NetConsumeResource(netid, idx, amt)
    local netdata = net_table[netid]
    local iamt = ValidAmount(amt)
    if !netdata || iamt == 0 then return 0 end
    if !netdata.res[idx] then return 0 end
    
    if iamt > netdata.res[idx].cur then
        iamt = netdata.res[idx].cur
        netdata.res[idx].cur = 0
        netdata.update = {}
    else
        netdata.res[idx].cur = netdata.res[idx].cur - iamt
        netdata.update = {}
    end
    
    local left = iamt
    for i = #netdata.entities, 1, -1 do
        local ent = netdata.entities[i]
        local entdata = ent_table[ent:EntIndex()]
        if entdata.res[idx] && entdata.res[idx].cur > 0 then
            if left > entdata.res[idx].cur then
                left = left - entdata.res[idx].cur
                entdata.res[idx].cur = 0
                entdata.update = {}
            else
                entdata.res[idx].cur = entdata.res[idx].cur - left
                entdata.update = {}
                left = 0
                break
            end
        end
    end
    
    if left != 0 then
        print("ARRD ERROR 2", netid, idx, left)
    end
    
    return iamt
end

function TK.RD:EntConsumeResource(ent, idx, amt)
    if !IsValid(ent) || !ent.IsTKRD then return 0 end
    local iamt = ValidAmount(amt)
    if iamt == 0 then return 0 end
    local entdata = ent_table[ent:EntIndex()]
    
    if entdata.netid != 0 then
        iamt = self:NetConsumeResource(entdata.netid, idx, iamt)
    else
        if !entdata.res[idx] then return 0 end
        if iamt > entdata.res[idx].cur then
            iamt = entdata.res[idx].cur
            entdata.res[idx].cur = 0
        else
            entdata.res[idx].cur = entdata.res[idx].cur - iamt
        end
        
        entdata.update = {}
        ent:UpdateValues()
    end
    
    return iamt
end

function TK.RD:GetNetPowerGrid(netid)
    local netdata = net_table[netid]
    if !netdata then return 0 end
    return netdata.powergrid || 0
end

function TK.RD:GetNetResourceAmount(netid, idx)
    local netdata = net_table[netid]
    if !netdata then return 0 end
    if !netdata.res[idx] then return 0 end
    return netdata.res[idx].cur
end

function TK.RD:GetEntPowerGrid(ent)
    if !IsValid(ent) then return 0 end
    local entdata = ent_table[ent:EntIndex()]
    if entdata.netid != 0 then
        local netdata = net_table[entdata.netid]
        return netdata.powergrid || 0
    else
        return entdata.powergrid || 0
    end
end

function TK.RD:GetEntResourceAmount(ent, idx)
    if !IsValid(ent) || !ent.IsTKRD then return 0 end
    local entdata = ent_table[ent:EntIndex()]
    if entdata.netid != 0 then
        local netdata = net_table[entdata.netid]
        if !netdata.res[idx] then return 0 end
        return netdata.res[idx].cur
    else
        if !entdata.res[idx] then return 0 end
        return entdata.res[idx].cur
    end
end

function TK.RD:GetUnitPowerGrid(ent)
    if !IsValid(ent) then return 0 end
    local entdata = ent_table[ent:EntIndex()]
    return entdata.powergrid || 0
end

function TK.RD:GetUnitResourceAmount(ent, idx)
    if !IsValid(ent) || !ent.IsTKRD then return 0 end
    local entdata = ent_table[ent:EntIndex()]
    if !entdata.res[idx] then return 0 end
    return entdata.res[idx].cur
end

function TK.RD:GetNetResourceCapacity(netid, idx)
    local netdata = net_table[netid]
    if !netdata then return 0 end
    if !netdata.res[idx] then return 0 end
    return netdata.res[idx].max
end

function TK.RD:GetEntResourceCapacity(ent, idx)
    if !IsValid(ent) || !ent.IsTKRD then return 0 end
    local entdata = ent_table[ent:EntIndex()]
    if entdata.netid != 0 then
        local netdata = net_table[entdata.netid]
        if !netdata.res[idx] then return 0 end
        return netdata.res[idx].max
    else
        if !entdata.res[idx] then return 0 end
        return entdata.res[idx].max
    end
end

function TK.RD:GetUnitResourceCapacity(ent, idx)
    if !IsValid(ent) || !ent.IsTKRD then return 0 end
    local entdata = ent_table[ent:EntIndex()]
    if !entdata.res[idx] then return 0 end
    return entdata.res[idx].max
end

function TK.RD:GetConnectedEnts(netid)
    local netdata = net_table[netid]
    return netdata.entities || {}
end

function TK.RD:GetNetTable(netid)
    return net_table[netid] || {}
end

function TK.RD:GetEntTable(entid)
    return ent_table[entid] || {}
end

function TK.RD:GetResources()
    local res = {}
    for k,v in pairs(res_table) do
        table.insert(res, k)
    end
    return res
end

function TK.RD:IsResource(str)
    return tobool(res_table[str])
end

function TK.RD:GetResourceName(idx)
    return res_table[idx] || idx
end
///--- ---\\\

///--- Resources ---\\\
hook.Add("Initialize", "TKRD", function()
    TK.RD:AddResource("oxygen", "Oxygen")
    TK.RD:AddResource("carbon_dioxide", "Carbon Dioxide")
    TK.RD:AddResource("nitrogen", "Nitrogen")
    TK.RD:AddResource("hydrogen", "Hydrogen")
    TK.RD:AddResource("liquid_nitrogen", "Liquid Nitrogen")
    TK.RD:AddResource("water", "Water")
    TK.RD:AddResource("asteroid_ore", "Asteroid Ore")
    TK.RD:AddResource("raw_tiberium", "Raw Tiberium")
end)
///--- ---\\\

///--- Vehicles ---\\\
hook.Add("PlayerSpawnedVehicle", "TKRD", function(ply, ent)
    ent.data = {}
    ent.data.power = 0
    
    function ent:Work()
        if self:GetUnitPowerGrid() != self.data.power then
            self:SetPower(self.data.power)
            return false
        end
        
        return true
    end

    function ent:DoThink(eff)
        local ply = self:GetDriver()
        self.data.power = IsValid(ply) && -5 || 0
        
        if !self:Work() then return end
        if !IsValid(ply) then return end
        
        if ply.tk_hev.engery < ply.tk_hev.energymax then
            ply:AddhevRes("energy", 5 * eff)
        end
        if ply.tk_hev.water < ply.tk_hev.watermax then
            ply:AddhevRes("water", self:ConsumeResource("water", 5) * eff)
        end
        if ply.tk_hev.oxygen < ply.tk_hev.oxygenmax then
            ply:AddhevRes("oxygen", self:ConsumeResource("oxygen", 5) * eff)
        end
    end

    function ent:NewNetwork(netid)

    end

    function ent:UpdateValues()

    end
    
    function ent:SetPower(power)
        return TK.RD:SetPower(self, power)
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
///--- ---\\\