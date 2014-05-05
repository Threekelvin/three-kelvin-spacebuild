
local table = table

local PP = {}
PP.BuddyTable = {}
PP.ShareTable = {}
PP.EntityTrace = {}

///--- Functions ---\\\
function PP:HasPermission(flag, typ)
    local id = TK.PP.Permissions[typ]
    if !id then return false end
    return bit.band(id, flag or 0) == id
end

function PP:GetByUniqueID(uid)
    for k,v in pairs(player.GetAll()) do
        if v:UID() == uid then
            return v
        end
    end
    return false
end

function PP:GetOwner(ent)
    if !IsValid(ent) then return nil, nil end
    local uid = ent:UID()
    if !uid then return nil, nil end
    local ply = self:GetByUniqueID(uid)
    if !IsValid(ply) then return NULL, uid
    else return ply, uid end
end

function PP:BlackList(ent, mdl, class)
    if IsValid(ent) then
        if ent:GetClass() == "prop_physics" and table.HasValue(TK.PP.PropBlackList, ent:GetModel()) then
            SafeRemoveEntity(ent)
            return true
        elseif table.HasValue(TK.PP.EntityBlackList, ent:GetClass()) then
            SafeRemoveEntity(ent)
            return true
        end
    elseif mdl then
        if table.HasValue(TK.PP.PropBlackList, mdl) then
            return true
        end
    elseif class then
        if table.HasValue(TK.PP.EntityBlackList, class) then
            return true
        end
    end
    
    return false
end

function PP:AddCleanup(uid, ent)
    self.EntityTrace[uid] = self.EntityTrace[uid] or {}
    local eid = ent:EntIndex()
    self.EntityTrace[uid][eid] = ent
end

function PP:RemoveCleanup(uid, ent)
    self.EntityTrace[uid] = self.EntityTrace[uid] or {}
    local eid = ent:EntIndex()
    self.EntityTrace[uid][eid] = nil
end

function PP:SetOwner(ply, ent, uid)
    if !IsValid(ent) then return false end
    local eid, curuid = ent:EntIndex(), ent:UID()
    
    if IsValid(ply) and ply:IsPlayer() then
        uid = ply:UID()
        if curuid == uid then return true end
        
        if self:BlackList(ent) then return false end
        if gamemode.Call("CPPIAssignOwnership", ply, ent) != nil then return false end
        ent:SetNWString("UID", uid)
        ent:SetPhysicsAttacker(ent)
        
        self:AddCleanup(uid, ent)
        self:RemoveCleanup(curuid, ent)
    elseif uid then
        if curuid == uid then return true end
        if self:BlackList(ent) then return false end
        local ply = self:GetByUniqueID(uid)
        if ply then return self:SetOwner(ply, ent) end
        
        if gamemode.Call("CPPIAssignOwnership", NULL, ent) != nil then return false end
        ent:SetNWString("UID", uid)
        
        self:AddCleanup(uid, ent)
        self:RemoveCleanup(curuid, ent)
    else
        SafeRemoveEntity(ent)
        return false
    end
    
    return true
end

function PP:UpdateBuddy(ply, tid, flag)
    local uid = ply:UID()
    self.BuddyTable[uid] = self.BuddyTable[uid] or {}
    local cppi = self:HasPermission(self.BuddyTable[uid][tid], "CPPI")
    self.BuddyTable[uid][tid] = flag
    
    if self:HasPermission(flag, "CPPI") != cppi then
        local friends = {}
        for k,v in pairs(self.BuddyTable[uid]) do
            if !self:HasPermission(v, "CPPI") then continue end
            local tar = self.GetByUniqueID(k)
            if !IsValid(tar) then continue end
            table.insert(friends, tar)
        end
        
        gamemode.Call("CPPIFriendsChanged", ply, friends)
    end
end

function PP:UpdateShare(ply, eid, flag)
    local ent = Entity(eid)
    if !IsValid(ent) then return false end
    local owner, uid = self:GetOwner(ent)
    if owner != ply then return false end
    self.ShareTable[eid] = flag
    return true
end

function PP:CanOverride(ply, typ, dir, tar)
    if IsValid(tar) and tar:IsPlayer() then 
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

