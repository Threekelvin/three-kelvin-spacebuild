
GM.Name         = "3K Spacebuild"
GM.Author         = "Ghost400"
GM.Email         = "N/A"
GM.Website         = ""

DeriveGamemode("sandbox")
_R = debug.getregistry()

TK = TK or {}

local string = string
local math = math

///--- Teams ---\\\
team.SetUp(0, "Console", Color(151,211,255), false)
team.SetUp(1, "Mercenary", Color(147,147,150))
team.SetUp(2, "The Solar Empire", Color(235,175,75))
team.SetUp(3, "The New Lunar Republic", Color(75,75,235))
team.SetUp(4, "The Changelings", Color(175,235,75))
team.SetUp(5, "I <3 DOTA 2", Color(200,75,75))
///--- ---\\\

function TK:HostName()
    return string.match(GetHostName(), "%[%w+%]") or "[Server]"
end

function TK:Format(num)
    if !num then return "0" end
    local int, rem = math.modf(tonumber(num))
    local val, ret, n = tostring(int), "", 0
    while true do
        ret = ret .. val[#val - n]
        n = n + 1
        if (n % 3) == 0 and n < #val then
            ret = ret..","
        end

        if n > #val then break end
    end
    if rem != 0 then
        return string.reverse(ret)..string.sub(tostring(rem), 2)
    else
        return string.reverse(ret)
    end
end

function TK:OO(num)
    if !num then return "0" end
    if num < 10 then
        return "0"..tostring(num)
    end
    return tostring(num)
end

function TK:FormatTime(num)
    if !num then return "0" end
    local days, rem = math.modf(num / 1440)
    local hours, rem = math.modf(rem * 24)
    local mins, rem = math.modf(rem * 60)
    
    if days > 0 then
        return TK:OO(days).." days "..TK:OO(hours).." hrs "..TK:OO(mins).." mins"
    elseif hours > 0 then
        return TK:OO(hours).." hrs "..TK:OO(mins).." mins"
    elseif mins > 0 then
        return TK:OO(mins).." mins"
    else
        return "0 mins"
    end
end

//--- Random string generation ---\\
local Chars = {}
for Loop = 0, 255 do
   Chars[Loop+1] = string.char(Loop)
end
local String = table.concat(Chars)

local Built = {['.'] = Chars}

local AddLookup = function(CharSet)
   local Substitute = string.gsub(String, '[^'..CharSet..']', '')
   local Lookup = {}
   for Loop = 1, string.len(Substitute) do
       Lookup[Loop] = string.sub(Substitute, Loop, Loop)
   end
   Built[CharSet] = Lookup

   return Lookup
end

function string.random(Length, CharSet)
   -- Length (number)
   -- CharSet (string, optional); e.g. %l%d for lower case letters and digits

   local CharSet = CharSet or '%a%d'

   if CharSet == '' then
      return ''
   else
      local Result = {}
      local Lookup = Built[CharSet] or AddLookup(CharSet)
      local Range = table.getn(Lookup)

      for Loop = 1,Length do
         Result[Loop] = Lookup[math.random(1, Range)]
      end

      return table.concat(Result)
   end
end
//--- ---\\

function TK:CanUsePlayerModel(ply, mdl)
    local modelname = player_manager.TranslatePlayerModel(mdl)
    
    if TK.Settings.PlyMdls[modelname] then
        local canuse = !TK.Settings.PlyMdls[modelname].sid and true or false
        
        for k,v in pairs(TK.Settings.PlyMdls[modelname].sid or {}) do
            if ply:SteamID() != v then continue end
            canuse = true
            break
        end
        
        if ply:GetRank() < (TK.Settings.PlyMdls[modelname].rank or 1) then
            canuse = false
        end
        
        return canuse
    end
    
    return true
end

local function IsValidFolder(dir)
    if dir == "." or dir == ".." then return false end
    if string.GetExtensionFromFilename(dir) then return false end
    return true
end

local function LoadModules()
    local root = GM.FolderName .."/gamemode/"
    local files, dirs = file.Find(root.."*", "LUA")
    
    for _,dir in pairs(dirs) do
        if !IsValidFolder(dir) then continue end
        
        for _,lua in pairs(file.Find(root .. dir .."/*.lua", "LUA")) do
            local path = root .. dir .."/".. lua
            
            if lua:match("^sv_") then
                if SERVER then
                    include(path)
                end
            elseif lua:match("^sh_") then
                if SERVER then
                    AddCSLuaFile(path)
                    include(path)
                else
                    include(path)
                end
            elseif lua:match("^cl_") then
                if SERVER then
                    AddCSLuaFile(path)
                else
                    include(path)
                end
            end
        end
    end
end

hook.Add("Initialize", "EntSpawn", function()
    GAMEMODE.EntitySpawned = function()
    end
    
    local Spawn = _R.Entity.Spawn
    function _R.Entity:Spawn()
        Spawn(self)
        gamemode.Call("EntitySpawned", self)
    end
    
    for k,v in pairs(ents.GetAll()) do
        if !IsValid(v) then continue end
        if v:GetClass() == "func_dustcloud" then
            v:Remove()
        end
    end
    
    local CleanUp = game.CleanUpMap
    function game.CleanUpMap(bln, filters)
        local data = filters or {}
        table.insert(data, "at_planet")
        table.insert(data, "at_star")
        
        CleanUp(bln, data)
        
        if !SERVER then return end
        
        for k,v in pairs(ents.GetAll()) do
            if v:GetClass() != "func_dustcloud" then continue end
            SafeRemoveEntity(v)
        end
        
        if TK.Settings.CleanUpFunction then
            TK.Settings.CleanUpFunction()
        end

        for k,v in pairs(TK.Settings.MapEntities) do
            local ent = ents.Create(v.ent)
            if !IsValid(ent) then continue end
            if v.model then ent:SetModel(v.model) end

            ent:SetPos(v.pos)
            ent:SetAngles(v.ang)
            ent:Spawn()
            ent:SetUnFreezable(true)
            
            local phys = ent:GetPhysicsObject()
            if phys:IsValid() then phys:EnableMotion(false) end
            if v.notsolid then ent:SetNotSolid(true) end
            if v.color then 
                ent:SetColor(v.color)
                ent:SetRenderMode(RENDERMODE_TRANSALPHA)
            end
        end
    end
end)


///--- GHD Fix ---\\\
function TK:FindInSphere(pos, rad)
    if ents.RealFindInSphere then
        local res = ents.RealFindInSphere(pos, rad)
        for k,v in pairs(res) do
            if !v.SLIsGhost then continue end
            res[k] = nil
        end

        return res
    end
    return ents.FindInSphere(pos, rad)
end
///--- ---\\\

LoadModules()