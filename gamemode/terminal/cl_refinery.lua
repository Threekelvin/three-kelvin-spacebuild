
local PANEL = {}

local function MakePanel(res, val)
	local btn = vgui.Create("DButton")
	btn:SetSkin("Terminal")
	btn:SetSize(0, 65)
	btn.active = true
	btn.res = res
	btn.pres = TK.RD:GetResourceName(res)
	btn.val = val
	btn:SetText("")
	
	btn.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "TKResPanel", btn, w, h)
		return true
	end

	return btn
end

local function AddResource(panel)
	local storage = TK.DB:GetPlayerData("terminal_storage")
	
	local mouseblock = vgui.Create("DPanel", panel.Terminal)
	mouseblock:SetPos(0, 0)
	mouseblock:SetSize(panel.Terminal:GetWide(), panel.Terminal:GetTall())
	mouseblock.Paint = function() 
		return true
	end
	
	local frame = vgui.Create("DPanel", mouseblock)
	frame:SetSkin("Terminal")
	frame:SetSize(250, 87)
	frame:Center()
	frame.title = "Input Amount To Refine"
	frame.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "TKFrame", frame, w, h)
		return true
	end
	
	local close = vgui.Create("DButton", frame)
	close:SetSize(20, 20)
	close:SetPos(229, 1)
	close:SetText("")
	close.Paint = function() 
		return true
	end
	close.DoClick = function()
		surface.PlaySound("ui/buttonclick.wav")
		mouseblock:Remove()
	end
	
	local textbox = vgui.Create("DTextEntry", frame)
	textbox:SetSkin("Terminal")
	textbox:SetSize(240, 22)
	textbox:SetPos(5, 25)
	textbox:SetNumeric(true)
	textbox:SetMultiline(false)
	textbox:SetText(tostring(storage[panel.RefineSetting] || 0))
	textbox:RequestFocus()
	textbox.style = {"dark"}
	textbox.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "TKTextBox", textbox, w, h)
		return true
	end
	
	local accept = vgui.Create("DButton", frame)
	accept:SetSkin("Terminal")
	accept:SetSize(240, 30)
	accept:SetPos(5, 52)
	accept:SetText("")
	accept.text = "Accept"
	accept.style = {"normal", "dim"}
	accept.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "TKButton", accept, w, h)
		return true
	end
	accept.DoClick = function()
		if !IsValid(panel.Terminal) then return end
		surface.PlaySound("ui/buttonclickrelease.wav")
		local storage = TK.DB:GetPlayerData("terminal_storage")
		local val = math.floor(tonumber(textbox:GetValue()) || 0)
		if val == 0 then
			mouseblock:Remove()
		elseif val < 0 then
			panel:ShowError("Nil Value Entered")
		else
			if val > storage[panel.RefineSetting] then
				val = storage[panel.RefineSetting]
			end
			
			panel.Terminal.AddQuery("refine", panel.RefineSetting, val)
			
			mouseblock:Remove()
		end
	end
end

usermessage.Hook("3k_terminal_refinery_start", function(msg)
	-- Ghost Hook
end)

usermessage.Hook("3k_terminal_refinery_finish", function(msg)
	-- Ghost Hook
end)

