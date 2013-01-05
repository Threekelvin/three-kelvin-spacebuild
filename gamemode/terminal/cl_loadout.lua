
local PANEL = {}

function PANEL:Init()
	self:SetSkin("Terminal")
	self.NextThink = 0
    
    self.inventory = vgui.Create("DPanelList", self)
	self.inventory:SetSkin("Terminal")
	self.inventory.list = {}
	self.inventory:SetSpacing(5)
	self.inventory:SetPadding(5)
	self.inventory:EnableHorizontal(false)
	self.inventory:EnableVerticalScrollbar(true)
end

function PANEL:PerformLayout()
    self.inventory:SetPos(520, 125)
	self.inventory:SetSize(245, 395)
end

function PANEL:Think()
	if CurTime() < self.NextThink then return end
	self.NextThink = CurTime() + 1
	
	self.score = TK:Format(TK.DB:GetPlayerData("player_info").score)
end

function PANEL.Paint(self, w, h)
	derma.SkinHook("Paint", "TKLoadout", self, w, h)
	return true
end

vgui.Register("tk_loadout", PANEL)