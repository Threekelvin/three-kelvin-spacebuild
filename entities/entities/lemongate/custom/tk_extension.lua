/*==============================================================================================
        Expression Advanced: TK Extensions
        Purpose: Collection of functions which are useful in Three Kelvin Spacebuild
        Creditors: Rusketh, randomic
==============================================================================================*/
local E_A = LemonGate
local API = E_A.API

MsgN( "EA: TK Extensions Available" )

API.NewComponent("TK Extensions", true)

/*==============================================================================================
        Section: CVars
==============================================================================================*/
local CV_Enabled = CreateConVar("lemon_tkex_enabled", 0, {FCVAR_ARCHIVE, FCVAR_NOTIFY})
local CV_MaxParticles = CreateConVar("lemon_tkex_maxParticles", "5", FCVAR_ARCHIVE)
local CV_MaxEffects= CreateConVar("lemon_tkex_maxEffects", "5", FCVAR_ARCHIVE)

/*==============================================================================================
        Section: Util
==============================================================================================*/
E_A:RegisterException( "tkextend" )

local function Check_Enabled( Context )
    if !CV_Enabled:GetBool( ) then
        Context:Throw("tkextend", "Server has disabled TK extensions")
    end
end

local function ValidAction(self, ent)
    Check_Enabled( self )
    
    if !IsValid( ent ) or ent:IsPlayer( ) then return false end
    if !E_A.IsOwner(self.Player, ent) then return false end
    return true
end

local function GetLoadout( self )
    Check_Enabled( self )
    
    local loadout = TK.DB:GetPlayerData(self.Player, "player_loadout")
    local validents = E_A.NewTable( )
    for k,v in pairs( loadout ) do
        if string.match(k, "[%w]+$") != "item" or v == 0 then continue end
        k = string.sub(k, 1, -6)
        validents:Set(k, "n", v)
    end
    return validents
end

local function CreateLOent(self, item, pos, angles, freeze)
    Check_Enabled( self )
    
    local ply = self.Player
    if !TK.LO:CanSpawn(ply, item) then return nil end

    local ent = TK.LO:SpawnItem(ply, item, pos, angles)

    local phys = ent:GetPhysicsObject( )
    if phys:IsValid( ) then
        if( angles != nil ) then phys:SetAngles( angles ) end
        phys:Wake()
        if( freeze > 0 ) then phys:EnableMotion( false ) end
    end
    
    undo.Create( ent.PrintName )
        undo.AddEntity( ent )
        undo.SetPlayer( ply )
    undo.Finish( )
    
    ply:AddCleanup(ent.PrintName, ent)
    return ent
end

local function CreateRDent(self, class, model, pos, angles, freeze)
    Check_Enabled( self )
    
    if !TK.RD.EntityData[class] then return nil end
    if !TK.RD.EntityData[class][model] then
        model = table.GetFirstKey( TK.RD.EntityData[class] )
    end

    local ply = self.Player
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
    
    ply:AddCount(class, ent)
    
    undo.Create( class )
        undo.AddEntity( ent )
        undo.SetPlayer( ply )
    undo.Finish( )

    ply:AddCleanup(self.Name, ent)
    return ent
end

local function IsWire( ent )
    if ent.IsWire and ent.IsWire == true then return true end
    if ent.Inputs or ent.Outputs  then return true end
    if ent.inputs or ent.outputs  then return true end
    return false
end

/*==============================================================================================
        Section: info funcs
==============================================================================================*/
E_A:RegisterFunction("tkextend","","n",
    function( self )
        return CV_Enabled:GetInt( )
    end)

/*==============================================================================================
        Section: Resources
==============================================================================================*/
E_A:RegisterFunction("link", "e:e", "n",
    function(self, A, B)
        local ent, node = A( self ), B( self )
        if !ValidAction(self, ent) or !ValidAction(self, node) then
            return 0
        end
        if !ent.IsTKRD then return 0 end
        if !node.IsNode then return 0 end
        return ent:Link( node.netid ) and 1 or 0
    end)