function PP:IsBuddy(uid, ply, typ)
    if !IsValid(ply) then return false end 
    if !self.BuddyTable[uid] then return false end
    
    return self:HasPermission(self.BuddyTable[uid][ply:UID()], typ)
end

function PP:IsShared(ent, typ)
    if !IsValid(ent) then return false end
    local eid = ent:EntIndex()
    
    return self:HasPermission(self.ShareTable[eid], typ)
end

function PP:CheckConstraints(ply, ent, typ)
    for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
        local owner, uid = self:GetOwner(v)
        if ply == owner then continue end
        if self:CanOverride(ply, typ, "Prop", owner) then continue end
        if self:IsBuddy(uid, ply, typ) then continue end
        if self:IsShared(v, typ) then continue end
        
        return false
    end
    return true
end

function PP:CleanUpPlayer(ply)
    if !IsValid(ply) then return end
    local uid = ply:UID()
    self.EntityTrace[uid] = self.EntityTrace[uid] or {}
    
    for _,ent in pairs(self.EntityTrace[uid]) do
        if !IsValid(ent) then continue end
        if table.HasValue(ply:GetWeapons(), ent) then continue end
        if table.HasValue(TK.PP.CleanupBlackList, ent:GetClass()) then continue end
        
        SafeRemoveEntity(ent)
    end
    
    self.EntityTrace[uid] = {}
end

function PP:CleanUpUID(uid)
    local ply = self:GetByUniqueID(uid)
    if IsValid(ply) then
        self:CleanUpPlayer(ply)
        return
    end

    self.EntityTrace[uid] = self.EntityTrace[uid] or {}
    
    for _,ent in pairs(self.EntityTrace[uid]) do
        if !IsValid(ent) then continue end
        
        SafeRemoveEntity(ent)
    end
    
    self.EntityTrace[uid] = {}
end

function PP:CleanUpDisconnected()
    for k,v in pairs(self.EntityTrace) do
        if IsValid(self:GetByUniqueID(k)) then continue end
        
        for _,ent in pairs(v) do
            if !IsValid(ent) then continue end
            SafeRemoveEntity(ent)
        end
        
        timer.Destroy(tostring(k).." cleanup")
        self.EntityTrace[k] = nil
    end
end
///--- ---\\\

///--- Console Commands ---\\\
concommand.Add("pp_updatebuddy", function(ply, cmd, arg)
    local tid, flag = arg[1], arg[2]
    PP:UpdateBuddy(ply, tid, flag)
end)

concommand.Add("pp_updateshare", function(ply, cmd, arg)
    local eid, flag = tonumber(arg[1]), arg[2]
    PP:UpdateShare(ply, eid, flag)
end)

concommand.Add("pp_cleanup", function(ply, cmd, arg)
    if ply:IsModerator() then
        local dcp, uid = tonumber(arg[1]), arg[2]
        if dcp == 1 then
            PP:CleanUpDisconnected()
            TK.AM:SystemMessage({ply, " Has Cleaned Up Disconnected User Props"})
        elseif uid == ply:UID() then
            PP:CleanUpPlayer(ply)
            TK.AM:SystemMessage({"Your Props Have Been Cleaned Up"}, {ply})
        else
            local tar = PP:GetByUniqueID(uid)
            if !IsValid(tar) then return end
            if !ply:CanRunOn(tar) then return end
            PP:CleanUpPlayer(tar)
            TK.AM:SystemMessage({ply, " Has Cleaned Up ", tar,"'s  Props"})
        end
    else
        PP:CleanUpPlayer(ply)
        TK.AM:SystemMessage({"Your Props Have Been Cleaned Up"}, {ply})
    end
end)
///--- ---\\\

