
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
    btn.Paint = function(btn, w, h)
        derma.SkinHook("Paint", "TKItemPanel", btn, w, h)
        return true
    end
    btn.DoClick = function()
        if !btn.active then return end
        btn.active = false
        timer.Simple(1, function() if IsValid(btn) then btn.active = true end end)
        
        surface.PlaySound("ui/buttonclickrelease.wav")
        panel.Terminal.AddQuery("setslot", btn.slot, btn.id, btn.item)
    end
    
    return btn
end

local function MakeSlot(panel, slot, id)
    local btn = vgui.Create("DButton", panel)
    btn:SetSkin("Terminal")
    btn.slot = slot
    btn.id = id
    btn.item = {}
    
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
        
        local valid_items = {}
        for k,v in pairs(TK.DB:GetPlayerData("player_terminal_inventory").inventory) do
            if !TK.LO:IsSlot(v, btn.slot) then continue end
            table.insert(valid_items, v)
        end
        
        for k,v in pairs(panel[btn.slot]) do
            for _,item in pairs(valid_items) do
                if v.item == item then
                    valid_items[_] = nil
                    break
                end
            end
        end
        
        for k,v in pairs(valid_items) do
            panel.items:AddItem(MakePanel(panel, btn.slot, btn.id, v))
        end
    end
    
    btn.Think = function()
        
    end
    btn.Update = function()
        local item_id = panel.loadout[btn.slot.. "_" ..btn.id]
        if !item_id or item_id == btn.item then return end
        btn.item = item_id
        local item = TK.LO:GetItem(item_id)
        
        btn:SetToolTip(item.name)
        btn:SetModel(item.mdl)
        btn.vCamPos = item.view
        btn.vLookatPos = Vector(0 ,0 , item.view.z * 0.5)
        
        btn:MakeList()
    end
    btn.Paint = function(btn, w, h)
        derma.SkinHook("Paint", "TKLOButton", btn, w, h)
        return true
    end
    btn.DoClick = function()
        if TK.LO:SlotLocked(btn.slot.. "_" ..btn.id) then return end
        surface.PlaySound("ui/buttonclickrelease.wav")
        btn:MakeList()
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
    
    for i=1,6 do
        self.mining[i] = MakeSlot(self, "mining", i)
        self.mining[i]:Update()
        self.storage[i] = MakeSlot(self, "storage", i)
        self.storage[i]:Update()
        self.weapon[i] = MakeSlot(self, "weapon", i)
        self.weapon[i]:Update()
    end
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

function PANEL:Think()

end

function PANEL:Update()
    self.score = TK:Format(TK.DB:GetPlayerData("player_stats").score)
    self.loadout = TK.DB:GetPlayerData("player_terminal_loadout").loadout
    
    for i=1,6 do
        self.mining[i]:Update()
        self.storage[i]:Update()
        self.weapon[i]:Update()
    end
end

function PANEL.Paint(self, w, h)
    derma.SkinHook("Paint", "TKLoadout", self, w, h)
    return true
end

vgui.Register("tk_loadout", PANEL)