E_A:RegisterFunction("unLink", "e:", "n",
    function(self, A)
        local ent = A( self )
        
        if !ValidAction(self, ent) then return 0 end
        if !ent.IsTKRD then return 0 end
        return ent:Unlink( ) and 1 or 0
    end)

E_A:RegisterFunction("getPowerGrid", "e:", "n",
    function(self, A)
        local ent = A( self )
        
        if !ValidAction(self, ent) then return 0 end
        if !ent.IsTKRD then return 0 end
        return ent:GetPowerGrid( )
    end)

E_A:RegisterFunction("getUnitPowerGrid", "e:", "n",
    function(self, A)
        local ent = A( self )
        
        if !ValidAction(self, ent) then return 0 end
        if !ent.IsTKRD then return 0 end
        return ent:GetUnitPowerGrid( )
    end)

E_A:RegisterFunction("getResourceAmount", "e:s", "n",
    function(self, A, B)
        local ent, res = A( self ), B( self )
        
        if !ValidAction(self, ent) then return 0 end
        if !ent.IsTKRD then return 0 end
        return ent:GetResourceAmount( res )
    end)

E_A:RegisterFunction("getUnitResourceAmount", "e:s", "n",
    function(self, A, B)
        local ent, res = A( self ), B( self )
        
        if !ValidAction(self, ent) then return 0 end
        if !ent.IsTKRD then return 0 end
        return ent:GetUnitResourceAmount( res )
    end)

E_A:RegisterFunction("getResourceCapacity", "e:s", "n",
    function(self, A, B)
        local ent, res = A( self ), B( self )
        
        if !ValidAction(self, ent) then return 0 end
        if !ent.IsTKRD then return 0 end
        return ent:GetResourceCapacity( res )
    end)

E_A:RegisterFunction("getUnitResourceCapacity", "e:s", "n",
    function(self, A, B)
        local ent, res = A( self ), B( self )
        
        if !ValidAction(self, ent) then return 0 end
        if !ent.IsTKRD then return 0 end
        return ent:GetUnitResourceCapacity( res )
    end)

/*==============================================================================================
        Section: Loadout Spawning
==============================================================================================*/
E_A:RegisterFunction("getLoadout", "", "t",
    function( self )
        return GetLoadout( self )
    end)

E_A:RegisterFunction("loSpawn", "sn", "e",
    function(self, A, B)
        local slot, frozen = A( self ), B( self )
        
        local loadout = GetLoadout( self )
        return CreateLOent(self, loadout.Data[slot], self.Entity:GetPos() + self.Entity:GetUp()*25, self.Entity:GetAngles(), frozen)
    end)

E_A:RegisterFunction("loSpawn", "nn", "e",
    function(self, A, B)
        local item, frozen = A( self ), B( self )
        
        return CreateLOent(self, item, self.Entity:GetPos() + self.Entity:GetUp()*25, self.Entity:GetAngles(), frozen)
    end)

E_A:RegisterFunction("loSpawn", "svn", "e",
    function(self, A, B, C)
        local slot, pos, frozen = A( self ), B( self ), C( self )
        
        local loadout = GetLoadout( self )
        return CreateLOent(self, loadout.Data[slot], Vector(pos[1], pos[2], pos[2]), self.Entity:GetAngles(), frozen)
    end)

E_A:RegisterFunction("loSpawn", "nvn", "e",
    function(self, A, B, C)
        local item, pos, frozen = A( self ), B( self ), C( self )
        
        return CreateLOent(self, item, Vector(pos[1], pos[2], pos[2]), self.Entity:GetAngles(), frozen)
    end)

E_A:RegisterFunction("loSpawn", "san", "e",
    function(self, A, B, C)
        local slot, ang, frozen = A( self ), B( self ), C( self )
        
        local loadout = GetLoadout( self )
        return CreateLOent(self, loadout.Data[slot], self.Entity:GetPos() + self.Entity:GetUp()*25, Angle(ang[1], ang[2], ang[3]), frozen)
    end)

