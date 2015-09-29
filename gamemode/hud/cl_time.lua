TK.HUD = TK.HUD or {}
TK.HUD.Time = {}
local Hud = TK.HUD.Time
Hud.show = CreateClientConVar("3k_show_hud_time", "1", true, false)
Hud.angleRatio = 100
Hud.moving = true
Hud.width = 0
Hud.verticies = {}
Hud.font = "TKFont18"

function Hud:CreateData()
    self.width = ScrW()
    self.longEdge = self.width / 3
    self.shortEdge = self.longEdge * 0.8
    self.tallEdge = 66
    self.maxang = math.atan(self.tallEdge / (0.2 * self.longEdge))

    self.points = {
        {
            x = self.width,
            y = 0
        },
        {
            x = self.width,
            y = self.tallEdge
        },
        {
            x = self.width - self.shortEdge,
            y = self.tallEdge
        },
        {
            x = self.width - self.longEdge,
            y = 0
        }
    }

    surface.SetFont(self.font)
    local w, h = surface.GetTextSize("TEST")
    if IsValid(self.MOTD) then return end
    self.MOTD = vgui.Create("DPanel")
    self.MOTD.vpaint = false
    self.MOTD.vtext = ""
    self.MOTD.vlenght = 0
    self.MOTD.voffset = 0
    self.MOTD:SetSize(self.shortEdge - 10, h)
    self.MOTD:SetPos(self.width - 5 - self.MOTD:GetWide(), self.tallEdge - 3 - h)

    self.MOTD.SetText = function(panel, str)
        panel.vtext = str
        surface.SetFont(self.font)
        w, h = surface.GetTextSize(str)
        panel.vlenght = w
    end

    self.MOTD.Paint = function(panel, pw, ph)
        if not panel.vpaint then return true end
        panel.vpaint = false
        surface.SetFont(self.font)
        surface.SetTextColor(TK.HUD.Colors.text)
        surface.SetTextPos(pw - panel.voffset, 0)
        surface.DrawText(panel.vtext)
        panel.voffset = panel.voffset + 25 * FrameTime()

        if panel.voffset > (panel.vlenght + pw) then
            panel:SetText(TK.HUD.NextMOTD())
            panel.voffset = 0
        end

        return true
    end

    self.MOTD:SetText(TK.HUD.NextMOTD())
end

function Hud:RotateVerticies(angle)
    local center = self.points[#self.points]

    for k, vertex in pairs(self.points) do
        local newX = math.cos(angle) * (vertex.x - center.x) - math.sin(angle) * (vertex.y - center.y) + center.x
        local newY = math.sin(angle) * (vertex.x - center.x) + math.cos(angle) * (vertex.y - center.y) + center.y

        self.verticies[k] = {
            x = newX,
            y = newY
        }
    end
end

function Hud:ShowHide()
    if self.show:GetBool() then
        if self.angleRatio > 0 then
            self.moving = true
            self.angleRatio = self.angleRatio - (5 * FrameTime() * (51 - math.abs(self.angleRatio - 50)))
        else
            self.angleRatio = 0
        end
    else
        if self.angleRatio < 100 then
            self.moving = true
            self.angleRatio = self.angleRatio + (5 * FrameTime() * (51 - math.abs(self.angleRatio - 50)))
        else
            self.angleRatio = 100
        end
    end

    if not self.moving then return end
    self:RotateVerticies(-self.maxang * self.angleRatio / 100)

    if self.angleRatio == 0 or self.angleRatio == 100 then
        self.moving = false
    end
end

hook.Add("GUIMousePressed", "TKPH_Time", function(mc)
    if mc ~= MOUSE_LEFT or not vgui.IsHoveringWorld() then return end
    if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() then return end
    local x, y = gui.MousePos()

    if y < Hud.tallEdge and x > Hud.width - Hud.longEdge then
        surface.PlaySound("garrysmod/ui_return.wav")
        RunConsoleCommand("3k_show_hud_time", Hud.show:GetBool() and 0 or 1)
    end
end)

hook.Add("HUDPaint", "TKPH_Time", function()
    if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() then return end

    if Hud.width ~= ScrW() then
        Hud:CreateData()
    end

    Hud:ShowHide()
    ---- Backround --\\
    surface.SetTexture(0)
    surface.SetDrawColor(TK.HUD.Colors.backround)
    surface.DrawPoly(Hud.verticies)
    ---- Boarder --\\
    surface.SetDrawColor(TK.HUD.Colors.border)
    surface.DrawLine(Hud.verticies[2].x, Hud.verticies[2].y, Hud.verticies[3].x, Hud.verticies[3].y)
    surface.DrawLine(Hud.verticies[3].x, Hud.verticies[3].y, Hud.verticies[4].x, Hud.verticies[4].y)
    ---- Info --\\
    if Hud.moving or not Hud.show:GetBool() then return end
    surface.SetFont(Hud.font)
    local x = surface.GetTextSize("00:00:00")
    draw.SimpleText("Playtime: " .. TK:FormatTime(LocalPlayer():GetNWInt("TKPlaytime", 0)), Hud.font, Hud.width - 5, 3, TK.HUD.Colors.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
    draw.SimpleText(os.date("%H:%M:%S"), Hud.font, Hud.width - x - 5, Hud.tallEdge / 2, TK.HUD.Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    ---- MOTD --\\
    Hud.MOTD.vpaint = true
end)
