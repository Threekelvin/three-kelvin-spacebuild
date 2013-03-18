
local net = net
local string = string
local Terminal = {}

local Pages = {
    [1] = {
        function() 
            return true 
        end,
        "Information",
        "tk_info",
        "icon16/feed.png"
    },
    [2] = {
        function() 
            return true 
        end,
        "Leaderboard",
        "tk_stats",
        "icon16/world.png"
    },
    [3] = {
        function() 
            return true 
        end,
        "Resources",
        "tk_resources",
        "icon16/ruby.png"
    },
    [4] = {
        function() 
            return true 
        end,
        "Refinery",
        "tk_refinery",
        "icon16/arrow_refresh.png"
    },
    [5] = {
        function() 
            return true 
        end,
        "Research",
        "tk_research",
        "icon16/wrench.png"
    },
    [6] = {
        function() 
            return true 
        end,
        "Loadout",
        "tk_loadout",
        "icon16/briefcase.png"
    },
    [7] = {
        function() 
            return true 
        end,
        "Market",
        "tk_market",
        "icon16/coins.png"
    },
    [8] = {
        function()
            return true
        end,
        "Faction",
        "tk_faction",
        "icon16/shield.png"
    }
}

local function BuildString(data)
    local str = [[]]
    for k,v in ipairs(data) do
        str = str .. string.char(v)
    end
    return str
end

local function BuildTable(data)
    return {string.byte(data, 1, string.len(data))}
end

net.Receive("3k_term_test", function()
    Terminal.request_key = BuildString(net.ReadTable())
end)

hook.Add("Initialize", "TKTerminal", function()
    function GAMEMODE:TKOpenTerminal()
    end
    
    Terminal.encrypt = aeslua.encrypt
    Terminal.decrypt = aeslua.decrypt
    Terminal.encrypt_key = string.random(32)
    Terminal.decrypt_key = string.random(32)
    Terminal.request_key = ""
    
    timer.Simple(0, function()
        net.Start("3k_term_key")
            net.WriteTable(BuildTable(Terminal.encrypt_key))
            net.WriteTable(BuildTable(Terminal.decrypt_key))
        net.SendToServer()
    end)
end)

function Terminal:Create()
    if surface.ScreenWidth() < 800 || surface.ScreenHeight() < 600 then
        ErrorNoHalt("[Terminal] Resolution Not Supported, minimum size 800 x 600\n")
        GAMEMODE:AddNotify("Resolution Not Supported, minimum size 800 x 600", NOTIFY_ERROR, 5)
        return
    end
    
    local frame = vgui.Create("DFrame")
    Terminal.Menu = frame
    frame.startTime = SysTime()
    frame:SetSkin("Terminal")
    frame:SetSize(800, 600)
    frame:Center()
    frame.title = "Terminal - V2.0.0"
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:SetScreenLock(true)
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        Derma_DrawBackgroundBlur(frame, frame.startTime)
        derma.SkinHook("Paint", "TKFrame", self, w, h)
    end
    frame.Think = function()
        for k,v in pairs(ents.FindByClass("tk_terminal")) do
            if (LocalPlayer():GetPos() - v:GetPos()):LengthSqr() < 22500 then
                return
            end
        end
        
        frame:SetVisible(false)
    end
    
    frame.AddQuery = function(...)
        if LocalPlayer():IsAFK() then 
            frame:SetVisible(false)
            return
        end
        
        local key = Terminal.decrypt(Terminal.decrypt_key, Terminal.request_key)
        local querry = Terminal.encrypt(Terminal.encrypt_key, table.concat({...}, " "))

        net.Start("3k_term_request")
            net.WriteTable(BuildTable(key))
            net.WriteTable(BuildTable(querry))
        net.SendToServer()
    end
    
    local close = vgui.Create("DButton", frame)
    close:SetPos(780, 0)
    close:SetSize(20, 20)
    close:SetText("")
    close.DoClick = function()
        surface.PlaySound("ui/buttonclick.wav")
        frame:SetVisible(false)
    end
    close.Paint = function() end

    local propertysheet = vgui.Create("DPropertySheet", frame)
    propertysheet:SetPos(5, 30)
    propertysheet:SetSize(790, 565)
    
    for k,v in ipairs(Pages) do
        if v[1]() then
            local page = vgui.Create(v[3])
            page.Terminal = frame
            page:SetSize(780, 535)
            propertysheet:AddSheet(v[2], page, v[4], false, false)
        end
    end
    
    frame.Update = function(self)
        propertysheet:GetActiveTab():GetPanel():Update()
    end
end

function Terminal:Rebuild()
    if Terminal.Menu then
        Terminal.Menu:Remove()
    end
    
    Terminal:Create()
    Terminal.Menu:SetVisible(false)
end

function Terminal:Open()
    if !Terminal.Menu then
        Terminal:Create()
    else
        hook.Remove("GUIMousePressed", "OuterClickClose")
        hook.Remove("KeyRelease", "ReleaseClose")
        timer.Simple(1, function()
            hook.Add("GUIMousePressed", "OuterClickClose", function(mc)
                if !vgui.IsHoveringWorld() then return end
                if !IsValid(Terminal.Menu) then return end
                Terminal.Menu:SetVisible(false)
                hook.Remove("GUIMousePressed", "OuterClickClose")
            end)
            hook.Add("KeyRelease", "ReleaseClose", function(ply, key)
                if !( key == IN_USE ) then return end
                if !IsValid(Terminal.Menu) then return end
                Terminal.Menu:SetVisible(false)
                hook.Remove("KeyRelease", "ReleaseClose")
            end)
        end)
        Terminal.Menu:SetVisible(true)
        Terminal.Menu.startTime = SysTime()
    end
    gamemode.Call("TKOpenTerminal")
end

usermessage.Hook("3k_terminal_open", function(msg)
    Terminal:Open()
end)

hook.Add("TKDBPlayerData", "UpdateTerm", function(dbtable, idx, data)
    if !Terminal.Menu then return end
    Terminal.Menu:Update()
end)

concommand.Add("3k_rebuild_terminal", function(ply, cmd, arg)
    Terminal:Rebuild()
end)