
function EFFECT:Init(data)
    local start = data:GetOrigin()
    local em = ParticleEmitter(start)
    for i=1, 512 do
        local part = em:Add("particle/smokesprites_0009", start)
        if part then
            part:SetVelocity(Vector(math.random(-10,10),math.random(-10,10),0):GetNormal() * math.random(1700,2000))
            local rad = math.abs(math.atan2(part:GetVelocity().x,part:GetVelocity().y))
            local angle = (rad/math.pi*1536)
            if(angle < 255 && angle >= 0) then
                part:SetColor(255,angle,0)
            end
            if(angle < 511 && angle >= 255) then
                part:SetColor(511-angle,255,0)
            end   
            if(angle < 767 && angle >= 511) then
                part:SetColor(0,255,angle-511)
            end
            if(angle < 1023 && angle >= 767) then
                part:SetColor(0,1023-angle,255)
            end 
            if(angle < 1279 && angle >= 1023) then
                part:SetColor(angle-1023,0,255)
            end
            if(angle < 1535 && angle >= 1279) then
                part:SetColor(255,0,1535-angle)
            end 
            if(angle > 1535) then
                part:SetColor(255,0,0)
            end

            part:SetDieTime(math.random(5,6))
            part:SetLifeTime(math.random(1,2))
            if (math.Dist(0,0,part:GetVelocity().x,part:GetVelocity().y) >= 1500) then    
                part:SetStartSize((math.Dist(0,0,part:GetVelocity().x,part:GetVelocity().y)-1600)/4)
                part:SetEndSize(math.Dist(0,0,part:GetVelocity().x,part:GetVelocity().y)-1600)
            else
                part:SetStartSize(0)
                part:SetEndSize(0)
            end
            part:SetAirResistance(5)
            part:SetRollDelta(math.random(-2,2))
       
        end
    end  
    
    for i=1,512 do
        local part1 = em:Add("particle/smokesprites_0010", start)
        if part1 then
            part1:SetVelocity(Vector(math.random(-100,100),math.random(-100,100),math.random(-3,3)):GetNormal() * math.random(100,2400))
            part1:SetColor(255,255,255)
            part1:SetDieTime(math.random(5,6))
            part1:SetLifeTime(math.random(0.3,0.5))
            part1:SetStartSize(150 - (math.Dist(0,0,part1:GetVelocity().x,part1:GetVelocity().y))/16)
            part1:SetEndSize(600 - (math.Dist(0,0,part1:GetVelocity().x,part1:GetVelocity().y))/4) 
            part1:SetAirResistance(50)
            part1:SetRollDelta(math.random(-2,2))
        end
        
        local part2 = em:Add("particle/smokesprites_0010", start)
        if part2 then
            part2:SetVelocity(Vector(math.random(-10,10),math.random(-10,10),0):GetNormal() * 2000)
            part2:SetColor(255,255,255)
            part2:SetDieTime(math.random(5,6))
            part2:SetLifeTime(math.random(0.5,1))
            part2:SetStartSize(10)
            part2:SetEndSize(math.random(80,120)) 
            part2:SetAirResistance(math.random(30,31))
            part2:SetRollDelta(math.random(-2,2))
        end
    end 
 
    em:Finish()
end

function EFFECT:Think()   

end

function EFFECT:Render() 

end