E_A:RegisterFunction("loSpawn", "nan", "e",
    function(self, A, B, C)
        local item, ang, frozen = A( self ), B( self ), C( self )
        
        return CreateLOent(self, item, self.Entity:GetPos() + self.Entity:GetUp()*25, Angle(ang[1], ang[2], ang[3]), frozen)
    end)

E_A:RegisterFunction("loSpawn", "svan", "e",
    function(self, A, B, C, D)
        local slot, pos, ang, frozen = A( self ), B( self ), C( self ), D( self )
        
        local loadout = GetLoadout( self )
        return CreateLOent(self, loadout.Data[slot], Vector(pos[1], pos[2], pos[3]), Angle(ang[1], ang[2], ang[3]), frozen)
    end)

E_A:RegisterFunction("loSpawn", "nvan", "e",
    function(self, A, B, C, D)
        local item, pos, ang, frozen = A( self ), B( self ), C( self ), D( self )
        
        return CreateLOent(self, item, Vector(pos[1], pos[2], pos[3]), Angle(ang[1], ang[2], ang[3]), frozen)
    end)

/*==============================================================================================
        Section: RD Spawning
==============================================================================================*/
E_A:RegisterFunction("rdSpawn", "ssn", "e",
    function(self, A, B, C)
        local class, model, frozen = A( self ), B( self ), C( self )
        
        return CreateRDent(self, class, model, self.Entity:GetPos() + self.Entity:GetUp()*25, self.Entity:GetAngles(), frozen)
    end)

E_A:RegisterFunction("rdSpawn", "en", "e",
    function(self, A, B)
        local template, frozen = A( self ), B( self )
        
        if !IsValid(template) then return nil end
        return CreateRDent(self, template:GetClass(), template:GetModel(), self.Entity:GetPos() + self.Entity:GetUp()*25, self.Entity:GetAngles(), frozen)
    end)

E_A:RegisterFunction("rdSpawn", "ssvn", "e",
    function(self, A, B, C, D)
        local class, model, pos, frozen = A( self ), B( self ), C( self ), D( self )
        
        return CreateRDent(self, class, model, Vector(pos[1], pos[2], pos[3]), self.Entity:GetAngles(), frozen)
    end)

E_A:RegisterFunction("rdSpawn", "evn", "e",
    function(self, A, B, C)
        local template, pos, frozen = A( self ), B( self ), C( self )
        
        if !IsValid(template) then return nil end
        return CreateRDent(self, template:GetClass(), template:GetModel(), Vector(pos[1], pos[2], pos[3]), self.Entity:GetAngles(), frozen)
    end)

E_A:RegisterFunction("rdSpawn", "ssan", "e",
    function(self, A, B, C, D)
        local class, model, ang, frozen = A( self ), B( self ), C( self ), D( self )
        
        return CreateRDent(self, class, model, self.Entity:GetPos() + self.Entity:GetUp()*25, Angle(ang[1], ang[2], ang[3]), frozen)
    end)

E_A:RegisterFunction("rdSpawn", "ean", "e",
    function(self, A, B, C)
        local template, ang, frozen = A( self ), B( self ), C( self )
        
        if !IsValid(template) then return nil end
        return CreateRDent(self, template:GetClass(), template:GetModel(), self.Entity:GetPos() + self.Entity:GetUp()*25, Angle(ang[1], ang[2], ang[3]), frozen)
    end)

E_A:RegisterFunction("rdSpawn", "ssvan", "e",
    function(self, A, B, C, D, E)
        local class, model, pos, ang, frozen = A( self ), B( self ), C( self ), D( self ), E( self )
        
        return CreateRDent(self, class, model, Vector(pos[1], pos[2], pos[3]), Angle(ang[1], ang[2], ang[3]), frozen)
    end)

