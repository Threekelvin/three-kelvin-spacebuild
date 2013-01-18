
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

TK.HUD.WARNING = {}

net.Receive( "HUD_WARNING", function()
	local sender, message = net.ReadString(), net.ReadString()
	for i=1,#TK.HUD.WARNING do
		if TK.HUD.WARNING[i][1] == sender then
			table.remove( TK.HUD.WARNING, i )
			break
		end
	end
	if message:gsub("%s+", "") != "" then table.insert( TK.HUD.WARNING, { sender, message } ) end
	if IsValid(TK.HUD.Time.MOTD) then TK.HUD.Time.MOTD:SetText(TK.HUD.NextMOTD()) end
end)

local index = 0
TK.HUD.MOTDs = {
	"Welcome to Three Kelvin Spacebuild!",
	"This server has Audio Emotes! Bind +AudioEmotePanel_Show to see the menu."
}

function TK.HUD.NextMOTD()
    if #TK.HUD.WARNING > 0 then
        return TK.HUD.WARNING[#TK.HUD.WARNING][2]
    else
        index = (index % #TK.HUD.MOTDs) + 1
        return TK.HUD.MOTDs[index]
    end
end

hook.Add("HUDPaint", "TKHUD_Admin", function()
    if !IsValid(LocalPlayer()) then return end
	local teamcol = team.GetColor(LocalPlayer():Team())
    TK.HUD.Colors.border = (#TK.HUD.WARNING > 0) && Color(255, 0, 0, 191 + 64*math.sin( math.pi*RealTime() )) || teamcol
    TK.HUD.Colors.bar = Color(teamcol.r, teamcol.g, teamcol.b, 100)
    
    if !LocalPlayer():Alive() || !LocalPlayer():IsModerator() then return end
    
    for k,ply in pairs(player.GetAll()) do
        if ply != LocalPlayer() then
			local vec = ply:LocalToWorld( ply:OBBCenter() )
			local localvec = LocalPlayer():LocalToWorld( LocalPlayer():OBBCenter() )
			local boxAlpha = math.Clamp( (localvec - vec):LengthSqr()/4000, 45, 300 ) - 45
			local teamCol = team.GetColor(ply:Team())

			local textPos = (vec + Vector( 0, 0, 0.9 * ply:BoundingRadius())):ToScreen()
			local boxPos = vec:ToScreen()
			textPos.y = math.min( textPos.y, boxPos.y - 18 )

            draw.SimpleText(ply:Name(), "TKFont15", textPos.x, textPos.y, teamCol, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            
            surface.SetDrawColor(Color(255, 255, 255, boxAlpha))
			surface.SetMaterial(ply:GetIcon())
			surface.DrawTexturedRect(boxPos.x - 8, boxPos.y - 8, 16, 16)
        end
    end
end)

hook.Add("HUDShouldDraw", "TKPH", function(str)
    if str == "CHudHealth" || str == "CHudBattery" then
        return false
    end
end)