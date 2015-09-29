local PANEL = {}

function PANEL:Init()
    self:SetSkin("Terminal")
    self.slot = slot
    self.id = id
    self.item = {}
    self.Model = nil
    self.vLookatPos = Vector()
    self.vCamPos = Vector()
end

function PANEL:SetModel(mdl)
    if IsValid(self.Model) then
        self.Model:Remove()
        self.Model = nil
    end

    if not ClientsideModel then return end
    self.Model = ClientsideModel(strModelName, RENDER_GROUP_OPAQUE_ENTITY)
    if not IsValid(self.Model) then return end
    self.Model:SetNoDraw(true)
end

function PANEL:DoClick()
    if TK.LO:SlotLocked(self.slot .. "_" .. self.id) then return end
    surface.PlaySound("ui/buttonclickrelease.wav")
end

function PANEL:PerformLayout()
end

function PANEL:Think(force)
end

function PANEL:Update()
    local item_id = self.slot .. "_" .. self.id
    if not item_id or item_id == self.item then return end
    self.item = item_id
    local item = TK.LO:GetItem(item_id)
    self:SetTooltip(item.name)
    self:SetModel(item.mdl)
    self.vCamPos = item.view
    self.vLookatPos = Vector(0, 0, item.view.z * 0.5)
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "TKMdlButton", self, w, h)

    return true
end

vgui.Register("tk_inventory_slot", PANEL, "DButton")
PANEL = {}

function PANEL:Init()
    self:SetSkin("Terminal")
    self.NextThink = 0
    self.score = TK:Format(TK.DB:GetPlayerData("player_stats").score)
end

function PANEL:PerformLayout()
end

function PANEL:Think(force)
end

function PANEL:Update()
    self.score = TK:Format(TK.DB:GetPlayerData("player_stats").score)
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "TKInventory", self, w, h)

    return true
end

vgui.Register("tk_inventory", PANEL)
