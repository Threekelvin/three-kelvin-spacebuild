
local table = table

local PP = {}
PP.BuddyTable = {}
PP.ShareTable = {}
PP.EntityTrace = {}

///--- Functions ---\\\
function PP.HasPermission(flag, typ)
    local id = TK.PP.Permissions[typ]
    if !id then return false end
    return bit.band(id, flag || 0) == id
end

function PP.GetByUniqueID(uid)
    for k,v in pairs(player.GetAll()) do
        if v:UID() == uid then
            return v
        end
    end
    return false
end

function PP.GetOwner(ent)
    if !IsValid(ent) then return nil, nil end
    local uid = ent:UID()
    if !uid then return nil, nil end
    local ply = PP.GetByUniqueID(uid)
    if !IsValid(ply) then return NULL, uid
    else return ply, uid end
end

function PP.BlackList(ent)
    if ent:GetClass() == "prop_physics" && table.HasValue(TK.PP.PropBlackList, ent:GetModel()) then
        SafeRemoveEntity(ent)
        return true
    elseif table.HasValue(TK.PP.EntityBlackList, ent:GetClass()) then
        SafeRemoveEntity(ent)
        return true
    end
    
    return false
end

function PP.AddCleanup(uid, ent)
    PP.EntityTrace[uid] = PP.EntityTrace[uid] || {}
    local eid = ent:EntIndex()
    PP.EntityTrace[uid][eid] = ent
end

function PP.RemoveCleanup(uid, ent)
    PP.EntityTrace[uid] = PP.EntityTrace[uid] || {}
    local eid = ent:EntIndex()
    PP.EntityTrace[uid][eid] = nil
end

function PP.SetOwner(ply, ent, uid)
    if !IsValid(ent) then return false end
    local eid, curuid = ent:EntIndex(), ent:UID()
    
    if IsValid(ply) && ply:IsPlayer() then
        uid = ply:UID()
        if curuid == uid then return true end
        
        if PP.BlackList(ent) then return false end
        if gamemode.Call("CPPIAssignOwnership", ply, ent) != nil then return false end
        
        ent:SetNWString("UID", uid)
        ent.Owner = ply
        
        PP.AddCleanup(uid, ent)
        PP.RemoveCleanup(curuid, ent)
    elseif uid then
        if curuid == uid then return true end
        
        if PP.BlackList(ent) then return false end
        if gamemode.Call("CPPIAssignOwnership", NULL, ent) != nil then return false end
        
        ent:SetNWString("UID", uid)
        ent.Owner = NULL
        
        PP.AddCleanup(uid, ent)
        PP.RemoveCleanup(curuid, ent)
    else
        ent:Remove()
        return false
    end
    
    return true
end

function PP.UpdateBuddy(ply, tid, flag)
    local uid = ply:UID()
    PP.BuddyTable[uid] = PP.BuddyTable[uid] || {}
    local cppi = PP.HasPermission(PP.BuddyTable[uid][tid], "CPPI")
    PP.BuddyTable[uid][tid] = flag
    
    if PP.HasPermission(flag, "CPPI") != cppi then
        local friends = {}
        for k,v in pairs(PP.BuddyTable[uid]) do
            if !PP.HasPermission(v, "CPPI") then continue end
            local tar = PP.GetByUniqueID(k)
            if !IsValid(tar) then continue end
            table.insert(friends, tar)
        end
        
        gamemode.Call("CPPIFriendsChanged", ply, friends)
    end
end

function PP.UpdateShare(ply, eid, flag)
    local ent = Entity(eid)
    if !IsValid(ent) then return false end
    local owner, uid = PP.GetOwner(ent)
    if owner != ply then return false end
    PP.ShareTable[eid] = flag
    return true
end

function PP.CanOverride(ply, typ, dir, tar)
    if IsValid(tar) && tar:IsPlayer() then 
        if !ply:CanRunOn(tar) then return false end
    end
    
    if ply:IsSuperAdmin() then
        return TK.PP.Settings[typ][dir].SuperAdmin
    elseif ply:IsAdmin() then
        return TK.PP.Settings[typ][dir].Admin
    elseif ply:IsModerator() then
        return TK.PP.Settings[typ][dir].Moderator
    else
        return TK.PP.Settings[typ][dir].User
    end
end

