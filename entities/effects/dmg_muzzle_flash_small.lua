
function EFFECT:Init(data)
 	self.origin = data:GetOrigin()
	self.ang = data:GetAngles()
    self.dir = self.ang:Forward()
    
	local emitter = ParticleEmitter(self.origin)
		for i = 0, 3 do
			local particle = emitter:Add("particles/flamelet"..math.random(1, 5), self.origin + (self.dir * 9 * i))
			if particle then
				particle:SetVelocity(self.dir * 36 * i)
				particle:SetLifeTime(0)
				particle:SetDieTime(0.2)
				particle:SetStartAlpha(math.Rand(200, 255))
				particle:SetEndAlpha(0)
				particle:SetStartSize(18 - 3 * i)
				particle:SetEndSize(0)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-40, 40))
				particle:SetColor(255, 255, 255)
			end
		end
	emitter:Finish() 
 end 

function EFFECT:Think( )
	return false
end

function EFFECT:Render()

end