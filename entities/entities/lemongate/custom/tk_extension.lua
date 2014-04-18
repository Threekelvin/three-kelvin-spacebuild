/*==============================================================================================
		Expression Advanced: TK Extensions
		Purpose: Collection of functions which are useful in Three Kelvin Spacebuild
		Creditors: Rusketh, randomic, oskar
==============================================================================================*/
local LEMON, API = LEMON, LEMON.API

local Component = API:NewComponent( "tkext", true )
local cTable = API:GetComponent( "table" )

/*==============================================================================================
		Section: CVars
==============================================================================================*/
local CV_MaxParticles = CreateConVar( "lemon_tkex_maxParticles", "5", FCVAR_ARCHIVE )
local CV_MaxEffects = CreateConVar( "lemon_tkex_maxEffects", "5", FCVAR_ARCHIVE )


/*==============================================================================================
		Section: Util
==============================================================================================*/

local function ValidAction( context, ent )
	if not IsValid( ent ) or ent:IsPlayer( ) then return false end
	if not API.Util.IsOwner( context.Player, ent ) then return false end
	return true
end

local function GetLoadout( context )
	local loadout = TK.DB:GetPlayerData( context.Player, "player_loadout" )
	local validents = cTable:GetMetaTable( )( )
	for k, v in pairs( loadout ) do
		if string.match( k, "[%w]+$" ) != "item" or v == 0 then continue end
		k = string.sub( k, 1, -6 )
		validents:Set( k, "n", v )
	end
	return validents
end

local function CreateLOent( context, item, pos, angles, freeze )
	local ply = context.Player
	if not TK.LO:CanSpawn( ply,  item) then return nil end
	
	local ent = TK.LO:SpawnItem( ply, item, pos, angles )
	
	local phys = ent:GetPhysicsObject( )
	if phys:IsValid( ) then
		if( angles != nil ) then phys:SetAngles( angles ) end
		phys:Wake( )
		if( freeze > 0 ) then phys:EnableMotion( false ) end
	end
	
	undo.Create( ent.PrintName )
		undo.AddEntity( ent )
		undo.SetPlayer( ply )
	undo.Finish( )
	
	ply:AddCleanup( ent.PrintName, ent )
	return ent
end

local function CreateRDent( context, class, model, pos, angles, freeze )
	if not TK.RD.EntityData[class] then return nil end
	if not TK.RD.EntityData[class][model] then
		model = table.GetFirstKey( TK.RD.EntityData[class] )
	end
	
	local ply = context.Player
	if !ply:CheckLimit( class ) then return nil end
	local ent = ents.Create( class )
	ent:SetModel( model )
	ent:SetPos( pos )
	ent:SetAngles( angles )
	ent:Spawn( )
	
	local phys = ent:GetPhysicsObject( )
	if phys:IsValid( ) then
		if( angles != nil ) then phys:SetAngles( angles ) end
		phys:Wake( )
		if( freeze > 0 ) then phys:EnableMotion( false ) end
	end
	
	ply:AddCount( class, ent )
	
	undo.Create( class )
		undo.AddEntity( ent )
		undo.SetPlayer( ply )
	undo.Finish( )
	
	ply:AddCleanup( context.Entity.GateName, ent )
	return ent
end

local function IsWire( ent )
	if ent.IsWire and ent.IsWire == true then return true end
	if ent.Inputs or ent.Outputs  then return true end
	if ent.inputs or ent.outputs  then return true end
	return false
end

Component:AddExternal( "TKTKValidAction", ValidAction ) 
Component:AddExternal( "GetLoadout", GetLoadout ) 
Component:AddExternal( "CreateLOent", CreateLOent ) 
Component:AddExternal( "CreateRDent", CreateRDent ) 
Component:AddExternal( "IsWire", IsWire ) 


/*==============================================================================================
		Section: Resources
==============================================================================================*/ 
Component:SetPerf( LEMON_PERF_CHEAP )

Component:AddFunction( "link", "e:e", "b", [[
	if %TKValidAction( %context, value %1 ) and %TKValidAction( %context, value %2 ) and value %1.IsTKRD and value %2.IsNode then 
		%util = value %1:Link( value %2.netid )
	end  
]], "(%util and true or false)" )

