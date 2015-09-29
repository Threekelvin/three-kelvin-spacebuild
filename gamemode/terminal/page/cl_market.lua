local PANEL = {}

function PANEL:Init()
    self:SetSkin("Terminal")
end

function PANEL:PerformLayout()
end

function PANEL:Think(force)
end

function PANEL:Update()
    self:Think(true)
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "TKMarket", self, w, h)

    return true
end

vgui.Register("tk_market", PANEL)
