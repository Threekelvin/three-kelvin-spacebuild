local PANEL = {}

---------------------------
---- DCategoryList_fix ----
---------------------------
function PANEL:Init()
    self.pnlCanvas:DockPadding(2, 2, 2, 2)
end

function PANEL:AddItem(item)
    item:Dock(TOP)
    DScrollPanel.AddItem(self, item)
    self:InvalidateLayout()
end

function PANEL:Add(name)
    local Category = vgui.Create("DCollapsibleCategory_fix", self)
    Category:SetLabel(name)
    Category:SetList(self)
    self:AddItem(Category)

    return Category
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "CategoryList", self, w, h)
end

function PANEL:UnselectAll()
    for k, v in pairs(self:GetChildren()) do
        if (v.UnselectAll) then
            v:UnselectAll()
        end
    end
end

derma.DefineControl("DCategoryList_fix", "", PANEL, "DScrollPanel")
PANEL = {}
----------------------------------
---- DCollapsibleCategory_fix ----
----------------------------------
AccessorFunc(PANEL, "m_bSizeExpanded", "Expanded", FORCE_BOOL)
AccessorFunc(PANEL, "m_iContentHeight", "StartHeight")
AccessorFunc(PANEL, "m_fAnimTime", "AnimTime")
AccessorFunc(PANEL, "m_bDrawBackground", "DrawBackground", FORCE_BOOL)
AccessorFunc(PANEL, "m_iPadding", "Padding")
AccessorFunc(PANEL, "m_pList", "List")

function PANEL:Init()
    self.Header = vgui.Create("DCategoryHeader", self)
    self.Header:Dock(TOP)
    self.Header:SetSize(20, 20)
    self:SetSize(20, 20)
    self:SetExpanded(true)
    self:SetMouseInputEnabled(true)
    self:SetAnimTime(0.2)
    self.animSlide = Derma_Anim("Anim", self, self.AnimSlide)
    self:SetDrawBackground(true)
    self:DockMargin(0, 0, 0, 2)
    self:DockPadding(0, 0, 0, 5)
end

function PANEL:Think()
    self.animSlide:Run()
end

function PANEL:SetLabel(strLabel)
    self.Header:SetText(strLabel)
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "CollapsibleCategory", self, w, h)

    return false
end

function PANEL:SetContents(pContents)
    self.Contents = pContents
    self.Contents:SetParent(self)
    self.Contents:Dock(FILL)
    self:InvalidateLayout()
end

function PANEL:Toggle()
    self:SetExpanded(not self:GetExpanded())

    if not self:GetExpanded() then
        self.OldHeight = self:GetTall()
    end

    self.animSlide:Start(self:GetAnimTime(), {
        From = self:GetTall()
    })

    self:InvalidateLayout(true)
    self:GetParent():InvalidateLayout()
    self:GetParent():GetParent():InvalidateLayout()
    local cookie = '1'

    if not self:GetExpanded() then
        cookie = '0'
    end

    self:SetCookie("Open", cookie)
    self:OnToggle(self:GetExpanded())
end

function PANEL:OnToggle(expanded)
end

function PANEL:DoExpansion(b)
    if self.m_bSizeExpanded == b then return end
    self:Toggle()
end

function PANEL:PerformLayout()
    if self.Contents then
        if (self:GetExpanded()) then
            self.Contents:InvalidateLayout(true)
            self.Contents:SetVisible(true)
        else
            self.Contents:SetVisible(false)
        end
    end

    if self:GetExpanded() then
        self:SizeToChildren(false, true)
    else
        self:SetTall(self.Header:GetTall())
    end

    -- Make sure the color of header text is set
    self.Header:ApplySchemeSettings()
    self.animSlide:Run()
end

function PANEL:OnMousePressed(mcode)
    if not self:GetParent().OnMousePressed then return end

    return self:GetParent():OnMousePressed(mcode)
end

function PANEL:AnimSlide(anim, delta, data)
    self:InvalidateLayout()
    self:InvalidateParent()

    if anim.Started then
        if self:GetExpanded() then
            data.To = self.OldHeight or self:GetTall()
        else
            data.To = self:GetTall()
        end
    end

    if anim.Finished then return end

    if self.Contents then
        self.Contents:SetVisible(true)
    end

    self:SetTall(Lerp(delta, data.From, data.To))
end

function PANEL:LoadCookies()
    local Open = self:GetCookieNumber("Open", 1) == 1
    self:SetExpanded(Open)
    self:InvalidateLayout(true)
    self:GetParent():InvalidateLayout()
    self:GetParent():GetParent():InvalidateLayout()
end

function PANEL:GenerateExample()
end

derma.DefineControl("DCollapsibleCategory_fix", "", PANEL, "Panel")