///--- Can Do Stuff Hooks ---\\\
function PP:CanToolEnt(ply, toolmode, ent)
    if IsValid(ply.InShip) then return false end
    if !IsValid(ent) then return end
    if ent:IsPlayer() then return false end
    
    local owner, uid = self:GetOwner(ent)
    if IsValid(owner) then
        if string.match(toolmode, "duplicator") or string.match(toolmode, "dupe") then
            if !self:CheckConstraints(ply, ent, "Dupe") then return false end
            
            if ply == owner then return end
            if self:CanOverride(ply, "Dupe", "Prop", owner) then return end
            if self:IsBuddy(uid, ply, "Dupe") then return end
            if self:IsShared(ent, "Dupe") then return end
            return false
        elseif toolmode == "remover" and (ply:KeyDown(IN_ATTACK2) or ply:KeyDownLast(IN_ATTACK2)) then
            if !self:CheckConstraints(ply, ent, "Tool Gun") then return false end
        end
        
        if ply == owner then return end
        if self:CanOverride(ply, "Tool Gun", "Prop", owner) then return end
        if self:IsBuddy(uid, ply, "Tool Gun") then return end
        if self:IsShared(ent, "Tool Gun") then return end
    else
        if string.match(toolmode, "duplicator") or string.match(toolmode, "dupe") then
            if self:CanOverride(ply, "Dupe", "World") then return end
        else
            if self:CanOverride(ply, "Tool Gun", "World") then return end
        end
    end
    return false
end

function PP:CanToolGun(ply, tr, toolmode)
    if IsValid(ply.InShip) then return false end
    if !tr.HitNonWorld or !IsValid(tr.Entity) then return end

    local ent = tr.Entity
    if ent:IsPlayer() then return false end

    local owner, uid = self:GetOwner(ent)
    if IsValid(owner) then
        if string.match(toolmode, "duplicator") or string.match(toolmode, "dupe") then
            if !self:CheckConstraints(ply, ent, "Dupe") then return false end
            
            if ply == owner then return end
            if self:CanOverride(ply, "Dupe", "Prop", owner) then return end
            if self:IsBuddy(uid, ply, "Dupe") then return end
            if self:IsShared(ent, "Dupe") then return end
            return false
        elseif toolmode == "remover" and (ply:KeyDown(IN_ATTACK2) or ply:KeyDownLast(IN_ATTACK2)) then
            if !self:CheckConstraints(ply, ent, "Tool Gun") then return false end
        elseif toolmode == "nail" then
            local tracedata = {}
            tracedata.start = tr.HitPos
            tracedata.endpos = tr.HitPos + (ply:GetAimVector() * 16)
            tracedata.filter = {ply, ent}
            
            if self:CanToolGun(ply, util.TraceLine(tracedata), "none") == false then return false end
        elseif table.HasValue(TK.PP.BadTools, toolmode) and (ply:KeyDown(IN_ATTACK2) or ply:KeyDownLast(IN_ATTACK2)) then
            local tracedata = {}
            tracedata.start = tr.HitPos
            tracedata.endpos = tr.HitPos + (tr.HitNormal * 16384)
            tracedata.filter = {ply}
            
            if self:CanToolGun(ply, util.TraceLine(tracedata), "none") == false then return false end
        end
        
        if ply == owner then return end
        if self:CanOverride(ply, "Tool Gun", "Prop", owner) then return end
        if self:IsBuddy(uid, ply, "Tool Gun") then return end
        if self:IsShared(ent, "Tool Gun") then return end
    else
        if string.match(toolmode, "duplicator") or string.match(toolmode, "dupe") then
            if self:CanOverride(ply, "Dupe", "World") then return end
        else
            if self:CanOverride(ply, "Tool Gun", "World") then return end
        end
    end
    return false
end

function PP:CanGravGun(ply, ent)
    if ent:IsPlayer() then return false end
    local owner, uid = self:GetOwner(ent)
    if IsValid(owner) then
        if ply == owner then return end
        if self:CanOverride(ply, "Grav Gun", "Prop", owner) then return end
        if self:IsBuddy(uid, ply, "Grav Gun") then return end
        if self:IsShared(ent, "Grav Gun") then return end
    else
        if self:CanOverride(ply, "Grav Gun", "World") then return end
    end
    return false
end

