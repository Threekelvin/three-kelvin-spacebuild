--/--- GHD ---\\\
function TK:FindInSphere(pos, rad)
    if ents.RealFindInSphere then
        local res = ents.RealFindInSphere(pos, rad)

        for k, v in pairs(res) do
            if not v.SLIsGhost then continue end
            res[k] = nil
        end

        return res
    end

    return ents.FindInSphere(pos, rad)
end

--/--- ---\\\
--/--- Audio Emotes ---\\\
AE = AE or {}

function AE.HasPermission(ply)
    return ply:IsVip()
end
--/--- ---\\\
