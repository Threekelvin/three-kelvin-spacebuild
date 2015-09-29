local Font = CreateClientConVar("3k_chatbox_font", "ChatFont", true, false)
local Emotes = CreateClientConVar("3k_chatbox_emotes", 1, true, false)
local Links = CreateClientConVar("3k_chatbox_links", 1, true, false)
local surface = surface
local string = string
local table = table
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

function PANEL:AddEmote(img, text_x, text_y)
    table.insert(self.emotes, {
        img = img,
        text_x = text_x,
        text_y = text_y
    })
end

function PANEL:AddLink(url, w, h, text_x, text_y)
    table.insert(self.links, {
        url = url,
        w = w,
        h = h,
        text_x = text_x,
        text_y = text_y
    })
end

function PANEL:TextLenght(txt)
    surface.SetFont(self.font)
    local font_width = surface.GetTextSize("U")
    local lenght = surface.GetTextSize(txt)

    for w in string.gmatch(txt, "&") do
        lenght = lenght + font_width
    end

    return lenght
end

function PANEL:IsEmote(txt)
    if !Emotes:GetBool() then return false end

    for k, v in pairs(self.emotelist) do
        if string.match(txt, k, 0) then return v end
    end

    return false
end

function PANEL:IsLink(txt)
    if !Links:GetBool() then return false end

    return string.match(txt, "^http://[^ ]+", 0) or string.match(txt, "^https://[^ ]+", 0)
end

function PANEL:DoLayout()
    self.layout = {}
    self.emotes = {}
    self.links = {}
    surface.SetFont(self.font)
    local text_x, text_y, temp_color = 0, 0, Color(255, 255, 255)
    local font_width, font_height = surface.GetTextSize(" ")
    local temp_height = 0

    for k, v in ipairs(self.data) do
        if type(v) == "string" then
            local temp_x, temp_string = text_x, ""
            local is_player = false

            for _, ply in pairs(player.GetAll()) do
                if ply:Name() ~= v then continue end
                is_player = true
                break
            end

            for _, word in ipairs(string.Explode(" ", v)) do
                local isEmote, isLink = self:IsEmote(word), self:IsLink(word)

                if !is_player and isEmote then
                    table.insert(self.layout, {temp_string,  text_x,  text_y,  temp_color})
                    temp_string = ""

                    if temp_x + 50 > self.width then
                        text_x, text_y = 50 + font_width, text_y + math.max(temp_height, font_height) + 2
                        temp_x, temp_height = text_x, 50
                        self:AddEmote(isEmote, 0, text_y)
                    else
                        self:AddEmote(isEmote, temp_x, text_y)
                        text_x = temp_x + 50 + font_width
                        temp_x, temp_height = text_x, 50
                    end
                elseif !is_player and isLink then
                    local wide = self:TextLenght(word)
                    table.insert(self.layout, {temp_string,  text_x,  text_y,  temp_color})
                    temp_string = ""

                    if temp_x + wide > self.width then
                        if wide > self.width then
                            local tempWord = " "

                            for letter in string.gmatch(word, ".?") do
                                wide = self:TextLenght(tempWord .. letter)

                                if temp_x + wide > self.width then
                                    table.insert(self.layout, {tempWord,  temp_x,  text_y,  Color(34, 148, 233)})
                                    self:AddLink(isLink, wide, font_height, temp_x, text_y)
                                    text_x, text_y = 0, text_y + math.max(temp_height, font_height) + 2
                                    temp_x, temp_string, tempWord, temp_height = 0, " ", letter, 0
                                else
                                    tempWord = tempWord .. letter
                                end
                            end

                            table.insert(self.layout, {temp_string .. tempWord,  temp_x,  text_y,  Color(34, 148, 233)})
                            self:AddLink(isLink, wide, font_height, temp_x, text_y)
                            text_x = temp_x + wide + font_width
                            temp_x = text_x
                        else
                            text_x, text_y = wide + font_width, text_y + math.max(temp_height, font_height) + 2
                            temp_x, temp_height = text_x, 0
                            table.insert(self.layout, {word,  0,  text_y,  Color(34, 148, 233)})
                            self:AddLink(isLink, wide, font_height, 0, text_y)
                        end
                    else
                        table.insert(self.layout, {word,  temp_x,  text_y,  Color(34, 148, 233)})
                        self:AddLink(isLink, wide, font_height, temp_x, text_y)
                        text_x = temp_x + wide + font_width
                        temp_x = text_x
                    end
                else
                    word = word .. " "
                    local wide = self:TextLenght(word)

                    if temp_x + wide > self.width then
                        if wide > self.width then
                            local tempWord = " "

                            for letter in string.gmatch(word, ".?") do
                                wide = self:TextLenght(tempWord .. letter)

                                if temp_x + wide > self.width then
                                    table.insert(self.layout, {temp_string .. tempWord,  text_x,  text_y,  temp_color})
                                    text_x, text_y = 0, text_y + math.max(temp_height, font_height) + 2
                                    temp_x, temp_string, tempWord, temp_height = 0, "", letter, 0
                                else
                                    tempWord = tempWord .. letter
                                end
                            end

                            temp_string = temp_string .. tempWord
                            temp_x = temp_x + wide
                        else
                            table.insert(self.layout, {temp_string,  text_x,  text_y,  temp_color})
                            text_x, text_y = 0, text_y + math.max(temp_height, font_height) + 2
                            temp_x, temp_string, temp_height = wide, word, 0
                        end
                    else
                        temp_string = temp_string .. word
                        temp_x = temp_x + wide
                    end
                end
            end

            table.insert(self.layout, {temp_string,  text_x,  text_y,  temp_color})
            text_x = temp_x - font_width
        else
            temp_color = v
        end
    end

    self:SetHeight(text_y + math.max(temp_height, font_height))
end

function PANEL:PerformLayout()
    local width = self:GetWide()

    if self.width ~= width then
        self.width = width
        self:DoLayout()
    end
end

function PANEL:SetMsg(data)
    if !data or type(data) ~= "table" then return end
    self.data = data
    self:DoLayout()
end

function PANEL:Paint(wide, tall)
    local alpha = self.hide and self.fade or 255
    if alpha <= 0 then return true end

    if self.fade > 0 and SysTime() > self.delay then
        self.fade = math.max(self.fade - (100 * (SysTime() - self.delay)), 0)
        self.delay = SysTime()
    end

    surface.SetFont(self.font)
    surface.SetDrawColor(Color(255, 255, 255, alpha))

    for k, v in pairs(self.layout) do
        surface.SetTextPos(v[2], v[3])
        surface.SetTextColor(Color(v[4].r, v[4].g, v[4].b, alpha))
        surface.DrawText(v[1])
    end

    for k, v in pairs(self.emotes) do
        surface.SetMaterial(v.img)
        surface.DrawTexturedRect(v.text_x, v.text_y, 50, 50)
    end

    return true
end

function PANEL:Think()
    if self.Hovered and !self.hide then
        local mx, my = gui.MousePos()
        local px, py = self:LocalToScreen()

        for k, v in pairs(self.links) do
            if mx >= px + v.text_x and mx <= px + v.text_x + v.w and my >= py + v.text_y and my <= py + v.text_y + v.h then
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

        for k, v in pairs(self.links) do
            if mx >= px + v.text_x and mx <= px + v.text_x + v.w and my >= py + v.text_y and my <= py + v.text_y + v.h then
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

        for k, v in pairs(self.data) do
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
