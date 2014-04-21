
hook.Add("Initialize", "3k_Tib_Damage", function()
    timer.Create("TKTI_Damage", 1, 0, function()
        for _,ply in pairs(player.GetAll()) do
            for k,v in pairs(TK.MapSetup.Resources.tk_tib_crystal) do
                local crystal = table.GetFirstValue(v.Ents)
                if !IsValid(crystal) then continue end
                
                local dist = (v.Pos - ply:GetPos()):LengthSqr()
                if dist > 2250000 then continue end
                
                local dmginfo = DamageInfo()
                dmginfo:SetDamage(math.ceil(25 * (1 - dist / 2250000)))
                dmginfo:SetDamageType(DMG_RADIATION)
                dmginfo:SetAttacker(crystal)
                dmginfo:SetInflictor(crystal)
                ply:TakeDamageInfo(dmginfo)
            end
        end
    end)
end)