

PLUGIN.Name       = "Orbital Friendship Cannon"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "OFC"
PLUGIN.Level      = 6

if SERVER then
    function PLUGIN.Call(ply, arg)
        local tr
        local tar
        local count, targets = TK.AM:TargetPlayer(ply, arg[1])
        
        if #arg == 0 && !IsValid(ply) then
            return
        elseif #arg == 0 then
            tr = ply:GetEyeTrace()
            ply:EmitSound(Sound("npc/attack_helicopter/aheli_megabomb_siren1.wav"))
        elseif count == 0 then
            TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
            return
        elseif count > 1 then
            TK.AM:SystemMessage({"Multiple Target Found"}, {ply}, 2)
            return
        else
            tar = targets[1]
            if IsValid(ply) then
                ply:EmitSound(Sound("npc/attack_helicopter/aheli_megabomb_siren1.wav"))
            end
        end
        
        
        timer.Simple(5, function()
            local HitPos = Vector(0,0,0)
            
            if IsValid(tar) then
                HitPos = tar:GetPos()
            elseif tr then
                HitPos = tr.HitPos
            else
                return
            end
            
            local trace = util.QuickTrace(HitPos + Vector(0,0,50000), Vector(0,0,-50000))
            
            local glow = ents.Create("env_lightglow")
            glow:SetKeyValue("rendercolor", "255 255 255")
            glow:SetKeyValue("VerticalGlowSize", "256")
            glow:SetKeyValue("HorizontalGlowSize", "256")
            glow:SetKeyValue("MaxDist", "512")
            glow:SetKeyValue("MinDist", "0")
            glow:SetKeyValue("HDRColorScale", "100")
            glow:SetPos(HitPos + Vector(0,0,64))
            glow:Spawn()

            local targ = ents.Create("info_target")
            targ:SetKeyValue("targetname", tostring(targ))
            targ:SetPos(trace.HitPos - Vector(0,0,100))
            targ:Spawn()
            
            local laser = ents.Create("env_laser")
            laser:SetKeyValue("texture", "rainbeam/rainbow1.vmt")
            laser:SetKeyValue("TextureScroll", "100")
            laser:SetKeyValue("noiseamplitude", "0")
            laser:SetKeyValue("width", "200")
            laser:SetKeyValue("damage", "1000000")
            laser:SetKeyValue("rendercolor", "255 255 255")
            laser:SetKeyValue("renderamt", "255")
            laser:SetKeyValue("dissolvetype", "0")
            laser:SetKeyValue("lasertarget", tostring(targ))
            laser:SetPos(HitPos)
            laser:Spawn()
            laser:Fire("turnon",0)
            
            BroadcastLua("surface.PlaySound('ambient/explosions/explode_6.wav')")
            BroadcastLua("util.ScreenShake(Vector(0,0,0), 5, 5, 6, 100000)")
            
            local effect = EffectData()
            effect:SetOrigin(HitPos + Vector(0,0,64)) 
            util.Effect("ofc_wave", effect)
            
            local radius = 200
            hook.Add("Tick", "OFCThink", function()
                for k, v in pairs(TK:FindInSphere(HitPos, radius)) do
                    if IsValid(v) then
                        if v:IsPlayer() && v:Alive() then
                            v:GodDisable()
                            local dmginfo = DamageInfo()
                            dmginfo:SetDamage(2)
                            dmginfo:SetDamageType(DMG_RADIATION)
                            dmginfo:SetAttacker(laser)
                            dmginfo:SetInflictor(laser)
                            v:TakeDamageInfo(dmginfo)
                        elseif v:IsVehicle() then
                            local p = v:GetDriver()
                            if IsValid(p) then
                                p:ExitVehicle()
                                p:Kill()
                            end                            
                        elseif v:IsNPC() then
                            local dmginfo = DamageInfo()
                            dmginfo:SetDamage(2)
                            dmginfo:SetDamageType(DMG_RADIATION)
                            dmginfo:SetAttacker(laser)
                            dmginfo:SetInflictor(laser)
                            v:TakeDamageInfo(dmginfo)
                        end
                    end
                end
                radius = radius + 10
            end)
            
            timer.Simple(5, function()
                hook.Remove("Tick", "OFCThink")
                laser:Remove()
                glow:Remove()
                targ:Remove()
            end)
        end)
    end
end

