
TK.HUD = TK.HUD || {}

TK.HUD.Stats = {}
local Hud = TK.HUD.Stats

Hud.show = CreateClientConVar("3k_show_hud_stats", "1", true, false)
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
		{x = 0, y = 0},
		{x = 0, y = self.tallEdge},
		{x = self.shortEdge, y = self.tallEdge},
		{x = self.longEdge, y = 0}
	}
	self.verticies = {}
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
    
    if !self.moving then return end
    
    self:RotateVerticies(self.maxang * self.angleRatio / 100)
    
    if self.angleRatio == 0 || self.angleRatio == 100 then 
        self.moving = false 
    end
end

hook.Add("GUIMousePressed", "TKPH_Stats", function(mc)
	if mc != MOUSE_LEFT || !vgui.IsHoveringWorld() then return end
    if !IsValid(LocalPlayer()) || !LocalPlayer():Alive() then return end
    local x, y = gui.MousePos()
    
    if y < Hud.tallEdge && x < Hud.longEdge then
		surface.PlaySound("garrysmod/ui_return.wav")
		RunConsoleCommand("3k_show_hud_stats", Hud.show:GetBool() && 0 || 1)
	end
end)

hook.Add("HUDPaint", "TKPH_Stats", function()
	if !IsValid(LocalPlayer()) || !LocalPlayer():Alive() then return end
	if Hud.width != surface.ScreenWidth() then
		Hud:CreateData()
	end
	
	Hud:ShowHide()
	
	//-- Backround --\\
	surface.SetTexture(0)
	surface.SetDrawColor(TK.HUD.Colors.backround)
	surface.DrawPoly(Hud.verticies)
	
	//-- Boarder --\\
	surface.SetDrawColor(TK.HUD.Colors.border)
	surface.DrawLine(Hud.verticies[2].x, Hud.verticies[2].y, Hud.verticies[3].x, Hud.verticies[3].y)
	surface.DrawLine(Hud.verticies[3].x, Hud.verticies[3].y, Hud.verticies[4].x, Hud.verticies[4].y)
	
	//-- Info --\\
	if Hud.moving || !Hud.show:GetBool() then return end
    
    local info = TK.DB:GetPlayerData("player_info")
    draw.SimpleText("Name:", Hud.font, 5, 3, TK.HUD.Colors.text)
    draw.SimpleText(info.name, Hud.font, 122, 3, TK.HUD.Colors.text)
    
    draw.SimpleText("Experience:", Hud.font, 5, Hud.tallEdge / 2, TK.HUD.Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText(TK:Format(info.exp), Hud.font, 122, Hud.tallEdge / 2, TK.HUD.Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    
    draw.SimpleText("Credits:", Hud.font, 5, Hud.tallEdge - 3, TK.HUD.Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    draw.SimpleText(TK:Format(info.credits), Hud.font, 122, Hud.tallEdge - 3, TK.HUD.Colors.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
end)