
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

///--- Player Spawning ---\\\
local function SetSpawnPoint(ply, side)
	local Spawn = TK.SpawnPoints[side]
    
	for I=1, 8 do
		local RotVec = Vector(100, 0, 36)
		RotVec:Rotate(Angle(0, 45 * I, 0))
		local check1 = util.QuickTrace(Spawn + RotVec, Vector(0, 0, 113))
		local check2 = util.QuickTrace(Spawn + RotVec, Vector(0, 0, -113))
		if !check1.StartSolid && !check2.StartSolid then
			if check1.Hit && check2.Hit then
				if check1.HitPos:Distance(check2.HitPos) > 82 then
					ply:SetPos(check2.HitPos + Vector(0, 0, 5))
					return
				end
			elseif check1.Hit then
				ply:SetPos(check1.HitPos - Vector(0, 0, 77))
				return
			elseif check2.Hit then
				ply:SetPos(check2.HitPos + Vector(0, 0, 5))
				return
			else
				ply:SetPos(Spawn + RotVec - Vector(0, 0, 36))
				return
			end
		end
	end
    
	ply:SetMoveType(MOVETYPE_NOCLIP)
	ply:SetPos(Spawn)
end

function GM:PlayerLoadout(ply)
	ply:StripWeapons()
	ply:StripAmmo()
	
	ply:Give("weapon_physcannon")
	ply:Give("weapon_physgun")
	ply:Give("gmod_camera")
	ply:Give("gmod_tool")
	ply:Give("hands")
	
	local cl_defaultweapon = ply:GetInfo("cl_defaultweapon")

	if ply:HasWeapon(cl_defaultweapon) then
		ply:SelectWeapon(cl_defaultweapon) 
	end
    
    player_manager.RunClass(ply, "Loadout")
end

function GM:PlayerSpawn(ply)
    ply:UnSpectate()
    
	self:SetPlayerSpeed(ply, 250, 500)
	
	if ply:Team() == 4 then
		SetSpawnPoint(ply, 4)
	elseif ply:Team() == 3 then
		SetSpawnPoint(ply, 3)
	elseif ply:Team() == 2 then 
		SetSpawnPoint(ply, 2)
	else
		SetSpawnPoint(ply, 1)
	end
	
	ply:TakeDamage(0)
    
    local col = ply:GetInfo("cl_playercolor")
    ply:SetPlayerColor(Vector(col))

    local col = ply:GetInfo("cl_weaponcolor")
    ply:SetWeaponColor(Vector(col))

    player_manager.OnPlayerSpawn(ply)
	player_manager.RunClass(ply, "Spawn")
    
    hook.Call("PlayerLoadout", self, ply)
	hook.Call("PlayerSetModel", self, ply)
end
///--- ---\\\

///--- Entity Tracking ---\\\
local Tracking = {}
local Devices = {"tk_ore_laser", "tk_ore_storage", "tk_ore_scanner", "tk_tib_extractor", "tk_tib_storage"}

local function Compare(tab1, tab2)
	for k,v in pairs(tab1) do
		if !tab2[k] || tab2[k] != v then
			return false
		end
	end
	return true
end

function TK:CanSpawnDevice(ply, ent)
	if !IsValid(ply) then return false end
	local uid = ply:GetNWString("UID")
	local count = 0
	Tracking[uid] = Tracking[uid] || {}
	
	for k,v in pairs(Tracking[uid]) do
		if IsValid(v) then
			if v.device[1] == ent.device[1] then
				if v.device[2] == ent.device[2] then
					count = count + 1
				end
			else
				ply:SendLua("GAMEMODE:AddNotify('Can Not Spawn Different Devices', NOTIFY_GENERIC, 5)")
				return false
			end
		else
			Tracking[uid][k] = nil
		end
	end
	
	if Compare(ent.device, {1, 1}) then
		if count >= 1 then
			ply:SendLua("GAMEMODE:AddNotify('Maximum Mining Devices', NOTIFY_GENERIC, 5)")
		else
			return true
		end
	elseif Compare(ent.device, {1, 2}) then
		if count >= 4 then
			ply:SendLua("GAMEMODE:AddNotify('Maximum Storage Devices', NOTIFY_GENERIC, 5)")
		else
			return true
		end
	elseif Compare(ent.device, {1, 3}) then
		if count >= 1 then
			ply:SendLua("GAMEMODE:AddNotify('Maximum Asteroid Scanners', NOTIFY_GENERIC, 5)")
		else
			return true
		end
	elseif Compare(ent.device, {2, 1}) then
		if count >= 1 then
			ply:SendLua("GAMEMODE:AddNotify('Maximum Mining Devices', NOTIFY_GENERIC, 5)")
		else
			return true
		end
	elseif Compare(ent.device, {2, 2}) then
		if count >= 4 then
			ply:SendLua("GAMEMODE:AddNotify('Maximum Storage Devices', NOTIFY_GENERIC, 5)")
		else
			return true
		end
	end
	
	return false
