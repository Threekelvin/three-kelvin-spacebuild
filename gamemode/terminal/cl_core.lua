TK.TD = TK.TD or {}
TK.TD.Ent = NULL
local Terminal = {}

local Pages = {
    [1] = {function() return true end,  "Information",  "tk_info",  "icon16/feed.png"},
    [2] = {function() return true end,  "Leaderboard",  "tk_stats",  "icon16/world.png"},
    [3] = {function() return true end,  "Resources",  "tk_resources",  "icon16/ruby.png"},
    [4] = {function() return true end,  "Research",  "tk_research",  "icon16/cog.png"},
    [5] = {function() return true end,  "Inventory",  "tk_inventory",  "icon16/package.png"},
    [6] = {function() return true end,  "Loadout",  "tk_loadout",  "icon16/briefcase.png"},
    [7] = {function() return true end,  "Market",  "tk_market",  "icon16/coins.png"}
}

local function BuildString(data)
    local str = [[]]

    for k, v in ipairs(data) do
        str = str .. string.char(v)
    end

    return str
end

local function BuildTable(data)
    return {string.byte(data, 1, string.len(data))}
end

hook.Add("Initialize", "TKTerminal", function()
    function GAMEMODE:TKOpenTerminal()
    end
end)

function Terminal:Create()
    if ScrW() < 800 or ScrH() < 600 then
        ErrorNoHalt("[Terminal] Resolution Not Supported, minimum size 800 x 600\n")
        GAMEMODE:AddNotify("Resolution Not Supported, minimum size 800 x 600", NOTIFY_ERROR, 5)

        return
    end

    local frame = vgui.Create("DFrame")
    self.Menu = frame
    frame.startTime = SysTime()
    frame:SetSkin("Terminal")
    frame:SetSize(800, 600)
    frame:Center()
    frame.title = "Terminal - V2.0.1"
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:SetScreenLock(true)
    frame:MakePopup()

    frame.Paint = function(self_f, w, h)
        Derma_DrawBackgroundBlur(frame, frame.startTime)
        derma.SkinHook("Paint", "TKFrame", frame, w, h)
    end

    frame.Think = function()
        for k, v in pairs(ents.FindByClass("tk_terminal")) do
            if (LocalPlayer():GetPos() - v:GetPos()):LengthSqr() < 22500 then return end
        end

        frame:SetVisible(false)
    end

    frame.AddQuery = function(...)
        if LocalPlayer():IsAFK() then
            frame:SetVisible(false)

            return
        end

        net.Start("3k_term_request")
        net.WriteEntity(frame.Ent)
        net.WriteTable(BuildTable(table.concat({...})))
        net.SendToServer()
    end

    local close = vgui.Create("DButton", frame)
    close:SetPos(780, 0)
    close:SetSize(20, 20)
    close:SetText("")
    close.Paint = function() end

    close.DoClick = function()
        surface.PlaySound("ui/buttonclick.wav")
        frame:SetVisible(false)
    end

    local propertysheet = vgui.Create("DPropertySheet", frame)
    propertysheet:SetPos(5, 30)
    propertysheet:SetSize(790, 565)

    for _, info in ipairs(Pages) do
        if info[1]() then
            local page = vgui.Create(info[3])
            page.Terminal = frame
            page:SetSize(780, 535)
            propertysheet:AddSheet(info[2], page, info[4], false, false)
        end
    end

    frame.Update = function()
        propertysheet:GetActiveTab():GetPanel():Update()
    end
end

function Terminal:Open(ent)
    TK.TD.Ent = ent

    if not self.Menu then
        self:Create()
    else
        hook.Remove("GUIMousePressed", "OuterClickClose")
        hook.Remove("KeyRelease", "ReleaseClose")

        timer.Simple(1, function()
            hook.Add("GUIMousePressed", "OuterClickClose", function(mc)
                if not vgui.IsHoveringWorld() then return end
                if not IsValid(self.Menu) then return end
                self.Menu:SetVisible(false)
                hook.Remove("GUIMousePressed", "OuterClickClose")
            end)

            hook.Add("KeyRelease", "ReleaseClose", function(ply, key)
                if not (key == IN_USE) then return end
                if not IsValid(self.Menu) then return end
                self.Menu:SetVisible(false)
                hook.Remove("KeyRelease", "ReleaseClose")
            end)
        end)

        self.Menu:SetVisible(true)
        self.Menu.startTime = SysTime()
    end

    gamemode.Call("TKOpenTerminal")
end

net.Receive("3k_terminal_open", function()
    local ent = net.ReadEntity()
    Terminal:Open(ent)
end)

hook.Add("TKDB_Player_Data", "UpdateTerm", function(dbtable, idx, data)
    if not Terminal.Menu then return end
    Terminal.Menu:Update()
end)
