local PP = {}
PP.BuddyTable = {}
PP.ShareTable = {}

--/--- Functions ---\\\
function PP:AddPermission(flag, typ)
    local id = TK.PP.Permissions[typ]
    flag = flag or 0
    if not id then return flag end

    return bit.bor(flag, id)
end

function PP:RemovePermission(flag, typ)
    local id = TK.PP.Permissions[typ]
    flag = flag or 0
    if not id then return flag end

    return bit.band(flag, bit.bnot(id))
end

function PP:HasPermission(flag, typ)
    local id = TK.PP.Permissions[typ]
    if not id then return false end

    return bit.band(id, flag or 0) == id
end

function PP:GetByUniqueID(uid)
    for k, v in pairs(player.GetAll()) do
        if v:UID() == uid then return v end
    end

    return false
end

function PP:GetOwner(ent)
    if not IsValid(ent) then return nil, nil end
    local uid = ent:UID()
    if not uid then return nil, nil end
    local ply = self:GetByUniqueID(uid)

    if not IsValid(ply) then
        return NULL, uid
    else
        return ply, uid
    end
end

function PP:IsBuddy(ply, typ)
    if not IsValid(ply) then return false end
    local flag = self.BuddyTable[ply:UID()] or 0

    return self:HasPermission(flag, typ)
end

--/--- ---\\\
--/--- Menus ---\\\
function PP:OpenPropMenu(msg)
    if IsValid(self.Menu) then return end
    local trace = LocalPlayer():GetEyeTraceNoCursor()
    if not IsValid(trace.Entity) then return end
    local owner = self:GetOwner(trace.Entity)
    if owner ~= LocalPlayer() then return end
    local ent = trace.Entity
    local entclass = ent:GetClass()
    local entid = ent:EntIndex()
    local pos = ent:GetPos()
    pos = math.floor(pos.x) .. ", " .. math.floor(pos.y) .. ", " .. math.floor(pos.z)
    local ang = ent:GetAngles()
    ang = math.floor(ang.p) .. ", " .. math.floor(ang.y) .. ", " .. math.floor(ang.r)
    self.Menu = vgui.Create("DFrame")
    self.Menu:SetSize(250, 25)
    self.Menu:SetTitle("Prop Sharing")
    self.Menu:SetDraggable(true)
    self.Menu:SetScreenLock(true)
    self.Menu:ShowCloseButton(true)
    self.Menu:MakePopup()

    function self.Menu:Think()
        if IsValid(ent) then return end
        PP.Menu:Remove()
    end

    for i, typ in pairs(TK.PP.SharePermissions) do
        local tick = vgui.Create("DCheckBoxLabel", self.Menu)
        tick:SetSize(25, 95)
        tick:SetPos(4, self.Menu:GetTall() + 5)
        tick:SetText(typ)
        tick:SetValue(self:HasPermission(self.ShareTable[entid], typ) and 1 or 0)
        tick:SizeToContents()

        function tick:OnChange(val)
            local flag = PP.ShareTable[entid] or 0

            if tobool(val) then
                flag = PP:AddPermission(flag, typ)
            else
                flag = PP:RemovePermission(flag, typ)
            end

            PP.ShareTable[entid] = flag
            RunConsoleCommand("pp_updateshare", entid, flag)
        end

        self.Menu:SetTall(self.Menu:GetTall() + 25)
    end

    local info = vgui.Create("DPanel", self.Menu)
    info:SetPos(self.Menu:GetWide() - 150, 30)
    info:SetSize(145, self.Menu:GetTall() - 35)

    function info:Paint(w, h)
        local col = Color(200, 200, 200, 255)
        surface.SetDrawColor(col)
        surface.DrawLine(0, 0, 0, h)
        draw.SimpleText(entclass, "DermaDefault", w * 0.5, 5, col, TEXT_ALIGN_CENTER)
        draw.SimpleText("Idx: " .. entid, "DermaDefault", 5, 25, col)
        draw.SimpleText("Pos: " .. pos, "DermaDefault", 5, 50, col)
        draw.SimpleText("Ang: " .. ang, "DermaDefault", 5, 75, col)

        return true
    end

    self.Menu:Center()
