
util.AddNetworkString("TKLS_Ply")

local function PlayerUpdate(ply)
    local data = {}
    data.energy = ply.tk_hev.energy
    data.water = ply.tk_hev.water
    data.oxygen = ply.tk_hev.oxygen
    data.temp = temp
    data.airper = airper
    
    net.Start("TKLS_Ply")
        net.WriteTable(data)
    net.Send(ply)
end

local function PlayerLSCheck()
	if !TK.AT.IsSpacebuild then return end
	for _,ply in pairs(player.GetAll()) do
		if !IsValid(ply) || !ply.tk_hev || !ply:Alive() then continue end
        
        local env = ply:GetEnv()
        local temp, insun = env:DoTemp(ply)
        local airper = math.floor(env:GetResourcePercent("oxygen"))
        
        if insun && env.atmosphere.sunburn then
            ply:TakeDamage(5)
        end
        
        if temp != ply.tk_hev.temp then
            ply.tk_hev.temp = temp
            ply.tk_hev.update = true
        end
        
        if ply.tk_hev.temp < 273 then
            local required = 5

            if ply.tk_hev.energy >= required then
                ply.tk_hev.energy = ply.tk_hev.energy - required
                ply.tk_hev.temp = 290
                ply.tk_hev.update = true
            else
                local left = required - ply.tk_hev.energy
                ply.tk_hev.energy = 0
                ply.tk_hev.temp = 290 - left * 17
                ply.tk_hev.update = true
                
                local dmg = (290 - ply.tk_hev.temp) / 10
                ply:TakeDamage(dmg)
            end
        elseif ply.tk_hev.temp > 307 then
            local required = 5
            
            if ply.tk_hev.water >= required then
                ply.tk_hev.water = ply.tk_hev.water - required
                ply.tk_hev.temp = 290
                ply.tk_hev.update = true
            else
                local left = required - ply.tk_hev.water
                ply.tk_hev.water = 0
                ply.tk_hev.temp = 290 + left * 17
                ply.tk_hev.update = true
                
                local dmg = (ply.tk_hev.temp - 290) / 10
                ply:TakeDamage(dmg)
            end
        else
            if ply.tk_hev.energy < ply.tk_hev.energymax  then
                ply.tk_hev.energy = math.min(ply.tk_hev.energy + 5, ply.tk_hev.energymax)
                ply.tk_hev.update = true
            end
            if ply.tk_hev.water < ply.tk_hev.watermax  then
                ply.tk_hev.water = math.min(ply.tk_hev.water + 5, ply.tk_hev.watermax)
                ply.tk_hev.update = true
            end
        end
        
        if airper != ply.tk_hev.airper then
            ply.tk_hev.airper = airper
            ply.tk_hev.update = true
        end
        
        if ply.tk_hev.airper < 5 || ply:WaterLevel() == 3 then
            local required = 5
            
            if ply.tk_hev.oxygen >= required then
                ply.tk_hev.oxygen = ply.tk_hev.oxygen - required
                ply.tk_hev.update = true
            else
                local left = required - ply.tk_hev.oxygen
                ply.tk_hev.oxygen = 0
                ply.tk_hev.update = true
                
                ply:TakeDamage(left)
            end
        else
            if ply.tk_hev.oxygen < ply.tk_hev.oxygenmax then
                ply.tk_hev.oxygen = math.min(ply.tk_hev.oxygen + 5, ply.tk_hev.oxygenmax)
                ply.tk_hev.update = true
            end
        end
        
        if ply.tk_hev.health == ply:Health() && ply:Health() < 100 then
            ply:SetHealth(math.min(ply:Health() + 1, 100))
        end
        
        ply.tk_hev.health = ply:Health()
        
        if ply.tk_hev.update then
            ply.tk_hev.update = false
            PlayerUpdate(ply)
        end
    end
end

hook.Add("Initialize", "TKLS", function()
	timer.Create("TKLS_Think", 1, 0, PlayerLSCheck)
end)

hook.Add("PlayerInitialSpawn", "TKLS", function(ply)
	ply.tk_env = {}
	ply.tk_env.envlist = {Space}
	ply.tk_env.gravity = -1
	ply:GetEnv():DoGravity(ply)
	
    ply.tk_hev = {}
    ply.tk_hev.energy = 300
    ply.tk_hev.energymax = 300
    ply.tk_hev.oxygen = 300
    ply.tk_hev.oxygenmax = 300
    ply.tk_hev.water = 300
    ply.tk_hev.watermax = 300
    ply.tk_hev.temp = 290
    ply.tk_hev.airper = 5
    ply.tk_hev.health = 100
    ply.tk_hev.update = true
end)

hook.Add("PlayerSpawn", "TKLS", function(ply)
	ply.tk_hev = ply.tk_hev || {}
	ply.tk_hev.energy = 300
	ply.tk_hev.oxygen = 300
	ply.tk_hev.water = 300
	ply.tk_hev.temp = 290
	ply.tk_hev.airper = 5
	ply.tk_hev.update = true
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