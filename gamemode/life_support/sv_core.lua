
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
    for _,ply in pairs(player.GetAll()) do
        if !IsValid(ply) or !ply.tk_hev or !ply:Alive() then continue end
        
        local env = ply:GetEnv()
        local temp, insun = env:DoTemp(ply)
        local airper = math.floor(env:GetResourcePercent("oxygen"))
        
        if insun and env:Sunburn() then
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
        
        if ply.tk_hev.airper < 10 or ply:WaterLevel() == 3 then
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
        
        if ply.tk_hev.health == ply:Health() and ply:Health() < 100 then
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
    timer.Create("TKLS", 1, 0, PlayerLSCheck)
    
    function _R.Player:AddhevRes(res, amt)
        if res == "energy" then
            self.tk_hev.energy = math.min(self.tk_hev.energy + amt, self.tk_hev.energymax)
        elseif res == "water" then
            self.tk_hev.water = math.min(self.tk_hev.water + amt, self.tk_hev.watermax)
        elseif res == "oxygen" then
            self.tk_hev.oxygen = math.min(self.tk_hev.oxygen + amt, self.tk_hev.oxygenmax)
        end
    end
end)

hook.Add("PlayerInitialSpawn", "TKLS", function(ply)
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
    ply.tk_hev = ply.tk_hev or {}
    ply.tk_hev.energy = 300
    ply.tk_hev.oxygen = 300
    ply.tk_hev.water = 300
    ply.tk_hev.temp = 290
    ply.tk_hev.airper = 5
    ply.tk_hev.update = true
end)

hook.Add("OnAtmosphereChange", "TKLS", function(ent, old_env, new_env)
    if !IsValid(ent) then return end
    if ent:IsPlayer() then
        ent:SetNWString("TKPlanet", new_env.atmosphere.name)
        if ent:IsAdmin() then return end
        if new_env:CanNoclip() then return end
        if ent:GetMoveType() != MOVETYPE_NOCLIP then return end
        
        ent:SetMoveType(MOVETYPE_WALK)
        ent:SetVelocity(-ent:GetVelocity() * 0.7)
    elseif ent:IsVehicle() then
        local ply = ent:GetDriver()
        if !IsValid(ply) then return end
        ply:SetNWString("TKPlanet", new_env.atmosphere.name)
    end
end)

hook.Add("PlayerNoClip", "TKLS", function(ply)
    if ply:IsAdmin() then return end
    if ply:GetEnv():CanNoclip() then return end
    return false
end)

hook.Add("SetupMove", "TKLS", function(ply, data)
    if ply:IsAdmin() then return end
    local env = ply:GetEnv()
    if env:CanNoclip() or env.atmosphere.gravity > 0 then return end
    data:SetForwardSpeed(0)
    data:SetSideSpeed(0)
    data:SetUpSpeed(0)
end)