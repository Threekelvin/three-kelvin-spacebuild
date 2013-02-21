
local PLUGIN = {}
PLUGIN.Name       = "Bring"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Bring"
PLUGIN.Level      = 2

if SERVER then
    function PLUGIN.Call(ply, arg)
        local count, targets = TK.AM:FindPlayer(arg[1])
        
        if count == 0 then
            TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
        elseif count > 1 then
            TK.AM:SystemMessage({"Multiple Targets Found"}, {ply}, 2)
        else
            local tar = targets[1]
            if ply:CanRunOn(tar) then
                if tar == ply then
                    TK.AM:SystemMessage({"You Can Not Bring Yourself"}, {ply}, 2)
                    return
                end
                
                for I=1, 8 do
                    local RotVec = Vector(40, 0, 36)
                    RotVec:Rotate(Angle(0, (360/8)*I, 0))
                    local check1 = util.QuickTrace(ply:LocalToWorld(RotVec), Vector(0, 0, 113))
                    local check2 = util.QuickTrace(ply:LocalToWorld(RotVec), Vector(0, 0, -113))
                    if !check1.StartSolid && !check2.StartSolid then
                        if check1.Hit && check2.Hit then
                            if check1.HitPos:Distance(check2.HitPos) > 82 then
                                tar:SetPos(check2.HitPos + Vector(0, 0, 5))
                                TK.AM:SystemMessage({ply, " Has Brought ", tar, " To Themself"})
                                return
                            end
                        elseif check1.Hit then
                            tar:SetPos(check1.HitPos - Vector(0, 0, 77))
                            TK.AM:SystemMessage({ply, " Has Brought ", tar, " To Themself"})
                            return
                        elseif check2.Hit then
                            tar:SetPos(check2.HitPos + Vector(0, 0, 5))
                            TK.AM:SystemMessage({ply, " Has Brought ", tar, " To Themself"})
                            return
                        else
                            tar:SetPos(ply:LocalToWorld(RotVec) - Vector(0, 0, 36))
                            TK.AM:SystemMessage({ply, " Has Brought ", tar, " To Themself"})
                            return
                        end
                    end
                end
                tar:SetMoveType(MOVETYPE_NOCLIP)
                tar:SetPos(tar:LocalToWorld((Vector(-40,0,0))))
                TK.AM:SystemMessage({ply, " Has Brought ", tar, " To Themself"})
            else
                TK.AM:SystemMessage({" You Can Not Bring ", tar}, {ply}, 2)
            end
        end
    end
else

end

TK.AM:RegisterPlugin(PLUGIN)