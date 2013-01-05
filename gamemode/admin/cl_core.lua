
local string = string
local table = table

TK.AM = TK.AM || {}

///--- Messages ---\\\
local function MessageSetup(arg)
	local Table = {Color(255,140,0), "[3K] "}
	
	for k,v in ipairs(arg) do
		if type(v) == "table" then
			table.insert(Table, v)
		elseif type(v) == "Entity" then
			table.insert(Table, Color(151,211,255))
			table.insert(Table, v:Name())
		elseif type(v) == "Player" then
			table.insert(Table, v:GetRGBA())
			table.insert(Table, v:GetTag())
			table.insert(Table, team.GetColor(v:Team()))
			table.insert(Table, v:Name())
		else
			if type(Table[#Table]) != "table" then
				table.insert(Table, Color(255,255,255))
			end
			table.insert(Table, v)
		end
	end
	return unpack(Table)
end

net.Receive("TKSysMsg", function()
	chat.AddText(MessageSetup(net.ReadTable()))
	local sound = net.ReadInt(4)
    
	if sound == 1 then 
		surface.PlaySound("buttons/combine_button_locked.wav")
	elseif sound == 2 then
		surface.PlaySound("ambient/water/drip"..math.random(1, 4)..".wav")
	end
end)
///--- ---\\\

///--- Console Commands ---\\\
concommand.Add("3k", function(ply, com, arg) 
	RunConsoleCommand("3k_cl", unpack(arg))
end,
function(com, arg)
	local List = {}
	for k,v in pairs(TK.AM:GetAllPlugins()) do
		if v.Command then
			if string.find(string.lower(v.Command), string.Trim(string.lower(arg))) then
				table.insert(List, com.." "..v.Command)
			end
		end
	end
	table.sort(List)
	
	return List
end)
///--- ---\\\

///--- Chat Commands ---\\\
hook.Add("OnChatTab", "TKOnChatTab", function(text)
	local Words = string.Explode(" ", text)
	local LastWord = Words[#Words]

	if !LastWord || LastWord == "" then return text end

	for k,v in pairs(player.GetAll()) do
		local name = v:Name()
		if string.len(LastWord) < string.len(name) && string.find(string.lower(name), string.lower(LastWord)) == 1  then
			text = string.sub(text, 1, (string.len(LastWord) * -1) - 1)
			text = text .. name
			return text
		end
	end
	
	return text
end)
///--- ---\\\

///--- Stop Sounds ---\\\
usermessage.Hook("TKStopSounds", function(msg)
	RunConsoleCommand("stopsound")
end)
///--- ---\\\