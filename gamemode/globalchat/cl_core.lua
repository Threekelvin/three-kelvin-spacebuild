
local GlobalChat = {}
GlobalChat.Cache = {}

function GlobalChat:ExtractFlag(num, flag)
	if flag > 7 || num > 4 then return false end
	if flag >= 4 then
		flag = flag - 4
		if num == 4 then return true end
	end
	if flag >= 2 then
		flag = flag - 2
		if num == 2 then return true end
	end
	if flag >= 1 then
		flag = flag - 1
		if num == 1 then return true end
	end
	return false
end

function GlobalChat:WriteMessage(id)
	if !GlobalChat.Cache[id] then return end
	data = GlobalChat.Cache[id]
	
	if GlobalChat:ExtractFlag(2, data.flag) then
		chat.AddText(Color(255,140,0), data.server.." [Admin] ", TK.AM.Rank.RGBA[data.rank], TK.AM.Rank.Tag[data.rank], team.GetColor(data.faction), data.name, Color(255,255,255), ": "..data.text)
	elseif GlobalChat:ExtractFlag(1, data.flag) then
		if GlobalChat:ExtractFlag(4, data.flag) then
			chat.AddText(Color(255,140,0), data.server, Color(30,160,40), " (Team) ", TK.AM.Rank.RGBA[data.rank], TK.AM.Rank.Tag[data.rank], team.GetColor(data.faction), data.name, " "..data.text)
		else
			chat.AddText(Color(255,140,0), data.server, Color(30,160,40), " (Team) ", TK.AM.Rank.RGBA[data.rank], TK.AM.Rank.Tag[data.rank], team.GetColor(data.faction), data.name, Color(255,255,255), ": "..data.text)
		end	
	elseif GlobalChat:ExtractFlag(4, data.flag) then
		chat.AddText(Color(255,140,0), data.server.." ", TK.AM.Rank.RGBA[data.rank], TK.AM.Rank.Tag[data.rank], team.GetColor(data.faction), data.name, " "..data.text)
	else
		chat.AddText(Color(255,140,0), data.server.." ", TK.AM.Rank.RGBA[data.rank], TK.AM.Rank.Tag[data.rank], team.GetColor(data.faction), data.name, Color(255,255,255), ": "..data.text)
	end
	
	GlobalChat.Cache[id] = nil
end

usermessage.Hook("TKGlobalChatSetup", function(msg)
	local id, flag, server, rank, faction = tonumber(msg:ReadString()), msg:ReadChar(), msg:ReadString(), msg:ReadChar(), msg:ReadChar()
	
	if !GlobalChat.Cache[id] then
		GlobalChat.Cache[id] = {
			flag = flag,
			server = server,
			rank = rank,
			faction = faction
		}
	else
		GlobalChat.Cache[id].flag = flag
		GlobalChat.Cache[id].server = server
		GlobalChat.Cache[id].rank = rank
		GlobalChat.Cache[id].faction = faction
	
		GlobalChat:WriteMessage(id)
	end
end)

usermessage.Hook("TKGlobalChatMsg", function(msg)
	local id, name, text = tonumber(msg:ReadString()), msg:ReadString(), msg:ReadString()
	if !GlobalChat.Cache[id] then
		GlobalChat.Cache[id] = {
			name = name,
			text = text
		}
	else
		GlobalChat.Cache[id].name = name
		GlobalChat.Cache[id].text = text
		
		GlobalChat:WriteMessage(id)
	end
end)

usermessage.Hook("TKGlobalSystem", function(msg)
	local server, text = msg:ReadString(), msg:ReadString()
	
	chat.AddText(Color(255,140,0), server.." ", Color(255,255,255), text)
end)