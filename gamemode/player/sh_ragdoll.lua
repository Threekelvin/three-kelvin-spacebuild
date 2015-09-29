if SERVER then
    util.AddNetworkString("TK_Ragdoll")

    hook.Add("PlayerDeath", "TK_Ragdoll", function(ply)
        local env = ply:GetEnv()
        net.Start("TK_Ragdoll")
        net.WriteEntity(ply)
        net.WriteFloat(env.atmosphere.gravity)
        net.Broadcast()
    end)
else
    net.Receive("TK_Ragdoll", function()
        local ply = net.ReadEntity()
        local grav = net.ReadFloat()

        timer.Simple(0.01, function()
            local rag = ply:GetRagdollEntity()
            local bool = grav > 0.001
            if not IsValid(rag) then return end

            for i = 0,  rag:GetPhysicsObjectCount() do
                local phys = rag:GetPhysicsObjectNum(i)
                if not IsValid(phys) then continue end
                phys:EnableGravity(bool)
                phys:EnableDrag(bool)
                phys:AddVelocity(Vector(math.Rand(-5, 5), math.Rand(-5, 5), math.Rand(-5, 5)))
                rag:SetGravity(grav + 0.001)
            end
        end)
    end)

    hook.Add("CreateClientsideRagdoll", "TK_Ragdoll", function(ent, rag)
        print(ent, rag)
    end)
end
