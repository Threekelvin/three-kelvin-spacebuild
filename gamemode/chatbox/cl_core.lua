
local Enable = CreateClientConVar("3k_chatbox_enable", 1, true, false)
local Font = CreateClientConVar("3k_chatbox_font", "ChatFont", true, false)
local Emotes = CreateClientConVar("3k_chatbox_emotes", 1, true, false)
local Links = CreateClientConVar("3k_chatbox_links", 1, true, false)

local Chatbox

local function MakeChatbox()
	if IsValid(Chatbox) then return end
	Chatbox = vgui.Create("TKChatBox")
	Chatbox:MakePopup()
	Chatbox:InvalidateLayout(true)
	Chatbox:Close()
end

net.Receive("3k_chat_b", function()
    local toTeam = tobool(net.ReadBit())
    local ply = net.ReadEntity()
    local msg = net.ReadString()

    if !IsValid(ply) then return end
    gamemode.Call("OnPlayerChat", ply, msg, toTeam, !ply:Alive())
end)

net.Receive("3k_chat_g", function()
    local typ = net.ReadInt(4)
    
    if typ == 1 then
        chat.AddText(Color(161,255,161), "Player " ..net.ReadString().. " has connected")
    elseif typ == 2 then
        chat.AddText(Color(161,255,161), "Player " ..net.ReadString().. " has joined the game")
    elseif typ == 3 then
        chat.AddText(Color(161,255,161), "Player " ..net.ReadString().. " has left the game (" ..net.ReadString().. ")")
    end
end)

hook.Add("Initialize", "TKChatBox", function()
	local oldchat = chat.AddText
	function chat.AddText(...)
		local newarg = {}
        
		for k,v in ipairs({...}) do
			if type(v) == "Entity" then
				table.insert(Table, Color(151,211,255))
				table.insert(Table, v:Name())
			elseif type(v) == "Player" then
				table.insert(newarg, v:GetRGBA())
				table.insert(newarg, v:GetTag())
				table.insert(newarg, team.GetColor(v:Team()))
				table.insert(newarg, v:Name())
			else
				table.insert(newarg, v)
			end
		end
		
		oldchat(unpack(newarg))
        
        if !IsValid(Chatbox) then
            MakeChatbox()
        end
        
        Chatbox:NewMsg(newarg, Enable:GetBool())
	end
	
	function _R.Player.ChatPrint(ply, txt)
		chat.AddText(Color(151,211,255), txt)
	end
end)

hook.Add("ChatText", "TKChatBox", function(plyidx, plyname, txt, msgtyp)
    if msgtyp == "joinleave" then return end
    chat.AddText(Color(255,255,255), txt)
    return true
end)

hook.Add("PlayerBindPress", "TKChatBox", function(ply, key, press)
    if Enable:GetBool() && IsValid(Chatbox) && press && key == "messagemode" then
        Chatbox.isTeam = false
        Chatbox:Open()
        return true
    elseif Enable:GetBool() && press && key == "messagemode2" then
        Chatbox.isTeam = true
        Chatbox:Open()
        return true
    end
end)

hook.Add("HUDShouldDraw", "TKChatBox", function(Element)
    if Enable:GetBool() && Element == "CHudChat" then 
        if !IsValid(Chatbox) then
            MakeChatbox()
        end
        return false 
    end
end)

hook.Add("StartChat", "TKChatBox", function()
    RunConsoleCommand("tk_chat_bubble", "1")
end)

hook.Add("FinishChat", "TKChatBox", function()
    RunConsoleCommand("tk_chat_bubble", "0")
end)

cvars.AddChangeCallback("3k_chatbox_emotes", function(cvar)
	if !IsValid(Chatbox) then return end
	for k,v in pairs(Chatbox.msgbox:GetItems()) do
		v:SetMsg(v.text)
	end
end)

cvars.AddChangeCallback("3k_chatbox_links", function(cvar)
	if !IsValid(Chatbox) then return end
	for k,v in pairs(Chatbox.msgbox:GetItems()) do
		v:SetMsg(v.text)
	end
end)