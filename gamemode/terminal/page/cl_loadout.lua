local PANEL = {}

---------------------
---- Item Select ----
---------------------
function PANEL:Init()
    self:SetSkin("Terminal")
    self.model_panel = vgui.Create("DModelPanel", self)

    self.model_panel.DoClick = function()
        self:DoClick()
    end

    self.model_panel:SetAmbientLight(Color(200, 200, 200))
    self.model_panel.FarZ = 32768
end

function PANEL:DoSetModel(data, item_id)
    self.data = data
    self.item_id = item_id
    local item = TK.LO:GetItem(item_id)
    self.model_panel:SetModel(item.mdl)
    self.model_panel:SetTooltip(item.name)
    if not IsValid(self.model_panel.Entity) then return end
    local tab = PositionSpawnIcon(self.model_panel.Entity, self.model_panel.Entity:GetPos())
    if not tab then return end
    self.model_panel:SetCamPos(tab.origin)
    self.model_panel:SetFOV(tab.fov)
    self.model_panel:SetLookAng(tab.angles)
end

function PANEL:PerformLayout(w, h)
    self.model_panel:SetSize(w, h)
    self.model_panel:SetPos(0, 0)
end

function PANEL:DoClick()
    surface.PlaySound("ui/buttonclickrelease.wav")
    TK.TD:Query("setslot", self.data.id, self.data.num, self.item_id)
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "LoadoutItem", self, w, h)

    return true
end

vgui.Register("tk_loadout_item_select", PANEL, "DPanel")
PANEL = {}

--------------
---- Slot ----
--------------
function PANEL:Init()
    self:SetSkin("Terminal")
    self.locked = true
    self.data = {}
    self.model_panel = vgui.Create("DModelPanel", self)

    self.model_panel.DoClick = function()
        self:DoClick()
    end

    self.model_panel:SetAmbientLight(Color(200, 200, 200))
    self.model_panel.FarZ = 32768
end

function PANEL:DoSetModel()
    local slots = TK.DB:GetPlayerData("player_terminal_loadout").slots or {}
    if not slots[self.data.idx] then return end
    self.locked = false
    local loadout = TK.DB:GetPlayerData("player_terminal_loadout").loadout or {}
    if not loadout[self.data.idx] then return end
    local item = TK.LO:GetItem(loadout[self.data.idx])
    self.model_panel:SetModel(item.mdl)
    self.model_panel:SetTooltip(item.name)
    self.data.tier = item.tier
    if not IsValid(self.model_panel.Entity) then return end
    local tab = PositionSpawnIcon(self.model_panel.Entity, self.model_panel.Entity:GetPos())
    if not tab then return end
    self.model_panel:SetCamPos(tab.origin)
    self.model_panel:SetFOV(tab.fov)
    self.model_panel:SetLookAng(tab.angles)
end

function PANEL:SetSlot(id, num, items_list)
    self.data.list = items_list
    self.data.id = id
    self.data.num = num
    self.data.idx = id .. "_" .. num
    self.data.tier = 0
    self:DoSetModel()
end

function PANEL:UpdateSlot()
    self:DoSetModel()
end

function PANEL:PerformLayout(w, h)
    self.model_panel:SetSize(w, h)
    self.model_panel:SetPos(0, 0)
end

function PANEL:DoClick()
    if self.locked then return end
    surface.PlaySound("ui/buttonclickrelease.wav")
    self.data.list:Clear(true)
    local inventory = TK.DB:GetPlayerData("player_terminal_inventory").inventory or {}

    for _, item_id in pairs(inventory) do
        if not TK.LO:IsSlot(item_id, self.data.id) then continue end
        local panel = vgui.Create("tk_loadout_item_select")
        panel:SetSize(100, 100)
        panel:DoSetModel(self.data, item_id)
        self.data.list:AddItem(panel)
    end
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "LoadoutSlot", self, w, h)

    return true
end

vgui.Register("tk_loadout_slot", PANEL, "DPanel")
PANEL = {}

---------------------
---- Slots Panel ----
---------------------
function PANEL:Init()
    self:SetSkin("Terminal")
    self.slots = {}
end

function PANEL:PerformLayout(w, h)
    local num_slots = #self.slots - 1

    for k, v in pairs(self.slots) do
        v:SetSize(100, 100)
        v:SetPos(5 + ((w - 100 - 10) / num_slots) * (k - 1), 5)
    end
end

function PANEL:AddSlots(id, num, items_list)
    for i = 1,  num do
        local slot = vgui.Create("tk_loadout_slot", self)
        slot:SetSlot(id, table.insert(self.slots, slot), items_list)
    end

    self:InvalidateLayout()
end

function PANEL:UpdateSlots()
    for k, v in pairs(self.slots) do
        v:UpdateSlot()
    end
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "LoadoutCategoryPanel", self, w, h)

    return true
end

vgui.Register("tk_loadout_category_panel", PANEL, "DPanel")
PANEL = {}

----------------------------
---- Loadout Main Panel ----
----------------------------
function PANEL:Init()
    self:SetSkin("Terminal")
    self.NextThink = 0
    self.list = vgui.Create("DCategoryList_fix", self)
    self.list:SetSkin("Terminal")

    self.list.Paint = function(self_p, w, h)
        derma.SkinHook("Paint", "LoadoutList", self_p, w, h)

        return true
    end

    self.items = vgui.Create("DPanelList", self)
    self.items:SetSpacing(5)
    self.items:SetPadding(5)
    self.items:EnableHorizontal(true)
    self.items:EnableVerticalScrollbar()
    self.categories = {}

    for id, data in pairs(TK.LO.slots) do
        self:AddCategory(data.name, id, data.slots)
    end
end

function PANEL:AddCategory(str_name, id, num_slots)
    local cat = self.list:Add(str_name)
    cat:SetSkin("Terminal")
    cat:SetZPos(TK.LO.slots[id].z)

    cat.Paint = function(self_p, w, h)
        derma.SkinHook("Paint", "LoadoutCategory", self_p, w, h)

        return true
    end

    cat.Header:SetFont("TKFont20")
    cat.Header:SetSkin("Terminal")
    local panel = vgui.Create("tk_loadout_category_panel")
    panel:AddSlots(id, num_slots, self.items)
    cat:SetContents(panel)
    table.insert(self.categories, cat)
end

function PANEL:PerformLayout(w, h)
    self.list:SetSize(512, 395)
    self.list:SetPos(10, 125)

    for k, v in pairs(self.categories) do
        v:SetHeight(135)
    end

    self.items:SetSize(228, 395)
    self.items:SetPos(537, 125)
end

function PANEL:Think()
end

function PANEL:Update()
    self.items:Clear(true)

    for k, v in pairs(self.categories) do
        v.Contents:UpdateSlots()
    end
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "TKLoadout", self, w, h)

    return true
end

vgui.Register("tk_loadout", PANEL)
