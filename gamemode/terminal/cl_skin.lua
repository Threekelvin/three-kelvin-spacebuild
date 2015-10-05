local surface = surface
local draw = draw
local Color = Color
local pairs = pairs
local SKIN = {}
SKIN.PrintName = "Terminal Skin"
SKIN.Author = "Ghost400"
SKIN.DermaVersion = 1
SKIN.light = Color(200, 200, 200)
SKIN.normal = Color(150, 150, 150)
SKIN.dim = Color(100, 100, 100)
SKIN.dark = Color(55, 57, 61)
SKIN.button = Color(110, 150, 250)
SKIN.text = Color(255, 255, 255)
SKIN.highlight = Color(20, 200, 250)
SKIN.warning = Color(200, 0, 0)
SKIN.link = Color(200, 200, 200)
SKIN.lock = Material("icon32/lock.png")

--/--- Frames ---\\\
function SKIN:PaintTKFrame(panel, w, h)
    draw.RoundedBox(4, 0, 0, w, h, self.dark)
    draw.RoundedBox(4, 1, 1, w - 2, h - 2, self.dim)
    draw.RoundedBoxEx(4, 1, 1, w - 2, 20, self.normal, true, true)
    draw.SimpleText(panel.title or "", "TKFont15", 6, 10, self.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("r", "Marlett", w - 11, 10, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function SKIN:PaintTKUpFrame(panel, w, h)
    draw.RoundedBox(4, 0, 0, w, h, self.dark)
    draw.RoundedBox(4, 1, 1, w - 2, h - 2, self.dim)
    draw.RoundedBoxEx(4, 1, 1, w - 2, 20, self.normal, true, true)
    draw.SimpleText(panel.title or "", "TKFont15", 6, 10, self.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("r", "Marlett", w - 11, 10, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.RoundedBox(4, 5, 25, 275, 25, self.normal)
    draw.SimpleText("Cost", "TKFont18", 142.5, 26, self.text, TEXT_ALIGN_CENTER)
    draw.RoundedBox(4, 285, 25, 210, 65, self.light)
    surface.SetMaterial(TK.TD:GetIcon(panel.btn.data.icon))
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(357.5, 25, 64, 64)
    draw.RoundedBox(4, 285, 95, 210, 25, self.normal)
    draw.SimpleText("Level", "TKFont18", 390, 96, self.text, TEXT_ALIGN_CENTER)
    draw.RoundedBoxEx(4, 285, 115, 210, 50, self.dark, false, false, true, true)
    draw.SimpleText(panel.btn.level .. " / " .. panel.btn.data.levels, "TKFont25", 390, 127.5, self.text, TEXT_ALIGN_CENTER)
    draw.RoundedBox(4, 5, 170, 490, 25, self.normal)
    draw.SimpleText("Bonus", "TKFont18", 250, 171, self.text, TEXT_ALIGN_CENTER)
end

---------------
---- Stats ----
---------------
function SKIN:PaintTKStats(panel, w, h)
    draw.RoundedBox(4, 0, 0, 775, 530, self.light)
    draw.RoundedBox(4, 265, 5, 250, 35, self.dim)
    draw.SimpleText("Leaderboard", "TKFont30", 390, 6, self.text, TEXT_ALIGN_CENTER)
    draw.RoundedBox(4, 5, 45, 765, 25, self.normal)
    draw.SimpleText("Score: " .. (panel.score or ""), "TKFont20", 10, 57.5, self.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.RoundedBox(4, 5, 75, 765, 450, self.dim)
    draw.RoundedBox(4, 10, 80, 755, 40, self.dark)
    draw.SimpleText("Name", "TKFont25", 50, 100, self.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.SimpleText("Score", "TKFont25", 390, 100, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText("Playtime", "TKFont25", 730, 100, self.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
end

-------------------
---- Resources ----
-------------------
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

        if not IsValid(panel.Active_Node) then
            draw.SimpleText("No Node Selected", "TKFont20", 10, 47.5, self.text)
        else
            draw.SimpleText("Node " .. panel.Active_Node:EntIndex() .. "    Network " .. panel.Active_Node:GetNWInt("NetID"), "TKFont20", 10, 47.5, self.text)
        end
    end
end

------------------
---- Research ----
------------------
function SKIN:PaintTKResearch(panel, w, h)
    draw.RoundedBox(4, 0, 0, 775, 530, self.light)
    draw.RoundedBox(4, 265, 5, 250, 35, self.dim)
    draw.SimpleText("Research", "TKFont30", 390, 6, self.text, TEXT_ALIGN_CENTER)
    draw.RoundedBox(4, 5, 75, 765, 450, self.normal)
    draw.RoundedBox(4, 55, 80, 665, 40, self.dark)

    if panel.ResearchSetting == "life_support" then
        draw.SimpleText("Life Support Research", "TKFont25", 390, 87.5, self.text, TEXT_ALIGN_CENTER)
    elseif panel.ResearchSetting == "ship" then
        draw.SimpleText("Ship Components Research", "TKFont25", 390, 87.5, self.text, TEXT_ALIGN_CENTER)
    elseif panel.ResearchSetting == "mining" then
        draw.SimpleText("Mining Research", "TKFont25", 390, 87.5, self.text, TEXT_ALIGN_CENTER)
    elseif panel.ResearchSetting == "weapons" then
        draw.SimpleText("Weaponry Research", "TKFont25", 390, 87.5, self.text, TEXT_ALIGN_CENTER)
    end

    if panel.Error then
        draw.RoundedBox(4, 5, 45, 765, 25, self.warning)
        draw.SimpleText(panel.Error, "TKFont20", 10, 47.5, self.text)
    else
        draw.RoundedBox(4, 5, 45, 765, 25, self.normal)
    end
end

-----------------
---- Loadout ----
-----------------
function SKIN:PaintTKLoadout(panel, w, h)
    draw.RoundedBox(4, 0, 0, 780, 535, self.light)
    draw.RoundedBox(4, 265, 5, 250, 35, self.dim)
    draw.SimpleText("Loadout", "TKFont30", 390, 6, self.text, TEXT_ALIGN_CENTER)
    draw.RoundedBox(4, 5, 75, 485, 450, self.normal)
    draw.RoundedBox(4, 10, 80, 475, 40, self.dark)
    draw.SimpleText("Item Slots", "TKFont25", 250, 87.5, self.text, TEXT_ALIGN_CENTER)
    draw.RoundedBox(4, 495, 75, 275, 450, self.normal)
    draw.RoundedBox(4, 500, 80, 265, 40, self.dark)
    draw.SimpleText("Available Items", "TKFont25", 635, 87.5, self.text, TEXT_ALIGN_CENTER)
    draw.RoundedBox(4, 5, 45, 765, 25, self.normal)
end

function SKIN:PaintLoadoutList(panel, w, h)
    draw.RoundedBoxEx(4, 0, 0, w, h, self.light)
end

function SKIN:PaintLoadoutCategory(panel, w, h)
    if panel:GetExpanded() then
        draw.RoundedBoxEx(4, 0, 0, w, 20, self.dim, true, true, false, false)
    else
        draw.RoundedBox(4, 0, 0, w, 20, self.dim)
    end
end

function SKIN:PaintLoadoutCategoryPanel(panel, w, h)
    draw.RoundedBoxEx(4, 0, 0, w, h, self.normal, false, false, true, true)
end

-------------------
---- Inventory ----
-------------------
function SKIN:PaintTKInventory(panel, w, h)
    draw.RoundedBox(4, 0, 0, 780, 535, self.light)
    draw.RoundedBox(4, 265, 5, 250, 35, self.dim)
    draw.SimpleText("Inventory", "TKFont30", 390, 6, self.text, TEXT_ALIGN_CENTER)
    draw.RoundedBox(4, 5, 75, 485, 450, self.normal)
    draw.RoundedBox(4, 10, 80, 475, 40, self.dark)
    draw.SimpleText("Item Slots", "TKFont25", 250, 87.5, self.text, TEXT_ALIGN_CENTER)

    for x = 1,  5 do
        for y = 1,  6 do
            draw.RoundedBox(4, y * 80 - 70, x * 80 + 45, 75, 75, self.dark)
        end
    end

    draw.RoundedBox(4, 495, 75, 275, 450, self.normal)
    draw.RoundedBox(4, 500, 80, 265, 40, self.dark)
    draw.SimpleText("Information", "TKFont25", 635, 87.5, self.text, TEXT_ALIGN_CENTER)

    if panel.Error then
        draw.RoundedBox(4, 5, 45, 765, 25, self.warning)
        draw.SimpleText(panel.Error, "TKFont20", 10, 47.5, self.text)
    else
        draw.RoundedBox(4, 5, 45, 765, 25, self.normal)
        draw.SimpleText("Score: " .. panel.score, "TKFont20", 10, 47.5, self.text)
    end
end

----------------
---- Market ----
----------------
function SKIN:PaintTKMarket(panel, w, h)
    draw.RoundedBox(4, 0, 0, 780, 535, self.light)
    draw.RoundedBox(4, 265, 5, 250, 35, self.dim)
    draw.SimpleText("Market", "TKFont30", 390, 6, self.text, TEXT_ALIGN_CENTER)
end

--/--- ---\\\
--/--- Buttons ---\\\
function SKIN:PaintTKButton(btn, w, h)
    if not btn.style then return end

    if btn.Depressed then
        draw.RoundedBox(4, 0, 0, w, h, self.button)
    elseif btn.Hovered then
        draw.RoundedBox(4, 0, 0, w, h, self[btn.style[1]])
    else
        draw.RoundedBox(4, 0, 0, w, h, self[btn.style[2]])
    end

    draw.SimpleText(btn.text or "", "TKFont25", w / 2, h / 2, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

--/--- ---\\\
--/--- TextBox ---\\\
function SKIN:PaintTKTextBox(box, w, h)
    draw.RoundedBox(4, 0, 0, w, h, self[box.style[1]])
    box:DrawTextEntryText(self.text, self.highlight, self.text)
end

function SKIN:PaintTKTopTextBox(box, w, h)
    draw.RoundedBoxEx(4, 0, 0, w, h, self[box.style[1]], false, false, true, true)
    box:DrawTextEntryText(self.text, self.highlight, self.text)
end

--/--- ---\\\
--/--- Panels ---\\\
function SKIN:PaintTKResPanel(btn, w, h)
    draw.RoundedBox(4, 0, 0, w, h, self.light)
    draw.RoundedBoxEx(4, h, 5, w - 65, 25, self.dark, true, false, true)
    draw.SimpleText(btn.data.resource_name or "", "TKFont20", h + 5, 17.5, self.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    draw.RoundedBoxEx(4, h, 40, w - 65, 20, self.dim, true, false, true)
    draw.SimpleText(TK:Format(btn.data.value), "TKFont18", w - 10, 50, self.text, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
    surface.SetMaterial(TK.TD:GetIcon(btn.data.resource or "default"))
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(0.5, 0.5, 64, 64)
end

function SKIN:PaintTKUpPanel(btn, w, h)
    draw.RoundedBox(4, 0, 0, w, h, self.light)
    draw.RoundedBox(4, h, 5, w - h - 5, 30, self.dark)
    draw.SimpleText(btn.data.name or "", "TKFont20", h + 5, 10, self.text)
    draw.RoundedBox(4, h, 40, w - h - 5, 30, self.dim)
    draw.SimpleText("Level", "TKFont20", h + 5, 45, self.text)
    draw.SimpleText(btn.level .. " / " .. btn.data.levels, "TKFont20", w - 10, 45, self.text, TEXT_ALIGN_RIGHT)
    surface.SetMaterial(TK.TD:GetIcon(btn.data.icon))
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(5, 5, 64, 64)
end

function SKIN:PaintTKItemPanel(btn, w, h)
    draw.RoundedBox(4, 0, 0, w, h, self.light)
    draw.RoundedBox(4, 5, 5, w - 10, 25, self.dark)
    draw.SimpleText(btn.name, "TKFont15", w / 2, 17.5, self.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

--/--- ---\\\
--/--- Container ---\\\
function SKIN:PaintTKContainer(panel, w, h)
    draw.RoundedBox(4, 0, 0, w, h, self.dark)

    for k, v in pairs(panel.children) do
        v:SetPos(panel.scrollx + v.posx, panel.scrolly + v.posy)

        for _, req in pairs(v.data.req or {}) do
            local pos = req.vec
            local cw, ch = v:GetSize()
            local x, y = 5 + ((cw + 100) * (pos.x - 1)), 5 + ((ch + 10) * (pos.y - 1))
            local Offset = 12.5 + 50 * (pos.y - 1) / panel.maxscrollx
            surface.SetDrawColor(self.link)
            surface.DrawLine(panel.scrollx + v.posx, panel.scrolly + v.posy + Offset, panel.scrollx + x + w + 12.5 + Offset, panel.scrolly + v.posy + Offset)
            surface.DrawLine(panel.scrollx + x + w, panel.scrolly + y + Offset, panel.scrollx + x + w + 12.5 + Offset, panel.scrolly + y + Offset)

            if Y ~= v.ypos then
                surface.DrawLine(panel.scrollx + x + w + 12.5 + Offset, panel.scrolly + y + Offset, panel.scrollx + x + w + 12.5 + Offset, panel.scrolly + v.posy + Offset)
            end
        end
    end
end

--/--- ---\\\
function SKIN:DrawLock(panel, w, h)
    surface.SetMaterial(self.lock)
    surface.SetDrawColor(255, 255, 255, 255)
    surface.DrawTexturedRect(w / 2 - 16, h / 2 - 16, 32, 32)
end

derma.DefineSkin("Terminal", "Terminal Skin", SKIN)