E_A:RegisterFunction("rdSpawn", "evan", "e",
    function(self, A, B, C, D)
        local template, pos, ang, frozen = A( self ), B( self ), C( self ), D( self )
        
        if !IsValid(template) then return nil end
        return CreateRDent(self, template:GetClass(), template:GetModel(), Vector(pos[1], pos[2], pos[3]), Angle(ang[1], ang[2], ang[3]), frozen)
    end)

/*==============================================================================================
        Section: Formatting
==============================================================================================*/
E_A:RegisterFunction("format", "n", "s",
    function(self, A)
        local num = A( self )
        
        return TK:Format(num)
    end)

/*==============================================================================================
        Section: Sequence
==============================================================================================*/
E_A:RegisterFunction("sequenceGet", "e:", "n",
    function(self, A)
        local ent = A( self )
        
        if !ValidAction(self, ent) then return 0 end
        return ent:GetSequence() or 0
    end)

E_A:RegisterFunction("sequenceLookUp", "e:s", "n",
    function(self, A, B)
        local ent, name = A( self ), B( self )
        
        if !ValidAction(self, ent) then return 0 end
        local id, dur = ent:LookupSequence(name)
        return id or 0
    end)

E_A:RegisterFunction("sequenceDuration", "e:s", "n",
    function(self, A, B)
        local ent, name = A( self ), B( self )
        
        if !ValidAction(self, ent) then return 0 end
        local id, dur = ent:LookupSequence(name)
        return dur or 0
    end)

E_A:RegisterFunction("sequenceSet", "e:n", "",
    function(self, A, B)
        local ent, id = A( self ), B( self )
        
        if !ValidAction(self, ent) then return end
        ent.AutomaticFrameAdvance = true
        ent:SetSequence(id)
    end)

E_A:RegisterFunction("sequenceReset", "e:n", "",
    function(self, A, B)
        local ent, id = A( self ), B( self )
        
        if !ValidAction(self, ent) then return end
        ent.AutomaticFrameAdvance = true
        ent:ResetSequence(id)
    end)

E_A:RegisterFunction("sequenceSetCycle", "e:n", "",
    function(self, A, B)
        local ent, frame = A( self ), B( self )
        
        if !ValidAction(self, ent) then return end
        ent:SetCycle(frame)
    end)

E_A:RegisterFunction("sequenceSetRate", "e:n", "",
    function(self, A, B)
        local ent, speed = A( self ), B( self )
        
        if !ValidAction(self, ent) then return end
        ent:SetPlaybackRate(speed)
    end)

E_A:RegisterFunction("setPoseParameter", "e:sn", "",
    function(self, A, B, C)
        local ent, param, value = A( self ), B( self ), C( self )
        
        if !ValidAction(self, ent) then return end
        ent:SetPoseParameter(param, value)
    end)

/*==============================================================================================
        Section: Wirelink
==============================================================================================*/
E_A:RegisterFunction("getWirelink", "e:", "wl",
    function(self, A)
        local ent = A( self )
        
        if !ValidAction(self, ent) then return NULL end
        if !IsWire( ent ) then return NULL end
        if ent.extended then return ent end
        
        ent.extended = true
        RefreshSpecialOutputs( ent )
        return ent
    end)

E_A:RegisterFunction("makeWirelink", "e:", "n",
    function(self, A)
        local ent = A( self )
        
        if !ValidAction(self, ent) then return 0 end
        if !IsWire( ent ) then return 0 end
        if ent.extended then return 0 end
        
        ent.extended = true
        RefreshSpecialOutputs( ent )
        return 1
    end)

E_A:RegisterFunction("removeWirelink", "e:", "n",
    function(self, A)
        local ent = A( self )
        
        if !ValidAction(self, ent) then return 0 end
        if !IsWire( ent ) then return 0 end
        if !ent.extended then return 0 end
        
        ent.extended = false
        RefreshSpecialOutputs( ent )
        return 1
    end)

/*==============================================================================================
        Section: Particles
==============================================================================================*/
util.AddNetworkString( "particlebeam" )

