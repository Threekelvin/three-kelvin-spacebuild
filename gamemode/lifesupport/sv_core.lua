
util.AddNetworkString("TKLS_Ply")

local function PlayerLSCheck()
	if !TK.AT.IsSpacebuild then return end
	for _,ply in pairs(player.GetAll()) do
		if IsValid(ply) && ply.hev && ply:Alive() then
			local pod = ply:GetVehicle()
			local env = ply:GetEnv()
			local temp, insun = env:DoTemp(ply)
			local airper = math.floor(env:GetTrueAtmospherePercent("oxygen"))
			
			if insun && env.atmosphere.sunburn then
				ply:TakeDamage(5)
			end
			
			if temp != ply.hev.temp then
				ply.hev.temp = temp
				ply.hev.update = true
			end
			
			if ply.hev.temp < 273 then
				local required = math.floor((290 - ply.hev.temp) / 34)
				if IsValid(pod) then
					required = required - pod:ConsumeResource("energy", required)
				end
				
				if required == 0 then
				
				elseif ply.hev.energy >= required then
					ply.hev.energy = ply.hev.energy - required
					ply.hev.temp = 290
					ply.hev.update = true
				else
					local left = required - ply.hev.energy
					ply.hev.energy = 0
					ply.hev.temp = 290 - left * 17
					ply.hev.update = true
					
					local dmg = (290 - ply.hev.temp) / 10
					ply.hev.recover = ply.hev.recover + dmg
					ply:TakeDamage(dmg)
				end
			elseif ply.hev.temp > 307 then
				local required = math.floor((ply.hev.temp - 290) / 34)
				if IsValid(pod) then
					required = required - pod:ConsumeResource("water", required)
				end
				
				if required == 0 then
				
				elseif ply.hev.water >= required then
					ply.hev.water = ply.hev.water - required
					ply.hev.temp = 290
					ply.hev.update = true
				else
					local left = required - ply.hev.water
					ply.hev.water = 0
					ply.hev.temp = 290 + left * 17
					ply.hev.update = true
					
					local dmg = (ply.hev.temp - 290) / 10
					ply.hev.recover = ply.hev.recover + dmg
					ply:TakeDamage(dmg)
				end
			else
				if ply.hev.energy < 100 then
					ply.hev.energy = math.min(ply.hev.energy + 5, 100)
					ply.hev.update = true
				end
				if ply.hev.water < 100 then
					ply.hev.water = math.min(ply.hev.water + 5, 100)
					ply.hev.update = true
				end
			end
			
			if airper != ply.hev.airper then
				ply.hev.airper = airper
				ply.hev.update = true
			end
			
			if ply.hev.airper < 5 || ply:WaterLevel() == 3 then
				local required = 5
				if IsValid(pod) then
					required = required - pod:ConsumeResource("oxygen", required)
				end
				if required == 0 then
				
				elseif ply.hev.oxygen >= required then
					ply.hev.oxygen = ply.hev.oxygen - required
					ply.hev.update = true
				else
					local left = required - ply.hev.oxygen
					ply.hev.oxygen = 0
					ply.hev.update = true
					
					ply.hev.recover = ply.hev.recover + left
					ply:TakeDamage(left)
				end
			else
				if ply.hev.oxygen < 100 then
					ply.hev.oxygen = math.min(ply.hev.oxygen + 5, 100)
					ply.hev.update = true
				end
				
				env:ConsumeAtmosphere("oxygen", 5)
				env:SupplyAtmosphere("carbon_dioxide", 5)
			end
			
			if ply.hev.recover > 0 && ply.hev.temp > 273 && ply.hev.temp < 307 && ply.hev.oxygen > 0 then
				if ply:Health() + 5 >= 100 then
					ply:SetHealth(100)
					ply.hev.recover = 0
				else
					ply:SetHealth(ply:Health() + 5)
					ply.hev.recover = ply.hev.recover - 5
				end
			end
			
			if ply.hev.update then
				ply.hev.update = false
                
                local data = {}
                data.energy = ply.hev.energy
                data.water = ply.hev.water
                data.oxygen = ply.hev.oxygen
                data.temp = temp
                data.airper = airper
                
                net.Start("TKLS_Ply")
                    net.WriteTable(data)
                net.Send(ply)
			end
		end
	end
end

hook.Add("Initialize", "TKLS", function()
	timer.Create("TKLS_Think", 1, 0, PlayerLSCheck)
end)

hook.Add("PlayerInitialSpawn", "TKLS", function(ply)
	ply.auenv = {}
	ply.auenv.envlist = {Space}
	ply.auenv.gravity = -1
	ply:GetEnv():DoGravity(ply)
	
	timer.Simple(5, function(ply)
		if !IsValid(ply) then return end
		ply.hev = {}
		ply.hev.energy = 100
		ply.hev.energymax = 1500
		ply.hev.oxygen = 100
		ply.hev.oxygenmax = 1500
		ply.hev.water = 100
		ply.hev.watermax = 1500
		ply.hev.temp = 290
		ply.hev.airper = 5
		ply.hev.recover = 0
		ply.hev.update = true
		ply.hev.sound = 0
	end, ply)
end)

hook.Add("PlayerSpawn", "TKLS", function(ply)
	ply.hev = ply.hev || {}
	ply.hev.energy = 100
	ply.hev.oxygen = 100
	ply.hev.water = 100
	ply.hev.temp = 290
	ply.hev.airper = 5
	ply.hev.recover = 0
	ply.hev.update = true
end)

hook.Add("OnAtmosphereChange", "TKLS", function(ent, old, new)
	if ent:IsPlayer() && !ent:IsAdmin() then
		if new.atmosphere.noclip then return end
		if ent:GetMoveType() == MOVETYPE_NOCLIP then
			ent:SetMoveType(MOVETYPE_WALK)
			ent:SetVelocity(-ent:GetVelocity() * 0.75)
		end
	end
end)

hook.Add("PlayerNoClip", "TKLS", function(ply)
	if ply:IsAdmin() then return end
	if ply:GetEnv().atmosphere.noclip then return end
	return false
end)

hook.Add("SetupMove", "TKLS", function(ply, data)
	if ply:IsAdmin() then return end
	local env = ply:GetEnv()
	if env.atmosphere.noclip || env.atmosphere.gravity > 0 then return end
	data:SetForwardSpeed(0)
	data:SetSideSpeed(0)
	data:SetUpSpeed(0)
end)