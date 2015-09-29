local string = string
local table = table
TK.AM = TK.AM or {}

TK.AM.Rank = {
    Group = {"User",  "VIP",  "DJ",  "Moderator",  "Admin",  "SuperAdmin",  "Owner"},
    Tag = {"",  "[VIP] ",  "[DJ] ",  "[M] ",  "[A] ",  "[SA] ",  "[O] "},
    RGBA = {Color(255, 255, 255),  Color(0, 75, 255),  Color(0, 0, 0),  Color(0, 200, 0),  Color(255, 215, 0),  Color(200, 0, 0),  Color(125, 0, 255)},
    Icon = {Material("icon16/user.png"),  Material("icon16/vip.png"),  Material("icon16/dj.png"),  Material("icon16/moderator.png"),  Material("icon16/admin.png"),  Material("icon16/superadmin.png"),  Material("icon16/owner.png")}
}

--/--- Plugins ---\\\
local Plugins = {}

function TK.AM:GetAllPlugins()
    return table.Copy(Plugins)
end

function TK.AM:CallPlugin(id, ply, arg)
    local plugin = Plugins[id]

    if ply:HasAccess(plugin.Level) then
        local status, error = pcall(plugin.Call, ply, arg)

        if not status then
            ErrorNoHalt(error .. "\n")
        end
    else
        TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
    end
end

local function LoadPlugins()
    print([[///--- TKAM Loading Plugins ---\\\]])
    local JustInCase = PLUGIN

    for _, lua in pairs(file.Find(GM.FolderName .. "/gamemode/admin/plugins/*.lua", "LUA")) do
        local path = GM.FolderName .. "/gamemode/admin/plugins/" .. lua
        PLUGIN = {}

        if SERVER then
            include(path)
            AddCSLuaFile(path)
        else
            include(path)
        end

        local idx = lua:match("^[%w_ ]+")
        Plugins[idx] = PLUGIN
        print("TKAM Plugin -", PLUGIN.Name, "- Loaded")
    end

    PLUGIN = JustInCase
    print([[///--- TKAM Loaded Plugins ---\\\]])
end

--/--- Player Functions ---\\\
local SafeLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890,<>#~!&_=|: "
local BadLetters = {"(",  "[",  "^",  "$",  "%",  ".",  "*",  "+",  "-",  "?",  "]",  ")"}

function TK.AM:NameMakeSafe(str)
    local safestr = ""

    for k, v in ipairs(string.ToTable(str)) do
        if not table.HasValue(BadLetters, v) and string.find(SafeLetters, v) then
            safestr = safestr .. v
        end
    end

    safestr = string.Trim(safestr)

    if safestr == "" then
        safestr = "[Too Many Invalid Characters]"
    end

    return string.sub(safestr, 1, 125)
end

function _R.Entity:GetSafeName()
    if not IsValid(self) or not self:IsPlayer() then return "Console" end
    local name = TK.AM:NameMakeSafe(self:GetName())

    return name
end

function _R.Player:Nick()
    if not IsValid(self) then return "Console" end

    return self:GetNWString("TKName", self:GetSafeName())
end

function _R.Player:Name()
    if not IsValid(self) then return "Console" end

    return self:GetNWString("TKName", self:GetSafeName())
end

function _R.Player:GetRank()
    if not IsValid(self) then return 1 end

    return self:GetNWInt("TKRank", 1)
end

function _R.Entity:GetGroup()
    if not IsValid(self) then return "Owner" end

    return TK.AM.Rank.Group[self:GetNWInt("TKRank", 1)]
end

function _R.Entity:GetTag()
    if not IsValid(self) then return "[Owner]" end

    return TK.AM.Rank.Tag[self:GetNWInt("TKRank", 1)]
end

function _R.Entity:GetRGBA()
    if not IsValid(self) then return TK.AM.Rank.RGBA[6] end

    return TK.AM.Rank.RGBA[self:GetNWInt("TKRank", 1)]
end

function _R.Entity:GetIcon()
    if not IsValid(self) then return TK.AM.Rank.Icon[6] end

    return TK.AM.Rank.Icon[self:GetNWInt("TKRank", 1)]
end

function _R.Entity:IsOwner()
    if not IsValid(self) then return true end

    return self:GetNWInt("TKRank", 1) >= 7
end

function _R.Entity:IsSuperAdmin()
    if not IsValid(self) then return true end

    return self:GetNWInt("TKRank", 1) >= 6
end

function _R.Player:IsSuperAdmin()
    if not IsValid(self) then return true end

    return self:GetNWInt("TKRank", 1) >= 6
end

function _R.Entity:IsAdmin()
    if not IsValid(self) then return true end

    return self:GetNWInt("TKRank", 1) >= 5
end

function _R.Player:IsAdmin()
    if not IsValid(self) then return true end

    return self:GetNWInt("TKRank", 1) >= 5
end

function _R.Entity:IsModerator()
    if not IsValid(self) then return true end

    return self:GetNWInt("TKRank", 1) >= 4
end

function _R.Entity:IsDJ()
    if not IsValid(self) then return true end

    return self:GetNWInt("TKRank", 1) >= 3
end

function _R.Entity:IsVip()
    if not IsValid(self) then return true end

    return self:GetNWInt("TKRank", 1) >= 2
end

function _R.Entity:IsUser()
    if not IsValid(self) then return true end

    return self:GetNWInt("TKRank", 1) >= 1
end

function _R.Entity:IsInGroup(name)
    return string.lower(self:GetGroup()) == string.lower(name)
end

function _R.Entity:HasAccess(lvl)
    if not IsValid(self) then return true end

    return self:GetNWInt("TKRank", 1) >= (lvl or 0)
end

function _R.Entity:CanRunOn(ply)
    if not IsValid(self) then return true end
    if not IsValid(ply) then return false end

    return self:GetNWInt("TKRank", 1) > ply:GetNWInt("TKRank", 1)
end

function _R.Player:IsAFK()
    return self:GetNWBool("TKAFK", false)
end

--/--- Messages ---\\\
local function ConMessageSetup(arg)
    local Table = {}

    for k, v in ipairs(arg) do
        if type(v) == "Entity" then
            if not IsValid(v) then
                table.insert(Table, "Console")
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