function PANEL:Init()
	self:SetSkin("Terminal")
	self.NextThink = 0
	self.RefineSetting = "asteroid_ore"
	
	self.selectore = vgui.Create("DButton", self)
	self.selectore:SetSkin("Terminal")
	self.selectore:SetText("")
	self.selectore.style = {"dim", "dark"}
	self.selectore.Paint = function(panel, w, h)
		if self.RefineSetting == "asteroid_ore" then
			self.selectore.text = "> Ore <"
		else
			self.selectore.text = "Ore"
		end
		derma.SkinHook("Paint", "TKButton", self.selectore, w, h)
		return true
	end
	self.selectore.DoClick = function()
		surface.PlaySound("ui/buttonclickrelease.wav")
		self.RefineSetting = "asteroid_ore"
	end
	
	self.selecttib = vgui.Create("DButton", self)
	self.selecttib:SetSkin("Terminal")
	self.selecttib:SetText("")
	self.selecttib.style = {"dim", "dark"}
	self.selecttib.Paint = function(panel, w, h)
		if self.RefineSetting == "raw_tiberium" then
			self.selecttib.text = "> Tib <"
		else
			self.selecttib.text = "Tib"
		end
		derma.SkinHook("Paint", "TKButton", self.selecttib, w, h)
		return true
	end
	self.selecttib.DoClick = function()
		surface.PlaySound("ui/buttonclickrelease.wav")
		self.RefineSetting = "raw_tiberium"
	end
	
	self.autorefine = vgui.Create("DButton", self)
	self.autorefine:SetSkin("Terminal")
	self.autorefine:SetText("")
	self.autorefine.style = {"dim", "dark"}
	self.autorefine.Paint = function(panel, w, h)
		if self.RefineSetting == "asteroid_ore" then
			if tobool(TK.DB:GetPlayerData("terminal_setting").auto_refine_ore) then
				self.autorefine.text = "Disable Auto"
			else
				self.autorefine.text = "Enable Auto"
			end
		elseif self.RefineSetting == "raw_tiberium" then
			if tobool(TK.DB:GetPlayerData("terminal_setting").auto_refine_tib) then
				self.autorefine.text = "Disable Auto"
			else
				self.autorefine.text = "Enable Auto"
			end
		end
		derma.SkinHook("Paint", "TKButton", self.autorefine, w, h)
		return true
	end
	self.autorefine.DoClick = function()
		if !IsValid(self.Terminal) then return end
		surface.PlaySound("ui/buttonclickrelease.wav")
		self.Terminal.AddQuery("toggleautorefine", self.RefineSetting)
	end
	
	self.addresource = vgui.Create("DButton", self)
	self.addresource:SetSkin("Terminal")
	self.addresource:SetText("")
	self.addresource.style = {"dim", "dark"}
	self.addresource.Paint = function(panel, w, h)
		if self.RefineSetting == "asteroid_ore" then
			self.addresource.text = "Add Ore"
		elseif self.RefineSetting == "raw_tiberium" then
			self.addresource.text = "Add Tib"
		end
		derma.SkinHook("Paint", "TKButton", self.addresource, w, h)
		return true
	end
	self.addresource.DoClick = function()
		if !IsValid(self.Terminal) || self.Analyzing then return end
		surface.PlaySound("ui/buttonclickrelease.wav")
		AddResource(self)
	end
	
	self.refinery = vgui.Create("DPanelList", self)
	self.refinery:SetSkin("Terminal")
	self.refinery.list = {}
	self.refinery:SetSpacing(5)
	self.refinery:SetPadding(5)
	self.refinery:EnableHorizontal(false)
	self.refinery:EnableVerticalScrollbar(true)
	
	self.refineall = vgui.Create("DButton", self)
	self.refineall:SetSkin("Terminal")
	self.refineall:SetText("")
	self.refineall.style = {"dim", "dark"}
	self.refineall.Paint = function(panel, w, h)
		if self.Analyzing then
			self.refineall.text = "Analyzing"
		else
			if self.refining then
				self.refineall.text = "Cancel Current Process"
			else
				self.refineall.text = "Refine All Resources"
			end
			
		end
		derma.SkinHook("Paint", "TKButton", self.refineall, w, h)
		return true
	end
	self.refineall.DoClick = function()
		if !IsValid(self.Terminal) || self.Analyzing then return end
		surface.PlaySound("ui/buttonclickrelease.wav")

		if self.refining then
			self.Terminal.AddQuery("cancelrefine")
		else
			self.Terminal.AddQuery("refineall")
		end
	end
	
	usermessage.Hook("3k_terminal_refinery_start", function(msg)
		if !IsValid(self) then return end
		self.Analyzing = true
		timer.Simple(3, function()
			if !IsValid(self) then return end
			self.Analyzing = false
		end)
		
		if msg:ReadBool() then
			GAMEMODE:AddNotify("Refining Process Started", NOTIFY_GENERIC, 10)
			surface.PlaySound("ambient/water/drip"..math.random(1, 4)..".wav")
		end
	end)

	usermessage.Hook("3k_terminal_refinery_finish", function(msg)
		if !IsValid(self) then return end
		self.Analyzing = false
		GAMEMODE:AddNotify("Refining Process Complete", NOTIFY_GENERIC, 10)
		surface.PlaySound("ambient/water/drip"..math.random(1, 4)..".wav")
	end)
end

function PANEL:ShowError(msg)
	self.Error = msg
	timer.Create("TermError_Refinery", 2, 1, function()
		self.Error = nil
	end)
end

function PANEL:PerformLayout()
	self.selectore:SetPos(10, 80)
	self.selectore:SetSize(117.5, 40)
	
	self.selecttib:SetPos(132.5, 80)
	self.selecttib:SetSize(117.5, 40)
	
	self.autorefine:SetPos(10, 415)
	self.autorefine:SetSize(240, 50)
	
	self.addresource:SetPos(10, 470)
	self.addresource:SetSize(240, 50)
	
	self.refinery:SetPos(270, 120)
	self.refinery:SetSize(500, 345)
	
	self.refineall:SetSize(500, 50)
	self.refineall:SetPos(265, 470)
end

function PANEL:Think()
	if CurTime() < self.NextThink then return end
	self.NextThink = CurTime() + 1
	
	local Refinery = TK.DB:GetPlayerData("terminal_refinery")
	self.OreCost = TK.TD:Ore("asteroid_ore")
	self.OreSpeed = TK.TD:Refine("asteroid_ore")
	self.OreAmount = math.floor(600 * self.OreSpeed)
	self.TibCost = TK.TD:Ore("raw_tiberium")
	self.TibSpeed = TK.TD:Refine("raw_tiberium")
	self.TibAmount = math.floor(600 * self.TibSpeed)
	
	local settings = TK.DB:GetPlayerData("terminal_setting")
	if settings.refine_started != 0 then
		self.refining = true
		local eta = math.floor(settings.refine_started + settings.refine_length - TK.DB:OSTime())
		if eta < 1 then eta = 1 end
		self.eta = "Estimated Time To Completion:    "..TK:FormatTime(eta / 60)
	else
		self.refining = false
		self.eta = "No Refining In Process"
	end
	
	
	//-- Refinery --\\
	for k,v in pairs(self.refinery.list) do
		if !Refinery[k] then
			self.refinery:RemoveItem(self.refinery.list[k])
			self.refinery.list[k] = nil
		end
	end
	
	for k,v in pairs(Refinery) do
		if v > 0 then
			if !self.refinery.list[k] then
				local panel = MakePanel(k, v)

				self.refinery.list[k] = panel
				self.refinery:AddItem(panel)
			else
				self.refinery.list[k].val = v
			end
		else
			if self.refinery.list[k] then
				self.refinery:RemoveItem(self.refinery.list[k])
				self.refinery.list[k] = nil
			end
		end
	end
end

function PANEL.Paint(self, w, h)
	derma.SkinHook("Paint", "TKRefinery", self, w, h)
	return true
end

vgui.Register("tk_refinery", PANEL)