
local PLUGIN = {}
PLUGIN.Name       = "TP"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "TP"
PLUGIN.Level      = 2

if SERVER then
	local SavedLocations = {}
	function PLUGIN.Call(ply, arg)
        if !ply:Alive() then return end
        if #arg == 3 then
            if ply:InVehicle() then ply:ExitVehicle() end
            ply:SetPos(Vector(tonumber(arg[1]), tonumber(arg[2]), tonumber(arg[3])))
            ply:SetVelocity(Vector(0, 0, 0))
        elseif #arg > 0 then
            if string.lower(arg[1]) == "save" then
                if arg[2]  then
                    local uid = ply:GetNWString("UID")
                    SavedLocations[uid] = SavedLocations[uid] || {}
                    SavedLocations[uid][arg[2]] = ply:GetPos()
                    TK.AM:SystemMessage({"Position "..arg[2].." Saved"}, {ply}, 2)
                else
                    TK.AM:SystemMessage({"No Index Entered"}, {ply}, 2)
                end
            elseif arg[1] then
                local uid = ply:GetNWString("UID")
                SavedLocations[uid] = SavedLocations[uid] || {}
                if SavedLocations[uid][arg[1]] then
                    if ply:InVehicle() then ply:ExitVehicle() end
                    ply:SetPos(SavedLocations[uid][arg[1]])
                    ply:SetVelocity(Vector(0, 0, 0))
                else
                    TK.AM:SystemMessage({"No Saved Location Found"}, {ply}, 2)
                end
            else
                TK.AM:SystemMessage({"Input Format Error"}, {ply}, 2)
            end
        else
            if ply:InVehicle() then ply:ExitVehicle() end
            local tr = ply:GetEyeTrace()
            if tr.HitNormal != Vector(0, 0, 0) then
                local check1 = util.QuickTrace(tr.HitPos + tr.HitNormal * Vector(32, 32, 0), Vector(0, 0, 113))
                local check2 = util.QuickTrace(tr.HitPos + tr.HitNormal * Vector(32, 32, 0), Vector(0, 0, -113))
                if !check1.StartSolid && !check2.StartSolid then
                    if check1.Hit && check2.Hit then
                        if check1.HitPos:Distance(check2.HitPos) > 82 then
                            ply:SetPos(check2.HitPos + tr.HitNormal * Vector(32, 32, 0) + Vector(0, 0, 5))
                        else
                            TK.AM:SystemMessage({"No Room To Teleport"}, {ply}, 2)
                            return
                        end
                    elseif check1.Hit then
                        ply:SetPos(check1.HitPos + tr.HitNormal * Vector(32, 32, 0) - Vector(0, 0, 77))
                    elseif check2.Hit then
                        ply:SetPos(check2.HitPos + tr.HitNormal * Vector(32, 32, 0) + Vector(0, 0, 5))
                    else
                        ply:SetPos(tr.HitPos + tr.HitNormal * Vector(32, 32, 0) - Vector(0, 0, 36))
                    end
                end
            else
                ply:SetPos(tr.HitPos + tr.HitNormal * Vector(32, 32, 0) - Vector(0, 0, 36))
            end
            ply:SetVelocity(Vector(0, 0, 0))
        end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)