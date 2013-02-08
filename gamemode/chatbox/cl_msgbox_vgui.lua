
local PANEL = {}

function PANEL:Init()
	self.Active = false
	self:EnableVerticalScrollbar(true)
	self:SetDrawBackground(false)
	self:SetSpacing(2)
	self.VBar.Paint = function()
		return true
	end
end

function PANEL:SetActive(bool)
	self.Active = bool
	
	self.VBar.btnUp:SetVisible(bool)
	self.VBar.btnDown:SetVisible(bool)
	self.VBar.btnGrip:SetVisible(bool)
end

function PANEL:GetLastMsg()
    return next(self.Items, #self.Items)
end

function PANEL:Capture(parent)
	self:SetActive(true)
	self:SetParent(parent)
	
	for k,v in pairs(self.Items) do
		v:Hide(false)
	end
end

function PANEL:Release(parent)
	self:SetActive(false)
	self:SetParent()
	
	for k,v in pairs(self.Items) do
		v:Hide(true)
	end
	
	local x, y = parent:GetPos()
	self:SetPos(x + 7, y + 7)
end

vgui.Register("TKMsgBox", PANEL, "DPanelList")