function PP.IsBuddy(uid, ply, typ)
    if !IsValid(ply) then return false end 
    if !PP.BuddyTable[uid] then return false end
    
    return PP.HasPermission(PP.BuddyTable[uid][ply:UID()], typ)
end

function PP.IsShared(ent, typ)
    if !IsValid(ent) then return false end
    local eid = ent:EntIndex()
    
    return PP.HasPermission(PP.ShareTable[eid], typ)
end

function PP.CheckConstraints(ply, ent, typ)
    for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
        local owner, uid = PP.GetOwner(v)
        if ply == owner then continue end
        if PP.CanOverride(ply, typ, "Prop", owner) then continue end
        if PP.IsBuddy(uid, ply, typ) then continue end
        if PP.IsShared(v, typ) then continue end
        
        return false
    end
    return true
end

function PP.CleanUpPlayer(ply)
    if !IsValid(ply) then return end
    local uid = ply:UID()
    PP.EntityTrace[uid] = PP.EntityTrace[uid] || {}
    
    for _,ent in pairs(PP.EntityTrace[uid]) do
        if !IsValid(ent) then continue end
        if table.HasValue(ply:GetWeapons(), ent) then continue end
        if table.HasValue(TK.PP.CleanupBlackList, ent:GetClass()) then continue end
        
        SafeRemoveEntity(ent)
    end
    
    PP.EntityTrace[uid] = {}
end

function PP.CleanUpUID(uid)
    local ply = PP.GetByUniqueID(uid)
    if IsValid(ply) then
        PP.CleanUpPlayer(ply)
        return
    end

    PP.EntityTrace[uid] = PP.EntityTrace[uid] || {}
    
    for _,ent in pairs(PP.EntityTrace[uid]) do
        if !IsValid(ent) then continue end
        
        SafeRemoveEntity(ent)
    end
    
    PP.EntityTrace[uid] = {}
end

function PP.CleanUpDisconnected()
    for k,v in pairs(PP.EntityTrace) do
        if IsValid(PP.GetByUniqueID(k)) then continue end
        
        for _,ent in pairs(v) do
            if !IsValid(ent) then continue end
            SafeRemoveEntity(ent)
        end
        
        timer.Remove(tostring(k).." cleanup")
        PP.EntityTrace[k] = nil
    end
end
///--- ---\\\

///--- Console Commands ---\\\
concommand.Add("pp_updatebuddy", function(ply, cmd, arg)
    local tid, flag = arg[1], arg[2]
    PP.UpdateBuddy(ply, tid, flag)
end)

concommand.Add("pp_updateshare", function(ply, cmd, arg)
    local eid, flag = tonumber(arg[1]), arg[2]
    PP.UpdateShare(ply, eid, flag)
end)

concommand.Add("pp_cleanup", function(ply, cmd, arg)
    if ply:IsModerator() then
        local dcp, uid = tonumber(arg[1]), arg[2]
        if dcp == 1 then
            PP.CleanUpDisconnected()
            TK.AM:SystemMessage({ply, " Has Cleaned Up Disconnected User Props"})
        elseif uid == ply:UID() then
            PP.CleanUpPlayer(ply)
            TK.AM:SystemMessage({"Your Props Have Been Cleaned Up"}, {ply})
        else
            local tar = PP.GetByUniqueID(uid)
            if !IsValid(tar) then return end
            if !ply:CanRunOn(tar) then return end
            PP.CleanUpPlayer(tar)
            TK.AM:SystemMessage({ply, " Has Cleaned Up ", tar,"'s  Props"})
        end
    else
        PP.CleanUpPlayer(ply)
        TK.AM:SystemMessage({"Your Props Have Been Cleaned Up"}, {ply})
    end
end)
///--- ---\\\

