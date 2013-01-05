
local PLUGIN = {}
PLUGIN.Name       = "PlayerResize"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Resize"
PLUGIN.Auto       = {"players", "number"}
PLUGIN.Level      = 2

if SERVER then
	local function Resize(ply, scale)
		local min 		= Vector(-16 * scale, -16 * scale, 0)
		local max 		= Vector(16 * scale,16 * scale, 72 * scale)
		local maxduck	= Vector(16 * scale, 16 * scale, 36 * scale)
		local stepsize  = math.Round(18 * scale)

		ply:SetHull(min , max)
		ply:SetHullDuck(min , maxduck)
		
		ply:SetViewOffset(Vector(0, 0, 68 * scale))
		ply:SetViewOffsetDucked(Vector(0, 0, 32 * scale))
		
		ply:SetStepSize(stepsize)
		ply:SetCollisionBounds(min, max)
		
		ply:SetNWFloat("PLScale" , scale)

		gamemode.Call("PlayerSpawn" , ply)
		
		hook.Add("PlayerSpawn", "SetSpeed", function(ply)
			if !IsValid(ply) then return end
			local scale = ply:GetNWFloat("PLScale", 1)
			ply:SetWalkSpeed(math.ceil(150 * scale) + 100)
			ply:SetRunSpeed(math.ceil(300 * scale) + 200)
		end)

		umsg.Start("ModelResize")
			umsg.Entity(ply)
			umsg.Float(scale)
		umsg.End()
	end
	
	function PLUGIN.Call(ply, arg)
		if ply:HasAccess(PLUGIN.Level) then
			local scale = math.Clamp(tonumber(arg[#arg]) || 1, 0.01, 10)
			arg[#arg] = nil
			local count, targets = TK.AM:FindTargets(ply, arg)
			
			if #arg == 0 then
				Resize(ply, scale)
				TK.AM:SystemMessage({ply, " Resized ", ply})
			elseif count == 0 then
				if ply:HasAccess(3) then
					TK.AM:SystemMessage({"No Targets Found"}, {ply}, 2)
				else
					TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
				end
			else
				if ply:HasAccess(3) then
					local msgdata = {ply, " Resized "}
					for k,v in pairs(targets) do
						Resize(v, scale)
						table.insert(msgdata, v)
						table.insert(msgdata, ", ")
					end
					msgdata[#msgdata] = nil
					TK.AM:SystemMessage(msgdata)
				else
					TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
				end
			end
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
		end
	end
else
	local function SetHitboxScale(ply, scale, updatebones)
		if !IsValid(ply) then return end
		local min 		= Vector(-16 * scale, -16 * scale, 0)
		local max 		= Vector(16 * scale,16 * scale, 72 * scale)
		local maxduck	= Vector(16 * scale, 16 * scale, 36 * scale)
		local stepsize  = math.Round(18 * scale)

		ply:SetModelScale(scale, 0)
		ply:SetRenderBounds(min, max)
			
		ply:SetHull(min , max)
		ply:SetHullDuck(min , maxduck)
		
		ply:SetViewOffset(Vector(0, 0, 68 * scale))
		ply:SetViewOffsetDucked(Vector(0, 0, 32 * scale))

		ply:SetStepSize(stepsize)
		
		if updatebones then ply:SetupBones() end
	end


	hook.Add("Tick", "UpdateScale", function()
		for k,v in pairs(player.GetAll()) do
			local scale = v:GetNWFloat("PLScale", 1)
			v:SetModelScale(scale, 0)
		end
	end)

	usermessage.Hook("ModelResize" , function(msg)
		SetHitboxScale(msg:ReadEntity(), msg:ReadFloat(), true)
	end)
end

TK.AM:RegisterPlugin(PLUGIN)