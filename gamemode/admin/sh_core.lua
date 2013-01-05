
TK.AM = TK.AM || {}

TK.AM.Rank = {
	Group = {"User", "VIP", "DJ", "Moderator", "Admin", "SuperAdmin", "Owner"},
	Tag = {"", "[VIP] ", "[DJ] ", "[M] ", "[A] ", "[SA] ", "[O] "},
	RGBA = {Color(255,255,255), Color(0,75,255), Color(0, 0, 0), Color(0,200,0), Color(255,215,0), Color(200,0,0), Color(125,0,255)}		
}

///--- Plugins ---\\\
local Plugins = {}

function TK.AM:GetAllPlugins()
	return table.Copy(Plugins)
end

function TK.AM:CallPlugin(name, arg)
	for _,plugin in pairs(Plugins) do
		if plugin.Name == name then
			local status, error = pcall(plugin.Call, unpack(arg || {}))
			if !status then 
				ErrorNoHalt(error.."\n") 
				return false
			end
			return true
		end
	end
end

function TK.AM:RegisterPlugin(Plugin)	
	print("3K Admin Plugin - "..Plugin.Name.." - Loaded")
	table.insert(Plugins, Plugin)
end

local function LoadPlugins()
	for k,v in pairs(file.Find(GM.FolderName .."/gamemode/admin/plugins/*.lua", "LUA")) do
		local path = GM.FolderName .."/gamemode/admin/plugins/"..v
		
		if SERVER then
			include(path)
			AddCSLuaFile(path) 
		else
			include(path)
		end
	end
	
	TK.AM.RegisterPlugin = nil
end

///--- Player functions ---\\\
local SafeLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890,<>#~!£&_=|: "
local BadLetters = {"(", "[", "^", "$", "%", ".", "*", "+", "-", "?", "]", ")"}

function TK.AM:NameMakeSafe(str)
	local safestr = ""
	for k,v in ipairs(string.ToTable(str)) do
		if !table.HasValue(BadLetters, v) && string.find(SafeLetters, v) then
			safestr = safestr..v
		end
	end
	safestr = string.Trim(safestr)
	if safestr == "" then
		safestr = "[Too Many Invalid Characters]"
	end
	return safestr
end

function _R.Entity:GetSafeName()
	if !IsValid(self) || !self:IsPlayer() then return "Console" end
	local name = TK.AM:NameMakeSafe(self:GetName())
	return name
end

function _R.Entity:Nick()
	if !IsValid(self) || !self:IsPlayer() then return "Console" end
	return self:GetNWString("TKName", self:GetSafeName())
end

function _R.Player:Nick()
	if !IsValid(self) then return "Console" end
	return self:GetNWString("TKName", self:GetSafeName())
end

function _R.Entity:Name()
	if !IsValid(self) || !self:IsPlayer() then return "Console" end
	return self:GetNWString("TKName", self:GetSafeName())
end

function _R.Player:Name()
	if !IsValid(self) || !self:IsPlayer() then return "Console" end
	return self:GetNWString("TKName", self:GetSafeName())
end

function _R.Player:GetRank()
	if !IsValid(self) then return 1 end
	return self:GetNWInt("TKRank", 1)
end

function _R.Entity:GetGroup()
	if !IsValid(self) then return "Owner" end
	return TK.AM.Rank.Group[self:GetNWInt("TKRank", 1)]
end

function _R.Entity:GetTag()
	if !IsValid(self) then return "[Owner]" end
	return TK.AM.Rank.Tag[self:GetNWInt("TKRank", 1)]
end

function _R.Entity:GetRGBA()
	if !IsValid(self) then return TK.AM.Rank.RGBA[6] end
	return TK.AM.Rank.RGBA[self:GetNWInt("TKRank", 1)]
end

function _R.Entity:IsOwner()
	if !IsValid(self) then return true end
	return self:GetNWInt("TKRank", 1) >= 7
end

function _R.Entity:IsSuperAdmin()
	if !IsValid(self) then return true end
	return self:GetNWInt("TKRank", 1) >= 6
end

function _R.Player:IsSuperAdmin()
	if !IsValid(self) then return true end
	return self:GetNWInt("TKRank", 1) >= 6
end

function _R.Entity:IsAdmin()
	if !IsValid(self) then return true end
	return self:GetNWInt("TKRank", 1) >= 5
end

function _R.Player:IsAdmin()
	if !IsValid(self) then return true end
	return self:GetNWInt("TKRank", 1) >= 5
end

function _R.Entity:IsModerator()
	if !IsValid(self) then return true end
	return self:GetNWInt("TKRank", 1) >= 4
end

function _R.Entity:IsDJ()
	if !IsValid(self) then return true end
	return self:GetNWInt("TKRank", 1) >= 3
end

function _R.Entity:IsVip()
	if !IsValid(self) then return true end
	return self:GetNWInt("TKRank", 1) >= 2
end

function _R.Entity:IsUser()
	if !IsValid(self) then return true end
	return self:GetNWInt("TKRank", 1) >= 1
end

function _R.Entity:IsInGroup(name)
	return string.lower(self:GetGroup()) == string.lower(name)
end

function _R.Entity:HasAccess(lvl)
	if !IsValid(self) then return true end
	return self:GetNWInt("TKRank", 1) >= (lvl || 0)
end

function _R.Entity:CanRunOn(ply)
	if !IsValid(self) then return true end
	if !IsValid(ply) then return false end
	return self:GetNWInt("TKRank", 1) >= ply:GetNWInt("TKRank", 1)
end

///--- Messages ---\\\
local function ConMessageSetup(arg)
	local Table = {}
	
	for k,v in ipairs(arg) do
		if type(v) == "Entity" then
			if !IsValid(v) then
				table.insert(Table, v:Name())
			end
		elseif type(v) == "Player" then
			table.insert(Table, v:GetTag())
			table.insert(Table, v:Name())
		elseif type(v) == "string" then
			table.insert(Table, v)
		end
	end
	return Table
end

function TK.AM:ConsleMessage(arg)
	print(table.concat(ConMessageSetup(arg), ""))
end

LoadPlugins()