///--- Can Do Stuff Hooks ---\\\
function PP.CanToolEnt(ply, toolmode, ent)
    if IsValid(ply.InShip) then return false end
    if !IsValid(ent) then return end
    if ent:IsPlayer() then return false end
    
    local owner, uid = PP.GetOwner(ent)
    if IsValid(owner) then
        if toolmode == "adv_duplicator" || toolmode == "duplicator" || toolmode == "advdupe2" then
            if !PP.CheckConstraints(ply, ent, "Dupe") then return false end
            
            if ply == owner then return end
            if PP.CanOverride(ply, "Dupe", "Prop", owner) then return end
            if PP.IsBuddy(uid, ply, "Dupe") then return end
            if PP.IsShared(ent, "Dupe") then return end
            return false
        elseif toolmode == "remover" && (ply:KeyDown(IN_ATTACK2) || ply:KeyDownLast(IN_ATTACK2)) then
            if !PP.CheckConstraints(ply, ent, "Tool Gun") then return false end
        end
        
        if ply == owner then return end
        if PP.CanOverride(ply, "Tool Gun", "Prop", owner) then return end
        if PP.IsBuddy(uid, ply, "Tool Gun") then return end
        if PP.IsShared(ent, "Tool Gun") then return end
    else
        if toolmode == "adv_duplicator" || toolmode == "duplicator" || toolmode == "advdupe2" then
            if PP.CanOverride(ply, "Dupe", "World") then return end
        else
            if PP.CanOverride(ply, "Tool Gun", "World") then return end
        end
    end
    return false
end

function PP.CanTool(ply, tr, toolmode)
    if IsValid(ply.InShip) then return false end
    if !tr.HitNonWorld || !IsValid(tr.Entity) then return end

    local ent = tr.Entity
    if ent:IsPlayer() then return false end

    local owner, uid = PP.GetOwner(ent)
    if IsValid(owner) then
        if toolmode == "adv_duplicator" || toolmode == "duplicator" || toolmode == "advdupe2" then
            if !PP.CheckConstraints(ply, ent, "Dupe") then return false end
            
            if ply == owner then return end
            if PP.CanOverride(ply, "Dupe", "Prop", owner) then return end
            if PP.IsBuddy(uid, ply, "Dupe") then return end
            if PP.IsShared(ent, "Dupe") then return end
            return false
        elseif toolmode == "remover" && (ply:KeyDown(IN_ATTACK2) || ply:KeyDownLast(IN_ATTACK2)) then
            if !PP.CheckConstraints(ply, ent, "Tool Gun") then return false end
        elseif toolmode == "nail" then
            local tracedata = {}
            tracedata.start = tr.HitPos
            tracedata.endpos = tr.HitPos + (ply:GetAimVector() * 16)
            tracedata.filter = {ply, ent}
            
            if PP.CanTool(ply, util.TraceLine(tracedata), "none") == false then return false end
        elseif table.HasValue(TK.PP.BadTools, toolmode) && (ply:KeyDown(IN_ATTACK2) || ply:KeyDownLast(IN_ATTACK2)) then
            local tracedata = {}
            tracedata.start = tr.HitPos
            tracedata.endpos = tr.HitPos + (tr.HitNormal * 16384)
            tracedata.filter = {ply}
            
            if PP.CanTool(ply, util.TraceLine(tracedata), "none") == false then return false end
        end
        
        if ply == owner then return end
        if PP.CanOverride(ply, "Tool Gun", "Prop", owner) then return end
        if PP.IsBuddy(uid, ply, "Tool Gun") then return end
        if PP.IsShared(ent, "Tool Gun") then return end
    else
        if toolmode == "adv_duplicator" || toolmode == "duplicator" || toolmode == "advdupe2" then
            if PP.CanOverride(ply, "Dupe", "World") then return end
        else
            if PP.CanOverride(ply, "Tool Gun", "World") then return end
        end
    end
    return false
end

function PP.CanGravGun(ply, ent)
    if ent:IsPlayer() then return false end
    local owner, uid = PP.GetOwner(ent)
    if IsValid(owner) then
        if ply == owner then return end
        if PP.CanOverride(ply, "Grav Gun", "Prop", owner) then return end
        if PP.IsBuddy(uid, ply, "Grav Gun") then return end
        if PP.IsShared(ent, "Grav Gun") then return end
    else
        if PP.CanOverride(ply, "Grav Gun", "World") then return end
    end
    return false
end

function PP.CanPhysGun(ply, ent)
    local owner, uid = PP.GetOwner(ent)
    if IsValid(owner) then
        if ply == owner then return end
        if ent:IsPlayer() then
            if PP.CanOverride(ply, "Phys Gun", "Player", ent) then return true end
        else
            if PP.CanOverride(ply, "Phys Gun", "Prop", owner) then return end
            if PP.IsBuddy(uid, ply, "Phys Gun") then return end
            if PP.IsShared(ent, "Phys Gun") then return end
        end
    else
        if PP.CanOverride(ply, "Phys Gun", "World") then return end
    end
    return false
end

