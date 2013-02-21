
util.AddNetworkString("3k_chat_r")
util.AddNetworkString("3k_chat_g")
util.AddNetworkString("3k_chat_b")

net.Receive("3k_chat_r", function(len, ply)
    local toTeam = tobool(net.ReadBit())
    local msg = net.ReadString()
    
    local rtn = gamemode.Call("PlayerSay", ply, msg, toTeam)
    if rtn != nil then
        if type(rtn) != "string" then return end
        if rtn == "" then return end
        msg = rtn
    end
    
    local plys = {}
    if toTeam then
        for k,v in pairs(player.GetAll()) do
            if v:Team() == ply:Team() then
                table.insert(plys, v)
            end
        end
    else
        plys = player.GetAll()
    end
    
    print((toTeam && "(TEAM) " || "") .. ply:Name() .. ": " .. msg)
    
    net.Start("3k_chat_b")
        net.WriteBit(toTeam)
        net.WriteEntity(ply)
        net.WriteString(msg)
    net.Send(plys)
end)

local function AddChatBubble(ply)
    if IsValid(ply.bubble) then
        ply.bubble:SetSkin(0)
        return
    end
    
    local ent = ents.Create("tk_bubble")
    ent:SetPos(ply:GetPos() + Vector(0,0,90))
    ent:SetAngles(ply:GetAngles())
    ent:Spawn()
    ent:SetParent(ply)
    ent:SetSkin(0)
    ply.bubble = ent
end

local function RemoveChatBubble(ply)
    if !IsValid(ply.bubble) then return end
    if ply.afk then
        ply.bubble:SetSkin(1)
        return
    end
    ply.bubble:Remove()
end

concommand.Add("tk_chat_bubble", function(ply, cmd, arg)
    if !IsValid(ply) then return end
    if tobool(arg[1]) then
        AddChatBubble(ply)
    else
        RemoveChatBubble(ply)
    end
end)

hook.Add("player_connect", "TKChatBox", function(data)
    print("Client '" ..data.name.. "' connected (" ..data.networkid.. ")")
    
    net.Start("3k_chat_g")
        net.WriteInt(1, 4)
        net.WriteString(data.name)
    net.Broadcast()
end)

hook.Add("PlayerInitialSpawn", "TKChatBox", function(ply)
    net.Start("3k_chat_g")
        net.WriteInt(2, 4)
        net.WriteString(ply:Name())
    net.SendOmit(ply)
end)

hook.Add("player_disconnect", "TKChatBox", function(data)
    net.Start("3k_chat_g")
        net.WriteInt(3, 4)
        net.WriteString(data.name)
        net.WriteString(data.reason)
    net.Broadcast()
end)