end

function PP:OpenPlayerMenu(msg)
    if IsValid(self.Menu) then return end
    self.Menu = vgui.Create("DFrame")
    self.Menu:SetSize(400, 250)
    self.Menu:SetTitle("Prop Protection")
    self.Menu:SetDraggable(true)
    self.Menu:SetScreenLock(true)
    self.Menu:ShowCloseButton(true)
    self.Menu:MakePopup()
    self.Menu:Center()
    local plylist = vgui.Create("DListView", self.Menu)
    plylist:SetPos(5, 30)
    plylist:SetSize(390, 185)
    plylist:SetMultiSelect(false)
    plylist:AddColumn("Player"):SetFixedWidth(190)
    plylist:AddColumn("SteamID"):SetFixedWidth(135)
    plylist:AddColumn("Permissions"):SetFixedWidth(65)

    function plylist:OnRowRightClick(line_id)
        local line = self:GetLine(line_id)
        local uid = line:GetValue(5)
        local dmenu = DermaMenu()

        for k, v in pairs(TK.PP.BuddyPermissions) do
            local tick = vgui.Create("DCheckBoxLabel", dmenu)
            tick:SetText(v)
            tick:SetValue(PP:HasPermission(PP.BuddyTable[uid], v) and 1 or 0)
            tick:SetTextColor(Color(0, 0, 0))

            function tick:OnChange(val)
                local flag = PP.BuddyTable[uid]

                if tobool(val) then
                    flag = PP:AddPermission(flag, v)
                else
                    flag = PP:RemovePermission(flag, v)
                end

                PP.BuddyTable[uid] = flag
                line:SetValue(3, flag)
                RunConsoleCommand("pp_updatebuddy", uid, flag)
            end

            dmenu:AddPanel(tick)
        end

        dmenu:Open()
    end

    for k, v in pairs(player.GetAll()) do
        if v == LocalPlayer() then continue end
        local uid = v:UID()
        local line = plylist:AddLine(v:Name(), v:SteamID(), self.BuddyTable[uid] or 0, v, uid)
        local text = vgui.Create("DTextEntry", line)
        text:SetPaintBackground(false)
        text:SetDrawBorder(false)
        text:SetNumeric(true)

        function text:OnEnter()
            local value = tonumber(self:GetValue()) or 0
            local flag = 0

            for typ, flg in pairs(TK.PP.Permissions) do
                if not PP:HasPermission(value, typ) then continue end
                flag = PP:AddPermission(flag, typ)
            end

            PP.BuddyTable[uid] = flag
            line:SetValue(3, flag)
            RunConsoleCommand("pp_updatebuddy", uid, flag)
            text:KillFocus()
        end

        function text:OnLoseFocus()
            self:SetText(line:GetValue(3))
        end

        local val = ""

        if IsValid(line.Columns[3]) then
            val = line.Columns[3]:GetValue()
            line.Columns[3]:Remove()
        end

        line.Columns[3] = text
        line:SetValue(3, val)
    end

    local clean = vgui.Create("DButton", self.Menu)
    clean:SetPos(5, 220)
    clean:SetSize(125, 25)
    clean:SetText("Cleanup My Props")

    clean.DoClick = function()
        surface.PlaySound("ui/buttonclickrelease.wav")
        RunConsoleCommand("pp_cleanup", 0, LocalPlayer():UID())
    end

    if not LocalPlayer():IsModerator() then return end
    local clean_ply = vgui.Create("DButton", self.Menu)
    clean_ply:SetPos(137.5, 220)
    clean_ply:SetSize(125, 25)
    clean_ply:SetText("")
    clean_ply:SetVisible(false)
    clean_ply:SetEnabled(false)

    plylist.OnRowSelected = function(panel, line_id)
        local line = plylist:GetLine(line_id)

        if LocalPlayer():CanRunOn(line:GetValue(4)) then
            local uid = line:GetValue(5)
            clean_ply:SetText("Cleanup " .. line:GetValue(1))
            clean_ply:SetVisible(true)
            clean_ply:SetEnabled(true)

            clean_ply.DoClick = function()
                surface.PlaySound("ui/buttonclickrelease.wav")
                RunConsoleCommand("pp_cleanup", 0, uid)
            end
        else
            clean_ply:SetVisible(false)
            clean_ply:SetEnabled(false)
        end
    end

    local disconnected = vgui.Create("DButton", self.Menu)
    disconnected:SetPos(270, 220)
    disconnected:SetSize(125, 25)
    disconnected:SetText("Cleanup Disconnected")

    disconnected.DoClick = function()
        surface.PlaySound("ui/buttonclickrelease.wav")
        RunConsoleCommand("pp_cleanup", 1)
    end
