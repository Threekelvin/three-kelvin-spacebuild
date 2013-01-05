
local PANEL = {}

function PANEL:Init()
	self:SetSkin("Terminal")
	self.NextThink = 0
	
	self.webpage = vgui.Create("HTML", self)
	self.webpage:OpenURL("http://threekelvin.co.uk/stats")
	
	hook.Add("TKOpenTerminal", "StatsRefresh", function()
		self.webpage:Refresh()
	end)
end

function PANEL:PerformLayout()
	self.webpage:SetPos(10, 125)
	self.webpage:SetSize(self:GetWide() - 25, self:GetTall() - 140)
end

function PANEL:Think()
	if CurTime() < self.NextThink then return end
	self.NextThink = CurTime() + 1
	
	self.score = TK:Format(TK.DB:GetPlayerData("player_info").score)
end

function PANEL.Paint(self, w, h)
	derma.SkinHook("Paint", "TKStats", self, w, h)
	return true
end

vgui.Register("tk_stats", PANEL)