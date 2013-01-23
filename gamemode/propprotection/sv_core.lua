
local PP = {
	BuddyTable = {},
	ShareTable = {},
	EntityRecord = {}
}

///--- Functions ---\\\
function PP.GetByUniqueID(uid)
	for k,v in pairs(player.GetAll()) do
		if v:GetNWString("UID", "") == uid then
			return v
		end
	end
	return false
end

function PP.GetOwner(ent)
	if !IsValid(ent) then return nil, nil end
	local uid = ent:GetNWString("UID", false)
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

function PP.SetOwner(ply, ent, uid)
	if !IsValid(ent) then return false end
	local eid, curuid = ent:EntIndex(), ent:GetNWString("UID", "none")
	
	if IsValid(ply) && ply:IsPlayer() then
		uid = ply:GetNWString("UID")
		if curuid != uid then
			if PP.BlackList(ent) then return false end
			if gamemode.Call("CPPIAssignOwnership", ply, ent) != nil then return false end
			
			ent:SetNWString("UID", uid)
			PP.EntityRecord[uid] = PP.EntityRecord[uid] || {}
			PP.EntityRecord[uid][eid] = ent
			
			if PP.EntityRecord[curuid] then
				PP.EntityRecord[curuid][eid] = nil
			end
		end
	elseif uid then
		if curuid != uid then
			if PP.BlackList(ent) then return false end
			if gamemode.Call("CPPIAssignOwnership", NullEntity(), ent) != nil then return false end
			
			ent:SetNWString("UID", uid)
			PP.EntityRecord[uid] = PP.EntityRecord[uid] || {}
			PP.EntityRecord[uid][eid] = ent
			
			if PP.EntityRecord[curuid] then
				PP.EntityRecord[curuid][eid] = nil
			end
		end
	else
		ent:Remove()
		return false
	end
	
	return true
end

function PP.UpdateBuddy(ply, taruid, typ, val)
	if !IsValid(ply) || !ply:IsPlayer() || !taruid || !typ then return false end
	local uid = ply:GetNWString("UID")
	PP.BuddyTable[uid][taruid] = PP.BuddyTable[uid][taruid] || {}
	PP.BuddyTable[uid][taruid][typ] = val
	if typ == "CPPI" then
		local Table = {}
		for k,v in pairs(PP.BuddyTable[uid]) do
			if v.CPPI && v.CPPI == 1 then
				local friend = PP.GetByUniqueID(k)
				if IsValid(friend) then
					table.insert(Table, friend)
				end
			end
		end
		gamemode.Call("CPPIFriendsChanged", ply, Table)
	end
end

function PP.UpdateShare(ent, ply, typ, val)
	if !IsValid(ent) || !IsValid(ply) || !ply:IsPlayer() then return false end
	local owner, id = PP.GetOwner(ent)
	local eid = ent:EntIndex()
	if ply == owner then
		PP.ShareTable[eid] = PP.ShareTable[eid] || {}
		PP.ShareTable[eid][typ] = val
		return true
	end
	return false
end

function PP.CanOverride(ply, method, typ, tar)
	if IsValid(tar) && tar:IsPlayer() then 
		if !ply:CanRunOn(tar) then return false end
	end
	
	if ply:IsSuperAdmin() then
		return TK.PP.Settings[method][typ].SuperAdmin
	elseif ply:IsAdmin() then
		return TK.PP.Settings[method][typ].Admin
	elseif ply:IsModerator() then
		return TK.PP.Settings[method][typ].Moderator
	else
		return TK.PP.Settings[method][typ].User
	end
end

function PP.IsBuddy(uid, tar, method)
	if !uid || !IsValid(tar) || !method then return false end	
	taruid = tar:GetNWString("UID")
	if PP.BuddyTable[uid] && PP.BuddyTable[uid][taruid] then
		if PP.BuddyTable[uid][taruid][method] then return true end
	end
	return false
end

function PP.IsShared(ent, method)
	if !IsValid(ent) || !method then return false end
	local eid = ent:EntIndex()
	if PP.ShareTable[eid] then
		if PP.ShareTable[eid][method] then return true end
	end
	return false
end

function PP.CheckConstraints(ply, ent, method)
	local con = constraint.GetAllConstrainedEntities(ent)
	for k,v in pairs(con) do
		local owner, uid = PP.GetOwner(v)
		if ply != owner then
			if !PP.CanOverride(ply, method, "Prop", owner) then
				if !PP.IsBuddy(uid, ply, method) then
					if !PP.IsShared(v, method) then
						return false
					end
				end
			end
		end
	end
	return true
end

