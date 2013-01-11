
local surface = surface
local draw = draw
local Color = Color
local pairs = pairs

local SKIN = {}

SKIN.PrintName 		= "Terminal Skin"
SKIN.Author 		= "Ghost400"
SKIN.DermaVersion	= 1

SKIN.light 		=	Color(200,200,200)
SKIN.normal 	= 	Color(150,150,150)
SKIN.dim 		= 	Color(100,100,100)
SKIN.dark 		= 	Color(55,57,61)
SKIN.button 	= 	Color(110,150,250)
SKIN.text 		= 	Color(255,255,255)
SKIN.highlight 	= 	Color(20,200,250)
SKIN.warning	= 	Color(200,0,0)
SKIN.link1 		= 	Color(200,0,0)
SKIN.link2 		= 	Color(0,200,0)
SKIN.link3 		= 	Color(0,0,200)
SKIN.link4 		= 	Color(200,200,200)

SKIN.lock       = Material("icon32/lock.png")

///--- Frames ---\\\
function SKIN:PaintTKFrame(panel, w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.dark)
	draw.RoundedBox(4, 1, 1, w - 2, h - 2, self.dim)
	draw.RoundedBoxEx(4, 1, 1, w - 2, 20, self.normal, true, true)
	draw.SimpleText(panel.title || "", "TKFont15", 6, 10, self.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("r", "Marlett", w - 11, 10, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintTKUpFrame(panel, w, h)
	local w, h = panel:GetWide(), panel:GetTall()
	draw.RoundedBox(4, 0, 0, w, h, self.dark)
	draw.RoundedBox(4, 1, 1, w - 2, h - 2, self.dim)
	draw.RoundedBoxEx(4, 1, 1, w - 2, 20, self.normal, true, true)
	draw.SimpleText(panel.title || "", "TKFont15", 6, 10, self.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("r", "Marlett", w - 11, 10, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	
	draw.RoundedBox(4, 5, 25, 275, 25, self.normal)
	draw.SimpleText("Information", "TKFont18", 142.5, 26, self.text, TEXT_ALIGN_CENTER)
	
	draw.RoundedBox(4, 5, 170, 275, 25, self.normal)
	draw.SimpleText("Bonuses", "TKFont18", 142.5, 171, self.text, TEXT_ALIGN_CENTER)
	
	draw.RoundedBox(4, 285, 25, 210, 65, self.light)
	surface.SetMaterial(TerminalData.Icons[panel.btn.data.icon || "default"])
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(357.5, 25, 64, 64)
	
	draw.RoundedBox(4, 285, 95, 210, 25, self.normal)
	draw.SimpleText("Level", "TKFont18", 390, 96, self.text, TEXT_ALIGN_CENTER)
	draw.RoundedBoxEx(4, 285, 115, 210, 50, self.dark, false, false, true, true)
	draw.SimpleText(panel.btn.rank.." / "..panel.btn.data.maxlvl, "TKFont25", 390, 127.5, self.text, TEXT_ALIGN_CENTER)
	
	draw.RoundedBox(4, 285, 170, 210, 25, self.normal)
	draw.SimpleText("Cost", "TKFont18", 390, 171, self.text, TEXT_ALIGN_CENTER)
	draw.RoundedBoxEx(4, 285, 190, 210, 50, self.dark, false, false, true, true)
	draw.SimpleText(TK:Format(panel.btn.cost), "TKFont25", 390, 202.5, self.text, TEXT_ALIGN_CENTER)
end
///--- ---\\\

///--- Pages ---\\\
function SKIN:PaintTKStats(panel, w, h)
	draw.RoundedBox(4, 0, 0, 775, 530, self.light)
	draw.RoundedBox(4, 265, 5, 250, 35, self.dim)
	draw.SimpleText("Leaderboard", "TKFont30", 390, 6, self.text, TEXT_ALIGN_CENTER)
	
	draw.RoundedBox(4, 5, 45, 765, 25, self.normal)
	draw.SimpleText("Score: "..(panel.score || ""), "TKFont20", 10, 57.5, self.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	
	draw.RoundedBox(4, 5, 75, 765, 450, self.dim)
	draw.RoundedBox(4, 10, 80, 755, 40, self.dark)
	draw.SimpleText("Name", "TKFont25", 50, 100, self.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.SimpleText("Score", "TKFont25", 390, 100, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("Playtime", "TKFont25", 730, 100, self.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

function SKIN:PaintTKResources(panel, w, h)
	draw.RoundedBox(4, 0, 0, 775, 530, self.light)
	draw.RoundedBox(4, 265, 5, 250, 35, self.dim)
	draw.SimpleText("Resources", "TKFont30", 390, 6, self.text, TEXT_ALIGN_CENTER)
	
	draw.RoundedBox(4, 5, 75, 250, 450, self.normal)
	draw.RoundedBox(4, 262.5, 75, 250, 450, self.normal)
	draw.RoundedBox(4, 520, 75, 250, 450, self.normal)
	
	draw.RoundedBox(4, 10, 80, 240, 40, self.dark)
	draw.RoundedBox(4, 525, 80, 240, 40, self.dark)
	
	draw.SimpleText("Station Storage", "TKFont25", 130, 87.5, self.text, TEXT_ALIGN_CENTER)
	draw.SimpleText("Node", "TKFont25", 650, 87.5, self.text, TEXT_ALIGN_CENTER)

	if panel.Error then
		draw.RoundedBox(4, 5, 45, 765, 25, self.warning)
		draw.SimpleText(panel.Error, "TKFont20", 10, 47.5, self.text)
	else
		draw.RoundedBox(4, 5, 45, 765, 25, self.normal)
		if !IsValid(panel.ActiveNode) then
			draw.SimpleText("No Node Selected", "TKFont20", 10, 47.5, self.text)
		else
			draw.SimpleText("Node "..panel.ActiveNode:EntIndex().."    Network "..panel.ActiveNode:GetNWInt("NetID"), "TKFont20", 10, 47.5, self.text)
		end
	end
end

function SKIN:PaintTKRefinery(panel, w, h)
	draw.RoundedBox(4, 0, 0, 775, 530, self.light)
	draw.RoundedBox(4, 265, 5, 250, 35, self.dim)
	draw.SimpleText("Refinery", "TKFont30", 390, 6, self.text, TEXT_ALIGN_CENTER)
	
	draw.RoundedBox(4, 5, 75, 250, 450, self.normal)
	draw.RoundedBox(4, 10, 125, 240, 285, self.dark)
	
	draw.RoundedBox(4, 15, 130, 230, 60, self.light)
	draw.RoundedBox(4, 20, 135, 220, 25, self.dark)
	draw.RoundedBox(4, 20, 165, 220, 20, self.dim)
	
	draw.RoundedBox(4, 15, 195, 230, 60, self.light)
	draw.RoundedBox(4, 20, 200, 220, 25, self.dark)
	draw.RoundedBox(4, 20, 230, 220, 20, self.dim)
	draw.SimpleText("Refining Speed", "TKFont20", 25, 202.5, self.text)

	draw.RoundedBox(4, 15, 260, 230, 60, self.light)
	draw.RoundedBox(4, 20, 265, 220, 25, self.dark)
	draw.RoundedBox(4, 20, 295, 220, 20, self.dim)
	draw.SimpleText("Auto Refine Amount", "TKFont20", 25, 267.5, self.text)
	
	if panel.RefineSetting == "asteroid_ore" then
		draw.SimpleText("Credits Per Ore", "TKFont20", 25, 137.5, self.text)
		draw.SimpleText(panel.OreCost, "TKFont18", 235, 167.5, self.text, TEXT_ALIGN_RIGHT)
		draw.SimpleText(panel.OreSpeed.." / s", "TKFont18", 235, 232.5, self.text, TEXT_ALIGN_RIGHT)
		draw.SimpleText(panel.OreAmount, "TKFont18", 235, 297.5, self.text, TEXT_ALIGN_RIGHT)
	elseif panel.RefineSetting == "raw_tiberium" then
		draw.SimpleText("Credits Per Tib", "TKFont20", 25, 137.5, self.text)
		draw.SimpleText(panel.TibCost, "TKFont18", 235, 167.5, self.text, TEXT_ALIGN_RIGHT)
		draw.SimpleText(panel.TibSpeed.." / s", "TKFont18", 235, 232.5, self.text, TEXT_ALIGN_RIGHT)
		draw.SimpleText(panel.TibAmount, "TKFont18", 235, 297.5, self.text, TEXT_ALIGN_RIGHT)
	end
	
	draw.RoundedBox(4, 260, 75, 510, 450, self.normal)
	draw.RoundedBox(4, 265, 80, 500, 40, self.dark)
	draw.SimpleText("Refinery", "TKFont25", 520, 87.5, self.text, TEXT_ALIGN_CENTER)

	if panel.Error then
		draw.RoundedBox(4, 5, 45, 765, 25, self.warning)
		draw.SimpleText(panel.Error, "TKFont20", 390, 47.5, self.text, TEXT_ALIGN_CENTER)
	else
		if panel.Analyzing then
			draw.RoundedBox(4, 5, 45, 765, 25, self.normal)
			draw.SimpleText("Analyzing Ore...", "TKFont20", 10, 47.5, self.text)
		else
			draw.RoundedBox(4, 5, 45, 765, 25, self.normal)
			draw.SimpleText(panel.eta, "TKFont20", 10, 47.5, self.text)
		end
	end
end

function SKIN:PaintTKResearch(panel, w, h)
	draw.RoundedBox(4, 0, 0, 775, 530, self.light)
	draw.RoundedBox(4, 265, 5, 250, 35, self.dim)
	draw.SimpleText("Research", "TKFont30", 390, 6, self.text, TEXT_ALIGN_CENTER)
	
	draw.RoundedBox(4, 5, 75, 765, 450, self.normal)
	draw.RoundedBox(4, 55, 80, 665, 40, self.dark)
	if panel.ResearchSetting == "ore" then
		draw.SimpleText("Asteroid Mining Research", "TKFont25", 390, 87.5, self.text, TEXT_ALIGN_CENTER)
	elseif panel.ResearchSetting == "tib" then
		draw.SimpleText("Tiberium Mining Research", "TKFont25", 390, 87.5, self.text, TEXT_ALIGN_CENTER)
	elseif panel.ResearchSetting == "ref" then
		draw.SimpleText("Refinery Research", "TKFont25", 390, 87.5, self.text, TEXT_ALIGN_CENTER)
	end
	
	if panel.Error then
		draw.RoundedBox(4, 5, 45, 765, 25, self.warning)
		draw.SimpleText(panel.Error, "TKFont20", 10, 47.5, self.text)
	else
		draw.RoundedBox(4, 5, 45, 765, 25, self.normal)
		draw.SimpleText("Credits: "..panel.credits, "TKFont20", 10, 47.5, self.text)
	end
end

function SKIN:PaintTKLoadout(panel, w, h)
    draw.RoundedBox(4, 0, 0, 780, 535, self.light)
	draw.RoundedBox(4, 265, 5, 250, 35, self.dim)
	draw.SimpleText("Loadout", "TKFont30", 390, 6, self.text, TEXT_ALIGN_CENTER)
    
    draw.RoundedBox(4, 5, 75, 490, 450, self.normal)
    draw.RoundedBox(4, 10, 80, 480, 40, self.dark)
    draw.SimpleText("Item Slots", "TKFont25", 250, 87.5, self.text, TEXT_ALIGN_CENTER)
    
    draw.RoundedBox(4, 10, 125, 200, 30, self.dim)
    draw.SimpleText("Mining Devices", "TKFont20", 15, 130, self.text)
    draw.RoundedBox(4, 10, 160, 75, 75, self.dark)
    draw.RoundedBox(4, 90, 160, 75, 75, self.dark)
    draw.RoundedBox(4, 170, 160, 75, 75, self.dark)
    draw.RoundedBox(4, 250, 160, 75, 75, self.dark)
    draw.RoundedBox(4, 330, 160, 75, 75, self.dark)
    draw.RoundedBox(4, 410, 160, 75, 75, self.dark)
    
    draw.RoundedBox(4, 10, 265, 200, 30, self.dim)
    draw.SimpleText("Mining Storage", "TKFont20", 15, 270, self.text)
    draw.RoundedBox(4, 10, 300, 75, 75, self.dark)
    draw.RoundedBox(4, 90, 300, 75, 75, self.dark)
    draw.RoundedBox(4, 170, 300, 75, 75, self.dark)
    draw.RoundedBox(4, 250, 300, 75, 75, self.dark)
    draw.RoundedBox(4, 330, 300, 75, 75, self.dark)
    draw.RoundedBox(4, 410, 300, 75, 75, self.dark)
    
    draw.RoundedBox(4, 10, 405, 200, 30, self.dim)
    draw.SimpleText("Weapons", "TKFont20", 15, 410, self.text)
    draw.RoundedBox(4, 10, 440, 75, 75, self.dark)
    draw.RoundedBox(4, 90, 440, 75, 75, self.dark)
    draw.RoundedBox(4, 170, 440, 75, 75, self.dark)
    draw.RoundedBox(4, 250, 440, 75, 75, self.dark)
    draw.RoundedBox(4, 330, 440, 75, 75, self.dark)
    draw.RoundedBox(4, 410, 440, 75, 75, self.dark)
    
    draw.RoundedBox(4, 500, 75, 270, 450, self.normal)
    draw.RoundedBox(4, 505, 80, 260, 40, self.dark)
    draw.SimpleText("Items", "TKFont25", 635, 87.5, self.text, TEXT_ALIGN_CENTER)
    
    if panel.Error then
		draw.RoundedBox(4, 5, 45, 765, 25, self.warning)
		draw.SimpleText(panel.Error, "TKFont20", 10, 47.5, self.text)
	else
		draw.RoundedBox(4, 5, 45, 765, 25, self.normal)
		draw.SimpleText("Score: "..panel.score, "TKFont20", 10, 47.5, self.text)
	end
end

function SKIN:PaintTKMarket(panel, w, h)
	draw.RoundedBox(4, 0, 0, 780, 535, self.light)
	draw.RoundedBox(4, 265, 5, 250, 35, self.dim)
	draw.SimpleText("Market", "TKFont30", 390, 6, self.text, TEXT_ALIGN_CENTER)
end

function SKIN:PaintTKFaction(panel, w, h)
    draw.RoundedBox(4, 0, 0, 780, 535, self.light)
	draw.RoundedBox(4, 265, 5, 250, 35, self.dim)
	draw.SimpleText("Faction", "TKFont30", 390, 6, self.text, TEXT_ALIGN_CENTER)
end
///--- ---\\\

///--- Buttons ---\\\
function SKIN:PaintTKButton(btn, w, h)
	if !btn.style then return end
	
	if btn.Depressed then
		draw.RoundedBox(4, 0, 0, w, h, self.button)
	elseif btn.Hovered then
		draw.RoundedBox(4, 0, 0, w, h, self[btn.style[1]])
	else
		draw.RoundedBox(4, 0, 0, w, h, self[btn.style[2]])
	end
	draw.SimpleText(btn.text || "", "TKFont25", w / 2, h / 2, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintTKLOButton(btn, w, h)
    if tobool(btn.loadout[btn.slot.. "_" ..btn.id.. "_locked"]) then
        surface.SetMaterial(self.lock)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.DrawTexturedRect(w / 2 - 16, h / 2 - 16, 32, 32)
        return 
    end
    
    if !IsValid(btn.Entity) then return end
	
	local x, y = btn:LocalToScreen(0, 0)
	
	btn.Entity:SetAngles(Angle(0, RealTime() * 10, 0))

	local ang = (btn.vLookatPos-btn.vCamPos):Angle()
	cam.Start3D(btn.vCamPos, ang, 70, x, y, w, h, 5, 4096)
        cam.IgnoreZ(true)
	
        render.SuppressEngineLighting(true)
        render.SetLightingOrigin(btn.Entity:GetPos())
        render.ResetModelLighting(50 / 255, 50 / 255, 50 / 255)
        render.SetColorModulation(1, 1, 1)
        render.SetBlend(1)

        render.SetModelLighting(BOX_TOP, 1, 1, 1)
        render.SetModelLighting(BOX_FRONT, 1, 1, 1)

        btn.Entity:DrawModel()
        
        render.SuppressEngineLighting( false )
        cam.IgnoreZ(false)
	cam.End3D()
end
///--- ---\\\

///--- TextBox ---\\\
function SKIN:PaintTKTextBox(box, w, h)
	draw.RoundedBox(4, 0, 0, w, h, self[box.style[1]])
	box:DrawTextEntryText(self.text, self.highlight, self.text)
end

function SKIN:PaintTKTopTextBox(box, w, h)
	draw.RoundedBoxEx(4, 0, 0, w, h, self[box.style[1]], false, false, true, true)
	box:DrawTextEntryText(self.text, self.highlight, self.text)
end
///--- ---\\\

///--- Panels ---\\\
function SKIN:PaintTKResPanel(btn, w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.light)
	draw.RoundedBox(4, h, 5, w - 65, 25, self.dark)
	draw.SimpleText(btn.pres || "", "TKFont20", h + 5, 17.5, self.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
	draw.RoundedBox(4, h, 40, w - 65, 20, self.dim)
	draw.SimpleText(TK:Format(btn.val), "TKFont18", w - 10, 50, self.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
	
	surface.SetMaterial(TerminalData.Icons[btn.res || "default"])
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(0.5, 0.5, 64, 64)
end

function SKIN:PaintTKUpPanel(btn, w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.light)
	draw.RoundedBox(4, h, 5, w - h - 5, 30, self.dark)
	draw.SimpleText(btn.data.name || "", "TKFont20", h + 5, 10, self.text)
	draw.RoundedBox(4, h, 40, w - h - 5, 30, self.dim)
	draw.SimpleText("Level", "TKFont20", h + 5, 45, self.text)
	draw.SimpleText(btn.rank.." / "..btn.data.maxlvl, "TKFont20", w - 10, 45, self.text, TEXT_ALIGN_RIGHT)
	
	surface.SetMaterial(TerminalData.Icons[btn.data.icon || "default"])
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawTexturedRect(5, 5, 64, 64)
end

function SKIN:PaintTKItemPanel(btn, w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.light)
	draw.RoundedBox(4, 5, 5, w - 10, 25, self.dark)
	draw.SimpleText(btn.item.name, "TKFont15", w / 2, 17.5, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
///--- ---\\\

///--- Container ---\\\
function SKIN:PaintTKContainer(panel, w, h)
	draw.RoundedBox(4, 0, 0, w, h, self.dark)

	for k,v in pairs(panel.children) do
		v:SetPos(panel.scrollx + v.posx, panel.scrolly + v.posy)
		for l,b in pairs(v.data.req || {}) do
			local req = TerminalData.ResearchData[v.root[1]][b].pos
			local w, h = v:GetSize()
			local X, Y = 5 + ((w + 100) * (req[1] - 1)), 5 + ((h + 10) * (req[2] - 1))
			local Offset = 12.5 + 50 * (req[2] - 1) / panel.ResearchMax

			surface.SetDrawColor(self["link"..req[2]])
			surface.DrawLine(panel.scrollx + v.posx, panel.scrolly + v.posy + Offset, panel.scrollx + X + w + 12.5 + Offset, panel.scrolly + v.posy + Offset)
			surface.DrawLine(panel.scrollx + X + w, panel.scrolly + Y + Offset, panel.scrollx + X + w + 12.5 + Offset, panel.scrolly + Y + Offset)
			if Y != v.ypos then
				surface.DrawLine(panel.scrollx + X + w + 12.5 + Offset, panel.scrolly + Y + Offset, panel.scrollx + X + w + 12.5 + Offset, panel.scrolly + v.posy + Offset)
			end
		end
	end
end
///--- ---\\\

derma.DefineSkin("Terminal", "Terminal Skin", SKIN)