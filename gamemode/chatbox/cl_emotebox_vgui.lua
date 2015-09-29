local PANEL = {}

function PANEL:Init()
    self:SetMouseInputEnabled(true)
    self.hidden = false
    self.emotelist = {}
    self.size = 50
    self.padding = 5
    self.offset = 0
    self.vscroll = vgui.Create("DVScrollBar", self)
end

function PANEL:Show()
    self.hidden = false
    self:PerformLayout()
end

function PANEL:Hide()
    self.hidden = true
end

function PANEL:PerformLayout()
    local wide, tall = self:GetSize()
    local w, h = 5, 5

    for k, v in pairs(self.emotelist) do
        w = w + self.size + self.padding

        if (w + self.size + self.padding) > wide then
            w = 0
            h = h + self.size + self.padding
        end
    end

    self.vscroll:SetPos(wide - 13, 0)
    self.vscroll:SetSize(13, tall)
    self.vscroll:SetUp(self:GetTall(), h)
end

function PANEL:OnMouseWheeled(dlta)
    return self.vscroll:OnMouseWheeled(dlta)
end

function PANEL:OnVScroll(iOffset)
    self.offset = iOffset
end

function PANEL:Think()
    return true
end

function PANEL:Paint(wide, tall)
    if self.hidden then return true end
    surface.SetDrawColor(Color(255, 255, 255, 255))
    local w, h = 5, 5 + self.offset

    for k, v in pairs(self.emotelist) do
        surface.SetMaterial(v)
        surface.DrawTexturedRect(w, h, 50, 50)
        w = w + self.size + self.padding

        if (w + self.size + self.padding) > wide then
            w = 0
            h = h + self.size + self.padding
        end
    end
end

function PANEL:OnMousePressed(mc)
    if self.hidden then return end
    local mx, my = gui.MousePos()
    local px, py = self:LocalToScreen()
    px = mx - px
    py = my - py
    local wide = self:GetWide()
    local w, h = 5, 5 + self.offset

    for k, v in pairs(self.emotelist) do
        if (h) < py and (h + self.size) > py then
            if w < px and (w + self.size) > px then
                surface.PlaySound("ui/buttonclickrelease.wav")
                self:Selected(k)
                self:MouseCapture(true)

                return
            end
        end

        w = w + self.size + self.padding

        if (w + self.size + self.padding) > wide then
            w = 0
            h = h + self.size + self.padding
        end
    end
end

function PANEL:OnMouseReleased()
    self:MouseCapture(false)
end

function PANEL:Selected(txt)
end

vgui.Register("TKEmoteBox", PANEL, "DPanel")
