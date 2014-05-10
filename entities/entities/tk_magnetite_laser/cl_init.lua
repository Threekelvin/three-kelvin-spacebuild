include('shared.lua')

local Mats = {}

Mats.BlueLaser = Material("sprites/bluelaser1")
Mats.BlueGlow = CreateMaterial("blueglow1", "UnlitGeneric", {
    ["$basetexture"] = "sprites/blueglow1",
    ["$vertexcolor"] = 1,
    ["$vertexalpha"] = 1,
    ["$additive"] = 1
})

Mats.RedLaser = Material("cable/redlaser")
Mats.RedGlow = CreateMaterial("redglow1", "UnlitGeneric", {
    ["$basetexture"] = "sprites/redglow1",
    ["$vertexcolor"] = 1,
    ["$vertexalpha"] = 1,
    ["$additive"] = 1
})

function ENT:Initialize()
    self.range = 0
    self.rmin, self.rmax = self:GetRenderBounds()
end

function ENT:Draw()
    self.BaseClass.Draw(self)
    
    if not self:GetActive() then return end
    local trace = util.QuickTrace(self:LocalToWorld(Vector(0,0,32)), self:GetUp() * (self.range + 32), self)
    
    if IsValid(trace.Entity) and trace.Entity:GetClass() == "tk_magnetite_ore" then
        render.SetMaterial(Mats.BlueLaser)
        render.DrawBeam(self:LocalToWorld(Vector(0,0,32)), trace.HitPos, 20, 0, 1, Color(255,255,255,255))
        render.DrawBeam(trace.HitPos, self:LocalToWorld(Vector(0,0,32)), 20, 0, 1, Color(255,255,255,255))
        render.SetMaterial(Mats.BlueGlow)
        render.DrawSprite(self:LocalToWorld(Vector(0,0,32)), 25, 25, Color(255,255,255,255))
    
        render.StartBeam(14)
            render.AddBeam(self:LocalToWorld(Vector(0,0,32)), 40, CurTime(), Color(255,255,255,255))
            
            local inc = self:LocalToWorld(Vector(0,0,32)):Distance(trace.HitPos) / 12
            local dir = self:GetUp()
            local i
            for i = 1, 12 do
                local point = (self:LocalToWorld(Vector(0,0,32)) + dir * (i * inc)) + VectorRand() * math.random(1, self.range * 0.02)
                local tcoord = CurTime() + ( 1 / 12 ) * i
                render.AddBeam(point, 40, tcoord, Color(255,255,255,255))
            end

            render.AddBeam(trace.HitPos, 40, CurTime() + 1, Color(255,255,255,255))
        render.EndBeam()
        render.DrawSprite(self:LocalToWorld(Vector(0,0,32)), 50, 50, Color(255,255,255,255))
        render.DrawSprite(trace.HitPos, 25, 25, Color(255,255,255,255))
        render.DrawSprite(trace.HitPos, 50, 50, Color(255,255,255,255))
    else
        render.SetMaterial(Mats.RedLaser)
        render.DrawBeam(self:LocalToWorld(Vector(0,0,32)), trace.HitPos, 20, 0, 1, Color(255,255,255,255))
        render.DrawBeam(trace.HitPos, self:LocalToWorld(Vector(0,0,32)), 20, 0, 1, Color(255,255,255,255))
        render.SetMaterial(Mats.RedGlow)
        render.DrawSprite(self:LocalToWorld(Vector(0,0,32)), 25, 25, Color(255,255,255,255))
    
        if IsValid(trace.Entity) and trace.Entity:GetClass() == "tk_magnetite" then
            render.StartBeam(14)
                render.AddBeam(self:LocalToWorld(Vector(0,0,32)), 40, CurTime(), Color(255,255,255,255))
                
                local inc = self:LocalToWorld(Vector(0,0,32)):Distance(trace.HitPos) / 12
                local dir = self:GetUp()
                local i
                for i = 1, 12 do
                    local point = (self:LocalToWorld(Vector(0,0,32)) + dir * (i * inc)) + VectorRand() * math.random(1, self.range * 0.02)
                    local tcoord = CurTime() + ( 1 / 12 ) * i
                    render.AddBeam(point, 40, tcoord, Color(255,255,255,255))
                end

                render.AddBeam(trace.HitPos, 40, CurTime() + 1, Color(255,255,255,255))
            render.EndBeam()
            render.DrawSprite(self:LocalToWorld(Vector(0,0,32)), 50, 50, Color(255,255,255,255))
            render.DrawSprite(trace.HitPos, 25, 25, Color(255,255,255,255))
            render.DrawSprite(trace.HitPos, 50, 50, Color(255,255,255,255))
        end
    end
end

function ENT:Think()
    if self.range == self:GetNWInt("range", 0) then return end
    self.range = self:GetNWInt("range", 0)
    
    self:SetRenderBounds(self.rmin, self.rmax + Vector(0, 0, self.range))
end