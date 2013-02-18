
function EFFECT:Init(data)
	local ent = data:GetEntity()
    if !IsValid(ent) then return end
    
    local origin = ent:LocalToWorld(ent:OBBCenter())
    local min, max = ent:WorldSpaceAABB()
    local radius = ent:BoundingRadius()
    
    scale = math.ceil(math.sqrt(radius)) * 5
    
    sound.Play("ambient/energy/ion_cannon_shot"..math.random(1, 3)..".wav", origin, 75, 100)
	
	local emitter = ParticleEmitter(origin)
		for i = 0, scale do
			local vPos = origin + Vector(math.Rand(min, max), math.Rand(min, max), math.Rand(min, max))
			local vVel = Vector(math.Rand(-150, 150), math.Rand(-150, 150), math.Rand(-150, 150))
			local particle = emitter:Add("particle/smokesprites_00".. TK:OO(math.random(1, 16)), vPos)
			if particle then
				particle:SetVelocity(vVel)
				particle:SetLifeTime(math.Rand(0.1, 1))
				particle:SetDieTime(math.Rand(1, 3))
				particle:SetStartAlpha(math.Rand(200, 255))
				particle:SetEndAlpha(0)
				particle:SetStartSize(25)
				particle:SetEndSize(math.Rand(75, 100))
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(0)
				particle:SetAirResistance(math.Rand(20, 25))
				particle:SetColor(math.random(125, 175),math.random(125, 175),math.random(125, 175))
			end
		end
        
        for i = 0, math.ceil(scale / 2) do
            local vPos = origin + Vector(math.Rand(min, max), math.Rand(min, max), math.Rand(min, max))
			local vVel = Vector(math.Rand(-100, 100), math.Rand(-100, 100), math.Rand(-100, 100))
			local particle = emitter:Add("particles/flamelet"..math.random(1,5), vPos)
			if particle then
				particle:SetVelocity(vVel)
				particle:SetLifeTime(math.Rand(0.1, 1))
				particle:SetDieTime(math.Rand(1, 3))
				particle:SetStartAlpha(math.Rand(200, 255))
				particle:SetEndAlpha(0)
				particle:SetStartSize(50)
				particle:SetEndSize(50)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(0)
				particle:SetAirResistance(math.Rand(20, 25))
				particle:SetColor(255, 255, 255)
			end
        end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()

end