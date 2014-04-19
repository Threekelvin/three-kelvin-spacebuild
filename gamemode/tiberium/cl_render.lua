
TK.TI = TK.TI or {}

local net = net

local Status = {}
local Models = {}
local Mat1 = Material("Models/effects/splodearc_sheet")
local Mat2 = Material("models/alyx/emptool_glow")

local function IsStable(entid)
    if Status[entid] == nil then return true end
    return Status[entid]
end

net.Receive("TKTib_S", function() 
    local entid = net.ReadInt(16)
    local data = net.ReadTable()
    
    Status[entid] = data.stable
end)

net.Receive("TKTib_M", function() 
    local entid = net.ReadInt(16)
    local data = net.ReadTable()
    
    Models[entid] = {}
    Models[entid].pre = (TK.TI.Settings[data.stage - 1] or {}).model
    Models[entid].cur = TK.TI.Settings[data.stage].model
    Models[entid].grow = true
    Models[entid].time = SysTime()
    Models[entid].origin = data.pos
end)

hook.Add("EntityRemove", "TKTIB", function(ent)
    local entid = ent:EntIndex()
    Status[entid] = nil
    Models[entid] = nil
end)

function TK.TI:DrawTib(ent)
    local entid = ent:EntIndex()
    local data = Models[entid]
    if !data then return end
    
    ent:SetColor(Color(0, 150 + 20 * math.sin(math.pi * (RealTime() - ent.RandCol)), 0, 255))
    
    if data.grow then
        if !data.offset then
            data.offset_max = (ent:OBBMaxs() - ent:OBBMins()).z + 20
            data.offset = data.offset_max
        end
        
        if util.IsValidModel(data.pre or "") then
            local progress = data.offset / data.offset_max
            
            ent:SetRenderOrigin(data.origin - ent:GetUp() * (data.offset_max - data.offset) * 0.5)
            ent:SetModel(data.pre)
            
            ent:SetModelScale(1 * progress, 0)
            ent:DrawModel()

            ent:SetModelScale(1.1 * progress, 0)
            render.MaterialOverride(Mat1)
            ent:DrawModel()
            
            ent:SetModel(data.cur)
        end
        
        ent:SetRenderOrigin(data.origin - ent:GetUp() * data.offset)
        data.offset = data.offset - 5 * (SysTime() - data.time)
        data.time = SysTime()
        
        if data.offset <= 0 then
            data.grow = false
            ent:SetRenderOrigin(data.origin)
        end
    end
    
    ent:SetModelScale(1, 0)
    render.MaterialOverride(nil)
    ent:DrawModel()

    ent:SetModelScale(1.1, 0)
    if IsStable(entid) then
        render.MaterialOverride(Mat1)
    else
        render.MaterialOverride(Mat2)
    end
    ent:DrawModel()

    render.MaterialOverride(nil)
end

function TK.TI:DrawExtractor(ent)
    if ent:GetActive() then
        if !ent.mining or ent.mining != ent:GetCrystal() then
            ent.mining = ent:GetCrystal()
            local crystal = Entity(ent.mining)
            ent:StopParticles()
            if ent.mining == 0 or !IsValid(crystal) then return end
            ent.stable = IsStable(ent.mining)
            
            local CPoint0 = {
                ["entity"] = crystal,
                ["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
            }
            local CPoint1 = {
                ["entity"] = ent,
                ["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
            }
            
            ent:CreateParticleEffect("medicgun_beam_blue_trail", {CPoint0, CPoint1})
            ent:CreateParticleEffect("medicgun_beam_blue_trail", {CPoint0, CPoint1})
            ent:CreateParticleEffect("medicgun_beam_attrib_overheal", {CPoint0, CPoint1})
            ent:CreateParticleEffect("medicgun_beam_attrib_healing", {CPoint0, CPoint1})
            
            if !ent.stable then
                ent:CreateParticleEffect("medicgun_beam_red_invunglow", {CPoint0, CPoint1})
            end
        else
            local crystal = Entity(ent.mining)
            if ent.mining == 0 or !IsValid(crystal) then return end
            
            local CPoint0 = {
                ["entity"] = crystal,
                ["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
            }
            local CPoint1 = {
                ["entity"] = ent,
                ["attachtype"] = PATTACH_ABSORIGIN_FOLLOW,
            }
            
            if ent.stable != IsStable(ent.mining) then
                ent.stable = IsStable(ent.mining)
                if !ent.stable then
                    ent:CreateParticleEffect("medicgun_beam_red_invunglow", {CPoint0, CPoint1})
                else
                    ent:StopParticles()
                    ent:CreateParticleEffect("medicgun_beam_blue_trail", {CPoint0, CPoint1})
                    ent:CreateParticleEffect("medicgun_beam_blue_trail", {CPoint0, CPoint1})
                    ent:CreateParticleEffect("medicgun_beam_attrib_overheal", {CPoint0, CPoint1})
                    ent:CreateParticleEffect("medicgun_beam_attrib_healing", {CPoint0, CPoint1})
                end
            end
        end
    else
        if ent.mining != 0 then
            ent.mining = 0
            ent.stable = true
            ent:StopParticles()
        end
    end
end