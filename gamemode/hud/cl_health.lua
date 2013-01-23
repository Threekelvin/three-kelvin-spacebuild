
TK.HUD = TK.HUD || {}

TK.HUD.Health = {}
local Hud = TK.HUD.Health

Hud.show = CreateClientConVar("3k_show_hud_health", "1", true, false)
Hud.angleRatio = 100
Hud.moving = true
Hud.width = 0
Hud.font = "TKFont18"
Hud.verticies = {}
Hud.mats = {
    Material("icon18/heart.png"),
    Material("icon18/lightning.png"),
    Material("icon18/leaf.png"),
    Material("icon18/water.png")
}

function Hud:CreateData()
	self.width = surface.ScreenWidth()
    self.height = surface.ScreenHeight()
    
	self.longEdge = self.width / 4
	self.shortEdge = self.longEdge * 0.8
	self.iconSize = 18
    self.barSize = 16
	self.barSpacing = 6
	self.tallEdge = 5*self.barSpacing + 4*self.iconSize

	self.healthLost = 0
	self.oldHealthRatio = 0
	self.healthDrainRate = 0.25

	self.energyLost = 0
	self.oldEnergyRatio = 0
	self.energyDrainRate = 0.1

	self.oxygenLost = 0
	self.oldOxygenRatio = 0
	self.oxygenDrainRate = 0.1

	self.waterLost = 0
	self.oldWaterRatio = 0
	self.waterDrainRate = 0.1

	self.maxang = math.atan(self.tallEdge / (0.2 * self.longEdge))
    self.points = {
		{x = 0, y = self.height},
		{x = 0, y = self.height - self.tallEdge - 1},
		{x = self.shortEdge, y = self.height - self.tallEdge - 1},
		{x = self.longEdge, y = self.height}
	}
end

