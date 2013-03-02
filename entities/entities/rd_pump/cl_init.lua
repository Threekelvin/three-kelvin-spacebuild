include('shared.lua')

local function Add(array, data)
    array[array.idx] = data
    array.idx = array.idx + 1
end

function ENT:Draw()
    self:DrawModel()
    
    if (self:GetPos() - LocalPlayer():GetPos()):LengthSqr() > 262144 then return end
    if LocalPlayer():GetEyeTrace().Entity != self then return end
    
    local entdata = self:GetEntTable()
    local owner , uid = self:CPPIGetOwner()
    local name = "World"
    if IsValid(owner) then
        name = owner:Name()
    elseif uid then
        name = "Disconnected"
    end 
    
    local OverlayText = {self.PrintName, "\n", idx = 3}
    if entdata.netid == 0 then
        Add(OverlayText, "Not Connected\n")
    else
        Add(OverlayText, "Network ")
        Add(OverlayText, entdata.netid)
        Add(OverlayText, "\n")
    end
    Add(OverlayText, "Owner: ")
    Add(OverlayText, name)
    Add(OverlayText, "\nRange: ")
    Add(OverlayText, self:GetRange())
    Add(OverlayText, "\nStatus: ")
    Add(OverlayText, self:GetActive() && "On" || "Off")
    Add(OverlayText, "\nPower Grid: ")
    
    if entdata.powergrid > 0 then
        Add(OverlayText, "+")
        Add(OverlayText, entdata.powergrid)
        Add(OverlayText, "kW")
    else
        Add(OverlayText, entdata.powergrid)
        Add(OverlayText, "kW")
    end
    
    Add(OverlayText, "\n\nTransfer:\n")
    for k,v in pairs(entdata.data) do
        Add(OverlayText, TK.RD:GetResourceName(k))
        Add(OverlayText, ": ")
        Add(OverlayText, v)
        Add(OverlayText, "\n")
    end

    Add(OverlayText, "\nTo:\n")
    if self:GetLinked() == 0 then
        Add(OverlayText, "Not Connected")
    else
        Add(OverlayText, "Network ")
        Add(OverlayText, self:GetLinked())
    end
    OverlayText.idx = nil
    AddWorldTip(nil, table.concat(OverlayText, ""), nil, self:LocalToWorld(self:OBBCenter()))
end

