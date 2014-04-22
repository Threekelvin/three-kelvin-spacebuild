local Show = CreateClientConVar("tk_aoc_show", 1, true, false)
local Version = CreateClientConVar("tk_aoc_version", 0, true, false)

local AOC = {}
AOC.ListVersion = 2 //change this to make it popup for everyone

AOC.Tutorial = {
}
AOC.Legacy = {
    ["SpaceBuild Enhancement Project"]      = "https://github.com/SnakeSVx/sbep.git",
    ["TKMP"]                                = "https://code.google.com/p/3k-model-pack/",
}
AOC.MountedLegacy = {}

function AOC:GetLegacyAddons()
    local _,root = file.Find("addons/*", "GAME")
    
    for _,dir in pairs(root) do
        if file.Exists("addons/" ..dir.. "/info.txt", "GAME") then
            local data = util.KeyValuesToTable(file.Read("addons/"..dir.."/info.txt", "GAME") or "")
            if data.name then
                AOC.MountedLegacy[data.name] = false
            end
        end
        
        if file.Exists("addons/" ..dir.. "/addon.txt", "GAME") then
            local data = util.KeyValuesToTable(file.Read("addons/"..dir.."/addon.txt", "GAME") or "")
            if data.name then
                AOC.MountedLegacy[data.name] = true
            end
        end
    end
end

function AOC:IsLegacyInstalled(id)
    return AOC.MountedLegacy[id] != nil
end

function AOC:IsLegacyMounted(id)
    return AOC.MountedLegacy[id] or false
end

function AOC:BuildMenu()
    local Panel = vgui.Create("DFrame")
    Panel:SetSize(535, 300)
    Panel:Center()
    Panel:SetTitle( "" )
    Panel:SetVisible( true )
    Panel:SetDraggable( true )
    Panel:ShowCloseButton( false )
    Panel:SetScreenLock( true )
    Panel:MakePopup()
    Panel.Paint = function(panel, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50,50,50,255))
        draw.RoundedBox(4, 1, 1, w - 2, h - 2, Color(100,100,100,255))
        draw.RoundedBoxEx(4, 1, 1, w - 2, 20, Color(150,150,150,255), true, true)
        draw.SimpleText("Server Addon List", "TKFont18", 5, 2.5, Color(255,255,255,255))
    end
    
    local close = vgui.Create("DButton", Panel)
    close:SetSize(20, 20)
    close:SetPos( Panel:GetWide() - close:GetWide(), 0 )
    close:SetText("")
    close.DoClick = function()
        surface.PlaySound("ui/buttonclick.wav")
        Panel:Remove()
    end
    close.Paint = function(panel, w, h)
        draw.SimpleText("r", "Marlett", w/2, h/2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    
    local options = vgui.Create("DButton", Panel)
    options:SetSize(20, 22)
    local x,_ = close:GetPos()
    options:SetPos( x - options:GetWide(), 0 )
    options:SetText("")
    options.DoClick = function()
        local menu = DermaMenu()
        menu:AddOption("Don't Show On Join", function()
            RunConsoleCommand("tk_aoc_show", "0")
        end)
        menu:Open()
    end
    options.Paint = function(panel, w, h)
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.SetMaterial( Material("icon16/cog.png") )
        surface.DrawTexturedRect( (w-16)/2, (h-16)/2, 16, 16 )
    end
    
    local copy
    local List = vgui.Create( "DListView", Panel )
    List:SetPos(5, 30)
    List:SetSize(525, 215)
    List:SetMultiSelect( false )
    List:AddColumn("Addon Name"):SetFixedWidth(300)
    List:AddColumn("Type"):SetFixedWidth(75)
    List:AddColumn("Installed"):SetFixedWidth(75)
    List:AddColumn("Mounted"):SetFixedWidth(75)
    
    local AutoHide = 0 // Prepare to set the AOC to hide if the player has all addons mounted.
    for k,v in pairs(self.Tutorial) do
        local line = List:AddLine(k, "Tutorial", "", "", v)
        line.OnSelect = function()
            copy.txt = "Open Tutorial Page"
        end
    end
    
    for k,v in pairs(self.Legacy) do
        local mounted = self:IsLegacyMounted(k)
        local line = List:AddLine(k, "Git", tostring(self:IsLegacyInstalled(k)), tostring(mounted), v)
        if !mounted then AutoHide = 1 end
        line.OnSelect = function()
            copy.txt = "Copy Selected Link"
        end
    end
    
    RunConsoleCommand("tk_aoc_show", AutoHide)
    
    copy = vgui.Create("DButton", Panel)
    copy.txt = "Copy Selected Link"
    copy:SetPos(5, 255)
    copy:SetSize(525, 35)
    copy:SetText("")
    copy.Paint = function(panel, w, h)
        if copy.Depressed then
            draw.RoundedBox(4, 0, 0, w, h, Color(110,150,250,255))
        elseif copy.Hovered then
            draw.RoundedBox(4, 0, 0, w, h, Color(150,150,150,255))
        else
            draw.RoundedBox(4, 0, 0, w, h, Color(100,100,100,255))
        end
        draw.SimpleText(panel.txt, "TKFont25", w / 2, 5, Color(255,255,255,255), TEXT_ALIGN_CENTER)
    end
    copy.DoClick = function()
        surface.PlaySound("ui/buttonclickrelease.wav")
        local line = List:GetSelected()
        if IsValid(line[1]) then
            if line[1]:GetValue(2) == "Tutorial" then
                gui.OpenURL(line[1]:GetValue(5))
            elseif line[1]:GetValue(2) == "Git" then
                SetClipboardText(line[1]:GetValue(5) or "")
            elseif line[1]:GetValue(2) == "Workshop" then
                steamworks.ViewFile(line[1]:GetValue(5))
            end
        end
    end
    
    List:SelectFirstItem()
end

hook.Add("Initialize", "AddonCheck", function()
    AOC:GetLegacyAddons()
    
    if Version:GetInt() != AOC.ListVersion then
        RunConsoleCommand("tk_aoc_show", "1")
        RunConsoleCommand("tk_aoc_version", AOC.ListVersion)
    end
end)

hook.Add("HUDPaint", "AddonCheck", function()
    if !IsValid(LocalPlayer()) or !LocalPlayer():Alive() then return end
    
    if Show:GetInt() == 1 then
        RunConsoleCommand("3k_addon_check")
    end
    hook.Remove("HUDPaint", "AddonCheck")
end)

concommand.Add("3k_addon_check", function(ply, cmd, arg)
    AOC:BuildMenu()
end)