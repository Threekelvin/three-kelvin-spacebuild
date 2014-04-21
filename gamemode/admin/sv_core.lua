
local string = string
local table = table

TK.AM = TK.AM or {}

///--- FindTargets ---\\\
function TK.AM:Match(ply, name)
    if name then
        if name == "*" then
            return true
        elseif string.lower(ply:Name()) == string.lower(name) then
            return true
        elseif string.find(string.lower(ply:Name()), string.lower(name)) then
            return true
        elseif string.match(name, "STEAM_[0-5]:[0-9]:[0-9]+") then
            return ply:SteamID() == name
        elseif string.match(name, "(%d+%.%d+%.%d+%.%d+)") then
            return ply:Ip() == string.match(name, "(%d+%.%d+%.%d+%.%d+)")
        end
    end
    return false
end

function TK.AM:TargetsList(ply)
    local Targets = {}
    for k,v in pairs(player.GetAll()) do
        if ply:CanRunOn(v) then
            table.insert(Targets, v)
        end
    end
    return #Targets, Targets
end

function TK.AM:FindTargets(ply, tab)
    local Targets = {}
    for k,v in pairs(tab or {}) do
        if v == "*" then
            return TK.AM:TargetsList(ply)
        else
            for l,b in pairs(player.GetAll()) do
                if TK.AM:Match(b, v) then
                    if ply:CanRunOn(b) and !table.HasValue(Targets, b) then
                        table.insert(Targets, b)
                        break
                    end
                end
            end
        end
    end
    
    return #Targets, Targets
end

function TK.AM:TargetPlayer(ply, name)
    local Targets = {}
    
    for k,v in pairs(player.GetAll()) do
        if TK.AM:Match(v, name) then
            if ply:CanRunOn(v) then
                table.insert(Targets, v)
            end
        end
    end
    
    return #Targets, Targets
end

function TK.AM:FindPlayer(name)
    local Targets = {}
    
    for k,v in pairs(player.GetAll()) do
        if TK.AM:Match(v, name) then
            table.insert(Targets, v)
        end
    end
    
    return #Targets, Targets
end
///--- ---\\\

///--- System Message ---\\\
util.AddNetworkString("TKSysMsg")

function TK.AM:SystemMessage(arg, ply, sound)
    net.Start("TKSysMsg")
        net.WriteTable(arg)
        net.WriteInt(tonumber(sound or 0), 4)
        
    if ply then
        net.Send(ply)
    else
        net.Broadcast()
    end
    
    TK.AM:ConsleMessage(arg)
end
///--- ---\\\

///--- Console Commands ---\\\
local function RunCmd(ply, cmd, arg)
    local command = arg[1]
    if !command or command == "" then return end
    table.remove(arg, 1)
    
    for k,v in pairs(TK.AM:GetAllPlugins()) do
        if v.Command then
            if string.lower(command) == string.lower(v.Command) then
                TK.AM:CallPlugin(k, ply, arg)
                return
            end
        end
    end
end

concommand.Add("3k", RunCmd)
concommand.Add("3k_cl", RunCmd)
///--- ---\\\

///--- Chat Commands ---\\\
hook.Add("PlayerSay", "TKChatCommands", function(ply, text, toteam)
    local Chat = string.Explode(" ", text)

    for k,v in pairs(TK.AM:GetAllPlugins()) do
        local p, c = v.Prefix, v.Command
        
        if !c or c == "" then
            if string.lower(string.Left(Chat[1], string.len(p))) == p then
                local temp = string.sub(Chat[1], string.len(p) + 1)
                table.remove(Chat, 1)
                table.insert(Chat, 1, temp)
                TK.AM:CallPlugin(k, ply, Chat)
                return false
            end
        else
            if string.lower(Chat[1]) == string.lower(p..c) then
                table.remove(Chat, 1)
                TK.AM:CallPlugin(k, ply, Chat)
                return false
            end
        end
    end
end)
///--- ---\\\

///--- AFK ---\\\
local Inputs = {IN_JUMP, IN_DUCK, IN_FORWARD, IN_BACK, IN_LEFT, IN_RIGHT, IN_MOVELEFT, IN_MOVERIGHT}

function TK.AM:SetAFK(ply, isAFK, txt)
    if !IsValid(ply) then return end
    if ply:IsAFK() and !isAFK then
        ply:SetNWBool("TKAFK", false)
        timer.Create("AFK_".. ply:UserID(), 600, 1, function() TK.AM:SetAFK(ply, true) end)
        umsg.Start("TKAFK", ply)
            umsg.Bool(false)
        umsg.End()
        
        TK.AM:SystemMessage({ply, " Is Back"})
    elseif !ply:IsAFK() and isAFK then
        ply:SetNWBool("TKAFK", true)
        timer.Remove("AFK_".. ply:UserID())
        umsg.Start("TKAFK", ply)
            umsg.Bool(true)
        umsg.End()
        
        local msg = "'"..(txt or "").."'"
        TK.AM:SystemMessage({ply, " Is AFK ".. (msg == "''" and "" or msg)})
    end
end

hook.Add("PlayerInitialSpawn", "TKAFKTimer", function(ply)
    TK.AM:SetAFK(ply, false)
end)

hook.Add("KeyPress", "TKAFKTimer", function(ply, key)
    if !table.HasValue(Inputs, key) then return end
    
    if ply:IsAFK() then
        TK.AM:SetAFK(ply, false)
    else
        timer.Remove("AFK_".. ply:UserID())
        timer.Create("AFK_".. ply:UserID(), 600, 1, function() TK.AM:SetAFK(ply, true) end)
    end
end)

hook.Add("PlayerDisconnected", "TKAFKTimer", function(ply)
    timer.Remove("AFK_".. ply:UserID())
end)
///--- ---\\\

///--- Functions ---\\\
umsg.PoolString("TKStopSounds")

function TK.AM:StopSounds(ply)
    umsg.Start("TKStopSounds", ply)
    
    umsg.End()
end

function TK.AM:SetRank(ply, lvl)
    ply:SetNWInt("TKRank", lvl)
    if     lvl >= 5 then ply:SetUserGroup("superadmin")
    elseif lvl == 4 then ply:SetUserGroup("admin")
    elseif lvl == 3 then ply:SetUserGroup("moderator")
    elseif lvl == 2 then ply:SetUserGroup("vip")
    else ply:SetUserGroup("user") end
end
///--- ---\\\