function PP.CleanUp(ply, cmd, arg)
	if ply:HasAccess(3) then
		if !arg[1] then
			local uid = ply:GetNWString("UID")
			PP.EntityRecord[uid] = PP.EntityRecord[uid] || {}
			for k,v in pairs(PP.EntityRecord[uid]) do
				if IsValid(v) && !table.HasValue(ply:GetWeapons(), v) && !table.HasValue(TK.PP.CleanupBlackList, v:GetClass()) then
					SafeRemoveEntity(v)
					PP.EntityRecord[uid][k] = nil
				end
			end
			TK.AM:SystemMessage({"Your Props Have Been Cleaned Up"}, {ply})
		elseif arg[1] == "DCP" then
			for k,v in pairs(PP.EntityRecord) do
				if !PP.GetByUniqueID(k) then
					for j,b in pairs(v) do
						if IsValid(b) then
							SafeRemoveEntity(b)
							PP.EntityRecord[k][j] = nil
						end
					end
				end
			end
			TK.AM:SystemMessage({ply, " Has Cleaned Up Disconnected User Props"})
		else
			local uid = arg[1]
			local tar = PP.GetByUniqueID(uid)
			if IsValid(tar) then
				if ply:CanRunOn(tar) then
					PP.EntityRecord[uid] = PP.EntityRecord[uid] || {}
					for k,v in pairs(PP.EntityRecord[uid]) do
						if IsValid(v) && !table.HasValue(tar:GetWeapons(), v) && !table.HasValue(TK.PP.CleanupBlackList, v:GetClass()) then
							SafeRemoveEntity(v)
							PP.EntityRecord[uid][k] = nil
						end
					end
					TK.AM:SystemMessage({ply, " Has Cleaned Up ", tar,"'s  Props"})
				end
			end
		end
	else
		local uid = ply:GetNWString("UID")
		PP.EntityRecord[uid] = PP.EntityRecord[uid] || {}
		for k,v in pairs(PP.EntityRecord[uid]) do
			if IsValid(v) && !table.HasValue(ply:GetWeapons(), v) && !table.HasValue(TK.PP.CleanupBlackList, v:GetClass()) then
				SafeRemoveEntity(v)
				PP.EntityRecord[uid][k] = nil
			end
		end
		TK.AM:SystemMessage({"Your Props Have Been Cleaned Up"}, {ply})
	end
end
///--- ---\\\

///--- Console Commands ---\\\
concommand.Add("pp_updatebuddy", function(ply, cmd, arg)
	local taruid, setting, value = arg[1], arg[2], tobool(arg[3])
	PP.UpdateBuddy(ply, taruid, setting, value)
end)

concommand.Add("pp_updateshare", function(ply, cmd, arg)
	local ent, setting, value = Entity(tonumber(arg[1])), arg[2], tobool(arg[3])
	PP.UpdateShare(ent, ply, setting, value)
end)

concommand.Add("pp_cleanup", PP.CleanUp)
///--- ---\\\

///--- Can Do Stuff Hooks ---\\\
function PP.CanToolEnt(ply, toolmode, ent)
	if !IsValid(ent) then return end
	if ent:IsPlayer() then return false end
	
	local owner, uid = PP.GetOwner(ent)
	if IsValid(owner) then
		if toolmode == "adv_duplicator" || toolmode == "duplicator" || toolmode == "advdupe2" then
			if !PP.CheckConstraints(ply, ent, "Duplicator") then return false end
			
			if ply == owner then return end
			if PP.CanOverride(ply, "Duplicator", "Prop", owner) then return end
			if PP.IsBuddy(uid, ply, "Duplicator") then return end
			if PP.IsShared(ent, "Duplicator") then return end
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
			if PP.CanOverride(ply, "Duplicator", "World") then return end
		else
			if PP.CanOverride(ply, "Tool Gun", "World") then return end
		end
	end
	return false
end

function PP.CanTool(ply, tr, toolmode)
	if !tr.HitNonWorld || !IsValid(tr.Entity) then return end

	local ent = tr.Entity
	if ent:IsPlayer() then return false end

	local owner, uid = PP.GetOwner(ent)
	if IsValid(owner) then
		if toolmode == "adv_duplicator" || toolmode == "duplicator" || toolmode == "advdupe2" then
			if !PP.CheckConstraints(ply, ent, "Duplicator") then return false end
			
			if ply == owner then return end
			if PP.CanOverride(ply, "Duplicator", "Prop", owner) then return end
			if PP.IsBuddy(uid, ply, "Duplicator") then return end
			if PP.IsShared(ent, "Duplicator") then return end
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
			if PP.CanOverride(ply, "Duplicator", "World") then return end
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
		if PP.CanOverride(ply, "Gravity Gun", "Prop", owner) then return end
		if PP.IsBuddy(uid, ply, "Gravity Gun") then return end
		if PP.IsShared(ent, "Gravity Gun") then return end
	else
		if PP.CanOverride(ply, "Gravity Gun", "World") then return end
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

hook.Add("PlayerSpawnProp", "PP_PSP", function(ply, mdl)
	if table.HasValue(TK.PP.PropBlackList, mdl) then
		return false
	end
end)

