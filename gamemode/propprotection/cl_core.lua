
local PP = {
	BuddySettings = {"Tool Gun", "Gravity Gun", "Phys Gun", "Use", "Duplicator", "CPPI"},
	BuddyTable = {},
	ShareTable = {}
}

///--- Functions ---\\\
function PP.GetByUniqueID(uid)
	for k,v in pairs(player.GetAll()) do
		if v:GetNWString("UID", "") == uid then
			return v
		end
	end
	return false
end

function PP.GetOwner(ent)
	if !IsValid(ent) then return nil, nil end
	local uid = ent:GetNWString("UID", "none")
	if uid == "none" then return nil, nil end
	local ply = PP.GetByUniqueID(uid)
	if !IsValid(ply) then return NULL, uid
	else return ply, uid end
end

function PP.IsBuddy(tar, method)
	if !IsValid(tar) || !method then return false end	
	taruid = tar:GetNWString("UID")
	if PP.BuddyTable && PP.BuddyTable[taruid] then
		if PP.BuddyTable[taruid][method] then return true end
	end
	return false
end

function PP.GetBuddyTypes()
	return PP.BuddySettings
end

function PP.GetShareTypes()
	local List = {}
	for k,v in pairs(PP.BuddySettings) do
		if v != "CPPI" then
			table.insert(List, v)
		end
	end
	return List
end
///--- ---\\\

///--- Menus ---\\\
local Open = false
usermessage.Hook("PP_Menu1", function()
	local Client = LocalPlayer()
	
	if !Open then
		local tr = Client:GetEyeTrace()
		if IsValid(tr.Entity) then
			local owner, id = PP.GetOwner(tr.Entity)
			if owner == Client then
				local eid = tr.Entity:EntIndex()
				Open = true
				
				local Panel = vgui.Create("DFrame")
				Panel:SetTitle("PP Share Menu")
				Panel:SetSize(150, 225)
				Panel:Center()
				Panel:SetVisible( true )
				Panel:SetDraggable(true)
				Panel:ShowCloseButton(false)
				Panel:MakePopup()
				
				local Options = vgui.Create("DPanelList", Panel)
				Options:SetPos(5, 25)
				Options:SetSize(140, 170)
				Options:SetSpacing(5)
				Options:SetPadding(5)
				Options:EnableHorizontal(false)
				Options:EnableVerticalScrollbar(true)
				
				for k,v in pairs(PP.GetShareTypes()) do
					local CheckBox = vgui.Create("DCheckBoxLabel")
					CheckBox:SetText(v)
					if PP.ShareTable[eid] && PP.ShareTable[eid][v] then
						CheckBox:SetValue(1)
					else
						CheckBox:SetValue(0)
					end
					CheckBox:SizeToContents()
					CheckBox.OnChange = function(CheckBox, Value)
						PP.ShareTable[eid] = PP.ShareTable[eid] || {}
						PP.ShareTable[eid][v] = Value
						RunConsoleCommand("pp_updateshare", eid, v, tostring(Value))
					end
					Options:AddItem(CheckBox)
				end
				
				local Close = vgui.Create("DButton", Panel)
				Close:SetPos(18.75, 200)
				Close:SetSize(112.5, 20)
				Close:SetText("Close")
				Close.DoClick = function(button)
					surface.PlaySound("ui/buttonclickrelease.wav")
					Open = false
					Panel:Remove()
				end
			end
		end
	end
end)

