--[[==============================================================================================
Section: Particles
==============================================================================================]]
net.Receive("particlebeam", function()
    local particle = net.ReadString()
    local this = Entity(net.ReadInt(16))
    local ent = Entity(net.ReadInt(16))
    if !IsValid(this) or !IsValid(ent) then return end

    local CP1 = {
        ["entity"] = this,
        ["attachtype"] = PATTACH_ABSORIGIN_FOLLOW
    }

    local CP2 = {
        ["entity"] = ent,
        ["attachtype"] = PATTACH_ABSORIGIN_FOLLOW
    }

    this:CreateParticleEffect(particle, {CP1,  CP2})
end)
