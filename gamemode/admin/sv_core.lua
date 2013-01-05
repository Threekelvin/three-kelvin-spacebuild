
local string = string
local table = table

TK.AM = TK.AM || {}

///--- FindTargets ---\\\
function TK.AM:GetIP(ply)
	if !IsValid(ply) then return end
	local ip = string.match(ply:IPAddress(), "(%d+%.%d+%.%d+%.%d+)")
	return ip
end

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
			return TK.AM:GetIP(ply) == string.match(name, "(%d+%.%d+%.%d+%.%d+)")
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
	for k,v in pairs(tab || {}) do
		if v == "*" then
			return TK.AM:TargetsList(ply)
		else
			for l,b in pairs(player.GetAll()) do
				if TK.AM:Match(b, v) then
					if ply:CanRunOn(b) && !table.HasValue(Targets, b) then
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
		net.WriteInt(tonumber(sound || 0), 4)
        
	if ply then
        net.Send(ply)
	else
        net.Broadcast()
	end
    
    TK.AM:ConsleMessage(arg)
end
///--- ---\\\

///--- Console Commands ---\\\
local function RunCmd(ply, com, arg)
	local command = arg[1]
	if !command || command == "" then return end
	table.remove(arg, 1)
	
	for k,v in pairs(TK.AM:GetAllPlugins()) do
		if v.Command then
			if string.lower(command) == string.lower(v.Command) then
				TK.AM:CallPlugin(v.Name, {ply, arg})
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
		
		if !c || c == "" then
			if string.lower(string.Left(Chat[1], string.len(p))) == p then
				local temp = string.sub(Chat[1], string.len(p) + 1)
				table.remove(Chat, 1)
				table.insert(Chat, 1, temp)
				TK.AM:CallPlugin(v.Name, {ply, Chat})
				return false
			end
		else
			if string.lower(Chat[1]) == string.lower(p..c) then
				table.remove(Chat, 1)
				TK.AM:CallPlugin(v.Name, {ply, Chat})
				return false
			end
		end
	end
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

function TK.AM:AddAFKBubble(ply)
	if IsValid(ply.bubble) then
		ply.bubble:SetSkin(1)
		return
	end
	
	local ent = ents.Create("tk_bubble")
	ent:SetPos(ply:GetPos())
	ent:SetAngles(ply:GetAngles())
	ent:Spawn()
	ent:SetParent(ply)
	ent:SetSkin(1)
	ply.bubble = ent
end

function TK.AM:RemoveAFKBubble(ply)
	if !IsValid(ply.bubble) then return end
	ply.bubble:Remove()
end
///--- ---\\\

///--- Hooks ---\\\
hook.Add("PlayXIsPermitted", "isTKDJ", function(ply)
	return ply:IsDJ()
end)
///--- ---\\\