PLUGIN.Name = "Slap"
PLUGIN.Prefix = "!"
PLUGIN.Command = "Slap"
PLUGIN.Level = 4

if SERVER then
    function PLUGIN.Call(ply, arg)
        local dmg = tonumber(arg[#arg])

        if dmg then
            arg[#arg] = nil
        else
            dmg = 0
        end

        local count, targets = TK.AM:FindTargets(ply, arg)

        if #arg == 0 then
            if !ply:Alive() then return end
            ply:EmitSound("physics/flesh/flesh_strider_impact_bullet" .. math.random(1, 3) .. ".wav")
            ply:ViewPunch(Angle(0, -10, 0))

            if dmg == 0 then
                TK.AM:SystemMessage({ply,  " Has Slapped ",  ply})
            else
                ply:TakeDamage(dmg, ply, ply)
                TK.AM:SystemMessage({ply,  " Has Slapped ",  ply,  " With " .. dmg .. " Damage"})
            end
        elseif count == 0 then
            TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
        else
            local msgdata = {ply,  " Has Slapped "}

            for k, v in pairs(targets) do
                if v:Alive() then
                    v:EmitSound("physics/flesh/flesh_strider_impact_bullet" .. math.random(1, 3) .. ".wav")
                    v:ViewPunch(Angle(0, -10, 0))
                    v:TakeDamage(dmg, ply, ply)
                    table.insert(msgdata, v)
                    table.insert(msgdata, ", ")
                end
            end

            if #msgdata == 3 then return end

            if dmg ~= 0 then
                msgdata[#msgdata] = " With " .. dmg .. " Damage"
            else
                msgdata[#msgdata] = nil
            end

            TK.AM:SystemMessage(msgdata)
        end
    end
end
