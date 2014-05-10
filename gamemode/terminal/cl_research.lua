
local PANEL = {}
local Cost_txt = [[%s  Magnetite

%s  Tiberium

%s  Quintinite

%s  Riddinite

]]

local function MakeResearchBox(panel, idx, data)
    local btn = vgui.Create("DButton")
    btn:SetSkin("Terminal")
    btn.NextThink = 0
    btn.idx = idx
    btn.data = data
    btn.level = 0
    btn:SetSize(400, 75)
    btn:SetText("")
    
    btn.Think = function()
        if CurTime() < btn.NextThink then return end
        btn.NextThink = CurTime() + 1

    end
    
    btn.Paint = function(panel, w, h)
        derma.SkinHook("Paint", "TKUpPanel", btn, w, h)
        return true
    end
    
    btn.DoClick = function()
        if !IsValid(panel.Terminal) then return end
        surface.PlaySound("ui/buttonclickrelease.wav")
        
        local mouseblock = vgui.Create("DPanel", panel.Terminal)
        mouseblock:SetPos(0, 0)
        mouseblock:SetSize(panel.Terminal:GetWide(), panel.Terminal:GetTall())
        mouseblock.Paint = function() 
            return true
        end
        
        local frame = vgui.Create("DPanel", mouseblock)
        frame:SetSkin("Terminal")
        frame.btn = btn
        frame:SetSize(500, 300)
        frame:Center()
        frame.title = "Research Info"
        frame.Paint = function(panel, w, h)
            derma.SkinHook("Paint", "TKUpFrame", frame, w, h)
            return true
        end
        
        local close = vgui.Create("DButton", frame)
        close:SetPos(479, 0)
        close:SetSize(20, 20)
        close:SetText("")
        close.DoClick = function()
            surface.PlaySound("ui/buttonclick.wav")
            mouseblock:Remove()
        end
        close.Paint = function() 
            return true
        end
        
        local cost = vgui.Create("DTextEntry", frame)
        cost:SetSkin("Terminal")
        cost:SetSize(275, 120)
        cost:SetPos(5, 45)
        cost:SetMultiline(true)
        cost:SetEditable(false)
        cost:SetText(string.format(Cost_txt, data.cost.m, data.cost.t, data.cost.q, data.cost.r))
        cost.style = {"dark"}
        cost.Paint = function(panel, w, h)
            panel:SetFontInternal("TKFont15")
            derma.SkinHook("Paint", "TKTopTextBox", cost, w, h)
            return true
        end
        
        local bonus = vgui.Create("DTextEntry", frame)
        bonus:SetSkin("Terminal")
        bonus:SetSize(490, 50)
        bonus:SetPos(5, 190)
        bonus:SetMultiline(true)
        bonus:SetEditable(false)
        bonus:SetText(data.bonus or "")
        bonus.style = {"dark"}
        bonus.Paint = function(panel, w, h)
            derma.SkinHook("Paint", "TKTopTextBox", bonus, w, h)
            return true
        end
        
        local upgrade = vgui.Create("DButton", frame)
        upgrade:SetSkin("Terminal")
        upgrade:SetSize(490, 50)
        upgrade:SetPos(5, 245)
        upgrade:SetText("")
        upgrade.text = "Upgrade"
        upgrade.style = {"normal", "dim"}
        upgrade.Paint = function(panel, w, h)
            derma.SkinHook("Paint", "TKButton", upgrade, w, h)
            return true
        end
        upgrade.DoClick = function()
            if !IsValid(panel.Terminal) then return end
            surface.PlaySound("ui/buttonclickrelease.wav")

            panel:ShowError("What are you doing here? go away!")
            return --[[
            
            local upgrades = TK.DB:GetPlayerData("terminal_upgrades")
            for k,v in pairs(btn.data.req or {}) do
                local updata = TK.TD:GetUpgrade(v)
                if upgrades[v] != updata.maxlvl then
                    panel:ShowError("Requires " ..updata.name.. " Level ".. updata.maxlvl) 
                    return
                end
            end

            panel.Terminal.AddQuery("addresearch", btn.idx)]]--
        end
    end
    
    return btn
end

local function MakeTechTree(parent, panel, cat)
    panel.maxscrollx = 0
    panel.scrollx = 0
    panel.maxscrolly = 0
    panel.scrolly = 0
    
    for k,v in pairs(panel.children) do
        if IsValid(v) then
            v:Remove()
        end
        panel.children[k] = nil
    end
    
    local btn
    for id,data in pairs(TK.UP:GetUpgradeTable(cat)) do
        btn = MakeResearchBox(parent, id, data)
        btn:SetParent(panel)
        btn.posx = 5 + ((btn:GetWide() + 100) * (data.vec.x - 1))
        btn.posy = 5 + ((btn:GetTall() + 10) * (data.vec.y - 1))
        btn:SetPos(btn.posx, btn.posy)
        table.insert(panel.children, btn)
        
        if data.vec.x > panel.maxscrollx then
            panel.maxscrollx = data.vec.x
        end
        
        if data.vec.y > panel.maxscrolly then
            panel.maxscrolly = data.vec.y
        end
    end
    
    if btn then
        panel.maxscrollx = (btn:GetWide() + 10) + ((btn:GetWide() + 100) * (panel.maxscrollx - 1))
        panel.maxscrolly = (btn:GetTall() + 10) + ((btn:GetTall() + 10) * (panel.maxscrolly - 1))
    end
