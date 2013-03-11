
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

include('shared.lua')

///--- Player Spawning ---\\\
gameevent.Listen("player_connect")
gameevent.Listen("player_disconnect")

function TK:SetSpawnPoint(ply, side)
    local Spawn = self.Settings.SpawnPoints[side]
    if !Spawn then Spawn = self.Settings.SpawnPoints[1] end
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

local BadConstraints = {
    ["phys_keepupright"] = true,
    ["logic_collision_pair"] = true
}

function _R.Entity:GetConstrainedEntities()
    local out = {[self] = self}
    if !self.Constraints then return out end
    
    local tbtab = {{self,1}}
    while #tbtab > 0 do
        local bd = tbtab[#tbtab]
        local bde = bd[1]
        local bdc = bde.Constraints[bd[2]]
        local ce
        
        if bdc then
            if bde == bdc.Ent1 then
                ce = bdc.Ent2
            else
                ce = bdc.Ent1
            end
        end
        
        if bd[2] > #bde.Constraints then
            tbtab[#tbtab] = nil
        elseif !IsValid(bdc) || !IsValid(ce) || BadConstraints[bdc:GetClass()] then
            bd[2] = bd[2] + 1
        else
            if !out[ce] then
                tbtab[#tbtab+1] = {ce,1}
            else
                bd[2] = bd[2] + 1
            end
            
            out[bde] = bde
            out[ce] = ce
        end
    end
    
    return out
end

local AllowedWeapons = {
    ["weapon_physcannon"]   =   true,
    ["weapon_physgun"]      =   true,
    ["gmod_camera"]         =   true,
    ["gmod_tool"]           =   true,
    ["hands"]               =   true,
    ["remotecontroller"]    =   true,
    ["laserpointer"]        =   true
}

hook.Add("PlayerCanPickupWeapon", "TKSB", function(ply, wep)
    if AllowedWeapons[wep:GetClass()] || ply:IsAdmin() then return true end
    return false
end)

hook.Add("PlayerSpawnSWEP", "TKSB", function(ply, wep)
    if AllowedWeapons[wep] || ply:IsAdmin() then return true end
    return false
end)

function GM:PlayerSetModel(ply)
    local cl_playermodel = ply:GetInfo("cl_playermodel")
    if ply.last_playermodel != cl_playermodel then
        local modelname = player_manager.TranslatePlayerModel(cl_playermodel)
        if TK:CanUsePlayerModel(ply, cl_playermodel) then
            util.PrecacheModel(modelname)
            ply:SetModel(modelname)
            ply.last_playermodel = cl_playermodel
        end
    end
    
    if !ply.last_playermodel then
        ply:ConCommand("cl_playermodel, kleiner")
    end
end

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
///--- ---\\\

hook.Add("Initialize", "PAC_Fix", function()
    timer.Create("pac_playermodels", 0.5, 0, function()
        for _,ply in pairs(player.GetAll()) do
            gamemode.Call("PlayerSetModel", ply)
        end
    end)
    
    timer.Create("TKTI_Damage", 1, 0, function()
        for _,ply in pairs(player.GetAll()) do
            for k,v in pairs(TK.Settings.TiberiumFields) do
                local crystal = table.GetFirstValue(v.Ents)
                if !IsValid(crystal) then continue end
                
                local dist = (v.Pos - ply:GetPos()):LengthSqr()
                if dist > 2250000 then continue end
                
                local dmginfo = DamageInfo()
                dmginfo:SetDamage(math.ceil(25 * (1 - dist / 2250000)))
                dmginfo:SetDamageType(DMG_RADIATION)
                dmginfo:SetAttacker(crystal)
                dmginfo:SetInflictor(crystal)
                ply:TakeDamageInfo(dmginfo)
            end
        end
    end)
    
    ///--- SBEP Vehicle Spawning Fix ---\\\
    hook.Remove("PlayerSpawnedVehicle", "Stop SBEP Vehicles spawning in the ground")
    
    if Spawn_Vehicle then
        local function MakeVehicle( Player, Pos, Ang, Model, Class, VName, VTable )

            if (!gamemode.Call( "PlayerSpawnVehicle", Player, Model, VName, VTable )) then return end
            
            local Ent = ents.Create( Class )
            if (!Ent) then return NULL end
            
            Ent:SetModel( Model )
            
            -- Fill in the keyvalues if we have them
            if ( VTable && VTable.KeyValues ) then
                for k, v in pairs( VTable.KeyValues ) do
                    Ent:SetKeyValue( k, v )
                end		
            end
                
            Ent:SetAngles( Ang )
            Ent:SetPos( Pos )

            DoPropSpawnedEffect( Ent )
                
            Ent:Spawn()
            Ent:Activate()
            
            Ent.VehicleName 	= VName
            Ent.VehicleTable 	= VTable
            
            -- We need to override the class in the case of the Jeep, because it 
            -- actually uses a different class than is reported by GetClass
            Ent.ClassOverride 	= Class

            if ( IsValid( Player ) ) then
                gamemode.Call( "PlayerSpawnedVehicle", Player, Ent )
            end

            return Ent	
            
        end
        
        function Spawn_Vehicle( Player, vname, tr )

            if ( !vname ) then return end

            local VehicleList = list.Get( "Vehicles" )
            local vehicle = VehicleList[ vname ]
            
            -- Not a valid vehicle to be spawning..
            if ( !vehicle ) then return end
            
            if ( !tr ) then
                tr = Player:GetEyeTraceNoCursor()
            end
            
            local Angles = Player:GetAngles()
                Angles.pitch = 0
                Angles.roll = 0
                Angles.yaw = Angles.yaw + 180
            
            local Ent = MakeVehicle( Player, tr.HitPos, Angles, vehicle.Model, vehicle.Class, vname, vehicle ) 
            if ( !IsValid( Ent ) ) then return end
            
            if vehicle.Category == "SpaceBuild Enhancement Project" then
                Ent:SetPos(Ent:GetPos() - Vector(0, 0, Ent:OBBMins().z))
            end
            
            if ( vehicle.Members ) then
                table.Merge( Ent, vehicle.Members )
                duplicator.StoreEntityModifier( Ent, "VehicleMemDupe", vehicle.Members );
            end
            
            undo.Create( "Vehicle" )
                undo.SetPlayer( Player )
                undo.AddEntity( Ent )
                undo.SetCustomUndoText( "Undone "..vehicle.Name )
            undo.Finish( "Vehicle ("..tostring( vehicle.Name )..")" )
            
            Player:AddCleanup( "vehicles", Ent )
            
        end
    end
    ///--- ---\\\
end)

hook.Add("PlayerLeaveVehicle", "Vehicle_Exit", function(ply, ent)
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

///--- Map Setup ---\\\
hook.Add("InitPostEntity", "TKSetup", function()
    game.CleanUpMap()
end)
///--- ---\\\

///--- Map Resources ---\\\
hook.Add("Tick", "TKSpawning", function()
    for k,v in pairs(TK.Settings.AsteroidFields) do
        if CurTime() > v.NextSpawn && table.Count(v.Ents) < 20 then
            local pos = Vector(math.random(0, 5000),0,0)
            pos:Rotate(Angle(math.random(0, 360), math.random(0, 360), 0))
            
            local rand = v.Pos + pos
            local space = TK:FindInSphere(rand, 1000)
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
    
    for k,v in pairs(TK.Settings.TiberiumFields) do
        if CurTime() < v.NextSpawn || table.Count(v.Ents) >= 10 then continue end
        local pos = Vector(math.random(0, 1100),0,0)
        pos:Rotate(Angle(0,math.random(0, 360),0))
        
        local rand = v.Pos + pos + Vector(0,0,260)
        local trace =  util.QuickTrace(rand, Vector(0,0,-520))
        if !trace.HitWorld then continue end
        
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
            v.NextSpawn = CurTime() + 90 * (table.Count(v.Ents)/10) + 5
        else
            v.NextSpawn = CurTime() + 1
        end
    end
end)
///--- ---\\\