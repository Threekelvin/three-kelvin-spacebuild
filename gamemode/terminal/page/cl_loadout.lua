local PANEL = {}

function PANEL:Init()
end

function PANEL:PerformLayout(w, h)
end

function Panel:Paint(w, h)
end

PANEL = {}

----------------------------
---- Loadout Main Panel ----
----------------------------
function PANEL:Init()
    self:SetSkin("Terminal")
    self.NextThink = 0
    self.loadout = TK.DB:GetPlayerData("player_terminal_loadout").loadout
    self.list = vgui.Create("DCategoryList_fix", self)
    self.list:SetSkin("Terminal")

    self.list.Paint = function(self_p, w, h)
        derma.SkinHook("Paint", "LoadoutList", self_p, w, h)

        return true
    end

    self.categories = {}
    self:AddCategory("Mining Equipment")
    self:AddCategory("Mining Storage")
    self:AddCategory("Life Support")
    self:AddCategory("Power Generation")
    self:AddCategory("Ship Subsystems")
    self:AddCategory("Ship Engines")
end

function PANEL:AddCategory(str_name)
    local cat = self.list:Add(str_name)
    cat:SetSkin("Terminal")

    cat.Paint = function(self_p, w, h)
        derma.SkinHook("Paint", "LoadoutCategory", self_p, w, h)

        return true
    end

    cat.Header:SetFont("TKFont20")
    cat.Header:SetSkin("Terminal")
    local panel = vgui.Create("DPanel")
    panel:SetSkin("Terminal")

    panel.Paint = function(self_p, w, h)
        derma.SkinHook("Paint", "LoadoutCategoryPanel", self_p, w, h)

        return true
    end

    cat:SetContents(panel)
    table.insert(self.categories, cat)
end

function PANEL:PerformLayout(w, h)
    self.list:SetSize(475, 395)
    self.list:SetPos(10, 125)

    for k, v in pairs(self.categories) do
        v:SetHeight(130)
    end
end

function PANEL:Think()
end

function PANEL:Update()
    self.loadout = TK.DB:GetPlayerData("player_terminal_loadout").loadout
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "TKLoadout", self, w, h)

    return true
end

vgui.Register("tk_loadout", PANEL)