function PP:CanPhysGun(ply, ent)
    local owner, uid = self:GetOwner(ent)
    if IsValid(owner) then
        if ply == owner then return end
        if ent:IsPlayer() then
            if self:CanOverride(ply, "Phys Gun", "Player", ent) then return end
        else
            if self:CanOverride(ply, "Phys Gun", "Prop", owner) then return end
            if self:IsBuddy(uid, ply, "Phys Gun") then return end
            if self:IsShared(ent, "Phys Gun") then return end
        end
    else
        if self:CanOverride(ply, "Phys Gun", "World") then return end
    end
    return false
end

function PP:CanPhysGunReload(wep, ply)
    local tr = ply:GetEyeTraceNoCursor()
    if tr.HitNonWorld and IsValid(tr.Entity) then
        if tr.Entity:IsPlayer() then return false end
        local owner, uid = self:GetOwner(tr.Entity)
        if IsValid(owner) then
            if !self:CheckConstraints(ply, tr.Entity, "Phys Gun") then return false end
            
            if ply == owner then return end
            if self:CanOverride(ply, "Phys Gun", "Prop", owner) then return end
            if self:IsBuddy(uid, ply, "Phys Gun") then return end
            if self:IsShared(tr.Entity, "Phys Gun") then  return end
        else
            if self:CanOverride(ply, "Phys Gun", "World") then return end
        end
    end
    return false
end

function PP:CanUseEnt(ply, ent)
    if ent:IsPlayer() then return false end
    local owner, uid = self:GetOwner(ent)
    if IsValid(owner) then
        if ply == owner then return end
        if self:CanOverride(ply, "Use", "Prop", owner) then return end
        if self:IsBuddy(uid, ply, "Use") then return end
        if self:IsShared(ent, "Use") then return end
    else
        if self:CanOverride(ply, "Use", "World") then return end
    end
    return false
end

hook.Add("PlayerSpawnSENT",         "TKPP", function(ply, class) if PP:BlackList(nil, nil, class) then return false end end)
hook.Add("PlayerSpawnProp",         "TKPP", function(ply, mdl) if PP:BlackList(nil, mdl) then return false end end)
hook.Add("CanTool",                 "TKPP", function(...) return PP:CanToolGun(...) end)
hook.Add("CanProperty",             "TKPP", function(...) return PP:CanToolEnt(...) end)
hook.Add("GravGunPunt",             "TKPP", function(...) return PP:CanGravGun(...) end)
hook.Add("GravGunPickupAllowed",    "TKPP", function(...) return PP:CanGravGun(...) end)
hook.Add("PhysgunPickup",           "TKPP", function(...) return PP:CanPhysGun(...) end)
hook.Add("PhysgunDrop",             "TKPP", function(...) return PP:CanPhysGun(...) end)
hook.Add("CanPlayerUnfreeze",       "TKPP", function(...) return PP:CanPhysGun(...) end)
hook.Add("OnPhysgunReload",         "TKPP", function(...) return PP:CanPhysGunReload(...) end)
hook.Add("CanPlayerEnterVehicle",   "TKPP", function(...) return PP:CanUseEnt(...) end)
hook.Add("PlayerUse",               "TKPP", function(...) return PP:CanUseEnt(...) end)
hook.Add("CanDrive",                "TKPP", function()    return false end)
///--- ---\\\

