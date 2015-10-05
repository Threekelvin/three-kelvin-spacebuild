local Show = CreateClientConVar("tk_aoc_show", 1, true, false)
local AOC = {}

AOC.Legacy = {
    ["SpaceBuild Enhancement Project"] = "https://github.com/SnakeSVx/sbep.git",
    ["Adv. Duplicator 2"] = "https://github.com/wiremod/advdupe2.git",
    ["TKMP"] = "https://code.google.com/p/3k-model-pack/"
}

AOC.MountedLegacy = {}
AOC.missing_addon = true

function AOC:GetLegacyAddons()
    local _, root = file.Find("addons/*", "GAME")

    for _, dir in pairs(root) do
        if file.Exists("addons/" .. dir .. "/info.txt", "GAME") then
            local data = util.KeyValuesToTable(file.Read("addons/" .. dir .. "/info.txt", "GAME") or "")

            if data.name then
                AOC.MountedLegacy[data.name] = false
            end
        end

        if file.Exists("addons/" .. dir .. "/addon.txt", "GAME") then
            local data = util.KeyValuesToTable(file.Read("addons/" .. dir .. "/addon.txt", "GAME") or "")

            if data.name then
                AOC.MountedLegacy[data.name] = true
            end
        end
    end
end

function AOC:IsLegacyInstalled(id)
    return AOC.MountedLegacy[id] ~= nil
end

function AOC:IsLegacyMounted(id)
    return AOC.MountedLegacy[id] or false
end

function AOC:GenerateUpdateFile()
    local str = "#!/bin/sh\n\n"

    for k, v in pairs(self.Legacy) do
        if self.MountedLegacy[k] then continue end
        str = str .. 'if [ -d "$(dirname "$0")"\\\\"' .. k .. '" ]; then\n'
        str = str .. '    cd "$(dirname "$0")"\\\\"' .. k .. '"\n'
        str = str .. '    git pull "' .. v .. '"\n'
        str = str .. 'else\n'
        str = str .. '    cd "$(dirname "$0")"\n'
        str = str .. '    git clone "' .. v .. '" "' .. k .. '"\n'
        str = str .. 'fi\n\n'
    end

    str = str .. 'echo Update Finished, Press Enter...\nread'
    file.Write("3k Addons Installer.txt", str)
end

local PANEL = {}

