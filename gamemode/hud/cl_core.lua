
TK.HUD = TK.HUD || {}

surface.CreateFont("Terminal", {
    font = "home remedy", 
    size = 128,
    weight = 400})
surface.CreateFont("TKFont45", {
    font = "classic robot",
    size = 45,
    weight = 400})
surface.CreateFont("TKFont30", {
    font = "classic robot",
    size = 30,
    weight = 400})
surface.CreateFont("TKFont25", {
    font = "classic robot",
    size = 25,
    weight = 400})
surface.CreateFont("TKFont20", {
    font = "classic robot",
    size = 20,
    weight = 400})
surface.CreateFont("TKFont18", {
    font = "classic robot",
    size = 18,
    weight = 400})
surface.CreateFont("TKFont15", {
    font = "classic robot",
    size = 15,
    weight = 400})
surface.CreateFont("TKFont12", {
    font = "classic robot",
    size = 12,
    weight = 400})

TK.HUD.Colors = {
    text = Color(255,255,255,125),
    backround = Color(0,0,0,200),
    border = Color(0,0,0,255),
    bar = Color(0,0,0,125)
}

TK.HUD.WARNING = false

net.Receive( "ADD_HUD_WARNING", function()
	TK.HUD.WARNING = net.ReadString()
end)
net.Receive( "CLEAR_HUD_WARNING", function()
	TK.HUD.WARNING = false
end)

hook.Add("HUDPaint", "TKHUD_Admin", function()
    if !IsValid(LocalPlayer()) then return end
    TK.HUD.Colors.border = team.GetColor(LocalPlayer():Team())
    TK.HUD.Colors.bar = Color(TK.HUD.Colors.border.r, TK.HUD.Colors.border.g, TK.HUD.Colors.border.b, 100)
    
    if !LocalPlayer():Alive() || !LocalPlayer():IsModerator() then return end
    
    for k,ply in pairs(player.GetAll()) do
        if ply != LocalPlayer() then
			local vec = ply:LocalToWorld( ply:OBBCenter() )
			local localvec = LocalPlayer():LocalToWorld( LocalPlayer():OBBCenter() )
			local boxAlpha = math.Clamp( (localvec - vec):LengthSqr()/4000, 45, 300 ) - 45
			local teamCol = team.GetColor(ply:Team())

			local textPos = (vec + Vector( 0, 0, 0.9*ply:BoundingRadius() )):ToScreen()
			local boxPos = vec:ToScreen()
			textPos.y = math.Clamp( textPos.y, 0, boxPos.y - 16 )

            draw.SimpleText(ply:Name(), "TKFont15", textPos.x, textPos.y, teamCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			teamCol.a = boxAlpha
			draw.RoundedBox(4, boxPos.x - 8, boxPos.y - 8, 16, 16, teamCol)
        end
    end
end)

hook.Add("HUDShouldDraw", "TKPH", function(str)
    if str == "CHudHealth" || str == "CHudBattery" then
        return false
    end
end)