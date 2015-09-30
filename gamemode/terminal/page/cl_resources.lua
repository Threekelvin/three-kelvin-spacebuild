local player_pos, player_pos_old = Vector(0, 0, 0), Vector(0, 0, 0)
local player_dir, player_dir_old = Vector(0, 0, 0), Vector(0, 0, 0)
local auto_node_check = false
local next_captcha = 0
local PANEL = {}

------------------------
---- Resource Panel ----
------------------------
function PANEL:Init()
    self:SetSkin("Terminal")
    self.active = true

    self.data = {
        resource = "",
        resource_name = "",
        value = 0
    }

    self:SetText("")
end

function PANEL:SetData(data)
    self.data = table.Merge(self.data, data)
end

function PANEL:AddTextBox(func)
    self.txtbox = vgui.Create("DTextEntry", self)
    self.txtbox:SetSkin("Terminal")
    self.txtbox.style = {"dim"}
    self.txtbox:SetNumeric(true)
    self.txtbox:SetMultiline(false)
    self.txtbox:SetText(tostring(self.data.value))
    self.txtbox:RequestFocus()

    self.txtbox.OnLoseFocus = function()
        self.txtbox:Remove()
    end

    self.txtbox.OnEnter = function()
        surface.PlaySound("ui/buttonclickrelease.wav")
        local value = math.Round(tonumber(self.txtbox:GetValue()))
        self.txtbox:Remove()
        pcall(func, value)
    end

    self.txtbox.Paint = function(self_p, w, h)
        derma.SkinHook("Paint", "TKTextBox", self_p, w, h)

        return true
    end

    self:InvalidateLayout()
end

function PANEL:DoClick()
    if not self.active then return end
    self.active = false

    timer.Simple(1, function()
        if IsValid(self) then
            self.active = true
        end
    end)

    surface.PlaySound("ui/buttonclickrelease.wav")
    pcall(self.LeftClick, self)
end

function PANEL:DoRightClick()
    if not self.active then return end
    self.active = false

    timer.Simple(1, function()
        if IsValid(self) then
            self.active = true
        end
    end)

    surface.PlaySound("ui/buttonclickrelease.wav")
    pcall(self.RightClick, self)
end

function PANEL:LeftClick()
end

function PANEL:RightClick()
end

function PANEL:Think()
end

function PANEL:Update()
end

function PANEL:PerformLayout(w, h)
    self:SetHeight(65)

    if IsValid(self.txtbox) then
        self.txtbox:SetSize(w - 65, 20)
        self.txtbox:SetPos(65, 40)
    end
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "TKResPanel", self, w, h)

    return true
end

vgui.Register("tk_resources_panel", PANEL, "DButton")
PANEL = {}
-----------------------
---- Select Button ----
-----------------------
local Active_Node = nil

function PANEL:Init()
    self:SetSkin("Terminal")
    self.style = {"normal",  "dim"}

    self.data = {
        ent = nil,
        entid = 0,
        parent = nil
    }

    self:SetText("")
end

function PANEL:SetData(data)
    self.data = table.Merge(self.data, data)
    self.text = "Node " .. self.data.entid .. "    Network " .. self.data.ent:GetNWInt("NetID", 0)
end

function PANEL:DoClick()
    if not IsValid(self.data.ent) then return end
    surface.PlaySound("ui/buttonclickrelease.wav")
    Active_Node = self.data.ent
    self.data.parent:Remove()
end

function PANEL:PerformLayout(w, h)
    self:SetHeight(50)
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "TKButton", self, w, h)

    return true
end

function PANEL:Think()
end

vgui.Register("tk_resources_select_button", PANEL, "DButton")
PANEL = {}