Component:AddFunction( "unlink", "e:", "b", [[
	if %TKValidAction( %context, value %1 ) and value %1.IsTKRD then 
		%util = value %1:Unlink( )
	end 
]], "(%util and true or false)" )

Component:AddFunction( "getPowerGrid", "e:", "n", [[
	if %TKValidAction( %context, value %1 ) and value %1.IsTKRD then 
		%util = value %1:GetPowerGrid( ) 
	end 
]], "(%util or 0)" )

Component:AddFunction( "getUnitPowerGrid", "e:", "n", [[
	if %TKValidAction( %context, value %1 ) and value %1.IsTKRD then 
		%util = value %1:GetUnitPowerGrid( ) 
	end 
]], "(%util or 0)" )

Component:AddFunction( "getResourceAmount", "e:s", "n", [[
	if %TKValidAction( %context, value %1 ) and value %1.IsTKRD then 
		%util = value %1:GetResourceAmount( value %2 ) 
	end 
]], "(%util or 0)" )

Component:AddFunction( "getUnitResourceAmount", "e:s", "n", [[
	if %TKValidAction( %context, value %1 ) and value %1.IsTKRD then 
		%util = value %1:GetUnitResourceAmount( value %2 ) 
	end
]], "(%util or 0)" )

Component:AddFunction( "getResourceCapacity", "e:s", "n", [[
	if %TKValidAction( %context, value %1 ) and value %1.IsTKRD then 
		%util = value %1:GetResourceCapacity( value %2 ) 
	end 
]], "(%util or 0)" )

Component:AddFunction( "getUnitResourceCapacity", "e:s", "n", [[
	if %TKValidAction( %context, value %1 ) and value %1.IsTKRD then 
		%util = value %1:getUnitResourceCapacity( value %2 ) 
	end 
]], "(%util or 0)" )


/*==============================================================================================
		Section: Loadout Spawning
==============================================================================================*/
Component:AddFunction( "getLoadout", "", "t", "%GetLoadout( %context )" ) 

