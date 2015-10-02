TK.HUD = TK.HUD or {}
TK.HUD.Warning = {}
TK.HUD.MOTDs = {}
TK.HUD.MOTDs[1] = "Welcome to Three Kelvin Spacebuild!"
TK.HUD.MOTDs[2] = "This server has Audio Emotes! Bind +AudioEmotePanel_Show to see the menu"
TK.HUD.MOTDs[3] = "We have a teamspeak server: threekelv.in"
TK.HUD.MOTDs[4] = "Not sure how to do something? Ask!"

local Admin = CreateClientConVar("3k_admin_overlay", 1, true, false)
local index = 0

TK.HUD.Colors = {
    text = Color(255, 255, 255, 125),
    backround = Color(0, 0, 0, 200),
    border = Color(0, 0, 0, 255),
    bar = Color(0, 0, 0, 125)
}

function TK.HUD.NextMOTD()
    if #TK.HUD.Warning > 0 then
        index = (index % #TK.HUD.Warning) + 1

        return TK.HUD.Warning[index]
    else
        index = (index % #TK.HUD.MOTDs) + 1

        return TK.HUD.MOTDs[index]
    end
end

hook.Add("HUDPaint", "TKHUD_Admin", function()
    if not IsValid(LocalPlayer()) then return end
    local teamcol = team.GetColor(LocalPlayer():Team())
    TK.HUD.Colors.border = #TK.HUD.Warning > 0 and Color(255, 0, 0, 191 + 64 * math.sin(math.pi * RealTime())) or teamcol
    TK.HUD.Colors.bar = Color(teamcol.r, teamcol.g, teamcol.b, 100)
    if not Admin:GetBool() then return end
    if not LocalPlayer():Alive() or not LocalPlayer():IsModerator() then return end

    for k, ply in pairs(player.GetAll()) do
        if ply == LocalPlayer() or not ply:Alive() then continue end
        local vec = ply:LocalToWorld(ply:OBBCenter())
        local localvec = LocalPlayer():LocalToWorld(LocalPlayer():OBBCenter())
        local boxAlpha = math.Clamp((localvec - vec):LengthSqr() / 4000, 45, 300) - 45
        local teamCol = team.GetColor(ply:Team())
        local textPos = (vec + Vector(0, 0, 0.9 * ply:BoundingRadius())):ToScreen()
        local boxPos = vec:ToScreen()
        textPos.y = math.min(textPos.y, boxPos.y - 18)
        draw.SimpleText(ply:Name(), "TKFont15", textPos.x, textPos.y, teamCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(Color(255, 255, 255, boxAlpha))
        surface.SetMaterial(ply:GetIcon())
        surface.DrawTexturedRect(boxPos.x - 8, boxPos.y - 8, 16, 16)
    end
end)

hook.Add("HUDShouldDraw", "TKPH", function(str)
    if str == "CHudHealth" or str == "CHudBattery" then return false end
end)

net.Receive("TKHUD_Start_Warning", function()
    table.insert(TK.HUD.Warning, net.ReadString())
    if not TK.HUD.Time then return end
    TK.HUD.Time.MOTD:SetText(TK.HUD.NextMOTD())
    TK.HUD.Time.MOTD.voffset = 0
end)

net.Receive("TKHUD_Stop_Warning", function()
    local msg = net.ReadString()

    for k, v in pairs(TK.HUD.Warning) do
        if v ~= msg then continue end
        table.remove(TK.HUD.Warning, k)
        if not TK.HUD.Time then return end
        TK.HUD.Time.MOTD:SetText(TK.HUD.NextMOTD())
        TK.HUD.Time.MOTD.voffset = 0
        break
    end
end)
