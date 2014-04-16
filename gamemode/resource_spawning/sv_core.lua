
hook.Add("Tick", "TK_Resource_Spawning", function()
    for k,v in pairs(TK.Settings.AsteroidFields) do
        if CurTime() > v.NextSpawn and table.Count(v.Ents) < 20 then
            local pos = Vector(math.random(0, 5000),0,0)
            pos:Rotate(Angle(math.random(0, 360), math.random(0, 360), 0))
            
            local rand = v.Pos + pos
            local space = TK:FindInSphere(rand, 1000)
            local CanSpawn = true
            for k2,v2 in pairs(space) do
                if IsValid(v2) and IsValid(v2:GetPhysicsObject()) then
                    CanSpawn = false
                    break
                end
            end
            
            if CanSpawn then
                local ent = ents.Create("tk_roid")
                ent:SetPos(rand)
                ent:SetAngles(Angle(math.random(0, 360), math.random(0, 360), math.random(0, 360)))
                ent:Spawn()
                ent.GetField = function()
                    return v.Ents or {}
                end
                ent:CallOnRemove("UpdateList", function()
                    v.Ents[ent:EntIndex()] = nil
                end)
                
                v.Ents[ent:EntIndex()] = ent
                v.NextSpawn = CurTime() + 30 * (table.Count(v.Ents)/20) + 5
            else
                v.NextSpawn = CurTime() + 1
            end
        end
    end
    
    for k,v in pairs(TK.Settings.TiberiumFields) do
        if CurTime() < v.NextSpawn or table.Count(v.Ents) >= 10 then continue end
        local pos = Vector(math.random(0, 1100),0,0)
        pos:Rotate(Angle(0,math.random(0, 360),0))
        
        local rand = v.Pos + pos + Vector(0,0,260)
        local trace =  util.QuickTrace(rand, Vector(0,0,-520))
        if !trace.HitWorld then continue end
        
        local CanSpawn = true
        for k2,v2 in pairs(v.Ents) do
            if v2:GetPos():Distance(trace.HitPos) < 400 then
                CanSpawn = false
                break
            end
        end
        
        if CanSpawn then
            local ent = ents.Create("tk_tib_crystal")
            ent:SetPos(trace.HitPos)
            ent:SetAngles(trace.HitNormal:Angle() + Angle(90,0,0))
            ent:Spawn()
            ent.GetField = function()
                return v.Ents or {}
            end
            ent:CallOnRemove("UpdateList", function()
                v.Ents[ent:EntIndex()] = nil
            end)
            
            v.Ents[ent:EntIndex()] = ent
            v.NextSpawn = CurTime() + 90 * (table.Count(v.Ents)/10) + 5
        else
            v.NextSpawn = CurTime() + 1
        end
    end
end)