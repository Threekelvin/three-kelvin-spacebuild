local Show = CreateClientConVar("tk_aoc_show", 1, true, false)

local AOC = {}
AOC.Legacy = {
    ["SpaceBuild Enhancement Project"]					= "https://github.com/SnakeSVx/sbep/trunk/",
    ["Spacebuild"]										= "http://spacebuild.googlecode.com/svn/trunk/sb3/spacebuild_content/",
    ["Shadowscion's Construction Props"]				= "http://shadowscions-construction-props.googlecode.com/svn/trunk/",
    ["TKMP"]											= "http://3k-model-pack.googlecode.com/svn/trunk/",
    ["Wiremod"]											= "https://github.com/wiremod/wire/trunk/",
    ["Wire Unofficial Extras"]							= "https://github.com/wiremod/wire-extras/trunk/"
}
AOC.Workshop = {
    ["104694154"]										= "104694154",
    ["106904944"]										= "106904944",
    ["107155115"]										= "107155115"
}
AOC.MountedLegacy = {}

function AOC:GetLegacyAddons()
    local _,root = file.Find("addons/*", "GAME")
    
    for _,dir in pairs(root) do
        if file.Exists("addons/" ..dir.. "/info.txt", "GAME") then
            local data = util.KeyValuesToTable(file.Read("addons/"..dir.."/info.txt", "GAME") || "")
            if data.name then
                AOC.MountedLegacy[data.name] = false
            end
        end
        
        if file.Exists("addons/" ..dir.. "/addon.txt", "GAME") then
            local data = util.KeyValuesToTable(file.Read("addons/"..dir.."/addon.txt", "GAME") || "")
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
    return AOC.MountedLegacy[id] || false
end

function AOC:IsWorkshopInstalled(id)
    return steamworks.IsSubscribed(id)
end

function AOC:IsWorkshopMounted(id)
    for k,v in pairs(engine.GetAddons()) do
        if v.wsid != id then continue end
        return true
    end
    return false
end

function AOC:BuildMenu()
    local Panel = vgui.Create("DFrame")
    Panel.opticon = Material("icon16/cog.png")
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
        draw.SimpleText("r", "Marlett", w - 10, 3, Color(255,255,255,255), TEXT_ALIGN_CENTER)
        
        surface.SetDrawColor(Color(255, 255, 255, 255))
        surface.SetMaterial(panel.opticon)
        surface.DrawTexturedRect(w - 35, 3, 16, 16)
    end
    
    local close = vgui.Create("DButton", Panel)
    close:SetPos(525, 0)
    close:SetSize(20, 20)
    close:SetText("")
    close.DoClick = function()
        surface.PlaySound("ui/buttonclick.wav")
        Panel:Remove()
    end
    close.Paint = function() end
    
    local options = vgui.Create("DButton", Panel)
    options:SetPos(500, 0)
    options:SetSize(20, 20)
    options:SetText("")
    options.DoClick = function()
        local menu = DermaMenu()
        if Show:GetBool() then
            menu:AddOption("Dont Show On Join", function()
                RunConsoleCommand("tk_aoc_show", "0")
            end)
        else
            menu:AddOption("Show On Join", function()
                RunConsoleCommand("tk_aoc_show", "1")
            end)
        end
        menu:Open()
    end
    options.Paint = function() end
    
    local copy
    local List = vgui.Create( "DListView", Panel )
    List:SetPos(5, 30)
    List:SetSize(525, 215)
    List:SetMultiSelect( false )
    List:AddColumn("Addon Name"):SetFixedWidth(300)
    List:AddColumn("Type"):SetFixedWidth(75)
    List:AddColumn("Installed"):SetFixedWidth(75)
    List:AddColumn("Mounted"):SetFixedWidth(75)
    
    for k,v in pairs(self.Legacy) do
        local line = List:AddLine(k, "SVN", tostring(self:IsLegacyInstalled(k)), tostring(self:IsLegacyMounted(k)), v)
        line.OnSelect = function()
            copy.txt = "Copy Selected Link"
        end
    end
    
    for k,v in pairs(self.Workshop) do
        local line = List:AddLine(k, "Workshop", tostring(self:IsWorkshopInstalled(k)), tostring(self:IsWorkshopMounted(k)), v)
        line.OnSelect = function()
            copy.txt = "Open Workshop Page"
        end
        
        steamworks.FileInfo(k, function(data) 
            if !data then return end
            line:SetValue(1, data.title) 
        end)
    end
    
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
            if line[1]:GetValue(2) == "SVN" then
                SetClipboardText(line[1]:GetValue(5) || "")
            elseif line[1]:GetValue(2) == "Workshop" then
                steamworks.ViewFile(line[1]:GetValue(5))
            end
        end
    end
end

hook.Add("Initialize", "AddonCheck", function()
    AOC:GetLegacyAddons()
end)

hook.Add("HUDPaint", "AddonCheck", function()
	if !IsValid(LocalPlayer()) || !LocalPlayer():Alive() then return end
    if Show:GetInt() == 1 then
        RunConsoleCommand("3k_addon_check")
    end
	hook.Remove("HUDPaint", "AddonCheck")
end)

concommand.Add("3k_addon_check", function(ply, cmd, arg)
    AOC:BuildMenu()
end)