---------------------
---- Select Node ----
---------------------
function PANEL:Init()
    self:SetSize(800, 600)
    self.NextThink = 0
    self.frame = vgui.Create("DPanel", self)
    self.frame:SetSkin("Terminal")
    self.frame.title = "Select Node"
    self.frame.Think = function() end

    self.frame.Paint = function(self_f, w, h)
        derma.SkinHook("Paint", "TKFrame", self_f, w, h)

        return true
    end

    self.close = vgui.Create("DButton", self.frame)
    self.close:SetText("")
    self.close.Paint = function() return true end

    self.close.DoClick = function()
        surface.PlaySound("ui/buttonclick.wav")
        self:Remove()
    end

    self.nodes = vgui.Create("DPanelList", self.frame)
    self.nodes:SetSkin("Terminal")
    self.nodes.list = {}
    self.nodes:SetSpacing(5)
    self.nodes:SetPadding(5)
    self.nodes:EnableHorizontal(false)
    self.nodes:EnableVerticalScrollbar(true)
end

function PANEL:PerformLayout(w, h)
    self:SetPos(0, 0)
    self.frame:SetSize(400, 300)
    self.frame:Center()
    self.close:SetSize(20, 20)
    self.close:SetPos(379, 0)
    self.nodes:SetSize(390, 270)
    self.nodes:SetPos(5, 25)
end

function PANEL:Think()
    if CurTime() < self.NextThink then return end
    self.NextThink = CurTime() + 1
    local Nodes = {}

    for k, v in pairs(ents.FindByClass("rd_node")) do
        if v:CPPIGetOwner() ~= LocalPlayer() then continue end
        table.insert(Nodes, v)
    end

    for k, v in pairs(self.nodes.list) do
        if IsValid(v) then continue end
        self.nodes:RemoveItem(self.nodes.list[k])
        self.nodes.list[k] = nil
    end

    for k, v in pairs(Nodes) do
        local id = v:EntIndex()

        if (v:GetPos() - TK.TD.Ent:GetPos()):LengthSqr() <= TK.RT.Radius then
            if self.nodes.list[id] then continue end
            local btn = vgui.Create("tk_resources_select_button")

            local data = {
                ent = v,
                entid = id,
                parent = self
            }

            btn:SetData(data)
            self.nodes.list[id] = btn
            self.nodes:AddItem(btn)
        else
            if not self.nodes.list[id] then continue end
            self.nodes:RemoveItem(self.nodes.list[id])
            self.nodes.list[id] = nil
        end
    end
end

function PANEL:Paint(w, h)
    return true
end

vgui.Register("tk_resources_select_node", PANEL, "DPanel")
PANEL = {}

-----------------
---- Captcha ----
-----------------
function PANEL:Init()
    self:SetSize(800, 600)
    self.NextThink = 0
    self.frame = vgui.Create("DPanel", self)
    self.frame:SetSkin("Terminal")
    self.frame.title = "Complete CAPTCHA"
    self.frame.Think = function() end

    self.frame.Paint = function(self_f, w, h)
        derma.SkinHook("Paint", "TKFrame", self_f, w, h)

        return true
    end

    self.close = vgui.Create("DButton", self.frame)
    self.close:SetText("")
    self.close.Paint = function() return true end

    self.close.DoClick = function()
        surface.PlaySound("ui/buttonclick.wav")
        self:Remove()
    end

    self.textbox = vgui.Create("DTextEntry", self.frame)
    self.textbox:SetEnterAllowed(true)

    self.textbox.OnEnter = function()
        self:DoSubmit()
    end

    self.submit = vgui.Create("DButton", self.frame)
    self.submit:SetText("Submit")

    self.submit.DoClick = function()
        self:DoSubmit()
    end

    self.browser = vgui.Create("HTML", self.frame)
    self.browser:OpenURL("http://resource.threekelv.in/captcha.php?steamid=" .. LocalPlayer():SteamID())
end

function PANEL:DoSubmit()
    self.textbox:SetEditable(false)
    self.textbox:SetEnterAllowed(false)
    self.submit:SetDisabled(true)
    net.Start("3k_terminal_resources_captcha_challenge")
    net.WriteString(self.textbox:GetValue())
    net.SendToServer()
end

function PANEL:Reset()
    self.textbox:SetValue("")
    self.textbox:SetEditable(true)
    self.textbox:SetEnterAllowed(true)
    self.submit:SetDisabled(false)
    self.browser:OpenURL("http://resource.threekelv.in/captcha.php?steamid=" .. LocalPlayer():SteamID())
    Derma_Message("Incorrect. Please try again.", "", "OK")
