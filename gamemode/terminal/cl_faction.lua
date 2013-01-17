
local PANEL = {}

function PANEL:Init()
	self:SetSkin("Terminal")

end

function PANEL:ShowError(msg)
	self.Error = msg
	timer.Create("TermError_Fac", 2, 1, function()
		self.Error = nil
	end)
end

function PANEL:PerformLayout()

end

function PANEL:Think(force)

end

function PANEL:Update()
    self:Think(true)
end

function PANEL.Paint(self, w, h)
	derma.SkinHook("Paint", "TKFaction", self, w, h)
	return true
end

vgui.Register("tk_faction", PANEL)