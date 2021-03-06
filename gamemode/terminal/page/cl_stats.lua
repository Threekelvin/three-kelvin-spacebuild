local PANEL = {}

function PANEL:Init()
    self:SetSkin("Terminal")
    self.NextThink = 0
    self.webpage = vgui.Create("HTML", self)
    self.webpage:OpenURL("http://resource.threekelv.in/leaderboard.php")

    hook.Add("TKOpenTerminal", "StatsRefresh", function()
        self.webpage:OpenURL("http://resource.threekelv.in/leaderboard.php")
    end)
end

function PANEL:PerformLayout()
    self.webpage:SetPos(10, 125)
    self.webpage:SetSize(self:GetWide() - 25, self:GetTall() - 140)
end

function PANEL:Think(force)
    if not force then
        if CurTime() < self.NextThink then return end
        self.NextThink = CurTime() + 1
    end

    self.score = TK:Format(TK.DB:GetPlayerData("player_info").score)
end

function PANEL:Update()
    self:Think(true)
end

function PANEL:Paint(w, h)
    derma.SkinHook("Paint", "TKStats", self, w, h)

    return true
end

vgui.Register("tk_stats", PANEL)