end

function PANEL:PerformLayout(w, h)
    self:SetPos(0, 0)
    self.frame:SetSize(210, 175)
    self.frame:Center()
    self.close:SetSize(20, 20)
    self.close:SetPos(189, 0)
    self.textbox:SetSize(140, 20)
    self.textbox:SetPos(5, 150)
    self.submit:SetSize(59, 20)
    self.submit:SetPos(146, 150)
    self.browser:SetSize(200, 120)
    self.browser:SetPos(5, 25)
end

function PANEL:Think()
end

function PANEL:Paint(w, h)
    return true
end

vgui.Register("tk_resources_captcha", PANEL, "DPanel")
PANEL = {}

--------------------
---- Main Panel ----
--------------------
function PANEL:Init()
    self:SetSkin("Terminal")
    self.NextThink = 0
    self.storage = vgui.Create("DPanelList", self)
    self.storage:SetSkin("Terminal")
    self.storage.list = {}
    self.storage:SetSpacing(5)
    self.storage:SetPadding(5)
    self.storage:EnableHorizontal(false)
    self.storage:EnableVerticalScrollbar(true)
    self.selectnode = vgui.Create("DButton", self)
    self.selectnode:SetSkin("Terminal")
    self.selectnode.style = {"dim",  "dark"}
    self.selectnode.text = "Select Node"
    self.selectnode:SetText("")

    self.selectnode.DoClick = function()
        if not IsValid(self.Terminal) then return end
        surface.PlaySound("ui/buttonclickrelease.wav")
        vgui.Create("tk_resources_select_node", self)
    end

    self.selectnode.Paint = function(self_f, w, h)
        derma.SkinHook("Paint", "TKButton", self_f, w, h)

        return true
    end

    self.node = vgui.Create("DPanelList", self)
    self.node:SetSkin("Terminal")
    self.node.list = {}
    self.node:SetSpacing(5)
    self.node:SetPadding(5)
    self.node:EnableHorizontal(false)
    self.node:EnableVerticalScrollbar(true)
end

function PANEL:ShowError(msg)
    self.Error = msg

    timer.Create("TermError_Resource", 2, 1, function()
        self.Error = nil
    end)
end

function PANEL:PerformLayout()
    self.storage:SetSize(245, 395)
    self.storage:SetPos(5, 125)
    self.selectnode:SetSize(240, 40)
    self.selectnode:SetPos(268, 480)
    self.node:SetSize(245, 395)
    self.node:SetPos(520, 125)
end

function PANEL:ShouldCaptcha()
    if CurTime() < next_captcha then return false end
    if (player_pos - player_pos_old):LengthSqr() < 1 then return true end
    -- Within approx 5 degrees
    if player_dir:Dot(player_dir_old) > 0.996 then return true end

    return auto_node_check
end

function PANEL:DoCaptcha(func)
    if not self:ShouldCaptcha() then
        func()

        return
    end

    local captcha = vgui.Create("tk_resources_captcha", self)

    net.Receive("3k_terminal_resources_captcha_response", function()
        if not IsValid(captcha) then return end

        if net.ReadBit() == 1 then
            captcha:Remove()
            func()
            next_captcha = CurTime() + 300
        else
            captcha:Reset()
        end
    end)
end

function PANEL:CreateStoragePanel()
    local panel = vgui.Create("tk_resources_panel")

    panel.LeftClick = function()
        if not IsValid(self.Terminal) then return end

        if not IsValid(Active_Node) then
            self:ShowError("No Node Selected")
        else
            self.Terminal.AddQuery("storagetonode", Active_Node:EntIndex(), panel.data.resource, panel.data.value)
        end
    end

    panel.RightClick = function()
        if not IsValid(self.Terminal) then return end

        if not IsValid(Active_Node) then
            self:ShowError("No Node Selected")
        else
            panel:AddTextBox(function(val)
                if val <= 0 then
                    self:ShowError("Nil Value Entered")

                    return
                end

                if val > panel.data.value then
                    val = panel.data.value
                end

                self.Terminal.AddQuery("storagetonode", Active_Node:EntIndex(), panel.data.resource, val)
            end)
        end
    end

    return panel
