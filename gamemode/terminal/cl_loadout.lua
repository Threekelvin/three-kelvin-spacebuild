
local PANEL = {}

local function MakePanel(panel, slot, id, item)
    local btn = vgui.Create("DButton")
    btn.active = true
    btn.slot = slot
    btn.id = id
    btn.item = item
    btn:SetSkin("Terminal")
    btn:SetSize(0, 65)
    btn.Paint = function(btn, w, h)
        derma.SkinHook("Paint", "TKItemPanel", btn, w, h)
        return true
    end
    btn.DoClick = function()
        if !btn.active then return end
        btn.active = false
        timer.Simple(1, function() if IsValid(btn) then btn.active = true end end)
        
        surface.PlaySound("ui/buttonclickrelease.wav")
        panel.Terminal.AddQuery("setslot", btn.slot, btn.id, btn.item.idx)
    end
    
    return btn
end

local function MakeSlot(panel, slot, id)
    local btn = vgui.Create("DButton", panel)
    btn:SetSkin("Terminal")
    btn.loadout = {}
    btn.slot = slot
    btn.id = id
    btn.item = 0
    
    btn.Entity = nil
    btn.vLookatPos = Vector()
    btn.vCamPos = Vector()
    btn.SetModel = function(btn, strModelName)
        if IsValid(btn.Entity) then
            btn.Entity:Remove()
            btn.Entity = nil        
        end

        if !ClientsideModel then return end
        
        btn.Entity = ClientsideModel(strModelName, RENDER_GROUP_OPAQUE_ENTITY)
        if !IsValid(btn.Entity) then return end
        
        btn.Entity:SetNoDraw(true)
    end
    btn.MakeList = function(btn)
        panel.items:Clear(true)
        
        local validitems = {}
        for k,v in pairs(TK.DB:GetPlayerData("player_inventory").inventory) do
            if !TK.TD:IsSlot(btn.slot, v) then continue end
            table.insert(validitems, v)
        end
        
        for k,v in pairs(panel[btn.slot]) do
            if v.item == 0 then continue end
            for _,itm in pairs(validitems) do
                if v.item == itm then
                    validitems[_] = nil
                    break
                end
            end
        end
        
        for k,v in pairs(validitems) do
            panel.items:AddItem(MakePanel(panel, btn.slot, btn.id, TK.TD:GetItem(v)))
        end
    end
    
    btn.Think = function()
        
    end
    btn.Update = function()
        local itemid = btn.loadout[btn.slot.. "_" ..btn.id.. "_item"]
        if !itemid or itemid == btn.item then return end
        btn.item = itemid
        local item = TK.TD:GetItem(itemid)
        
        btn:SetToolTip(item.name)
        btn:SetModel(item.mdl)
        btn.vCamPos = Vector(item.r, item.r, item.r)
        btn.vLookatPos = Vector(0 ,0 , item.r / 2)
        
        btn:MakeList()
    end
    btn.Paint = function(btn, w, h)
        derma.SkinHook("Paint", "TKLOButton", btn, w, h)
        return true
    end
    btn.DoClick = function()
        if tobool(btn.loadout[btn.slot.. "_" ..btn.id.. "_locked"]) then return end
        surface.PlaySound("ui/buttonclickrelease.wav")
        btn:MakeList()
    end
    
    return btn
end

function PANEL:Init()
    self:SetSkin("Terminal")
    self.NextThink = 0
    self.loadout = {}
    
    self.items = vgui.Create("DPanelList", self)
    self.items:SetSpacing(5)
    self.items:SetPadding(5)
    self.items:EnableHorizontal(false)
    self.items:EnableVerticalScrollbar(true)
    
    self.mining = {}
    self.mining[1] = MakeSlot(self, "mining", 1)
    self.mining[2] = MakeSlot(self, "mining", 2)
    self.mining[3] = MakeSlot(self, "mining", 3)
    self.mining[4] = MakeSlot(self, "mining", 4)
    self.mining[5] = MakeSlot(self, "mining", 5)
    self.mining[6] = MakeSlot(self, "mining", 6)
    
    self.storage = {}
    self.storage[1] = MakeSlot(self, "storage", 1)
    self.storage[2] = MakeSlot(self, "storage", 2)
    self.storage[3] = MakeSlot(self, "storage", 3)
    self.storage[4] = MakeSlot(self, "storage", 4)
    self.storage[5] = MakeSlot(self, "storage", 5)
    self.storage[6] = MakeSlot(self, "storage", 6)
    
    self.weapon = {}
    self.weapon[1] = MakeSlot(self, "weapon", 1)
    self.weapon[2] = MakeSlot(self, "weapon", 2)
    self.weapon[3] = MakeSlot(self, "weapon", 3)
    self.weapon[4] = MakeSlot(self, "weapon", 4)
    self.weapon[5] = MakeSlot(self, "weapon", 5)
    self.weapon[6] = MakeSlot(self, "weapon", 6)
end

function PANEL:PerformLayout()
    for k,v in pairs(self.mining) do
        v:SetPos(10 + ((k - 1) * 80), 160)
        v:SetSize(75, 75)
    end
    
    for k,v in pairs(self.storage) do
        v:SetPos(10 + ((k - 1) * 80), 300)
        v:SetSize(75, 75)
    end
    
    for k,v in pairs(self.weapon) do
        v:SetPos(10 + ((k - 1) * 80), 440)
        v:SetSize(75, 75)
    end
    
    self.items:SetPos(505, 125)
    self.items:SetSize(260, 395)
end

function PANEL:Think(force)
    if !force then
        if CurTime() < self.NextThink then return end
        self.NextThink = CurTime() + 1
    end
    
    self.score = TK:Format(TK.DB:GetPlayerData("player_info").score)
    self.loadout = TK.DB:GetPlayerData("player_loadout")
    
    for k,v in pairs(self.mining) do
        v.loadout = self.loadout
        v:Update()
    end
    
    for k,v in pairs(self.storage) do
        v.loadout = self.loadout
        v:Update()
    end
    
    for k,v in pairs(self.weapon) do
        v.loadout = self.loadout
        v:Update()
    end
end

function PANEL:Update()
    self:Think(true)
end

function PANEL.Paint(self, w, h)
    derma.SkinHook("Paint", "TKLoadout", self, w, h)
    return true
end

vgui.Register("tk_loadout", PANEL)