
TK.HUD = TK.HUD || {}

TK.HUD.Time = {}
local Hud = TK.HUD.Time

Hud.show = CreateClientConVar("3k_show_hud_time", "1", true, false)
Hud.angleRatio = 100
Hud.moving = true
Hud.width = 0
Hud.font = "TKFont18"

function Hud:CreateData()
	self.width = surface.ScreenWidth()
    
	self.longEdge = self.width / 3
	self.shortEdge = self.longEdge * 0.8
	self.tallEdge = 66
	self.maxang = math.atan(self.tallEdge / (0.2 * self.longEdge))
    self.points = {
		{x = self.width, y = 0},
		{x = self.width, y =  self.tallEdge},
		{x = self.width - self.shortEdge, y =  self.tallEdge},
		{x = self.width - self.longEdge, y = 0}
	}
	self.verticies = {}
	
	self.MOTDSpeed = 20
	self.MOTD = vgui.Create( "DPanel" )
	self.MOTD.Paint = function() return true end
		self.MOTDtext = vgui.Create( "DLabel", self.MOTD )
		self.MOTDtext:SetFont( self.font )
		self.MOTDtext:SetColor( TK.HUD.Colors.text )
		self.MOTDtext:SetText( TK.HUD.MOTDs[TK.HUD.MOTDindex] )
		self.MOTDtext:SizeToContents()
	self.MOTD:SetSize( self.shortEdge - 10, self.MOTDtext:GetTall() )
	self.MOTD:SetPos( Hud.width - 5 - self.MOTD:GetWide(), self.tallEdge - 3 - self.MOTD:GetTall() )
		self.MOTDtext:SetPos( self.MOTD:GetWide(), 0 )
	self.MOTD:SetVisible(false)
	self.MOTD.xCur = self.MOTD:GetWide()
end

function Hud:RotateVerticies(angle)
	local center = self.points[#self.points]
    
	for k,vertex in pairs(self.points) do
		local newX = math.cos(angle) * (vertex.x-center.x) - math.sin(angle) * (vertex.y-center.y) + center.x
		local newY = math.sin(angle) * (vertex.x-center.x) + math.cos(angle) * (vertex.y-center.y) + center.y
		self.verticies[k] = {x = newX, y = newY}
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

    if !self.moving then return	end

    self:RotateVerticies(-self.maxang * self.angleRatio / 100)
    
    if self.angleRatio == 0 || self.angleRatio == 100 then
		self.MOTD:SetVisible( self.show:GetBool() )
        self.moving = false 
    end
end

hook.Add("GUIMousePressed", "TKPH_Time", function(mc)
	if mc != MOUSE_LEFT || !vgui.IsHoveringWorld() then return end
    if !IsValid(LocalPlayer()) || !LocalPlayer():Alive() then return end
    local x, y = gui.MousePos()
    
    if y < Hud.tallEdge && x > Hud.width - Hud.longEdge then
		surface.PlaySound("garrysmod/ui_return.wav")
		RunConsoleCommand("3k_show_hud_time", Hud.show:GetBool() && 0 || 1)
		Hud.MOTD:SetVisible(false)
	end
end)

hook.Add("HUDPaint", "TKPH_Time", function()
	if !IsValid(LocalPlayer()) || !LocalPlayer():Alive() then return end
	if Hud.width != surface.ScreenWidth() then
		Hud:CreateData()
	end

	Hud:ShowHide()

	//-- MOTD Scroll --\\
	if ( Hud.MOTD:IsVisible() ) then
		local x = Hud.MOTD.xCur
		Hud.MOTD.xCur = Hud.MOTD:GetWide()
		if !( x < -Hud.MOTDtext:GetWide() ) then
			Hud.MOTD.xCur = x - Hud.MOTDSpeed*FrameTime()
		else
			TK.HUD.NextMOTD()
		end
		Hud.MOTDtext:SetPos( Hud.MOTD.xCur, 0 )
	end
	
	//-- Backround --\\
	surface.SetTexture(0)
	surface.SetDrawColor(TK.HUD.Colors.backround)
	surface.DrawPoly(Hud.verticies)
	
	//-- Boarder --\\
	surface.SetDrawColor(TK.HUD.WARNING && Color(255, 0, 0, 191 + 64*math.sin( math.pi*RealTime() )) || TK.HUD.Colors.border)
	surface.DrawLine(Hud.verticies[2].x, Hud.verticies[2].y, Hud.verticies[3].x, Hud.verticies[3].y)
	surface.DrawLine(Hud.verticies[3].x, Hud.verticies[3].y, Hud.verticies[4].x, Hud.verticies[4].y)
	
	//-- Info --\\
	if Hud.moving || !Hud.show:GetBool() then return end
    
    local info = TK.DB:GetPlayerData("player_info")
    
    surface.SetFont(Hud.font)
    local x, y = surface.GetTextSize("00:00:00")
    
    draw.SimpleText("Playtime: "..TK:FormatTime(info.playtime), Hud.font, Hud.width - 5, 3, TK.HUD.Colors.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	draw.SimpleText(os.date("%H:%M:%S"), Hud.font, Hud.width - x - 5, Hud.tallEdge / 2, TK.HUD.Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end)