function Hud:RotateVerticies(angle)
	local center = self.points[#self.points]
	local centerY = center.y - 1 // Correction for bottom screen edge.
    
	for k,vertex in pairs(self.points) do
		local newX = math.cos(angle) * (vertex.x-center.x) - math.sin(angle) * (vertex.y-centerY) + center.x
		local newY = math.sin(angle) * (vertex.x-center.x) + math.cos(angle) * (vertex.y-centerY) + centerY
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
    
    self:RotateVerticies(-self.maxang * self.angleRatio / 100)
    
    if self.angleRatio == 0 || self.angleRatio == 100 then 
        self.moving = false 
    end
end

hook.Add("GUIMousePressed", "TKPH_Health", function(mc)
	if mc != MOUSE_LEFT || !vgui.IsHoveringWorld() then return end
    if !IsValid(LocalPlayer()) || !LocalPlayer():Alive() then return end
    local x, y = gui.MousePos()
    
    if y > Hud.height - Hud.tallEdge && x < Hud.longEdge then
		surface.PlaySound("garrysmod/ui_return.wav")
		RunConsoleCommand("3k_show_hud_health", Hud.show:GetBool() && 0 || 1)
	end
end)

hook.Add("HUDPaint", "TKPH_Health", function()
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
	local yOffset = Hud.barSpacing
	if Hud.moving || !Hud.show:GetBool() then return end
    surface.SetDrawColor(Color(255, 255, 255, 255))

	local HealthRatio = math.Clamp( LocalPlayer():Health() / math.max(LocalPlayer():Health(), 100), 0, 1 )
    surface.SetMaterial(Hud.mats[1])
    surface.DrawTexturedRect(5, Hud.height - Hud.tallEdge + yOffset, Hud.iconSize, Hud.iconSize)
    surface.SetDrawColor(TK.HUD.Colors.bar)
    surface.DrawOutlinedRect(10 + Hud.iconSize, Hud.height - Hud.tallEdge + yOffset + 1, Hud.shortEdge - 33, Hud.barSize)
    surface.DrawRect(10 + Hud.iconSize, Hud.height - Hud.tallEdge + yOffset + 1, (Hud.shortEdge - 33) * HealthRatio, Hud.barSize)
    surface.SetDrawColor(Color(255, 255, 255, 255))

	Hud.healthLost = math.Clamp( Hud.healthLost - HealthRatio + Hud.oldHealthRatio - Hud.healthDrainRate*FrameTime(), 0, 1 )
	surface.DrawRect(10 + Hud.iconSize + (Hud.shortEdge - 33) * HealthRatio, Hud.height - Hud.tallEdge + yOffset + 1, (Hud.shortEdge - 33) * Hud.healthLost, Hud.barSize)
	Hud.oldHealthRatio = HealthRatio
	yOffset = yOffset + Hud.barSpacing + Hud.iconSize

    local hev = TK.HEV:GetData()

	local EnergyRatio = math.Clamp( hev.energy / hev.energymax, 0, 1 )
    surface.SetMaterial(Hud.mats[2])
    surface.DrawTexturedRect(5, Hud.height - Hud.tallEdge + yOffset, Hud.iconSize, Hud.iconSize)
    surface.SetDrawColor(TK.HUD.Colors.bar)
    surface.DrawOutlinedRect(10 + Hud.iconSize, Hud.height - Hud.tallEdge + yOffset + 1, Hud.shortEdge - 33, Hud.barSize)
    surface.DrawRect(10 + Hud.iconSize, Hud.height - Hud.tallEdge + yOffset + 1, (Hud.shortEdge - 33) * EnergyRatio, Hud.barSize)
    surface.SetDrawColor(Color(255, 255, 255, 255))

	Hud.energyLost = math.Clamp( Hud.energyLost - EnergyRatio + Hud.oldEnergyRatio - Hud.energyDrainRate*FrameTime(), 0, 1 )
	surface.DrawRect(10 + Hud.iconSize + (Hud.shortEdge - 33) * EnergyRatio, Hud.height - Hud.tallEdge + yOffset + 1, (Hud.shortEdge - 33) * Hud.energyLost, Hud.barSize)
	Hud.oldEnergyRatio = EnergyRatio
	yOffset = yOffset + Hud.barSpacing + Hud.iconSize

	local OxygenRatio = math.Clamp( hev.oxygen / hev.oxygenmax, 0, 1 )
    surface.SetMaterial(Hud.mats[3])
    surface.DrawTexturedRect(5, Hud.height - Hud.tallEdge + yOffset, Hud.iconSize, Hud.iconSize)
    surface.SetDrawColor(TK.HUD.Colors.bar)
    surface.DrawOutlinedRect(10 + Hud.iconSize, Hud.height - Hud.tallEdge + yOffset + 1, Hud.shortEdge - 33, Hud.barSize)
    surface.DrawRect(10 + Hud.iconSize, Hud.height - Hud.tallEdge + yOffset + 1, (Hud.shortEdge - 33) * OxygenRatio, Hud.barSize)
    surface.SetDrawColor(Color(255, 255, 255, 255))
	
	Hud.oxygenLost = math.Clamp( Hud.oxygenLost - OxygenRatio + Hud.oldOxygenRatio - Hud.oxygenDrainRate*FrameTime(), 0, 1 )
	surface.DrawRect(10 + Hud.iconSize + (Hud.shortEdge - 33) * OxygenRatio, Hud.height - Hud.tallEdge + yOffset + 1, (Hud.shortEdge - 33) * Hud.oxygenLost, Hud.barSize)
	Hud.oldOxygenRatio = OxygenRatio
	yOffset = yOffset + Hud.barSpacing + Hud.iconSize

	local WaterRatio = math.Clamp( hev.water / hev.watermax, 0, 1 )
    surface.SetMaterial(Hud.mats[4])
    surface.DrawTexturedRect(5, Hud.height - Hud.tallEdge + yOffset, Hud.iconSize, Hud.iconSize)
    surface.SetDrawColor(TK.HUD.Colors.bar)
    surface.DrawOutlinedRect(10 + Hud.iconSize, Hud.height - Hud.tallEdge + yOffset + 1, Hud.shortEdge - 33, Hud.barSize)
    surface.DrawRect(10 + Hud.iconSize, Hud.height - Hud.tallEdge + yOffset + 1, (Hud.shortEdge - 33) * WaterRatio, Hud.barSize)
	surface.SetDrawColor(Color(255, 255, 255, 255))
	
	Hud.waterLost = math.Clamp( Hud.waterLost - WaterRatio + Hud.oldWaterRatio - Hud.waterDrainRate*FrameTime(), 0, 1 )
	surface.DrawRect(10 + Hud.iconSize + (Hud.shortEdge - 33) * WaterRatio, Hud.height - Hud.tallEdge + yOffset + 1, (Hud.shortEdge - 33) * Hud.waterLost, Hud.barSize)
	Hud.oldWaterRatio = WaterRatio

    local info = TK.DB:GetPlayerData("player_info")
end)