hook.Add("CanTool", 			    "PP_CT",    PP.CanTool)
hook.Add("CanProperty",             "PP_CP",    PP.CanToolEnt)
hook.Add("GravGunPunt", 		    "PP_GGP",   PP.CanGravGun)
hook.Add("GravGunPickupAllowed", 	"PP_GGPA",  PP.CanGravGun)
hook.Add("PhysgunPickup", 		    "PP_PP",    PP.CanPhysGun)
hook.Add("PhysgunDrop",             "PP_PD",    PP.CanPhysGun)
hook.Add("CanPlayerUnfreeze", 		"PP_CPU",   PP.CanPhysGun)
hook.Add("OnPhysgunReload",         "PP_OPR",   PP.CanPhysGunReload)
hook.Add("CanPlayerEnterVehicle",   "PP_CPEV",  PP.CanUse)
hook.Add("PlayerUse",				"PP_PU",    PP.CanUse)
hook.Add("CanDrive",                "PP_CD",    function() return false end)
///--- ---\\\

///--- Find Owner Functions ---\\\
hook.Add("PlayerSpawnedRagdoll", 	"PP_PSR",    function(ply, mdl, ent) PP.SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedProp", 		"PP_PSP",    function(ply, mdl, ent) PP.SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedEffect", 	"PP_PSE",    function(ply, mdl, ent) PP.SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedVehicle", 	"PP_PSV",    function(ply, ent)      PP.SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedNPC", 		"PP_PSNPC",  function(ply, ent)	   	 PP.SetOwner(ply, ent) end)
hook.Add("PlayerSpawnedSENT", 		"PP_PSSENT", function(ply, ent)      PP.SetOwner(ply, ent) end)

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

hook.Add("EntitySpawned", "PP_OEC", function(ent)
    timer.Simple(0.1, function()
        local owner, id = PP.GetOwner(ent)
        if !owner && !id then
            local Parent = ent:GetParent()
            if IsValid(Parent) then
                local owner, id = PP.GetOwner(Parent)
                if id then 
                    PP.SetOwner(owner, ent, id)
                    return
                end
            end
            
            for k,v in pairs(constraint.GetAllConstrainedEntities(ent) || {}) do
                local owner, id = PP.GetOwner(v)
                if id then 
                    PP.SetOwner(owner, ent, id)
                    break
                end
            end
        end
    end)
end)
///--- ---\\\

///--- Player Hooks ---\\\
hook.Add("PlayerAuthed", "TK_SUID", function(ply, SteamID, UniqueID) 
	ply:SetNWString("UID", tostring(UniqueID)) 
end)

util.AddNetworkString("PPBuddy")
util.AddNetworkString("PPShare")

hook.Add("PlayerInitialSpawn", "TK_ATBL", function(ply)
	local uid = tostring(ply:UniqueID())
	PP.BuddyTable[uid] = PP.BuddyTable[uid] || {}
	PP.EntityRecord[uid] = PP.EntityRecord[uid] || {}
	timer.Remove(uid.." cleanup")
	
	local STable = {}
	for k,v in pairs(PP.ShareTable) do
		if PP.GetOwner(Entity(k)) == ply then
			STable[k] = v
		end
	end
    
    net.Start("PPBuddy")
        net.WriteTable(PP.BuddyTable[uid])
    net.Send(ply)
    
    net.Start("PPShare")
        net.WriteTable(STable)
    net.Send(ply)
end)

hook.Add("ShowSpare1", "PPMenu1", function(ply)
	umsg.Start("PP_Menu1", ply)
	umsg.End()
end)

hook.Add("ShowSpare2", "PPMenu2", function(ply)
	umsg.Start("PP_Menu2", ply)
	umsg.End()
end)

hook.Add("PlayerDisconnected", "TK_PD", function(ply)
    if !IsValid(ply) then return end
	local uid, name = ply:GetNWString("UID"), ply:Name()
    
	timer.Create(uid.." cleanup", TK.PP.Settings.CleanUp.Delay, 1, function()
		TK.AM:SystemMessage({name.."'s Props Have Been Cleaned Up"})
		if PP.EntityRecord[uid] then
			for k,v in pairs(PP.EntityRecord[uid]) do
				if IsValid(v) then
					v:Remove()
				end
				PP.EntityRecord[uid] = nil
			end
		end
	end)
end)
///--- ---\\\

///--- Remove Entities ---\\\
hook.Add("EntityRemoved", "PP_ER", function(ent)
	local owner, id = PP.GetOwner(ent)
	local eid = ent:EntIndex()
	if PP.EntityRecord[id] then
		PP.EntityRecord[id][eid] = nil
	end
	
	if PP.ShareTable[eid] then
		PP.ShareTable[eid] = nil
	end
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
	local uid = self:GetNWString("UID")
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

hook.Add("Initialize", "CPPIInitGM", function()
	function GAMEMODE:CPPIAssignOwnership(ply, ent)
	end
	function GAMEMODE:CPPIFriendsChanged(ply, tab)
	end
end)
///--- ---\\\