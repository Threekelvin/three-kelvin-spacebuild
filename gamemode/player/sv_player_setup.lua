
local AllowedWeapons = {
    ["weapon_physcannon"]   =   true,
    ["weapon_physgun"]      =   true,
    ["gmod_camera"]         =   true,
    ["gmod_tool"]           =   true,
    ["hands"]               =   true,
    ["remotecontroller"]    =   true,
    ["laserpointer"]        =   true
}

function TK:SetSpawnPoint(ply, side)
    local Spawn = self.MapSetup.SpawnPoints[side]
    if !Spawn then Spawn = self.MapSetup.SpawnPoints[1] end
    local grid, spacing = 5, 27
    local td = {}
    td.mins = ply:OBBMins()
    td.mins.z = td.mins.z * 0.5
    td.maxs = ply:OBBMaxs()
    td.maxs.z = td.maxs.z * 0.5
    td.Filter = ply
    
    for X = 1, grid do
        for Y = 1, grid do
            local x_pos = (-spacing * 0.5 * grid) + spacing * (X - 1)
            local y_pos = (-spacing * 0.5 * grid) + spacing * (Y - 1)
        
            td.start = Spawn + Vector(x_pos, y_pos, 36)
            td.endpos = Spawn + Vector(x_pos, y_pos, -36)
            
            local trace_down = util.TraceHull(td)
            td.start = Spawn + Vector(x_pos, y_pos, 36)
            td.endpos = Spawn + Vector(x_pos, y_pos, 108)
            local trace_up = util.TraceHull(td)
            
            if trace_down.Fraction + trace_up.Fraction >= 0.5 then
                ply:SetPos(trace_down.HitPos)
                return
            end
        end
    end
    
    ply:SetMoveType(MOVETYPE_NOCLIP)
    ply:SetPos(Spawn)
end

hook.Add("PlayerCanPickupWeapon", "TKSB", function(ply, wep)
    if AllowedWeapons[wep:GetClass()] or ply:IsAdmin() then return true end
    return false
end)

hook.Add("PlayerSpawnSWEP", "TKSB", function(ply, wep)
    if AllowedWeapons[wep] or ply:IsAdmin() then return true end
    return false
end)

function GM:PlayerInitialSpawn(ply)
    if ply:Team() == 0 then ply:SetTeam(1) end
    player_manager.SetPlayerClass(ply, "player_tk")
end

function GM:PlayerSpawn(ply)
    ply:UnSpectate()

    player_manager.OnPlayerSpawn(ply)
    player_manager.RunClass(ply, "Spawn")

    hook.Call("PlayerLoadout", GAMEMODE, ply)
    hook.Call("PlayerSetModel", GAMEMODE, ply)
end

hook.Add("PlayerLeaveVehicle", "3k_Vehicle_Exit", function(ply, ent)
    local hasExit = false
    local env = ent:GetEnv()
    local pos = ent:GetPos()
    local grid, spacing = 5, 27
    local td = {}
    td.mins = ply:OBBMins()
    td.mins.z = td.mins.z * 0.5
    td.maxs = ply:OBBMaxs()
    td.maxs.z = td.maxs.z * 0.5
    td.Filter = ply
    
    
    for k,v in pairs(ent:GetConstrainedEntities()) do
        if !v.VehicleExitPoint then continue end
        hasExit = v
        break
    end
    
    if hasExit then
        env = hasExit:GetEnv()
        pos = hasExit:GetPos()
        td.Filter = {ply, hasExit}
    end
    
    for X = 1, grid do
        for Y = 1, grid do
            local x_pos = (-spacing * 0.5 * grid) + spacing * (X - 1)
            local y_pos = (-spacing * 0.5 * grid) + spacing * (Y - 1)
        
            td.start = pos + Vector(x_pos, y_pos, 36)
            td.endpos = pos + Vector(x_pos, y_pos, -36)
            
            local trace_down = util.TraceHull(td)
            td.start = pos + Vector(x_pos, y_pos, 36)
            td.endpos = pos + Vector(x_pos, y_pos, 108)
            local trace_up = util.TraceHull(td)

            if trace_down.Fraction + trace_up.Fraction >= 0.5 then
                if env:InAtmosphere(trace_down.HitPos + Vector(0,0,36)) then
                    ply:SetPos(trace_down.HitPos)
                    return
                end
            end
        end
    end
    
    ply:SetPos(pos)
end)