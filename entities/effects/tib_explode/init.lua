
function EFFECT:Init(data)
    self.origin = data:GetOrigin()
    self.scale = 0.5 + data:GetScale()
    self.lifetime = CurTime() + 1
    
    sound.Play("ambient/levels/labs/electric_explosion"..math.random(1, 5)..".wav", self.origin, 100, 100)
    local emitter = ParticleEmitter(self.origin)
        for i = 0, 128 * self.scale do
            local vPos = self.origin + Vector(math.Rand(-25, 25), math.Rand(-25, 25), math.Rand(0, 25))
            local vVel = Vector(math.Rand(-150, 150), math.Rand(-150, 150), math.Rand(0, 200)) * self.scale
            local particle = emitter:Add("particle/smokesprites_0010", vPos)
            if particle then
                particle:SetVelocity(vVel)
                particle:SetLifeTime(math.Rand(0.1, 1))
                particle:SetDieTime(math.Rand(1, 3))
                particle:SetStartAlpha(math.Rand(200, 255))
                particle:SetEndAlpha(0)
                particle:SetStartSize(25)
                particle:SetEndSize(math.Rand(75, 100) )
                particle:SetRoll(math.Rand(0, 360))
                particle:SetRollDelta(0)
                particle:SetAirResistance(math.Rand(20, 25))
                particle:SetColor(0, math.random(125, 175), 0)
            end
        end
    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()

end