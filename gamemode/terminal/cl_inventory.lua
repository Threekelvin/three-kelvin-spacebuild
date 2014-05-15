
local PANEL = {}

local function MakeSlot(panel, x, y)
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
        local item_id = (panel.loadout or {})[btn.slot.. "_" ..btn.id]
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
        derma.SkinHook("Paint", "TKMdlButton", btn, w, h)
        return true
    end
    btn.DoClick = function()
        if TK.LO:SlotLocked(btn.slot.. "_" ..btn.id) then return end
        surface.PlaySound("ui/buttonclickrelease.wav")
    end
    
    return btn
end

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

function PANEL.Paint(self, w, h)
    derma.SkinHook("Paint", "TKInventory", self, w, h)
    return true
end

vgui.Register("tk_inventory", PANEL)