///--- Find Owner Functions ---\\\
hook.Add("PlayerSpawnedRagdoll",    "TKPP", function(ply, mdl, ent) PP:SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedProp",       "TKPP", function(ply, mdl, ent) PP:SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedEffect",     "TKPP", function(ply, mdl, ent) PP:SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedVehicle",    "TKPP", function(ply, ent)      PP:SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedNPC",        "TKPP", function(ply, ent)      PP:SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedSENT",       "TKPP", function(ply, ent)      PP:SetOwner(ply, ent) end)


hook.Add("Initialize", "TKPP", function()
    if cleanup then
        local CleanUpOld = cleanup.Add
        function cleanup.Add(ply, typ, ent)
            PP:SetOwner(ply, ent)
            return CleanUpOld(ply, typ, ent)
        end
    end

    if _R.Player.AddCount then
        local AddCountOld = _R.Player.AddCount
        function _R.Player:AddCount(typ, ent)
            PP:SetOwner(self, ent)
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
                    PP:SetOwner(UndoPlayer, v)
                end
            end
            Undo = {}
            UndoPlayer = nil
            
            FinishOld(...)
        end
    end
end)

hook.Add("EntitySpawned", "TKPP", function(ent)
    timer.Simple(0.01, function()
        if not IsValid(ent) then return end
        local owner, uid = PP:GetOwner(ent)
        if owner and uid then return end
        
        local Parent = ent:GetParent()
        if IsValid(Parent) then
            local owner, uid = PP:GetOwner(Parent)
            if uid then
                PP:SetOwner(owner, ent, uid)
                return
            end
        end
        
        for k,v in pairs(constraint.GetAllConstrainedEntities(ent)) do
            local owner, uid = PP:GetOwner(v)
            if not uid then continue end
            PP:SetOwner(owner, ent, uid)
            return
        end
    end)
end)
///--- ---\\\

///--- Player Hooks ---\\\
util.AddNetworkString("PPBuddy")
util.AddNetworkString("PPShare")

hook.Add("PlayerInitialSpawn", "TKPP", function(ply)
    local uid = ply:UID()
    timer.Destroy(uid.." cleanup")

    if PP.BuddyTable[uid] then
        net.Start("PPBuddy")
            net.WriteTable(PP.BuddyTable[uid])
        net.Send(ply)
    end

    if PP.EntityTrace[uid] then
        local shared = {}
        for k,v in pairs(PP.EntityTrace[uid]) do
            if not PP.ShareTable[k] then continue end
            shared[k] = v
        end
        
        if table.Count(shared) == 0 then return end
        
        timer.Simple(5, function()
            net.Start("PPShare")
                net.WriteTable(shared)
            net.Send(ply)
        end)
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
    if not IsValid(ply) then return end
    local uid, name = ply:UID(), ply:Name()
    
    timer.Create(uid.." cleanup", TK.PP.Settings.CleanUp.Delay, 1, function()
        PP:CleanUpUID(uid)
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
CPPI = CPPI or {}

function CPPI:GetNameFromUID(uid)
    if not uid then return nil end
    local ply = PP:GetByUniqueID(tostring(uid))
    if not IsValid(ply) then return nil end
    return string.sub(ply:Name(), 1, 31)
end

function _R.Player:CPPIGetFriends()
    local TrustedPlayers = {}
    local uid = self:UID()
    for k,v in pairs(player.GetAll()) do
        if not PP:IsBuddy(uid, v, "CPPI") then continue end
        table.insert(TrustedPlayers, v)
    end
    return TrustedPlayers
end

function _R.Entity:CPPIGetOwner()
    return PP:GetOwner(self)
end


function _R.Entity:CPPISetOwner(ply)
    PP:SetOwner(ply, self)
    return true
end

function _R.Entity:CPPISetOwnerUID(uid)
    PP:SetOwner(PP:GetByUniqueID(uid), self, uid)
    return true
end

function _R.Entity:CPPICanTool(ply, toolmode)
    if PP:CanToolEnt(ply, toolmode, self) == false then return false end
    return true
end

function _R.Entity:CPPICanPhysgun(ply)
    if PP:CanPhysGun(ply, self) == false then return false end
    return true
end

function _R.Entity:CPPICanPickup(ply)
    if PP:CanGravGun(ply, self) == false then return false end
    return true
end

function _R.Entity:CPPICanPunt(ply)
    if PP:CanGravGun(ply, self) == false then return false end
    return true
end

function _R.Entity:CPPICanUse(ply)
    if PP:CanUseEnt(ply, self) == false then return false end
    return true
end

hook.Add("Initialize", "CPPIInit", function()
    function GAMEMODE:CPPIAssignOwnership(ply, ent)
    end
    function GAMEMODE:CPPIFriendsChanged(ply, tab)
    end
end)
///--- ---\\\

///--- Player Death Blame ---\\\
hook.Add("EntityTakeDamage", "TKPP", function(ent, dmg)
    if not ent:IsPlayer() then return end
    local inf = dmg:GetInflictor()
    if not IsValid(inf) then return end
    dmg:SetAttacker(PP:GetOwner(inf))
end)