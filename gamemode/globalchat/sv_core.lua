
local GlobalChat = {}
GlobalChat.LastMsg = -1
GlobalChat.Flood = {}

umsg.PoolString("TKGlobalChatSetup")
umsg.PoolString("TKGlobalChatMsg")
umsg.PoolString("TKGlobalSystem")

function GlobalChat:CanSendMsg(ply)
	local uid = ply:GetNWString("UID")
	GlobalChat.Flood[uid] = (GlobalChat.Flood[uid] || 0) + 1

	if GlobalChat.Flood[uid] >= 6 then return false end
	return true
end

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

function GlobalChat:SendPlyMsg(flag, server, rank, faction, name, msg)
	toteam, toadmin, faction = tobool(toteam), tobool(toadmin), tonumber(faction) || 1
	local plys = {}
	
	if GlobalChat:ExtractFlag(1, flag)  then
		print(server .."[Team]", TK.AM.Rank.Tag[rank]..name, msg)
		for k,v in pairs(player.GetAll()) do
			if v:Team() == faction then
				table.insert(plys, v)
			end
		end
	elseif GlobalChat:ExtractFlag(2, flag) then
		print(server .."[Admin]", TK.AM.Rank.Tag[rank]..name, msg)
		for k,v in pairs(player.GetAll()) do
			if v:GetRank() >= 3 then
				table.insert(plys, v)
			end
		end
	else
		print(server, TK.AM.Rank.Tag[rank]..name, msg)
		plys = nil
	end
	
	local id = util.CRC(server.. name .. msg)
	
	umsg.Start("TKGlobalChatSetup", plys)
		umsg.String(id)
		umsg.Char(flag)
		umsg.String(tostring(server) || "")
		umsg.Char(tonumber(rank) || 1)
		umsg.Char(faction)
	umsg.End()
	
	umsg.Start("TKGlobalChatMsg", plys)
		umsg.String(id)
		umsg.String(tostring(name) || "")
		umsg.String(tostring(msg) || "")
	umsg.End()
end

function GlobalChat:SendSysMsg(server, msg)
	print(server, msg)
	umsg.Start("TKGlobalSystem")
		umsg.String(tostring(server) || "")
		umsg.String(tostring(msg) || "")
	umsg.End()
end

function GlobalChat:RemoteFunction(server, toserver, cmd, rank, faction, name)
	if toserver != "*" && !string.find(string.lower(TK.HostName()), string.lower(toserver)) then return end
	
	print(server, " Remote Command From "..TK.AM.Rank.Tag[rank]..name, cmd)
	RunConsoleCommand("3k", cmd)
end

function TK.DB:SendGlobalMsg(ply, msg, flag)
	if !IsValid(ply) || !ply:IsPlayer() then return end
	if !GlobalChat:CanSendMsg(ply) then
		TK.AM:SystemMessage({"Global Message Limit, please wait"}, {ply}, 2)
		return
	end
	
	TK.DB:MakeQuery(TK.DB:FormatInsertQuery("server_globalchat", {
		{"msg_conection_id", false},
		{"msg_key", 0},
		{"msg_origin", TK:HostName()},
		{"msg_flag", flag},
		{"msg_data", msg},
		{"sender_rank", ply:GetRank()},
		{"sender_faction", ply:Team()},
		{"sender_name", ply:Name()}
	}))
	
	GlobalChat:SendPlyMsg(flag, TK:HostName(), ply:GetRank(), ply:Team(), ply:Name(), msg)	
end

function TK.DB:SendGlobalSystemMsg(msg)
	TK.DB:MakeQuery(TK.DB:FormatInsertQuery("server_globalchat", {
		{"msg_conection_id", false},
		{"msg_key", 1},
		{"msg_origin", TK:HostName()},
		{"msg_data", msg}
	}))
	
	GlobalChat:SendSysMsg(TK:HostName(), msg)
end

function TK.DB:SendRemoteCmd(ply, svr, cmd)
	TK.DB:MakeQuery(TK.DB:FormatInsertQuery("server_globalchat", {
		{"msg_conection_id", false},
		{"msg_key", 2},
		{"msg_origin", TK:HostName()},
		{"msg_recipient", svr},
		{"msg_data", cmd},
		{"sender_rank", ply:GetRank()},
		{"sender_faction", ply:Team()},
		{"sender_name", ply:Name()}
	}))
end

hook.Add("Initialize", "TKGlobalChat", function()
	timer.Create("TKGlobalChat", 15, 0, function()
		if !TK.DB:IsConnected() || GlobalChat.LastMsg == -1 then return end

		TK.DB:MakeQuery(TK.DB:FormatSelectQuery("server_globalchat", {}, {"msg_idx > %s", GlobalChat.LastMsg}, {"msg_idx"}), function(data)
			for k,v in ipairs(data) do
				GlobalChat.LastMsg = v.msg_idx
				if v.msg_conection_id == MySQL.ConnectionID then return end
				
				if v.msg_key == 0 then
					GlobalChat:SendPlyMsg(v.msg_flag, v.msg_origin, v.sender_rank, v.sender_faction, v.sender_name, v.msg_data)
				elseif v.msg_key == 1 then
					GlobalChat:SendSysMsg(v.msg_origin, v.msg_data)
				elseif v.msg_key == 2 then
					GlobalChat:RemoteFunction(v.msg_origin, v.msg_recipient, v.msg_data, v.sender_rank, v.sender_faction, v.sender_name)
				end
			end
		end)
		
		print("clear")
		GlobalChat.Flood = {}
	end)
end)

hook.Add("PlayerSay", "TKGlobalChat", function(ply, text, toteam)
	if string.sub(text, 1, 1) != ";" then return end
	local flag, msg = toteam && 1 || 0, ""
	if string.sub(text, 2, 2) == "@" then
		flag = flag + 2
		msg = string.Trim(string.sub(text, 3))
	else
		if string.sub(text, 2, 4) == "/me" then
			flag = flag + 4
			msg = string.Trim(string.sub(text, 5))
		else
			msg = string.Trim(string.sub(text, 2))
		end
	end
	if string.len(msg) < 2 then return end

	TK.DB:SendGlobalMsg(ply, msg, flag)
	return false
end)
