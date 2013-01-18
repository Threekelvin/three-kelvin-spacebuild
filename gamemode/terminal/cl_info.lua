
local PANEL = {}

function PANEL:Init()
	self:SetSkin("Terminal")
	
	self.webpage = vgui.Create("HTML", self)
	self.webpage:OpenURL("http://threekelvin.co.uk")
	self.webpage.FinishedURL = function()
		self.webpage:SetVisible(true)
	end
end

function PANEL:PerformLayout()
	self.webpage:SetPos(0, 0)
	self.webpage:SetSize(self:GetWide(), self:GetTall())
end

function PANEL:Think(force)

end

function PANEL:Update()
    self:Think(true)
end

function PANEL.Paint(self, w, h)
	return true
end

vgui.Register("tk_info", PANEL)