end

function PANEL:CreateResourcesPanel()
    local panel = vgui.Create("tk_resources_panel")

    panel.LeftClick = function()
        if not IsValid(self.Terminal) then return end

        self:DoCaptcha(function()
            if not IsValid(Active_Node) then
                self:ShowError("No Node Selected")
            else
                self.Terminal.AddQuery("nodetostorage", Active_Node:EntIndex(), panel.data.resource, panel.data.value)
            end
        end)
    end

    panel.RightClick = function()
        if not IsValid(self.Terminal) then return end

        panel:AddTextBox(function(val)
            if val <= 0 then
                self:ShowError("Nil Value Entered")

                return
            end

            if val > panel.data.value then
                val = panel.data.value
            end

            self:DoCaptcha(function()
                if not IsValid(Active_Node) then
                    self:ShowError("No Node Selected")
                else
                    self.Terminal.AddQuery("nodetostorage", Active_Node:EntIndex(), panel.data.resource, val)
                end
            end)
        end)
    end

    return panel
end

function PANEL:Think(force)
    self.Active_Node = Active_Node

    if not force then
        if CurTime() < self.NextThink then return end
        self.NextThink = CurTime() + 1
    end

    local Storage = TK.DB:GetPlayerData("player_terminal_storage").storage or {}

    if IsValid(Active_Node) then
        if (Active_Node:GetPos() - TK.TD.Ent:GetPos()):LengthSqr() > TK.RT.Radius then
            Active_Node = nil
            auto_node_check = true
        end
    end

    if not IsValid(Active_Node) then
        for k, v in pairs(ents.FindByClass("rd_node")) do
            if v:CPPIGetOwner() ~= LocalPlayer() then continue end

            if (v:GetPos() - TK.TD.Ent:GetPos()):LengthSqr() <= TK.RT.Radius then
                Active_Node = v
                break
            end
        end
    end

    ---- Station Storage ----
    for k, v in pairs(self.storage.list) do
        if Storage[k] then continue end
        self.storage:RemoveItem(self.storage.list[k])
        self.storage.list[k] = nil
    end

    for k, v in pairs(Storage) do
        if v > 0 then
            if not self.storage.list[k] then
                local panel = self:CreateStoragePanel()

                panel:SetData({
                    resource = k,
                    resource_name = TK.RD:GetResourceName(k),
                    value = v
                })

                self.storage.list[k] = panel
                self.storage:AddItem(panel)
            else
                self.storage.list[k]:SetData({
                    value = v
                })
            end
        else
            if self.storage.list[k] then
                self.storage:RemoveItem(self.storage.list[k])
                self.storage.list[k] = nil
            end
        end
    end

    ---- Node Resources ----
    if IsValid(Active_Node) then
        local Resources = Active_Node:GetNetTable().resources

        for k, v in pairs(self.node.list) do
            if not Resources[k] then
                self.node:RemoveItem(self.node.list[k])
                self.node.list[k] = nil
            end
        end

        for k, v in pairs(Resources) do
            if v.cur > 0 then
                if not self.node.list[k] then
                    local panel = self:CreateResourcesPanel()

                    panel:SetData({
                        resource = k,
                        resource_name = TK.RD:GetResourceName(k),
                        value = v.cur
                    })

                    self.node.list[k] = panel
                    self.node:AddItem(panel)
                else
                    self.node.list[k]:SetData({
                        value = v.cur
                    })
                end
            else
                if self.node.list[k] then
                    self.node:RemoveItem(self.node.list[k])
                    self.node.list[k] = nil
                end
            end
        end
    else
        self.node:Clear(true)
        self.node.list = {}
    end
end

function PANEL:Update()
    self:Think(force)
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "TKResources", self, w, h)

    return true
end

vgui.Register("tk_resources", PANEL)

hook.Add("TKOpenTerminal", "TKTD_PData", function()
    auto_node_check = false
    player_pos_old = player_pos
    player_dir_old = player_dir
    player_pos = LocalPlayer():GetPos()
    player_dir = LocalPlayer():EyeAngles():Forward()
end)
