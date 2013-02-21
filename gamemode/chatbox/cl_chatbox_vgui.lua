
local PANEL = {}

function PANEL:Init()
    local wide, tall = math.max(surface.ScreenWidth() / 3, 320), math.max(surface.ScreenHeight() / 4, 240)
    self:SetSize(wide, tall)
    self:SetPos(5, surface.ScreenHeight() / 2)
    self.emotelist = {}
    self.inputlog = {}
    self.inputidx = 0
    self.wide = wide
    self.msgcount = 0
    self.isTeam = false
    self.isOpen = false
    self:PopulateEmotes()
    
    //-- Msg Box --\\
    self.msgbox = vgui.Create("TKMsgBox", self)
    
    //-- Text Entry --\\
    self.textentry = vgui.Create("DTextEntry", self)
    self.textentry:SetAllowNonAsciiCharacters(true)
    self.textentry.Paint = function(panel, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(55,57,61))
        draw.RoundedBox(2, 1, 1, w - 2, h - 2, Color(100,100,100))
        self.textentry:DrawTextEntryText(Color(255,255,255), Color(20,200,250), Color(255,255,255))
        return true
    end
    self.textentry.OnTextChanged = function()
        if string.len(self.textentry:GetValue()) > 1024 then
            self.textentry:SetText(string.sub(self.textentry:GetValue(), 1, 1024))
            self.textentry:SetCaretPos(1024)
        end
    end
    self.textentry.OnKeyCodeTyped = function(panel, key)
        if key == KEY_ESCAPE then
            self:Close()
            panel:SetText("")
        elseif key == KEY_TAB then
            local str = tostring(gamemode.Call("OnChatTab", panel:GetValue()) || " ")
            if str != " " then
                panel:SetText(str)
                panel:SetCaretPos(string.len(str))
                return true
            end
        elseif key == KEY_ENTER then
            local txt = panel:GetValue()
            self:Close()
            panel:SetText("")
            
            if txt == "" then return end
            table.insert(self.inputlog, 1, txt)
            net.Start("3k_chat_r")
                net.WriteBit(self.isTeam)
                net.WriteString(txt)
            net.SendToServer()
        elseif key == KEY_UP then
            self.inputidx = math.min(self.inputidx + 1, #self.inputlog)
            local txt = self.inputlog[self.inputidx]
            if !txt then return end
            self.textentry:SetText(txt)
            self.textentry:SetCaretPos(string.len(txt))
        elseif key == KEY_DOWN then
            self.inputidx = math.max(self.inputidx - 1, 0)
            local txt = self.inputlog[self.inputidx]
            if !txt then return end
            self.textentry:SetText(txt)
            self.textentry:SetCaretPos(string.len(txt))
        end
    end
    
    //-- Expand Button --\\
    self.options = vgui.Create("DButton", self)
    self.options:SetText(">")
    self.options.DoClick = function()
        surface.PlaySound("ui/buttonclickrelease.wav")
        if self.isOpen then
            self:Expand(false)
            self.options:SetText(">")
        else
            self:Expand(true)
            self.options:SetText("<")
        end
    end

    //-- Emote Browser --\\
    self.emotebox = vgui.Create("TKEmoteBox", self)
    self.emotebox.emotelist = self.emotelist
    self.emotebox:Hide()
    self.emotebox.Selected = function(panel, txt)
        local str = self.textentry:GetValue().." "..txt.." "
        self.textentry:SetText(str)
        self.textentry:SetCaretPos(string.len(str))
        self.textentry:RequestFocus()
    end
end

function PANEL:Delete()
    self.msgbox:Remove()
    self:Remove()
end

function PANEL:PerformLayout()
    local wide, tall = self:GetSize()
    
    self.msgbox:SetSize(self.wide - 12, tall - 44)
    if self.msgbox:GetParent() == self then
        self.msgbox:SetPos(7, 7)
    else
        local x, y = self:GetPos()
        self.msgbox:SetPos(x + 7, y + 7)
    end
    
    if self.isTeam then
        surface.SetFont("ChatFont")
        local x, y = surface.GetTextSize("Team")
        
        self.textentry:SetSize(self.wide - 47 - x , 25)
        self.textentry:SetPos(x + 13, tall - 30)
    else
        self.textentry:SetSize(self.wide - 40, 25)
        self.textentry:SetPos(5, tall - 30)
    end
    
    self.options:SetSize(25, 25)
    self.options:SetPos(self.wide - 30, tall - 30)
    
    self.emotebox:SetSize(wide - self.wide - 5, tall - 10)
    self.emotebox:SetPos(self.wide + 5, 5)
end

function PANEL:PopulateEmotes()
    local files = file.Find("materials/smilies/*", "GAME")
    self.emotelist = {}
    
    for k,v in ipairs(files) do
        self.emotelist[":".. string.match(v, "^[%w]+") ..":"] = Material("smilies/" .. v)
    end
    
    table.sort(self.emotelist)
end

function PANEL.Paint(self, wide, tall)
    draw.RoundedBox(2, self.wide, 0, wide - self.wide, tall, Color(100,100,100))
    draw.RoundedBox(2, self.wide + 5, 5, wide - self.wide - 10, tall - 10, Color(55,57,61))
    draw.RoundedBox(2, 0, 0, self.wide, tall, Color(150,150,150))
    draw.RoundedBox(2, 5, 5, self.wide - 10, tall - 40, Color(55,57,61))
    
     if self.isTeam then
        surface.SetFont("ChatFont")
        local x, y = surface.GetTextSize("Team")
        
        draw.RoundedBox(2, 5, tall - 30, x + 3, 25, Color(55,57,61))
        draw.RoundedBox(2, 6, tall - 29, x + 1, 23, Color(100,100,100))
        draw.SimpleText("Team", "ChatFont", 7, tall - 17.5, Color(255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end
    
    return true
end

function PANEL:Think()
    local wide, tall = self:GetSize()

    if self.Dragging then
        local x = math.Clamp(gui.MouseX() - self.Dragging[1], 0, surface.ScreenWidth() - wide)
        local y = math.Clamp(gui.MouseY() - self.Dragging[2], 0, surface.ScreenHeight() - tall)
        
        self:SetPos(x, y)
    end
    
    if self.Sizing then
        local px, py = self:GetPos()
        local x = math.Clamp(gui.MouseX() - self.Sizing[1], self.isOpen && 320 + 145 || 320, surface.ScreenWidth() - px)
        local y = math.Clamp(gui.MouseY() - self.Sizing[2], 240, surface.ScreenHeight() - py)

        self:SetSize(x, y)
        self.wide = self.isOpen && x - 145 || x
        return
    end
    
    if self.Hovered && !self.moving && gui.MouseY() <= self.y + 5 then
        self:SetCursor("sizeall")
        return
    elseif self.Hovered && !self.moving && gui.MouseX() >= self.x + wide - 5 && gui.MouseY() >= self.y + tall - 5 then
        self:SetCursor("sizenwse")
        return
    end
    
    self:SetCursor("arrow")
end

function PANEL:OnMousePressed()
    if !self.moving && gui.MouseX() >= self.x + self:GetWide() - 5 && gui.MouseY() >= self.y + self:GetTall() - 5 then            
        self.Sizing = {gui.MouseX() - self:GetWide(), gui.MouseY() - self:GetTall()}
        self:MouseCapture(true)
        return
    end
    
    if !self.moving && gui.MouseY() <= self.y + 5 then
        self.Dragging = {gui.MouseX() - self.x, gui.MouseY() - self.y}
        self:MouseCapture(true)
        return
    end
end

function PANEL:OnMouseReleased()
    self.Dragging = nil
    self.Sizing = nil
    self:MouseCapture(false)
end

function PANEL:NewMsg(data, show)
    self.msgcount = self.msgcount + 1
    
    local msg = vgui.Create("TKMsg")
    msg.idx = self.msgcount
    msg.box = self.msgbox
    msg.fade = show && 255 || 0
    msg.emotelist = self.emotelist
    
    msg:SetMsg(data)
    
    if table.Count(self.msgbox.Items) >= 100 then
        self.msgbox.Items[1]:Remove()
        table.remove(self.msgbox.Items, 1)
    end
    
    self.msgbox:AddItem(msg)
    self.msgbox:InvalidateLayout(true)
    
    if self:IsVisible() then
        msg:Hide(false)
        self.msgbox.VBar:SetScroll(self.msgbox.VBar:GetScroll() + (msg:GetTall() + 2))
    else
        msg:Hide(true)
        self.msgbox.VBar:SetScroll(self.msgbox.VBar.CanvasSize)
    end
end

function PANEL:Open()
    self.active = true
    self.msgbox:Capture(self)
    self:SetVisible(true)
    self:MakePopup()
    self.textentry:RequestFocus()
    self.inputidx = 0
    RunConsoleCommand("tk_chat_bubble", "1")
    
    self:InvalidateLayout()
end

function PANEL:Close()
    self.active = false
    self.msgbox:Release(self)
    self:SetVisible(false)
    RunConsoleCommand("cancelselect")
    RunConsoleCommand("tk_chat_bubble", "0")
    
    self:InvalidateLayout()
end

function PANEL:Expand(bool)
    if bool then
        self:SetWide(self.wide + 138)
        self.emotebox:Show()
        self.isOpen = true
    else
        self:SetWide(self.wide)
        self.emotebox:Hide()
        self.isOpen = false
    end
end

vgui.Register("TKChatBox", PANEL, "EditablePanel")