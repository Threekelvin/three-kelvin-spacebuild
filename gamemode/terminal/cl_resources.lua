
local PANEL = {}

local function MakePanel(res, val, btnl, btnr)
	local btn = vgui.Create("DButton")
	btn:SetSkin("Terminal")
	btn:SetSize(0, 65)
	btn.active = true
	btn.res = res
	btn.pres = TK.RD.GetResourceName(res)
	btn.val = val
	btn:SetText("")
	
	btn.AddTextBox = function(func)
		btn.txtbox = vgui.Create("DTextEntry", btn)
		btn.txtbox:SetSkin("Terminal")
		btn.txtbox:SetNumeric(true)
		btn.txtbox:SetMultiline(false)
		btn.txtbox:SetText(tostring(btn.val))
		btn.txtbox:SetSize(btn:GetWide() - 65, 20) 
		btn.txtbox:SetPos(60, 35)
		btn.txtbox:RequestFocus()
		btn.txtbox.OnLoseFocus = function()
			btn.txtbox:Remove()
		end
		
		btn.txtbox.OnEnter = function()
			surface.PlaySound("ui/buttonclickrelease.wav")
			local val = math.Round(tonumber(btn.txtbox:GetValue()))
			btn.txtbox:Remove()
			pcall(func, btn, val)
		end
		
		btn.txtbox.style = {"dim"}
		btn.txtbox.Paint = function(panel, w, h)
			derma.SkinHook("Paint", "TKTextBox", btn.txtbox, w, h)
			return true
		end
	end
	
	btn.PerformLayout = function()
		if IsValid(btn.txtbox) then
			btn.txtbox:SetSize(btn:GetWide() - 65, 20) 
		end
	end
	
	btn.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "TKResPanel", btn, w, h)
		return true
	end
	
	if btnl then
		btn.DoClick = function()
			if btn.active then
				btn.active = false
				timer.Simple(1, function() if IsValid(btn) then btn.active = true end end)
				surface.PlaySound("ui/buttonclickrelease.wav")
				pcall(btnl, btn)
			end
		end
	end
	if btnr then
		btn.DoRightClick = function()
			if btn.active then
				btn.active = false
				timer.Simple(1, function() if IsValid(btn) then btn.active = true end end)
				surface.PlaySound("ui/buttonclickrelease.wav")
				pcall(btnr, btn)
			end
		end
	end

	return btn
end


local function SelectButton(panel, frame, entid, ent)
	local btn = vgui.Create("DButton")
	btn:SetSkin("Terminal")
	btn:SetSize(0, 50)
	btn.id = entid
	btn.ent = ent
	btn.text = "Node "..entid.."    Network "..ent:GetNWInt("NetID", 0)
	btn:SetText("")
	
	btn.DoClick = function()
		if IsValid(btn.ent) then
			surface.PlaySound("ui/buttonclickrelease.wav")
			panel.ActiveNode = btn.ent
			frame:Remove()
		end
	end
	
	btn.style = {"normal", "dim"}
	btn.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "TKButton", btn, w, h)
		return true
	end
	
	return btn
end

local function SelectNode(panel)
	local nodes = nil
	
	local mouseblock = vgui.Create("DPanel", panel.Terminal)
	mouseblock:SetPos(0, 0)
	mouseblock:SetSize(panel.Terminal:GetWide(), panel.Terminal:GetTall())
	mouseblock.Paint = function()
		return true
	end

	local frame = vgui.Create("DPanel", mouseblock)
	frame:SetSkin("Terminal")
	frame.NextThink = 0
	frame:SetSize(400, 300)
	frame:Center()
	frame.title = "Select Node"
	frame.Think = function()
		if CurTime() < frame.NextThink then return end
		frame.NextThink = CurTime() + 1
		
		local Nodes = {}
		for k,v in pairs(ents.FindByClass("rd_node")) do
			if v:CPPIGetOwner() == LocalPlayer() then
				table.insert(Nodes, v)
			end
		end
		
		for k,v in pairs(nodes.list) do
			if !IsValid(v) then
				nodes:RemoveItem(nodes.list[k])
				nodes.list[k] = nil
			end
		end
		
		for k,v in pairs(Nodes) do
			local id = v:EntIndex()
			if (v:GetPos() - TK.TerminalPlanet.Pos):LengthSqr() <= TK.TerminalPlanet.Size then
				if !nodes.list[id] then
					local btn = SelectButton(panel, mouseblock, id, v)
					nodes.list[id] = btn
					nodes:AddItem(btn)
				end
			else
				if nodes.list[id] then
					nodes:RemoveItem(nodes.list[id])
					nodes.list[id] = nil
				end
			end
		end
	end
	frame.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "TKFrame", frame, w, h)
		return true
	end
	
	local close = vgui.Create("DButton", frame)
	close:SetPos(379, 0)
	close:SetSize(20, 20)
	close:SetText("")
	close.DoClick = function()
		surface.PlaySound("ui/buttonclick.wav")
		mouseblock:Remove()
	end
	close.Paint = function() 
		return true
	end
	
	nodes = vgui.Create("DPanelList", frame)
	nodes:SetSkin("Terminal")
	nodes.list = {}
	nodes:SetPos(5, 25)
	nodes:SetSize(390, 270)
	nodes:SetSpacing(5)
	nodes:SetPadding(5)
	nodes:EnableHorizontal(false)
	nodes:EnableVerticalScrollbar(true)
end

