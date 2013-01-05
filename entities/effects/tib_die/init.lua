
function EFFECT:Init(data)
	local pos = data:GetOrigin()

	sound.Play("/ambient/energy/ion_cannon_shot"..math.random(1, 3)..".wav", pos, 75, 100)
	
	local emitter = ParticleEmitter( pos )
		
		for i = 0, 64 do
		
			local vPos = pos + Vector( math.Rand(-25, 25), math.Rand(-25, 25), math.Rand(-25, 25) )
			local vVel = Vector( math.Rand(-100, 100), math.Rand(-100, 100), math.Rand(0, 25) )
			local particle = emitter:Add( "particle/smokesprites_0010", vPos )
			if (particle) then
				particle:SetVelocity( vVel )
				particle:SetLifeTime( math.Rand(0.1, 1) )
				particle:SetDieTime( math.Rand( 0.5, 2 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 15 )
				particle:SetEndSize( math.Rand(30, 60) )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( 0 )
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