local PANEL = {}

local function MakePanel(panel, slot, id, item)
    local btn = vgui.Create("DButton")
    btn.active = true
    btn.slot = slot
    btn.id = id
    btn.item = item
    btn.name = TK.LO:GetItem(item).name
    btn:SetSkin("Terminal")
    btn:SetSize(0, 65)

    function btn:Paint(w, h)
        derma.SkinHook("Paint", "TKItemPanel", self, w, h)

        return true
    end

    function btn:DoClick()
        if not self.active then return end
        self.active = false

        timer.Simple(1, function()
            if IsValid(self) then
                self.active = true
            end
        end)

        surface.PlaySound("ui/buttonclickrelease.wav")
        panel.Terminal.AddQuery("setslot", self.slot, self.id, self.item)
    end

    return btn
end

local function MakeSlot(panel, slot, id)
    local btn = vgui.Create("DButton", panel)
    btn:SetSkin("Terminal")
    btn.slot = slot
    btn.id = id
    btn.item = {}
    btn.Model = nil
    btn.vLookatPos = Vector()
    btn.vCamPos = Vector()

    function btn:SetModel(strModelName)
        if IsValid(self.Model) then
            self.Model:Remove()
            self.Model = nil
        end

        if not ClientsideModel then return end
        self.Model = ClientsideModel(strModelName, RENDER_GROUP_OPAQUE_ENTITY)
        if not IsValid(self.Model) then return end
        self.Model:SetNoDraw(true)
    end

    function btn:MakeList()
        panel.items:Clear(true)
        local valid_items = {}

        for k, v in pairs(TK.DB:GetPlayerData("player_terminal_inventory").inventory) do
            if not TK.LO:IsSlot(v, self.slot) then continue end
            table.insert(valid_items, v)
        end

        for k, v in pairs(panel[self.slot]) do
            for _, item in pairs(valid_items) do
                if v.item == item then
                    valid_items[_] = nil
                    break
                end
            end
        end

        for k, v in pairs(valid_items) do
            panel.items:AddItem(MakePanel(panel, self.slot, self.id, v))
        end
    end

    btn.Think = function() end

    btn.Update = function()
        local item_id = (panel.loadout or {})[btn.slot .. "_" .. btn.id]
        if not item_id or item_id == btn.item then return end
        btn.item = item_id
        local item = TK.LO:GetItem(item_id)
        btn:SetTooltip(item.name)
        btn:SetModel(item.mdl)
        btn.vCamPos = item.view
        btn.vLookatPos = Vector(0, 0, item.view.z * 0.5)
        btn:MakeList()
    end

    function btn:Paint(w, h)
        if TK.LO:SlotLocked(self.slot .. "_" .. self.id) then
            derma.SkinHook("Draw", "Lock", self, w, h)

            return true
        end

        derma.SkinHook("Paint", "TKMdlButton", self, w, h)

        return true
    end

    function btn:DoClick()
        if TK.LO:SlotLocked(self.slot .. "_" .. self.id) then return end
        surface.PlaySound("ui/buttonclickrelease.wav")
        self:MakeList()
    end

    return btn
end

function PANEL:Init()
    self:SetSkin("Terminal")
    self.NextThink = 0
    self.score = TK:Format(TK.DB:GetPlayerData("player_stats").score)
    self.loadout = TK.DB:GetPlayerData("player_terminal_loadout").loadout
    self.items = vgui.Create("DPanelList", self)
    self.items:SetSpacing(5)
    self.items:SetPadding(5)
    self.items:EnableHorizontal(false)
    self.items:EnableVerticalScrollbar(true)
    self.mining = {}
    self.storage = {}
    self.weapon = {}

    for i = 1,  4 do
        self.mining[i] = MakeSlot(self, "mining", i)
        self.mining[i]:Update()
        self.storage[i] = MakeSlot(self, "storage", i)
        self.storage[i]:Update()
        self.weapon[i] = MakeSlot(self, "weapon", i)
        self.weapon[i]:Update()
    end
end

function PANEL:PerformLayout()
    for i = 1,  4 do
        self.mining[i]:SetPos(30 + ((i - 1) * 120), 160)
        self.mining[i]:SetSize(75, 75)
        self.storage[i]:SetPos(30 + ((i - 1) * 120), 300)
        self.storage[i]:SetSize(75, 75)
        self.weapon[i]:SetPos(30 + ((i - 1) * 120), 440)
        self.weapon[i]:SetSize(75, 75)
    end

    self.items:SetPos(500, 125)
    self.items:SetSize(265, 395)
end

function PANEL:Think()
end

function PANEL:Update()
    self.score = TK:Format(TK.DB:GetPlayerData("player_stats").score)
    self.loadout = TK.DB:GetPlayerData("player_terminal_loadout").loadout

    for i = 1,  6 do
        self.mining[i]:Update()
        self.storage[i]:Update()
        self.weapon[i]:Update()
    end
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "TKLoadout", self, w, h)

    return true
end

vgui.Register("tk_loadout", PANEL)
