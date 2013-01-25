
local function GetLegacyAddons()
	local _,dirs = file.Find( "addons/*", "GAME" )
	local addons = {}
	for _,dir in pairs( dirs ) do

		local info = nil
		local tInfo = nil
		if !file.Exists( "addons/"..dir.."/addon.txt", "GAME" ) && file.Exists( "addons/"..dir.."/info.txt", "GAME" ) then
			info = file.Read( "addons/"..dir.."/info.txt", "GAME" )
			if info != nil then
				tInfo = util.KeyValuesToTable( info )
				Derma_Message( "Create a copy of 'info.txt'. Rename the copy 'addon.txt'", tInfo.name.." is not correctly installed." )
			end
		else
			info = file.Read( "addons/"..dir.."/addon.txt", "GAME" )
			if info != nil then
				tInfo = util.KeyValuesToTable( info )
			end
		end
		
		if tInfo != nil then
			table.insert( addons,  tInfo )
		end
		
	end
	
	return addons
end

local function CheckAddons()
	local addons = {
		["Advanced Duplicator"]								= "https://github.com/wiremod/AdvDuplicator/trunk/",
		["SpaceBuild Enhancement Project"]					= "https://github.com/SnakeSVx/sbep/trunk/",
		["Spacebuild"]										= "http://spacebuild.googlecode.com/svn/trunk/sb3/spacebuild_content/",
		["Shadowscion's Construction Props"]				= "http://shadowscions-construction-props.googlecode.com/svn/trunk/",
		["TKMP"]											= "http://3k-model-pack.googlecode.com/svn/trunk/",
		["Wiremod"]											= "https://github.com/wiremod/wire/trunk/",
		["Wire Unofficial Extras"]							= "https://github.com/wiremod/wire-extras/trunk/",
	}

	for k,v in pairs(GetLegacyAddons()) do
		addons[v.name] = nil
	end

	if( table.Count( addons ) > 0 ) then
		local Panel = vgui.Create("DFrame")
		Panel:SetSize(800, 300)
		Panel:Center()
		Panel:SetTitle( "" )
		Panel:SetVisible( true )
		Panel:SetDraggable( true )
		Panel:ShowCloseButton( false )
		Panel:SetScreenLock( true )
		Panel:MakePopup()
		Panel.Paint = function()
			draw.RoundedBox(4, 0, 0, 800, 300, Color(50,50,50,255))
			draw.RoundedBox(4, 1, 1, 798, 298, Color(100,100,100,255))
			draw.RoundedBoxEx(4, 1, 1, 798, 20, Color(150,150,150,255), true, true)
			draw.SimpleText("WARNING: Missing Addons", "TKFont18", 5, 2.5, Color(255,255,255,255))
			draw.SimpleText("r", "Marlett", 790, 5, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		end
		
		local close = vgui.Create("DButton", Panel)
		close:SetPos(780, 0)
		close:SetSize(20, 20)
		close:SetText("")
		close.DoClick = function()
			surface.PlaySound("ui/buttonclick.wav")
			Panel:Remove()
		end
		close.Paint = function() end
		
		local List = vgui.Create( "DListView", Panel )
		List:SetPos(10, 30)
		List:SetSize(780, 215)
		List:SetMultiSelect( false )
		List:AddColumn("Addon Name"):SetFixedWidth( 300 )
		List:AddColumn("SVN URL")	
		for k,v in pairs(addons) do
			List:AddLine(k, v)
		end
		
		local copy = vgui.Create("DButton", Panel)
		copy:SetPos(10, 255)
		copy:SetSize(780, 35)
		copy:SetText("")
		copy.Paint = function()
			if copy.Depressed then
				draw.RoundedBox(4, 0, 0, 780, 35, Color(110,150,250,255))
			elseif copy.Hovered then
				draw.RoundedBox(4, 0, 0, 780, 35, Color(150,150,150,255))
			else
				draw.RoundedBox(4, 0, 0, 780, 35, Color(100,100,100,255))
			end
			draw.SimpleText("Copy Selected SVN Link", "TKFont25", 390, 5, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		end
		copy.DoClick = function()
			surface.PlaySound("ui/buttonclickrelease.wav")
			local line = List:GetSelected()
			if ValidEntity(line[1]) then
				SetClipboardText(line[1]:GetValue(2) || "")
			end
		end
	end
end

hook.Add("Think", "AddonCheck", function()
	if !LocalPlayer():IsValid() || !LocalPlayer():Alive() then return end
	CheckAddons()
	hook.Remove("Think", "AddonCheck")
end)

concommand.Add("3k_addon_check", function(ply, cmd, arg)
	CheckAddons()
end)