usermessage.Hook("PP_Menu2", function()
	local SelectedPlayer = SelectedPlayer || nil
	local Client = LocalPlayer()
	
	if !Open then
		Open = true
		
		local Panel = vgui.Create("DFrame")
		Panel.Active = "Options"
		Panel:SetTitle("PP Menu")
		Panel:SetSize(295, 225)
		Panel:Center()
		Panel:SetVisible( true )
		Panel:SetDraggable(true)
		Panel:ShowCloseButton(false)
		Panel:MakePopup()
		Panel.PaintOver = function()
			surface.SetFont("Default")
			local x, y = surface.GetTextSize(Panel.Active)
			x = math.max(70, x + 5)
			
			draw.RoundedBox(4, 40, 25, 70, 20, Color(55, 57, 61))
			draw.RoundedBox(4, 220 - x / 2, 25, x, 20, Color(55, 57, 61))
			draw.SimpleText("Players", "Default", 75, 27.5, Color(255, 255, 255), TEXT_ALIGN_CENTER)
			draw.SimpleText(Panel.Active, "Default", 220, 27.5, Color(255, 255, 255), TEXT_ALIGN_CENTER)
		end
		
		local List = vgui.Create("DPanelList", Panel)
		List:SetPos(5, 50)
		List:SetSize(140, 145)
		List:SetSpacing(5)
		List:SetPadding(5)
		List:EnableHorizontal(false)
		List:EnableVerticalScrollbar(true)
		
		local Options = vgui.Create("DPanelList", Panel)
		Options:SetPos(150, 50)
		Options:SetSize(140, 145)
		Options:SetSpacing(5)
		Options:SetPadding(5)
		Options:EnableHorizontal(false)
		Options:EnableVerticalScrollbar(true)
		
		for k,v in pairs(player.GetAll()) do
			local uid = v:GetNWString("UID")
			local button = vgui.Create("DButton")
			button:SetText(v:Name())
			button.DoClick = function(button)
				Panel.Active = v:Name()
				Options:Clear()
				if Client == v then
					local clean = vgui.Create("DButton")
					clean:SetText("Clean Up Props")
					clean.DoClick = function(clean)
						RunConsoleCommand("pp_cleanup")
					end
					Options:AddItem(clean)
				else
					for l,b in pairs(PP.GetBuddyTypes()) do
						local CheckBox = vgui.Create("DCheckBoxLabel")
						CheckBox:SetText(b)
						if PP.BuddyTable[uid] && PP.BuddyTable[uid][b] then
							CheckBox:SetValue(1)
						else
							CheckBox:SetValue(0)
						end
						CheckBox:SizeToContents()
						CheckBox.OnChange = function(CheckBox, Value)
							PP.BuddyTable[uid] = PP.BuddyTable[uid] || {}
							PP.BuddyTable[uid][b] = Value
							RunConsoleCommand("pp_updatebuddy", uid, b, tostring(Value))
						end
						Options:AddItem(CheckBox)
					end
					
					if Client:HasAccess(4) && Client:CanRunOn(v) then
						local clean = vgui.Create("DButton")
						clean:SetText("Clean Up Props")
						clean.DoClick = function(clean)
							RunConsoleCommand("pp_cleanup", v:GetNWString("UID"))
						end
						Options:AddItem(clean)
					end
				end
			end
			List:AddItem(button)
		end
		
		if Client:HasAccess(4) then
			local button = vgui.Create("DButton")
			button:SetText("Disconnected")
			button.DoClick = function(button)
				Panel.Active = "Disconnected"
				Options:Clear()
				local clean = vgui.Create("DButton")
				clean:SetText("Clean Up Props")
				clean.DoClick = function(clean)
					RunConsoleCommand("pp_cleanup", "DCP")
				end
				Options:AddItem(clean)
			end
			List:AddItem(button)
		end
		
		local Close = vgui.Create("DButton", Panel)
		Close:SetPos(91.5, 200)
		Close:SetSize(112.5, 20)
		Close:SetText("Close")
		Close.DoClick = function(button)
			surface.PlaySound("ui/buttonclickrelease.wav")
			Open = false
			Panel:Remove()
		end
	end
end)
///--- ---\\\

///--- Datastreams ---\\\
net.Receive("PPBuddy", function()
    PP.BuddyTable = net.ReadTable()
end)

net.Receive("PPShare", function()
	PP.ShareTable = net.ReadTable()
end)
///--- ---\\\

///--- Owner Display ---\\\
hook.Add("HUDPaint", "PP_OwnerBox", function()
	local Client = LocalPlayer()
	if !Client:Alive() then return end
	local tr = Client:GetEyeTraceNoCursor()
	if tr.HitNonWorld && IsValid(tr.Entity) then
		local scrw, scrh = surface.ScreenWidth(), surface.ScreenHeight()
		local owner , uid = PP.GetOwner(tr.Entity)
		local name = "World"
		if IsValid(owner) then
			name = owner:Name()
		elseif uid then
			name = "Disconnected"
		end 
		
		surface.SetFont("TKFont12")
		local x, y = surface.GetTextSize(name)
		
		draw.RoundedBox(4, scrw - x - 9.5, scrh / 4 - 1, x + 7, y + 7, Color(55,57,61))
		draw.RoundedBox(4, scrw - x - 8.5, scrh / 4, x + 5, y + 5, Color(150,150,150))
		draw.SimpleText(name, "TKFont12", scrw - 6, scrh/4 + 2.5, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
		
		local class = tr.Entity:GetClass()
		x, y = surface.GetTextSize(class)
		
		draw.RoundedBox(4, scrw - x - 9.5, scrh / 4 + y + 8, x + 7, y + 7, Color(55,57,61))
		draw.RoundedBox(4, scrw - x - 8.5, scrh / 4 + y + 9, x + 5, y + 5, Color(150,150,150))
		draw.SimpleText(class, "TKFont12", scrw - 6, scrh/4 + y + 11.5, Color(255,255,255), TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
	end
end)
///--- ---\\\

///--- CPPI ---\\\
CPPI = CPPI || {}

function CPPI:GetNameFromUID(uid)
	if !uid then return nil end
	local ply = PP.GetByUniqueID(tostring(uid))
	if !IsValid(ply) then return nil end
	return string.sub(ply:Name(), 1, 31)
end

function _R.Player:CPPIGetFriends()
	local TrustedPlayers = {}
	local uid = self:GetNWString("UID")
	for k,v in pairs(player.GetAll()) do
		if PP.IsBuddy(v, "CPPI") then
			table.insert(TrustedPlayers, v)
		end
	end
	return TrustedPlayers
end

function _R.Entity:CPPIGetOwner()
	return PP.GetOwner(self)
end
///--- ---\\\