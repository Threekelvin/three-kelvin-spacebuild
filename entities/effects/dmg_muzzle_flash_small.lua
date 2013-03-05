
function EFFECT:Init(data)
 	self.origin     = data:GetOrigin()
	self.dir  = data:GetNormal()
    
	local emitter = ParticleEmitter(self.origin)
		for i = 0, 4 do
			local particle = emitter:Add("particles/flamelet"..math.random(1, 5), self.origin + (self.dir * 30 * i))
			if particle then
				particle:SetVelocity(self.dir * 60 * i)
				particle:SetLifeTime(0)
				particle:SetDieTime(0.2)
				particle:SetStartAlpha(math.Rand(200, 255))
				particle:SetEndAlpha(0)
				particle:SetStartSize(50 - 5 * i)
				particle:SetEndSize(0)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-40, 40))
				particle:SetColor(Color(255,255,255,255))
			end
		end
		
		for i = 0, 2 do
			local particle = emitter:Add("particles/smokey", self.origin + self.dir * math.Rand(10, 40))
			if particle then
				particle:SetVelocity(VectorRand() * 20 + self.origin * math.Rand(60, 100))
				particle:SetLifeTime(0)
				particle:SetDieTime(math.Rand(1, 3))
				particle:SetStartAlpha(math.Rand(200, 255))
				particle:SetEndAlpha(0)
				particle:SetStartSize(30)
				particle:SetEndSize(40)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-0.2, 0.2))
				particle:SetAirResistance(70) 
 				particle:SetGravity(Vector(0,0,4)) 
				particle:SetColor(Color(255,255,255))
			end
			
		end
	emitter:Finish() 
 end 

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end