end

local function ContainerThink(panel)
    if panel.maxscrollx <= panel:GetWide() and panel.maxscrolly <= panel:GetTall() then return end
    if panel.Depressed then
        if !panel.Drag then
            panel.Drag = {gui.MouseX() - panel.scrollx, gui.MouseY() - panel.scrolly}
        else
            panel.scrollx = math.Clamp(gui.MouseX() - panel.Drag[1], -(math.Max(panel.maxscrollx, panel:GetWide()) - panel:GetWide()), 0)
            panel.scrolly = math.Clamp(gui.MouseY() - panel.Drag[2], -(math.Max(panel.maxscrolly, panel:GetTall()) - panel:GetTall()), 0)
        end
    else
        panel.Drag = nil
    end
end

function PANEL:Init()
    self:SetSkin("Terminal")
    self.NextThink = 0
    self.ResearchSetting = "life_support"
    
    self.container = vgui.Create("DButton", self)
    self.container:SetSkin("Terminal")
    self.container.maxscrollx = 0
    self.container.scrollx = 0
    self.container.maxscrolly = 0
    self.container.scrolly = 0
    self.container.children = {}
    self.container:SetText("")
    self.container:SetCursor("sizeall")
    self.container.Think = function(panel)
        ContainerThink(panel)
    end
    self.container.Paint = function(panel, w, h)
        derma.SkinHook("Paint", "TKContainer", self.container, w, h)
        return true
    end
    
    self.scrollleft = vgui.Create("DButton", self)
    self.scrollleft:SetSkin("Terminal")
    self.scrollleft:SetText("")
    self.scrollleft.text = "<"
    self.scrollleft.style = {"dim", "dark"}
    self.scrollleft.Paint = function(panel, w, h)
        derma.SkinHook("Paint", "TKButton", self.scrollleft, w, h)
        return true
    end
    self.scrollleft.DoClick = function()
        if self.ResearchSetting == "life_support" then
            self.ResearchSetting = "weapons"
        elseif self.ResearchSetting == "weapons" then
            self.ResearchSetting = "mining"
        elseif self.ResearchSetting == "mining" then
            self.ResearchSetting = "ship"
        elseif self.ResearchSetting == "ship" then
            self.ResearchSetting = "life_support"
        end
        
        surface.PlaySound("ui/buttonclickrelease.wav")
        MakeTechTree(self, self.container, self.ResearchSetting)
    end
    
    self.scrollright = vgui.Create("DButton", self)
    self.scrollright:SetSkin("Terminal")
    self.scrollright:SetText("")
    self.scrollright.text = ">"
    self.scrollright.style = {"dim", "dark"}
    self.scrollright.Paint = function(panel, w, h)
        derma.SkinHook("Paint", "TKButton", self.scrollright, w, h)
        return true
    end
    self.scrollright.DoClick = function()
        if self.ResearchSetting == "life_support" then
            self.ResearchSetting = "ship"
        elseif self.ResearchSetting == "ship" then
            self.ResearchSetting = "mining"
        elseif self.ResearchSetting == "mining" then
            self.ResearchSetting = "weapons"
        elseif self.ResearchSetting == "weapons" then
            self.ResearchSetting = "life_support"
        end
        
        surface.PlaySound("ui/buttonclickrelease.wav")
        MakeTechTree(self, self.container, self.ResearchSetting)
    end
    
    MakeTechTree(self, self.container, self.ResearchSetting)
end

function PANEL:ShowError(msg)
    self.Error = msg
    timer.Create("TermError_Research", 2, 1, function()
        self.Error = nil
    end)
end

function PANEL:PerformLayout()
    self.container:SetPos(10, 125)
    self.container:SetSize(755, 395)
    
    self.scrollleft:SetPos(10, 80)
    self.scrollleft:SetSize(40, 40)
    
    self.scrollright:SetPos(725, 80)
    self.scrollright:SetSize(40, 40)
end

function PANEL:Think(force)
    if !force then
        if CurTime() < self.NextThink then return end
        self.NextThink = CurTime() + 1
    end
end

function PANEL:Update()
    self:Think(true)
end

function PANEL.Paint(self, w, h)
    derma.SkinHook("Paint", "TKResearch", self, w, h)
    return true
end

vgui.Register("tk_research", PANEL)