end

net.Receive("PP_Menu1", function()
    PP:OpenPropMenu()
end)

net.Receive("PP_Menu2", function()
    PP:OpenPlayerMenu()
end)

--/--- ---\\\
--/--- Datastreams ---\\\
net.Receive("PPBuddy", function()
    PP.BuddyTable = net.ReadTable()
end)

net.Receive("PPShare", function()
    PP.ShareTable = net.ReadTable()
end)

--/--- ---\\\
--/--- Owner Display ---\\\
hook.Add("HUDPaint", "PP_OwnerBox", function()
    local Client = LocalPlayer()
    if not Client:Alive() then return end
    local tr = Client:GetEyeTraceNoCursor()
    if not IsValid(tr.Entity) then return end
    local scrw, scrh = ScrW(), ScrH() * 0.25
    local owner, uid = PP:GetOwner(tr.Entity)
    local name = "World"

    if IsValid(owner) then
        name = owner:Name()
    elseif uid then
        name = "Disconnected"
    end

    surface.SetFont("TKFont12")
    local x, y = surface.GetTextSize(name)
    draw.RoundedBox(4, scrw - x - 10, scrh, x + 5, y + 5, Color(55, 57, 61))
    draw.RoundedBox(4, scrw - x - 9, scrh + 1, x + 3, y + 3, Color(150, 150, 150))
    draw.SimpleText(name, "TKFont12", scrw - x - 10 + 2.5, scrh + 2.5, Color(255, 255, 255))
    local class = "[" .. tr.Entity:EntIndex() .. "] " .. tr.Entity:GetClass()
    x, y = surface.GetTextSize(class)
    draw.RoundedBox(4, scrw - x - 10, scrh + y + 8, x + 5, y + 5, Color(55, 57, 61))
    draw.RoundedBox(4, scrw - x - 9, scrh + y + 9, x + 3, y + 3, Color(150, 150, 150))
    draw.SimpleText(class, "TKFont12", scrw - x - 10 + 2.5, scrh + y + 8 + 2.5, Color(255, 255, 255))
end)

--/--- ---\\\
hook.Add("EntityRemoved", "TKPP", function(ent)
    local eid = ent:EntIndex()

    if PP.ShareTable[eid] then
        PP.ShareTable[eid] = nil
    end
end)

--/--- CPPI ---\\\
CPPI = CPPI or {}

function CPPI:GetNameFromUID(uid)
    if not uid then return nil end
    local ply = PP:GetByUniqueID(tostring(uid))
    if not IsValid(ply) then return nil end

    return string.sub(ply:Name(), 1, 31)
end

function _R.Player:CPPIGetFriends()
local TrustedPlayers = {}

for k, v in pairs(player.GetAll()) do
    if PP:IsBuddy(v, "CPPI") then
        table.insert(TrustedPlayers, v)
    end
end

return TrustedPlayers
end

function _R.Entity:CPPIGetOwner()
    return PP:GetOwner(self)
end
--/--- ---\\\