Component:AddFunction( "loSpawn", "s,n", "e", [[
	local %slot, %frozen = value %1, value %2 
	local %loadout = %GetLoadout( %context ) 
	
	%util = %CreateLOent( %context, %loadout.Data[%slot], %context.Entity:GetPos( ) + %context.Entity:GetUp( ) * 25, %context.Entity:GetAngles( ), %frozen )
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "loSpawn", "n,n", "e", [[
	local %item, %frozen = value %1, value %2 
	local %loadout = %GetLoadout( %context ) 
	
	%util = %CreateLOent( %context, %item, %context.Entity:GetPos( ) + %context.Entity:GetUp( ) * 25, %context.Entity:GetAngles( ), %frozen )
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "loSpawn", "s,v,n", "e", [[
	local %slot, %pos, %frozen = value %1, value %2, value %3
	local %loadout = %GetLoadout( %context ) 
	
	%util = %CreateLOent( %context, %loadout.Data[slot], %pos:Garry( ), %context.Entity:GetAngles( ), %frozen )
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "loSpawn", "n,v,n", "e", [[
	local %item, %pos, %frozen = value %1, value %2, value %3
	local %loadout = %GetLoadout( %context ) 
	
	%util = %CreateLOent( %context, %item, %pos:Garry( ), %context.Entity:GetAngles( ), %frozen )
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "loSpawn", "s,a,n", "e", [[
	local %slot, %ang, %frozen = value %1, value %2, value %3
	local %loadout = %GetLoadout( %context ) 
	
	%util = %CreateLOent( %context, %loadout.Data[slot], %context.Entity:GetPos( ) + %context.Entity:GetUp( ) * 25, %ang, %frozen )
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "loSpawn", "n,a,n", "e", [[
	local %item, %ang, %frozen = value %1, value %2, value %3
	local %loadout = %GetLoadout( %context ) 
	
	%util = %CreateLOent( %context, %item, %context.Entity:GetPos( ) + %context.Entity:GetUp( ) * 25, %ang, %frozen )
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "loSpawn", "s,v,a,n", "e", [[
	local %slot, %pos, %ang, %frozen = value %1, value %2, value %3, value %4
	local %loadout = %GetLoadout( %context ) 
	
	%util = %CreateLOent( %context, %loadout.Data[slot], %pos:Garry( ), %ang, %frozen )
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "loSpawn", "n,v,a,n", "e", [[
	local %item, %pos, %ang, %frozen = value %1, value %2, value %3, value %4
	local %loadout = %GetLoadout( %context ) 
	
	%util = %CreateLOent( %context, %item, %pos:Garry( ), %ang, %frozen )
]], "(%util or %NULL_ENTITY)" ) 


/*==============================================================================================
		Section: RD Spawning
==============================================================================================*/

Component:AddFunction( "rdSpawn", "s,s,n", "e", [[
	local %class, %model, %frozen = value %1, value %2, value %3
	
	%util = %CreateRDent( %context, %class, %model, %context.Entity:GetPos( ) + %context.Entity:GetUp( ) * 25, %context.Entity:GetAngles( ), %frozen )
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "rdSpawn", "e,n", "e", [[
	local %template, %frozen = value %1, value %2
	
	if  %IsValid( %template ) then 
		%util = %CreateRDent( %context, %template:GetClass( ), %template:GetModel( ), %context.Entity:GetPos( ) + %context.Entity:GetUp( ) * 25, %context.Entity:GetAngles( ), %frozen )
	end 
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "rdSpawn", "s,s,v,n", "e", [[
	local %class, %model, %pos, %frozen = value %1, value %2, value %3, value %4
	
	%util = %CreateRDent( %context, %class, %model, %pos:Garry( ), %context.Entity:GetAngles( ), %frozen )
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "rdSpawn", "e,v,n", "e", [[
	local %template, %pos, %frozen = value %1, value %2, value %3
	
	if %IsValid( %template ) then 
		%util = %CreateRDent( %context, %template:GetClass( ), %template:GetModel( ), %pos:Garry( ), %context.Entity:GetAngles( ), %frozen )
	end 
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "rdSpawn", "s,s,a,n", "e", [[
	local %class, %model, %ang, %frozen = value %1, value %2, value %3, value %4
	
	%util = %CreateRDent( %context, %class, %model, %context.Entity:GetPos( ) + %context.Entity:GetUp( ) * 25, %ang, %frozen )
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "rdSpawn", "e,a,n", "e", [[
	local %template, %ang, %frozen = value %1, value %2, value %3
	
	if %IsValid( %template ) then 
		%util = %CreateRDent( %context, %template:GetClass( ), %template:GetModel( ), %context.Entity:GetPos( ) + %context.Entity:GetUp( ) * 25, %ang, %frozen )
	end 
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "rdSpawn", "s,s,v,a,n", "e", [[
	local %class, %model, %pos, %ang, %frozen = value %1, value %2, value %3, value %4, value %5
	
	%util = %CreateRDent( %context, %class, %model, %pos:Garry( ), %ang, %frozen )
]], "(%util or %NULL_ENTITY)" ) 

Component:AddFunction( "rdSpawn", "e,v,a,n", "e", [[
	local %template, %pos, %ang, %frozen = value %1, value %2, value %3, value %4
	
	if %IsValid( %template ) then 
		%util = %CreateRDent( %context, %template:GetClass( ), %template:GetModel( ), %pos:Garry( ), %ang, %frozen )
	end 
]], "(%util or %NULL_ENTITY)" ) 


/*==============================================================================================
		Section: Formatting
==============================================================================================*/ 
Component:AddFunction( "format", "n", "s", "$TK:Format( value %1 )" )


/*==============================================================================================
		Section: Sequence
==============================================================================================*/

Component:AddFunction( "sequenceGet", "e:", "n", [[
	if %TKValidAction( %context, value %1 ) then 
		%util = value %1:GetSequence( ) or 0 
	end 
]], "(%util or 0)" )

Component:AddFunction( "sequenceLookup", "e:s", "n", [[
	if %TKValidAction( %context, value %1 ) then 
		local %id, %dur = value %1:LookupSequence( value %2 ) 
		%util = %id or 0
	end 
]], "(%util or 0)" )

Component:AddFunction( "sequenceDuration", "e:s", "n", [[
	if %TKValidAction( %context, value %1 ) then 
		local %id, %dur = value %1:LookupSequence( value %2 ) 
		%util = %dur or 0
	end 
]], "(%util or 0)" )

Component:AddFunction( "sequenceSet", "e:n", "", [[
	if %TKValidAction( %context, value %1 ) then  
		value %1.AutomaticFrameAdvance = true 
		value %1:SetSequence( value %2 )
	end 
]] )

Component:AddFunction( "sequenceReset", "e:n", "", [[
	if %TKValidAction( %context, value %1 ) then 
		value %1.AutomaticFrameAdvance = true 
		value %1:ResetSequence( value %2 )
	end 
]] )

Component:AddFunction( "sequenceSetCycle", "e:n", "", [[
	if %TKValidAction( %context, value %1 ) then 
		value %1:SetCycle( value %2 ) 
	end 
]] )

Component:AddFunction( "sequenceSetRate", "e:n", "", [[
	if %TKValidAction( %context, value %1 ) then 
		value %1:SetPlaybackRate( value %2 ) 
	end 
]] )

Component:AddFunction( "setPoseParameter", "e:s,n", "", [[
	if %TKValidAction( %context, value %1 ) then 
		value %1:SetPoseParameter( value %2, value %3 ) 
	end 
]] )


/*==============================================================================================
		Section: Particles
==============================================================================================*/
util.AddNetworkString( "particlebeam" )

local ParticleCount = 0
local ParticleClear = 0
local ParticleBlackList = { "portal_rift_01" }

hook.Add( "Think", "ParticleCount", function( )
	if CurTime( ) >= ParticleClear then
		ParticleClear = CurTime( ) + 1
		ParticleCount = 0
	end
end )

local function ValidParticle( particle )
	if table.HasValue(ParticleBlackList, name) then return false end
	if ParticleCount < CV_MaxParticles:GetInt( ) then
		ParticleCount = ParticleCount + 1
		return true
	end
	return false
end

Context:AddExternal( "ValidParticle", ValidParticle )
Context:AddExternal( "ParticleEffect", ParticleEffect )
Context:AddExternal( "ParticleEffectAttach", ParticleEffectAttach )
Context:AddExternal( "SendParticleBeamData", function( particle, this, ent ) 
	timer.Simple( 0.1, function( )
		net.Start( "particleBeam" )
			net.WriteString( particle )
			net.WriteInt( this:EntIndex( ), 16)
			net.WriteInt( ent:EntIndex( ), 16)
		net.Broadcast( )
	end)
end )


Component:AddFunction( "particleCreate", "e:s,v,a", "", [[
	local %ent, %particle, %pos, %ang = value %1, value %2, value %3, value %4 
	
	if %TKValidAction( %context, %ent ) and %ValidParticle( %particle ) then 
		%ParticleEffect( %particle, %pos:Garry( ), %ang, %ent )
	end 
]] )

Component:AddFunction( "particleAttach", "e:s", "", [[
	local %ent, %particle = value %1, value %2
	
	if %TKValidAction( %context, %ent ) and %ValidParticle( %particle ) then
		%ParticleEffectAttach( %particle, PATTACH_ABSORIGIN_FOLLOW, %ent, 0 )
	end 
]] )

Component:AddFunction( "particleBeam", "e:s,e", "", [[
	local %this, %ent, %particle = value %1, value %2, value %3
	
	if not %TKValidAction( %context, %this ) and %TKValidAction( %context, %ent ) and %ValidParticle( %particle ) then
		%SendParticleBeamData( %particle, %this, %ent )
	end 
]] )

Component:AddFunction( "particleBeam", "e:", "", "if %TKValidAction( %context, value %1 ) then value %1:StopParticles( ) end" )


/*==============================================================================================
		Section: Effects
==============================================================================================*/
local EffectCount = 0
local EffectClear = 0
local EffectBlackList = { "ptorpedoimpact", "effect_explosion_scaleable", "nuke_blastwave", "nuke_blastwave_cheap", "nuke_disintegrate", "nuke_effect_air", "nuke_effect_ground", "nuke_vaporize", "warpcore_breach" }

hook.Add("Think", "EffectCount", function( )
	if CurTime( ) >= EffectClear then
		EffectClear = CurTime( ) + 1
		EffectCount = 0
	end
end)

local function ValidEffect( name )
	if table.HasValue (EffectBlackList, name ) then return false end
	if EffectCount < CV_MaxEffects:GetInt( ) then
		EffectCount = EffectCount + 1
		return true
	end
	return false
end

local function MakeEffect( ent, name, origin, start, angle, magnitude, scale )
	local fx = EffectData( )
	fx:SetOrigin( origin )
	fx:SetEntity( ent )
	if start then fx:SetStart( start ) end
	if angle then fx:SetAngle( angle ) end
	if magnitude then fx:SetMagnitude( magnitude ) end
	if scale then fx:SetScale( scale ) end
	util.Effect(name, fx)
end

Context:AddExternal( "ValidEffect", ValidEffect )
Context:AddExternal( "MakeEffect", MakeEffect )

Component:AddFunction( "fx", "s,v", "", [[
	local %effect, %origin = value %1, value %2 
	
	if %ValidEffect( %effect ) then 
		%MakeEffect( %context.Entity, %effect, %origin:Garry( ) )
	end 
]] )

Component:AddFunction( "fx", "s,v,v", "", [[
	local %effect, %origin, %start = value %1, value %2, value %3
	
	if %ValidEffect( %effect ) then 
		%MakeEffect( %context.Entity, %effect, %origin:Garry( ), %start:Garry( ) )
	end 
]] )

Component:AddFunction( "fx", "s,v,v,a", "", [[
	local %effect, %origin, %start, %ang = value %1, value %2, value %3, value %4
	
	if %ValidEffect( %effect ) then 
		%MakeEffect( %context.Entity, %effect, %origin:Garry( ), %start:Garry( ), %ang )
	end 
]] )

Component:AddFunction( "fx", "s,v,v,a,n", "", [[
	local %effect, %origin, %start, %ang, %magnitude = value %1, value %2, value %3, value %4, value %5
	
	if %ValidEffect( %effect ) then 
		%MakeEffect( %context.Entity, %effect, %origin:Garry( ), %start:Garry( ), %ang, %magnitude ) 
	end 
]] )

Component:AddFunction( "fx", "s,v,v,a,n,n", "", [[
	local %effect, %origin, %start, %ang, %magnitude, %scale = value %1, value %2, value %3, value %4, value %5, value %6
	
	if %ValidEffect( %effect ) then 
		%MakeEffect( %context.Entity, %effect, %origin:Garry( ), %start:Garry( ), %ang, %magnitude, %scale ) 
	end 
]] )


/*==============================================================================================
		Section: Admin
==============================================================================================*/

Component:AddFunction( "isVip", "e:", "b", [[
	if %IsValid( value %1 ) and value %1:IsPlayer then 
		%util = value %1:IsVip( ) 
	end 
]], "(%util and true or false)" )

Component:AddFunction( "isDJ", "e:", "b", [[
	if %IsValid( value %1 ) and value %1:IsPlayer then 
		%util = value %1:IsDJ( ) 
	end 
]], "(%util and true or false)" )

Component:AddFunction( "isModerator", "e:", "b", [[
	if %IsValid( value %1 ) and value %1:IsPlayer then 
		%util = value %1:IsModerator( ) 
	end 
]], "(%util and true or false)" )

Component:AddFunction( "isAdmin", "e:", "b", [[
	if %IsValid( value %1 ) and value %1:IsPlayer then 
		%util = value %1:IsAdmin( ) 
	end 
]], "(%util and true or false)" )

Component:AddFunction( "isSuperAdmin", "e:", "b", [[
	if %IsValid( value %1 ) and value %1:IsPlayer then 
		%util = value %1:IsSuperAdmin( ) 
	end 
]], "(%util and true or false)" )

Component:AddFunction( "isOwner", "e:", "b", [[
	if %IsValid( value %1 ) and value %1:IsPlayer then 
		%util = value %1:IsOwner( ) 
	end 
]], "(%util and true or false)" )


/*==============================================================================================
		Section: Gameplay
==============================================================================================*/

Component:AddFunction( "score", "e:", "n", [[
	if %IsValid( value %1 ) and value %1:IsPlayer then 
		%util = $TK.DB:GetPlayerData( value %1, "player_info" ).score
	end 
]], "(%util or 0)" )

Component:AddFunction( "getSunPos", "", "v", "Vector3( $TK.AT:GetSuns()[1] )" )