----------------------
----Install Giude ----
----------------------
function PANEL:Init()
    self.page_number = 1
    self.close = vgui.Create("DButton", self)
    self.close:SetText("")

    self.close.DoClick = function()
        surface.PlaySound("ui/buttonclick.wav")
        self:Remove()
    end

    self.close.Paint = function(self_p, w, h)
        draw.SimpleText("r", "Marlett", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.git_link = vgui.Create("DButton", self)
    self.git_link:SetText("")

    self.git_link.Paint = function(self_p, w, h)
        if self_p.Depressed then
            draw.RoundedBox(4, 0, 0, w, h, Color(110, 150, 250, 255))
        elseif self_p.Hovered then
            draw.RoundedBox(4, 0, 0, w, h, Color(150, 150, 150, 255))
        else
            draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100, 255))
        end

        draw.SimpleText("Open git Website / Copy Link", "TKFont25", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.git_link.DoClick = function()
        surface.PlaySound("ui/buttonclickrelease.wav")
        gui.OpenURL("https://git-scm.com/downloads")
        SetClipboardText("https://git-scm.com/downloads")
    end

    self.previous_page = vgui.Create("DButton", self)
    self.previous_page:SetText("")

    self.previous_page.Paint = function(self_p, w, h)
        if self.page_number == 1 then
            draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100, 255))

            return
        end

        if self_p.Depressed then
            draw.RoundedBox(4, 0, 0, w, h, Color(110, 150, 250, 255))
        elseif self_p.Hovered then
            draw.RoundedBox(4, 0, 0, w, h, Color(150, 150, 150, 255))
        else
            draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100, 255))
        end

        draw.SimpleText("< < Previous < <", "TKFont25", w / 2, 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    end

    self.previous_page.DoClick = function()
        if self.page_number == 1 then return end

        if self.page_number == 2 then
            self.git_link:SetVisible(true)
        end

        surface.PlaySound("ui/buttonclickrelease.wav")
        self.page_number = self.page_number - 1
    end

    self.next_page = vgui.Create("DButton", self)
    self.next_page:SetText("")

    self.next_page.Paint = function(self_p, w, h)
        if self.page_number ~= 1 then
            self.git_link:SetVisible(false)
        end

        if self.page_number == 5 then
            draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100, 255))

            return
        end

        if self_p.Depressed then
            draw.RoundedBox(4, 0, 0, w, h, Color(110, 150, 250, 255))
        elseif self_p.Hovered then
            draw.RoundedBox(4, 0, 0, w, h, Color(150, 150, 150, 255))
        else
            draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100, 255))
        end

        draw.SimpleText("> > Next > >", "TKFont25", w / 2, 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    end

    self.next_page.DoClick = function()
        if self.page_number == 5 then return end
        surface.PlaySound("ui/buttonclickrelease.wav")
        self.page_number = self.page_number + 1
    end
end

function PANEL:PerformLayout(w, h)
    self:SetSize(535, 300)
    self:SetPos(0, 0)
    self.close:SetSize(20, 20)
    self.close:SetPos(w - 20, 0)
    self.git_link:SetSize(w - 60, 50)
    self.git_link:SetPos(30, 133.5)
    self.previous_page:SetSize(260, 35)
    self.previous_page:SetPos(5, 255)
    self.next_page:SetSize(260, 35)
    self.next_page:SetPos(270, 255)
end

function PANEL:DrawPageOne(w, h)
    draw.SimpleText("Step 1", "TKFont45", w / 2, 22, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    draw.SimpleText([[Install git]], "TKFont25", 8, 74, Color(255, 255, 255, 255))
end

function PANEL:DrawPageTwo(w, h)
    draw.SimpleText("Step 2", "TKFont45", w / 2, 22, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    draw.SimpleText([[Open \garrysmod\data\]], "TKFont25", 8, 74, Color(255, 255, 255, 255))
    draw.SimpleText([[Copy "3k Addons Installer.txt"]], "TKFont25", 8, 104, Color(255, 255, 255, 255))
    draw.SimpleText([[Move it to \garrysmod\addons\]], "TKFont25", 8, 134, Color(255, 255, 255, 255))
end

function PANEL:DrawPageThree(w, h)
    draw.SimpleText("Step 3", "TKFont45", w / 2, 22, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    draw.SimpleText([[Rename "3k Addons Installer.txt"]], "TKFont25", 8, 74, Color(255, 255, 255, 255))
    draw.SimpleText([[to "3k Addons Installer.sh"]], "TKFont25", 8, 104, Color(255, 255, 255, 255))
end

function PANEL:DrawPageFour(w, h)
    draw.SimpleText("Step 4", "TKFont45", w / 2, 22, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    draw.SimpleText([[Run "3k Addons Installer.sh"]], "TKFont25", 8, 74, Color(255, 255, 255, 255))
end

function PANEL:DrawPageFive(w, h)
    draw.SimpleText("Step 5", "TKFont45", w / 2, 22, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    draw.SimpleText([[Restart garrysmod]], "TKFont25", 8, 74, Color(255, 255, 255, 255))
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
    draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(100, 100, 100, 255))
    draw.RoundedBoxEx(4, 1, 1, w - 2, 20, Color(150, 150, 150, 255), true, true)
    draw.SimpleText("Addon Installation Guide", "TKFont18", 5, 2.5, Color(255, 255, 255, 255))
    draw.RoundedBox(4, 4, 72, w - 8, 173, Color(50, 50, 50, 255))

    if self.page_number == 1 then
        self:DrawPageOne(w, h)
    elseif self.page_number == 2 then
        self:DrawPageTwo(w, h)
    elseif self.page_number == 3 then
        self:DrawPageThree(w, h)
    elseif self.page_number == 4 then
        self:DrawPageFour(w, h)
    elseif self.page_number == 5 then
        self:DrawPageFive(w, h)
    end

    return true
end

vgui.Register("tk_addon_guide", PANEL, "DPanel")
PANEL = {}

---------------------
---- Addon Panel ----
---------------------
function PANEL:Init()
    self:SetTitle("")
    self:SetVisible(true)
    self:SetDraggable(false)
    self:SetSizable(false)
    self:ShowCloseButton(false)
    self:SetScreenLock(true)
    self:MakePopup()
    self.close = vgui.Create("DButton", self)
    self.close:SetText("")

    self.close.DoClick = function()
        surface.PlaySound("ui/buttonclick.wav")
        self:Remove()
    end

    self.close.Paint = function(self_p, w, h)
        draw.SimpleText("r", "Marlett", w / 2, h / 2, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    self.list = vgui.Create("DListView", self)
    self.list:SetMultiSelect(false)
    self.list:AddColumn("Addon Name")
    local column
    column = self.list:AddColumn("Type")
    column:SetMinWidth(75)
    column:SetMaxWidth(75)
    column = self.list:AddColumn("Installed")
    column:SetMinWidth(75)
    column:SetMaxWidth(75)
    column = self.list:AddColumn("Mounted")
    column:SetMinWidth(75)
    column:SetMaxWidth(75)
    self.install = vgui.Create("DButton", self)
    self.install:SetText("")

    self.install.Paint = function(self_p, w, h)
        if not AOC.missing_addon then
            draw.SimpleText("Required Addons Are Insalled", "TKFont25", w / 2, 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)

            return
        end

        if self_p.Depressed then
            draw.RoundedBox(4, 0, 0, w, h, Color(110, 150, 250, 255))
        elseif self_p.Hovered then
            draw.RoundedBox(4, 0, 0, w, h, Color(150, 150, 150, 255))
        else
            draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100, 255))
        end

        draw.SimpleText("Open Installation Guide", "TKFont25", w / 2, 5, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER)
    end

    self.install.DoClick = function()
        if not AOC.missing_addon then return end
        surface.PlaySound("ui/buttonclickrelease.wav")
        vgui.Create("tk_addon_guide", self)
    end
end

function PANEL:Populate()
    for k, v in pairs(AOC.Legacy) do
        self.list:AddLine(k, "Git", tostring(AOC:IsLegacyInstalled(k)), tostring(AOC:IsLegacyMounted(k)), v)
    end

    self.list:SelectFirstItem()
end

function PANEL:PerformLayout(w, h)
    self:SetSize(535, 300)
    self:SetPos(ScrW() / 2 - 267.5, ScrH() / 2 - 150)
    self.close:SetSize(20, 20)
    self.close:SetPos(w - 20, 0)
    self.list:SetSize(w - 10, 215)
    self.list:SetPos(5, 30)
    self.install:SetSize(525, 35)
    self.install:SetPos(5, 255)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 255))
    draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(100, 100, 100, 255))
    draw.RoundedBoxEx(4, 1, 1, w - 2, 20, Color(150, 150, 150, 255), true, true)
    draw.SimpleText("Server Addon List", "TKFont18", 5, 2.5, Color(255, 255, 255, 255))

    return true
end

vgui.Register("tk_addon", PANEL, "DFrame")
PANEL = {}

hook.Add("Initialize", "AddonCheck", function()
    AOC:GetLegacyAddons()
    AOC:GenerateUpdateFile()

    for k, v in pairs(AOC.Legacy) do
        if not AOC.MountedLegacy[k] then
            AOC.missing_addon = true
            RunConsoleCommand("tk_aoc_show", AOC.missing_addon and 1 or 0)

            return
        end
    end

    AOC.missing_addon = false
    RunConsoleCommand("tk_aoc_show", AOC.missing_addon and 1 or 0)
end)

hook.Add("HUDPaint", "AddonCheck", function()
    if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() then return end

    if Show:GetBool() then
        RunConsoleCommand("3k_addon_check")
    end

    hook.Remove("HUDPaint", "AddonCheck")
end)

concommand.Add("3k_addon_check", function(ply, cmd, arg)
    local panel = vgui.Create("tk_addon")
    panel:Populate()
end)