function ENT:DoMenu()
    if IsValid(self.Menu) then return end
    
    local resources, nodes, toggle, rate_input, usage_input
    self.Menu = vgui.Create("DFrame")
    self.Menu.NextUpdate = 0
    self.Menu:SetSize(400, 200)
    self.Menu:Center()
    self.Menu:SetTitle(self.PrintName)
    self.Menu:ShowCloseButton(true)
    self.Menu:SetDraggable(false)
    self.Menu:MakePopup()
    self.Menu.Think = function()
        if CurTime() < self.Menu.NextUpdate then return end
        self.Menu.NextUpdate = CurTime() + 1
        local range = self:GetRange() * self:GetRange()
        local entdata = self:GetEntTable()
        local inrange = {}
        
        for k,v in pairs(ents.FindByClass("rd_node")) do
            if (v:GetPos() - self:GetPos()):LengthSqr() <= range && v:GetNWInt("NetID", 0) != entdata.netid then
                inrange[v:EntIndex()] = v:GetNetID()
            end
        end
        for k,v in pairs(nodes.list) do
            if !inrange[k] then
                nodes.list[k]:Remove()
                nodes.list[k] = nil
            end
        end
        for k,v in pairs(inrange) do
            if !nodes.list[k] then
                local line = nodes:AddLine("Network "..v, k)
                nodes.list[k] = line
            end
        end
        
        toggle:SetText(self:GetActive() && "Turn Off" || "Turn On")
        
        local energy = 0
        for k,v in pairs(resources:GetLines()) do
            if v == resources:GetSelected()[1] then
                energy = energy + math.ceil(tonumber(rate_input:GetValue()) * 0.01)
            else
                energy = energy + math.ceil((entdata.data[v:GetValue(2)] || 0) * 0.01)
            end
        end
        usage_input:SetText(tostring(energy).. " kW")
    end
    
    resources = vgui.Create("DListView", self.Menu)
    resources.list = {}
    resources:SetSize(125, 170)
    resources:SetPos(5, 25)
    resources:SetMultiSelect(false)
    resources:AddColumn("Resources")
    resources.OnRowSelected = function(panel, idx, line)
        local entdata = self:GetEntTable()
        local val = entdata.data[line:GetValue(2)] || 0
        rate_input:SetText(tostring(val))
        
        local energy = 0
        for k,v in pairs(resources:GetLines()) do
            if v == resources:GetSelected()[1] then
                energy = energy + math.ceil(tonumber(rate_input:GetValue()) * 0.01)
            else
                energy = energy + math.ceil((entdata.data[v:GetValue(2)] || 0) * 0.01)
            end
        end
        usage_input:SetText(tostring(energy).. " kW")
    end
    
    for k,v in pairs(TK.RD:GetResources()) do
        resources:AddLine(TK.RD:GetResourceName(v), v)
    end
    
    local rate = vgui.Create("DButton", self.Menu)
    rate:SetSize(125, 16)
    rate:SetPos(137.5, 25)
    rate:SetText("Transfer Rate")
    
    rate_input = vgui.Create("DTextEntry", self.Menu)
    rate_input:SetMultiline(false)
    rate_input:SetSize(125, 25) 
    rate_input:SetPos(137.5, 46)
    rate_input:SetNumeric(true)
    rate_input:SetEditable(true)
    rate_input:SetText("0")
    rate_input.OnTextChanged = function()
        local entdata = self:GetEntTable()
        local val = math.floor(math.Clamp(tonumber(rate_input:GetValue()) || 0, 0, 1000))
        local pos = rate_input:GetCaretPos()
        rate_input:SetText(tostring(val))
        rate_input:SetCaretPos(pos)
        
        local energy = 0
        for k,v in pairs(resources:GetLines()) do
            if v == resources:GetSelected()[1] then
                energy = energy + math.ceil(val * 0.01)
            else
                energy = energy + math.ceil((entdata.data[v:GetValue(2)] || 0) * 0.01)
            end
        end
        usage_input:SetText(tostring(energy).. " kW")
    end
    
    local usage = vgui.Create("DButton", self.Menu)
    usage:SetSize(125, 16)
    usage:SetPos(137.5, 89)
    usage:SetText("Energy Usage")
    
    usage_input = vgui.Create("DTextEntry", self.Menu)
    usage_input:SetMultiline(false)
    usage_input:SetSize(125, 25) 
    usage_input:SetPos(137.5, 110)
    usage_input:SetNumeric(true)
    usage_input:SetEditable(false)
    usage_input:SetText("0 kW")
    
    local update = vgui.Create("DButton", self.Menu)
    update:SetSize(125, 25)
    update:SetPos(137.5, 170)
    update:SetText("Update")
    update.DoClick = function()
        local res = resources:GetSelected()[1]
        if !IsValid(res) then return end
        surface.PlaySound("ui/buttonclickrelease.wav")
        self:DoCommand("set", res:GetValue(2), rate_input:GetValue())
    end
    
    nodes = vgui.Create("DListView", self.Menu)
    nodes.list = {}
    nodes:SetSize(125, 110)
    nodes:SetPos(270, 25)
    nodes:SetMultiSelect(false)
    nodes:AddColumn("Nodes")
    
    local connect = vgui.Create("DButton", self.Menu)
    connect:SetSize(125, 25)
    connect:SetPos(270, 140)
    connect:SetText("Connect")
    connect.DoClick = function()
        local entid = nodes:GetSelected()[1]:GetValue(2)
        local ent = Entity(entid)
        if !IsValid(ent) then return end
        surface.PlaySound("ui/buttonclickrelease.wav")
        self:DoCommand("link", entid)
    end
    
    toggle = vgui.Create("DButton", self.Menu)
    toggle:SetSize(125, 25)
    toggle:SetPos(270, 170)
    toggle:SetText("Turn On")
    toggle.DoClick = function()
        surface.PlaySound("ui/buttonclickrelease.wav")
        self:DoCommand("on", tostring(!self:GetActive()))
    end
    
    resources:SelectFirstItem()
end