function PANEL:Init()
	self:SetSkin("Terminal")
	self.NextThink = 0
	
	self.storage = vgui.Create("DPanelList", self)
	self.storage:SetSkin("Terminal")
	self.storage.list = {}
	self.storage:SetSpacing(5)
	self.storage:SetPadding(5)
	self.storage:EnableHorizontal(false)
	self.storage:EnableVerticalScrollbar(true)
	
	self.selectnode = vgui.Create("DButton", self)
	self.selectnode:SetSkin("Terminal")
	self.selectnode.text = "Select Node"
	self.selectnode:SetText("")
	self.selectnode.DoClick = function()
		if !IsValid(self.Terminal) then return end
		surface.PlaySound("ui/buttonclickrelease.wav")
		SelectNode(self)
	end
	self.selectnode.style = {"dim", "dark"}
	self.selectnode.Paint = function(panel, w, h)
		derma.SkinHook("Paint", "TKButton", self.selectnode, w, h)
		return true
	end
	
	self.node = vgui.Create("DPanelList", self)
	self.node:SetSkin("Terminal")
	self.node.list = {}
	self.node:SetSpacing(5)
	self.node:SetPadding(5)
	self.node:EnableHorizontal(false)
	self.node:EnableVerticalScrollbar(true)
end

function PANEL:ShowError(msg)
	self.Error = msg
	timer.Create("TermError_Resource", 2, 1, function()
		self.Error = nil
	end)
end

function PANEL:PerformLayout()
	self.storage:SetPos(5, 125)
	self.storage:SetSize(245, 395)
	
	self.selectnode:SetPos(268, 480)
	self.selectnode:SetSize(240, 40)
	
	self.node:SetPos(520, 125)
	self.node:SetSize(245, 395)
end

function PANEL:Think()
	if CurTime() < self.NextThink && !IsValid(self.Terminal) then return end
	self.NextThink = CurTime() + 1
	
	local Storage = TK.DB:GetPlayerData("terminal_storage")
	
	if IsValid(self.ActiveNode) then
		if (self.ActiveNode:GetPos() - TK.TerminalPlanet.Pos):LengthSqr() > TK.TerminalPlanet.Size then
			self.ActiveNode = nil
		end
	end
	
	if !IsValid(self.ActiveNode) then
		for k,v in pairs(ents.FindByClass("rd_node")) do
			if v:CPPIGetOwner() == LocalPlayer() then
				if (v:GetPos() - TK.TerminalPlanet.Pos):LengthSqr() <= TK.TerminalPlanet.Size then
					self.ActiveNode = v
					break
				end
			end
		end
	end
	
	//-- Station Storage --\\
	for k,v in pairs(self.storage.list) do
		if !Storage[k] then
			self.storage:RemoveItem(self.storage.list[k])
			self.storage.list[k] = nil
		end
	end
	
	for k,v in pairs(Storage) do
		if v > 0 && table.HasValue(TerminalData.Resources, k) then
			if !self.storage.list[k] then
				local panel = MakePanel(k, v, function(panel)
					if !IsValid(self.Terminal) then return end
					if !IsValid(self.ActiveNode) then
						self:ShowError("No Node Selected")
					else
						self.Terminal.AddQuery("storagetonode", self.ActiveNode:EntIndex(), panel.res, panel.val)
					end
				end, function(panel)
					if !IsValid(self.Terminal) then return end
					if !IsValid(self.ActiveNode) then
						self:ShowError("No Node Selected")
					else
						panel.AddTextBox(function(panel, val)
							if val <= 0 then self:ShowError("Nil Value Entered") return end
							if val > panel.val then val = panel.val end
							self.Terminal.AddQuery("storagetonode", self.ActiveNode:EntIndex(), panel.res, val)
						end)
					end
				end)

				self.storage.list[k] = panel
				self.storage:AddItem(panel)
			else
				self.storage.list[k].val = v
			end
		else
			if self.storage.list[k] then
				self.storage:RemoveItem(self.storage.list[k])
				self.storage.list[k] = nil
			end
		end
	end
	
	//-- Node Resources --\\
	if IsValid(self.ActiveNode) then
		local Resources = self.ActiveNode:GetNetTable().res
		for k,v in pairs(self.node.list) do
			if !Resources[k] then
				self.node:RemoveItem(self.node.list[k])
				self.node.list[k] = nil
			end
		end
		
		for k,v in pairs(Resources) do
			if v.cur > 0 && table.HasValue(TerminalData.Resources, k) then
				if !self.node.list[k] then
					local panel = MakePanel(k, v.cur, function(panel)
						if !IsValid(self.Terminal) then return end
						if panel.res == "raw_tiberium" then return end
						self.Terminal.AddQuery("nodetostorage", self.ActiveNode:EntIndex(), panel.res, panel.val)
					end, function(panel)
						if !IsValid(self.Terminal) then return end
						panel.AddTextBox(function(panel, val)
							if panel.res == "raw_tiberium" then return end
							if val <= 0 then self:ShowError("Nil Value Entered") return end
							if val > panel.val then val = panel.val end
							self.Terminal.AddQuery("nodetostorage", self.ActiveNode:EntIndex(), panel.res, val)
						end)
					end)

					self.node.list[k] = panel
					self.node:AddItem(panel)
				else
					self.node.list[k].val = v.cur
				end
			else
				if self.node.list[k] then
					self.node:RemoveItem(self.node.list[k])
					self.node.list[k] = nil
				end
			end
		end
	else
		self.node:Clear(true)
		self.node.list = {}
	end
end

function PANEL.Paint(self, w, h)
	derma.SkinHook("Paint", "TKResources", self, w, h)
	return true
end

vgui.Register("tk_resources", PANEL)