local ParticleCount = 0
local ParticleClear = 0
local ParticleBlackList = {"portal_rift_01"}

hook.Add("Think", "ParticleCount", function( )
    if CurTime( ) >= ParticleClear then
        ParticleClear = CurTime( ) + 1
        ParticleCount = 0
    end
end)

local function ValidParticle( particle )
    if table.HasValue(ParticleBlackList, name) then return false end
    if ParticleCount < CV_MaxParticles:GetInt( ) then
        ParticleCount = ParticleCount + 1
        return true
    end
    return false
end

E_A:RegisterFunction("particleCreate", "e:sva", "",
    function(self, A, B, C, D)
        local ent, particle, pos, ang = A( self ), B( self ), C( self ), D( self )
        
        if !ValidAction(self, ent) then return end
        if !ValidParticle( particle ) then return end
        ParticleEffect(particle, Vector(pos[1], pos[2], pos[3]), Angle(ang[1], ang[2], ang[3]), ent)
    end)

E_A:RegisterFunction("particleAttach", "e:s", "",
    function(self, A, B)
        local ent, particle = A( self ), B( self )
        
        if !ValidAction(self, ent) then return end
        if !ValidParticle( particle ) then return end
        ParticleEffectAttach(particle, PATTACH_ABSORIGIN_FOLLOW, ent, 0)
    end)

E_A:RegisterFunction("particleBeam", "e:se", "",
    function(self, A, B, C)
        local this, particle, ent = A( self ), B( self ), C( self )
        
        if !ValidAction(self, this) then return end
        if !ValidAction(self, ent) then return end
        if !ValidParticle( particle ) then return end
        
        timer.Simple(0.1, function( )
            net.Start( "particleBeam" )
                net.WriteString( particle )
                net.WriteInt(this:EntIndex(), 16)
                net.WriteInt(ent:EntIndex(), 16)
            net.Broadcast( )
        end)
    end)

E_A:RegisterFunction("particleStop", "e:", "",
    function(self, A)
        local ent = A( self )
        
        if !ValidAction(self, ent) then return end
        ent:StopParticles()
    end)

/*==============================================================================================
        Section: Effects
==============================================================================================*/
local EffectCount = 0
local EffectClear = 0
local EffectBlackList = {"ptorpedoimpact", "effect_explosion_scaleable", "nuke_blastwave", "nuke_blastwave_cheap", "nuke_disintegrate", "nuke_effect_air", "nuke_effect_ground", "nuke_vaporize", "warpcore_breach"}

hook.Add("Think", "EffectCount", function( )
    if CurTime( ) >= EffectClear then
        EffectClear = CurTime( ) + 1
        EffectCount = 0
    end
end)

local function ValidEffect( name )
    if table.HasValue(EffectBlackList, name) then return false end
    if EffectCount < CV_MaxEffects:GetInt( ) then
        EffectCount = EffectCount + 1
        return true
    end
    return false
end

local function MakeEffect(self, name, origin, start, angle, magnitude, scale)
    local fx = EffectData( )
    fx:SetOrigin( origin )
    fx:SetEntity( self )
    if start then fx:SetStart( start ) end
    if angle then fx:SetAngle( Angle(angle[1], angle[2], angle[3]) ) end
    if magnitude then fx:SetMagnitude( magnitude ) end
    if scale then fx:SetScale( scale ) end
    util.Effect(name, fx)
end

E_A:RegisterFunction("fx", "sv", "",
    function(self, A, B)
        Check_Enabled( self )
        
        local effect, origin = A( self ), B( self )
        
        if !ValidEffect( effect ) then return end
        MakeEffect(self, effect, origin)
    end)

E_A:RegisterFunction("fx", "svv", "",
    function(self, A, B, C)
        Check_Enabled( self )
        
        local effect, origin, start = A( self ), B( self ), C( self )
        
        if !ValidEffect( effect ) then return end
        MakeEffect(self, effect, origin, start)
    end)

