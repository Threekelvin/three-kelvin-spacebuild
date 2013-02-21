
local Font = CreateClientConVar("3k_chatbox_font", "ChatFont", true, false)
local Emotes  = CreateClientConVar("3k_chatbox_emotes", 1, true, false)
local Links  = CreateClientConVar("3k_chatbox_links", 1, true, false)

local surface = surface
local string = string
local table = table

local LastEmote = 0

local PANEL = {}

function PANEL:Init()
    self.font = Font:GetString()
    self.delay = SysTime() + 10
    self.emotelist = {}
    self.data = {}
    self.layout = {}
    self.emotes = {}
    self.links = {}
    self.fade = 255
    self.hide = true
    self.width = 0
end

function PANEL:Hide(bool)
    self.hide = bool
end

function PANEL:AddEmote(img, x, y)
    table.insert(self.emotes, {
        img = img,
        x = x,
        y = y
    })
end

function PANEL:AddLink(url, w, h, x, y)
    table.insert(self.links, {
        url = url,
        w = w,
        h = h,
        x = x,
        y = y
    })
end

function PANEL:TextLenght(txt)
    surface.SetFont(self.font)
    local space = surface.GetTextSize("U")
    local lenght = surface.GetTextSize(txt)
    for w in string.gmatch(txt, "&") do
        lenght = lenght + space
    end    
    return lenght
end

function PANEL:IsEmote(txt)
    if !Emotes:GetBool() then return false end
    for k,v in pairs(self.emotelist) do
        if string.match(txt, k, 0) then
            return v
        end
    end
    return false
end

function PANEL:IsLink(txt)
    if !Links:GetBool() then return false end
    return string.match(txt, "^http://[^ ]+", 0) || string.match(txt, "^https://[^ ]+", 0)
end

function PANEL:DoLayout()
    self.layout = {}
    self.emotes = {}
    self.links = {}
    
    surface.SetFont(self.font)
    local X, Y, Col = 0, 0, Color(255,255,255)
    local space, height = surface.GetTextSize(" ")
    local tempHeight = 0
    
    for k,v in ipairs(self.data) do
        if type(v) == "string" then
            local tempX, tempStr = X, ""
            local isPlayer = false
            
            for _,ply in pairs(player.GetAll()) do
                if ply:Name() != v then continue end
                isPlayer = true
                break
            end
            
            for _,word in ipairs(string.Explode(" ", v)) do
                local isEmote, isLink = self:IsEmote(word), self:IsLink(word)
                
                if !isPlayer && isEmote then
                    table.insert(self.layout, {tempStr, X, Y, Col})
                    tempStr = ""
                    
                    if tempX + 50 > self.width then
                        X, Y = 50 + space, Y + math.max(tempHeight, height) + 2
                        tempX, tempHeight = X, 50
                        self:AddEmote(isEmote, 0, Y)
                    else
                        self:AddEmote(isEmote, tempX, Y)
                        X = tempX + 50 + space
                        tempX, tempHeight = X, 50
                    end
                elseif !isPlayer && isLink then
                    local wide = self:TextLenght(word)
                    table.insert(self.layout, {tempStr, X, Y, Col})
                    tempStr = ""
                    
                    if tempX + wide > self.width then
                        if wide > self.width then
                            local tempWord = " "
                            for letter in string.gmatch(word, ".?") do
                                wide = self:TextLenght(tempWord..letter)
                                
                                if tempX + wide > self.width then
                                    table.insert(self.layout, {tempWord, tempX, Y, Color(34,148,233)})
                                    self:AddLink(isLink, wide, height, tempX, Y)
                                    X, Y = 0, Y + math.max(tempHeight, height) + 2
                                    tempX, tempStr, tempWord, tempHeight = 0, " ",  letter, 0
                                else
                                    tempWord = tempWord..letter
                                end
                            end
                            
                            table.insert(self.layout, {tempStr..tempWord, tempX, Y, Color(34,148,233)})
                            self:AddLink(isLink, wide, height, tempX, Y)
                            X = tempX + wide + space
                            tempX = X
                        else
                            X, Y = wide + space, Y + math.max(tempHeight, height) + 2
                            tempX, tempHeight = X, 0
                            table.insert(self.layout, {word, 0, Y, Color(34,148,233)})
                            self:AddLink(isLink, wide, height, 0, Y)
                        end
                    else
                        table.insert(self.layout, {word, tempX, Y, Color(34,148,233)})
                        self:AddLink(isLink, wide, height, tempX, Y)
                        X = tempX + wide + space
                        tempX = X
                    end
                else
                    word = word.." "
                    local wide = self:TextLenght(word)
                    if tempX + wide > self.width then
                        if wide > self.width then
                            local tempWord = " "
                            for letter in string.gmatch(word, ".?") do
                                wide = self:TextLenght(tempWord..letter)
                                if tempX + wide > self.width then
                                    table.insert(self.layout, {tempStr..tempWord, X, Y, Col})
                                    X, Y = 0, Y + math.max(tempHeight, height) + 2
                                    tempX, tempStr, tempWord, tempHeight = 0, "",  letter, 0
                                else
                                    tempWord = tempWord..letter
                                end
                            end
                            
                            tempStr = tempStr..tempWord
                            tempX = tempX + wide
                        else
                            table.insert(self.layout, {tempStr, X, Y, Col})
                            X, Y = 0, Y + math.max(tempHeight, height) + 2
                            tempX, tempStr, tempHeight = wide, word, 0
                        end
                    else
                        tempStr = tempStr..word
                        tempX = tempX + wide
                    end
                end
            end
            
            table.insert(self.layout, {tempStr, X, Y, Col})
            X = tempX - space
        else
            Col = v
        end
    end

    self:SetHeight(Y + math.max(tempHeight, height))