function PP.CanPhysGunReload(wep, ply)
    local tr = ply:GetEyeTraceNoCursor()
    if tr.HitNonWorld && IsValid(tr.Entity) then
        if tr.Entity:IsPlayer() then return false end
        local owner, uid = PP.GetOwner(tr.Entity)
        if IsValid(owner) then
            if !PP.CheckConstraints(ply, tr.Entity, "Phys Gun") then return false end
            
            if ply == owner then return end
            if PP.CanOverride(ply, "Phys Gun", "Prop", owner) then return end
            if PP.IsBuddy(uid, ply, "Phys Gun") then return end
            if PP.IsShared(tr.Entity, "Phys Gun") then  return end
        else
            if PP.CanOverride(ply, "Phys Gun", "World") then return end
        end
    end
    return false
end

function PP.CanUse(ply, ent)
    if ent:IsPlayer() then return false end
    local owner, uid = PP.GetOwner(ent)
    if IsValid(owner) then
        if ply == owner then return end
        if PP.CanOverride(ply, "Use", "Prop", owner) then return end
        if PP.IsBuddy(uid, ply, "Use") then return end
        if PP.IsShared(ent, "Use") then return end
    else
        if PP.CanOverride(ply, "Use", "World") then return end
    end
    return false
end

hook.Add("PlayerSpawnProp", "TKPP", function(ply, mdl)
    if table.HasValue(TK.PP.PropBlackList, mdl) then
        return false
    end
end)

hook.Add("CanTool",                 "TKPP", PP.CanTool)
hook.Add("CanProperty",             "TKPP", PP.CanToolEnt)
hook.Add("GravGunPunt",             "TKPP", PP.CanGravGun)
hook.Add("GravGunPickupAllowed",    "TKPP", PP.CanGravGun)
hook.Add("PhysgunPickup",           "TKPP", PP.CanPhysGun)
hook.Add("PhysgunDrop",             "TKPP", PP.CanPhysGun)
hook.Add("CanPlayerUnfreeze",       "TKPP", PP.CanPhysGun)
hook.Add("OnPhysgunReload",         "TKPP", PP.CanPhysGunReload)
hook.Add("CanPlayerEnterVehicle",   "TKPP", PP.CanUse)
hook.Add("PlayerUse",               "TKPP", PP.CanUse)
hook.Add("CanDrive",                "TKPP", function() return false end)
///--- ---\\\