E_A:RegisterFunction("fx", "svva", "",
    function(self, A, B, C, D)
        Check_Enabled( self )
        
        local effect, origin, start, ang = A( self ), B( self ), C( self ), D( self )
        
        if !ValidEffect( effect ) then return end
        MakeEffect(self, effect, origin, start, ang)
    end)

E_A:RegisterFunction("fx", "svvan", "",
    function(self, A, B, C, D, E)
        Check_Enabled( self )
        
        local effect, origin, start, ang, magnitude = A( self ), B( self ), C( self ), D( self ), E( self )
        
        if !ValidEffect( effect ) then return end
        MakeEffect(self, effect, origin, start, ang, magnitude)
    end)

E_A:RegisterFunction("fx", "svvann", "",
    function(self, A, B, C, D, E, F)
        Check_Enabled( self )
        
        local effect, origin, start, ang, magnitude, scale = A( self ), B( self ), C( self ), D( self ), E( self ), F( self )
        
        if !ValidEffect( effect ) then return end
        MakeEffect(self, effect, origin, start, ang, magnitude, scale)
    end)

/*==============================================================================================
        Section: Admin
==============================================================================================*/
E_A:RegisterFunction("isVip", "e:", "n",
    function(self, A)
        Check_Enabled( self )
        
        local ply = A( self )
        
        if !IsValid( ply ) then return 0 end
        if !ply:IsPlayer( ) then return 0 end
        return ply:IsVip( ) and 1 or 0
    end)

E_A:RegisterFunction("isDJ", "e:", "n",
    function(self, A)
        Check_Enabled( self )
        
        local ply = A( self )
        
        if !IsValid( ply ) then return 0 end
        if !ply:IsPlayer( ) then return 0 end
        return ply:IsDJ( ) and 1 or 0
    end)

E_A:RegisterFunction("isModerator", "e:", "n",
    function(self, A)
        Check_Enabled( self )
        
        local ply = A( self )
        
        if !IsValid( ply ) then return 0 end
        if !ply:IsPlayer( ) then return 0 end
        return ply:IsModerator( ) and 1 or 0
    end)

E_A:RegisterFunction("isAdmin", "e:", "n",
    function(self, A)
        Check_Enabled( self )
        
        local ply = A( self )
        
        if !IsValid( ply ) then return 0 end
        if !ply:IsPlayer( ) then return 0 end
        return ply:IsAdmin( ) and 1 or 0
    end)

E_A:RegisterFunction("isSuperAdmin", "e:", "n",
    function(self, A)
        Check_Enabled( self )
        
        local ply = A( self )
        
        if !IsValid( ply ) then return 0 end
        if !ply:IsPlayer( ) then return 0 end
        return ply:IsSuperAdmin( ) and 1 or 0
    end)

E_A:RegisterFunction("isOwner", "e:", "n",
    function(self, A)
        Check_Enabled( self )
        
        local ply = A( self )
        
        if !IsValid( ply ) then return 0 end
        if !ply:IsPlayer( ) then return 0 end
        return ply:IsOwner( ) and 1 or 0
    end)

/*==============================================================================================
        Section: Gameplay
==============================================================================================*/
E_A:RegisterFunction("credits", "e:", "n",
    function(self, A)
        Check_Enabled( self )
        
        local ply = A( self )
        
        if !IsValid( ply ) then return 0 end
        if !ply:IsPlayer( ) then return 0 end
        return TK.DB:GetPlayerData(ply, "player_info").credits
    end)

E_A:RegisterFunction("score", "e:", "n",
    function(self, A)
        Check_Enabled( self )
        
        local ply = A( self )
        
        if !IsValid( ply ) then return 0 end
        if !ply:IsPlayer( ) then return 0 end
        return TK.DB:GetPlayerData(ply, "player_info").score
    end)

E_A:RegisterFunction("getSunPos", "", "v",
    function( self )
        Check_Enabled( self )
        
        local sun = TK.AT:GetSuns()[1]
        return sun
    end)