end

function TK:LoadDeviceData(ply, ent)
	if ent.device[1] == 1 then
		ent.upgrades = TK.DB:GetPlayerData(ply, "terminal_upgrades_ore")
		ent:Update()
	elseif ent.device[1] == 2 then
		ent.upgrades = TK.DB:GetPlayerData(ply, "terminal_upgrades_tib")
		ent:Update()
	end
end

function TK:UpdateDeviceData(ply, device)
	local uid = ply:GetNWString("UID")
	Tracking[uid] = Tracking[uid] || {}
	
	if device == 1 then
		for k,v in pairs(Tracking[uid]) do
			if IsValid(v) && v.device[1] == 1 then
				v.upgrades = TK.DB:GetPlayerData(ply, "terminal_upgrades_ore")
				v:Update()
			end
		end
	elseif device == 2 then
		for k,v in pairs(Tracking[uid]) do
			if IsValid(v) && v.device[1] == 2 then
				v.upgrades = TK.DB:GetPlayerData(ply, "terminal_upgrades_tib")
				v:Update()
			end
		end
	end
end

hook.Add("CPPIAssignOwnership", "TKTracking", function(ply, ent)
	if table.HasValue(Devices, ent:GetClass()) then
		if !TK:CanSpawnDevice(ply, ent) then 
			SafeRemoveEntity(ent)
		else
			TK:LoadDeviceData(ply, ent)
			table.insert(Tracking[ply:GetNWString("UID")], ent)
		end
	end
end)
///--- ---\\\

///--- Map Setup ---\\\
hook.Add("InitPostEntity", "TKSetup", function()
	timer.Simple(1, function()
		for k,v in pairs(ents.GetAll()) do
			if v:GetClass() == "prop_physics" then
				v:Remove()
			end
		end

		for k,v in pairs(TK.Ents) do
			local ent = ents.Create(v.ent)
			if v.model then
				ent:SetModel(v.model)
			end
			ent:SetPos(v.pos)
			ent:SetAngles(v.ang)
			ent:Spawn()
			ent:SetUnFreezable(true)
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableMotion(false)
			end
			table.insert(TK.SpawnedEnts, ent)
		end
	end)
end)
///--- ---\\\

///--- Map Resources ---\\\
hook.Add("Tick", "TKSpawning", function()
	for k,v in pairs(TK.RoidFields) do
		if CurTime() > v.NextSpawn && table.Count(v.Ents) < 20 then
			local pos = Vector(math.random(0, 5000),0,0)
			pos:Rotate(Angle(math.random(0, 360), math.random(0, 360), 0))
			
			local rand = v.Pos + pos
			local space = ents.FindInSphere(rand, 1000)
			local CanSpawn = true
			for k2,v2 in pairs(space) do
				if IsValid(v2) && IsValid(v2:GetPhysicsObject()) then
                    CanSpawn = false
                    break
				end
			end
			
			if CanSpawn then
				local ent = ents.Create("tk_roid")
				ent:SetPos(rand)
				ent:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
				ent:Spawn()
				ent.GetField = function()
					return v.Ents || {}
				end
				ent:CallOnRemove("UpdateList", function()
					v.Ents[ent:EntIndex()] = nil
				end)
				
				v.Ents[ent:EntIndex()] = ent
				v.NextSpawn = CurTime() + 30 * (table.Count(v.Ents)/20) + 5
			else
				v.NextSpawn = CurTime() + 1
			end
		end
	end
	
	for k,v in pairs(TK.TibFields) do
		if CurTime() > v.NextSpawn && table.Count(v.Ents) < 10 then
			local pos = Vector(math.random(0, 1100),0,0)
			pos:Rotate(Angle(0,math.random(0, 360),0))
			
			local rand = v.Pos + pos + Vector(0,0,260)
			local trace =  util.QuickTrace(rand, Vector(0,0,-520))
			if trace.HitWorld then
				local CanSpawn = true
				for k2,v2 in pairs(v.Ents) do
					if v2:GetPos():Distance(trace.HitPos) < 400 then
						CanSpawn = false
						break
					end
				end
				
				if CanSpawn then
					local ent = ents.Create("tk_tib_crystal")
					ent:SetPos(trace.HitPos)
					ent:SetAngles(trace.HitNormal:Angle() + Angle(90,0,0))
					ent:Spawn()
					ent.GetField = function()
						return v.Ents || {}
					end
					ent:CallOnRemove("UpdateList", function()
						v.Ents[ent:EntIndex()] = nil
					end)
					
					v.Ents[ent:EntIndex()] = ent
					v.NextSpawn = CurTime() + 60 * (table.Count(v.Ents)/10) + 5
				else
					v.NextSpawn = CurTime() + 1
				end
			end
		end
	end
end)
///--- ---\\\