///--- Find Owner Functions ---\\\
hook.Add("PlayerSpawnedRagdoll",    "TKPP", function(ply, mdl, ent) PP.SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedProp",       "TKPP", function(ply, mdl, ent) PP.SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedEffect",     "TKPP", function(ply, mdl, ent) PP.SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedVehicle",    "TKPP", function(ply, ent)      PP.SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedNPC",        "TKPP", function(ply, ent)      PP.SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedSENT",       "TKPP", function(ply, ent)      PP.SetOwner(ply, ent) end)

hook.Add("Initialize", "PP_FO", function()
    if cleanup then
        local CleanUpOld = cleanup.Add
        function cleanup.Add(ply, typ, ent)
            PP.SetOwner(ply, ent)
            return CleanUpOld(ply, typ, ent)
        end
    end

    if _R.Player.AddCount then
        local AddCountOld = _R.Player.AddCount
        function _R.Player:AddCount(typ, ent)
            PP.SetOwner(self, ent)
            return AddCountOld(self, typ, ent)
        end
    end

    if undo then
        local AddEntityOld, SetPlayerOld, FinishOld =  undo.AddEntity, undo.SetPlayer, undo.Finish
        local Undo, UndoPlayer = {}
        
        function undo.AddEntity(ent, ...)
            if type(ent) != "boolean" and IsValid(ent) then
                if !ent:IsConstraint() then 
                    table.insert(Undo, ent)
                end
            end
            AddEntityOld(ent, ...)
        end
        
        function undo.SetPlayer(ply, ...)
            UndoPlayer = ply
            SetPlayerOld(ply, ...)
        end
        
        function undo.Finish(...)
            if IsValid(UndoPlayer) then
                for k,v in pairs(Undo) do
                    PP.SetOwner(UndoPlayer, v)
                end
            end
            Undo = {}
            UndoPlayer = nil
            
            FinishOld(...)
        end
    end
end)

hook.Add("EntitySpawned", "TKPP", function(ent)
    timer.Simple(0.1, function()
        if !IsValid(ent) then return end
        local owner, uid = PP.GetOwner(ent)
        if !owner && !uid then
            local Parent = ent:GetParent()
            if IsValid(Parent) then
                local owner, uid = PP.GetOwner(Parent)
                if uid then 
                    PP.SetOwner(owner, ent, uid)
                    return
                end
            end
            
            for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
                local owner, uid = PP.GetOwner(v)
                if uid then 
                    PP.SetOwner(owner, ent, uid)
                    return
                end
            end
        end
    end)
end)
///--- ---\\\

///--- Player Hooks ---\\\
util.AddNetworkString("PPBuddy")
util.AddNetworkString("PPShare")

hook.Add("PlayerInitialSpawn", "TKPP", function(ply)
    local uid = ply:UID()
    timer.Remove(uid.." cleanup")

    if PP.BuddyTable[uid] then
        net.Start("PPBuddy")
            net.WriteTable(PP.BuddyTable[uid])
        net.Send(ply)
    end

    if PP.EntityTrace[uid] then
        local shared = {}
        for k,v in pairs(PP.EntityTrace[uid]) do
            v.Owner = ply
            
            if PP.ShareTable[k] then
                shared[k] = v
            end
        end
        
        if table.Count(shared) > 0 then
            timer.Simple(5, function()
                net.Start("PPShare")
                    net.WriteTable(shared)
                net.Send(ply)
            end)
        end
    end
end)

hook.Add("ShowSpare1", "TKPP", function(ply)
    umsg.Start("PP_Menu1", ply)
    umsg.End()
end)

hook.Add("ShowSpare2", "TKPP", function(ply)
    umsg.Start("PP_Menu2", ply)
    umsg.End()
end)

hook.Add("PlayerDisconnected", "TKPP", function(ply)
    if !IsValid(ply) then return end
    local uid, name = ply:UID(), ply:Name()
    
    timer.Create(uid.." cleanup", TK.PP.Settings.CleanUp.Delay, 1, function()
        PP.CleanUpUID(uid)
        TK.AM:SystemMessage({name.."'s Props Have Been Cleaned Up"})
    end)
end)
///--- ---\\\

///--- Remove Entities ---\\\
hook.Add("EntityRemoved", "TKPP", function(ent)
    local uid, eid = ent:UID(), ent:EntIndex()

    if PP.EntityTrace[uid] then
        PP.EntityTrace[uid][eid] = nil
    end
    
    PP.ShareTable[eid] = nil
end)
///--- ---\\\

///--- CPPI ---\\\
CPPI = CPPI || {}

function CPPI:GetNameFromUID(uid)
    if !uid then return nil end
    local ply = PP.GetByUniqueID(tostring(uid))
    if !IsValid(ply) then return nil end
    return string.sub(ply:Name(), 1, 31)
end

function _R.Player:CPPIGetFriends()
    local TrustedPlayers = {}
    local uid = self:UID()
    for k,v in pairs(player.GetAll()) do
        if PP.IsBuddy(uid, v, "CPPI") then
            table.insert(TrustedPlayers, v)
        end
    end
    return TrustedPlayers
end

function _R.Entity:CPPIGetOwner()
    return PP.GetOwner(self)
end


function _R.Entity:CPPISetOwner(ply)
    PP.SetOwner(ply, self)
    return true
end

function _R.Entity:CPPISetOwnerUID(uid)
    PP.SetOwner(PP.GetByUniqueID(uid), self, uid)
    return true
end

function _R.Entity:CPPICanTool(ply, toolmode)
    if PP.CanToolEnt(ply, toolmode, self) == false then return false end
    return true
end

function _R.Entity:CPPICanPhysgun(ply)
    if PP.CanPhysGun(ply, self) == false then return false end
    return true
end

function _R.Entity:CPPICanPickup(ply)
    if PP.CanGravGun(ply, self) == false then return false end
    return true
end

function _R.Entity:CPPICanPunt(ply)
    if PP.CanGravGun(ply, self) == false then return false end
    return true
end

function _R.Entity:CPPICanUse(ply)
    if PP.CanUse(ply, self) == false then return false end
    return true
end

hook.Add("Initialize", "CPPIInit", function()
    function GAMEMODE:CPPIAssignOwnership(ply, ent)
    end
    function GAMEMODE:CPPIFriendsChanged(ply, tab)
    end
end)
///--- ---\\\