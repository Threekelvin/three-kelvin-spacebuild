
///--- Pac ---\\\
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

hook.Add("Initialize", "Pac_Fix", function()
    timer.Create("pac_playermodels", 0.5, 0, function()
        for _,ply in pairs(player.GetAll()) do
            gamemode.Call("PlayerSetModel", ply)
        end
    end)
end)

///--- SBEP ---\\\
hook.Add("Initialize", "SBEP_Fix", function()
    hook.Remove("PlayerSpawnedVehicle", "Stop SBEP Vehicles spawning in the ground")
    
    if Spawn_Vehicle then
        local function MakeVehicle( Player, Pos, Ang, Model, Class, VName, VTable )

            if (!gamemode.Call( "PlayerSpawnVehicle", Player, Model, VName, VTable )) then return end
            
            local Ent = ents.Create( Class )
            if (!Ent) then return NULL end
            
            Ent:SetModel( Model )
            
            -- Fill in the keyvalues if we have them
            if ( VTable and VTable.KeyValues ) then
                for k, v in pairs( VTable.KeyValues ) do
                    Ent:SetKeyValue( k, v )
                end        
            end
                
            Ent:SetAngles( Ang )
            Ent:SetPos( Pos )

            DoPropSpawnedEffect( Ent )
            
            Ent:Spawn()
            Ent:Activate()
            
            Ent.VehicleName     = VName
            Ent.VehicleTable     = VTable
            
            -- We need to override the class in the case of the Jeep, because it 
            -- actually uses a different class than is reported by GetClass
            Ent.ClassOverride     = Class

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

///--- Sit Anywhere ---\\\
hook.Add("EntitySpawned", "Sit_Anywhere", function(ent)
    if !ent:IsVehicle() then return end
    timer.Simple(0.1, function()
        if ent:GetCollisionGroup() == COLLISION_GROUP_VEHICLE then return end
        TK.AT:ManualCheck(ent)
        timer.Create("SitAnywhereFix_".. ent:EntIndex(), 1, 0, function()
            TK.AT:ManualCheck(ent)
        end)
        ent:CallOnRemove("SitAnywhereFix", function(ent)
            timer.Destroy("SitAnywhereFix_".. ent:EntIndex())
        end)
    end)
end)
///--- ---\\\