end

function PANEL:PerformLayout()
    local width = self:GetWide()
    if self.width != width then
        self.width = width
        self:DoLayout()
    end
end

function PANEL:SetMsg(data)
    if !data || type(data) != "table" then return end
    self.data = data
    self:DoLayout()
end

function PANEL.Paint(self, wide, tall)
    local alpha = self.hide && self.fade || 255
    if alpha <= 0 then return true end
    
    if self.fade > 0 && SysTime() > self.delay then
        self.fade = math.max(self.fade - (100 * (SysTime() - self.delay)), 0)
        self.delay = SysTime()
    end
    
    surface.SetFont(self.font)
    surface.SetDrawColor(Color(255, 255, 255, alpha))
    
    for k,v in pairs(self.layout) do
        surface.SetTextPos(v[2], v[3])
        surface.SetTextColor(Color(v[4].r, v[4].g, v[4].b, alpha))
        surface.DrawText(v[1])
    end
    
    for k,v in pairs(self.emotes) do
        surface.SetMaterial(v.img)
        surface.DrawTexturedRect(v.x, v.y, 50, 50)
    end
    
    return true
end

function PANEL:Think()
    if self.Hovered && !self.hide then
        local mx, my = gui.MousePos()
        local px, py = self:LocalToScreen()
        for k,v in pairs(self.links) do
            if mx >= px + v.x && mx <= px + v.x + v.w && my >= py + v.y && my <= py + v.y + v.h then
                self:SetCursor("hand")
                return true
            end
        end
    end
    
    self:SetCursor("arrow")
    return true
end

function PANEL:OnMousePressed(mc)
    if !self.hide then
        surface.PlaySound("ui/buttonclickrelease.wav")
        local mx, my = gui.MousePos()
        local px, py = self:LocalToScreen()
        for k,v in pairs(self.links) do
            if mx >= px + v.x && mx <= px + v.x + v.w && my >= py + v.y && my <= py + v.y + v.h then
                if mc == MOUSE_LEFT then
                    gui.OpenURL(v.url)
                elseif mc == MOUSE_RIGHT then
                    SetClipboardText(v.url)
                    GAMEMODE:AddNotify("Link Copied To Clipboard", NOTIFY_GENERIC, 5)
                end
                self:MouseCapture(true)
                return
            end
        end
        
        local str = ""
        for k,v in pairs(self.data) do
            if type(v) == "string" then
                str = str .. v
            end
        end
        if mc == MOUSE_LEFT then
            SetClipboardText(str)
        elseif mc == MOUSE_RIGHT then
            local split = string.Explode(": ", str)
            SetClipboardText(table.concat(split, ": ", 2))
        end
    end
end

function PANEL:OnMouseReleased()
    self:MouseCapture(false)
end

vgui.Register("TKMsg", PANEL)