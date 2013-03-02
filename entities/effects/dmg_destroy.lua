
function EFFECT:Init(data)
    local ent = data:GetEntity()
    if !IsValid(ent) then return end
    
    local origin = ent:LocalToWorld(ent:OBBCenter())
    local min, max = ent:WorldSpaceAABB()
    
    scale = math.floor(math.sqrt(ent:BoundingRadius())) * 5
    
    sound.Play("ambient/energy/ion_cannon_shot"..math.random(1, 3)..".wav", origin, 75, 100)
    
    local emitter = ParticleEmitter(origin)
        for i = 0, scale do
            local vPos = Vector(math.Rand(min.x, max.x), math.Rand(min.y, max.y), math.Rand(min.z, max.z))
            local vVel = Vector(math.Rand(-150, 150), math.Rand(-150, 150), math.Rand(-150, 150))
            local particle = emitter:Add("particle/smokesprites_00".. TK:OO(math.random(1, 16)), vPos)
            if !particle then continue end
            
            particle:SetVelocity(vVel)
            particle:SetLifeTime(math.Rand(0.1, 1))
            particle:SetDieTime(math.Rand(1, 3))
            particle:SetStartAlpha(math.Rand(200, 255))
            particle:SetEndAlpha(0)
            particle:SetStartSize(scale * 0.25)
            particle:SetEndSize(math.Rand(scale, scale * 1.5))
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(0)
            particle:SetAirResistance(math.Rand(20, 25))
            particle:SetColor(math.random(125, 175),math.random(125, 175),math.random(125, 175))
        end
        
        for i = 0, math.floor(scale / 2) do
            local vPos = Vector(math.Rand(min.x, max.x), math.Rand(min.y, max.y), math.Rand(min.z, max.z))
            local vVel = Vector(math.Rand(-100, 100), math.Rand(-100, 100), math.Rand(-100, 100))
            local particle = emitter:Add("particles/flamelet".. math.random(1,5), vPos)
            if !particle then continue end
            
            particle:SetVelocity(vVel)
            particle:SetLifeTime(math.Rand(0.1, 1))
            particle:SetDieTime(math.Rand(1, 3))
            particle:SetStartAlpha(math.Rand(200, 255))
            particle:SetEndAlpha(0)
            particle:SetStartSize(scale * 0.5)
            particle:SetEndSize(scale)
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(0)
            particle:SetAirResistance(math.Rand(20, 25))
            particle:SetColor(255, 255, 255)
        end
    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()

end