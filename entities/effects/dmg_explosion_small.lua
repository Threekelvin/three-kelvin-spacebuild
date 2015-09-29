local ExpMat = Material("sprites/splodesprite")

function EFFECT:Init(data)
    self.Lifetime = CurTime() + 1
    self.origin = data:GetOrigin()
    self.emitter = ParticleEmitter(self.origin)

    for i = 0,  25 do
        local particle = self.emitter:Add("particles/smokey", self.origin)

        if particle then
            particle:SetVelocity(VectorRand() * math.Rand(50, 100))
            particle:SetLifeTime(0)
            particle:SetDieTime(math.Rand(1, 2))
            particle:SetStartAlpha(math.Rand(200, 255))
            particle:SetEndAlpha(0)
            particle:SetStartSize(75)
            particle:SetEndSize(125)
            particle:SetRoll(math.Rand(0, 360))
            particle:SetRollDelta(math.Rand(-0.2, 0.2))
            particle:SetColor(40, 40, 40)
        end

        local particle1 = self.emitter:Add("particles/flamelet" .. math.random(1, 5), self.origin)

        if particle1 then
            particle1:SetVelocity(VectorRand() * math.Rand(25, 75))
            particle1:SetLifeTime(0)
            particle1:SetDieTime(0.5)
            particle1:SetStartAlpha(math.Rand(200, 255))
            particle1:SetEndAlpha(0)
            particle1:SetStartSize(75)
            particle1:SetEndSize(25)
            particle1:SetRoll(math.Rand(0, 360))
            particle1:SetRollDelta(math.Rand(-10, 10))
            particle1:SetColor(255, 255, 255)
        end
    end

    self.emitter:Finish()
    self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
    self:SetPos(self.origin)
end

function EFFECT:Think()
    return self.Lifetime > CurTime()
end

function EFFECT:Render()
local Fraction = self.Lifetime - CurTime()
Fraction = math.Clamp(Fraction, 0, 1)
self:SetColor(255, 255, 255, 100 * Fraction)
self:SetModelScale(100 * (1 - Fraction), 0)
render.MaterialOverride(ExpMat)
self:DrawModel()
render.MaterialOverride(nil)
end
