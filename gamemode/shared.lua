
GM.Name 		= "3K Spacebuild"
GM.Author 		= "Ghost400"
GM.Email 		= "N/A"
GM.Website 	    = ""

DeriveGamemode("sandbox")
_R = debug.getregistry()

TK = TK || {}

local string = string
local math = math

///--- Teams ---\\\
team.SetUp(1, "Mercenary", Color(147,147,150))
team.SetUp(2, "The Solar Empire", Color(235,175,75))
team.SetUp(3, "The New Lunar Republic", Color(75,75,235))
team.SetUp(4, "The Changelings", Color(175,235,75))
team.SetUp(5, "I <3 DOTA 2", Color(135,45,45))
///--- ---\\\

function TK:HostName()
	return string.match(GetHostName(), "%[%w+%]") || "[Server]"
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

local function IsValidFolder(dir)
	if dir == "." || dir == ".." then return false end
	if string.GetExtensionFromFilename(dir) then return false end
	return true
end

local function LoadModules()
	local root = GM.FolderName .."/gamemode/"
    local files, dirs = file.Find(root.."*", "LUA")
    
	for _,dir in pairs(dirs) do
		if IsValidFolder(dir) then
			for _,lua in pairs(file.Find(root .. dir .."/*.lua", "LUA")) do
				local path = root .. dir .."/".. lua
				local run = string.sub(lua, 1, 3)
				
				if run == "sv_" then
					if SERVER then
						include(path)
					end
				elseif run == "sh_" then
					if SERVER then
						AddCSLuaFile(path)
						include(path)
					else
						include(path)
					end
				elseif run == "cl_" then
					if SERVER then
						AddCSLuaFile(path)
					else
						include(path)
					end
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
    
    local CleanUp = game.CleanUpMap
    function game.CleanUpMap(bln, filters)
        local data = filters || {}
        table.insert(data, "at_planet")
        table.insert(data, "at_star")
        
        CleanUp(bln, data)
        
        if !SERVER then return end
        
        for k,v in pairs(TK.SpawnedEnts) do
            if IsValid(v) then v:Remove() end
            TK.SpawnedEnts[k] = nil
        end
        
        for k,v in pairs(TK.Ents) do
            local ent = ents.Create(v.ent)
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
            
            table.insert(TK.SpawnedEnts, ent)
        end
    end
end)

LoadModules()