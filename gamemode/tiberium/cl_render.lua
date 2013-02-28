
TK.TI = TK.TI || {}

local Status = {}
local Models = {}
local Mat1 = Material("Models/effects/splodearc_sheet")
local Mat2 = Material("models/alyx/emptool_glow")

local function IsStable(entid)
    if Status[entid] == nil then return true end
    return Status[entid]
end

hook.Add("Initialize", "TKTIB", function()
    if usermessage then
        local IncomingMessage = usermessage.IncomingMessage
        function usermessage.IncomingMessage(idx, msg)
            if idx == "TKTib_S" then
                local entid, stable = msg:ReadShort(), msg:ReadBool()
                Status[entid] = stable
                return
            elseif idx == "TKTib_M" then
                local entid, stage = msg:ReadShort(), msg:ReadShort()
                Models[entid] = Models[entid] || {}
                Models[entid].pre = Models[entid].cur
                Models[entid].cur = TK.Settings.Tiberium[stage].model
                Models[entid].grow = true
                Models[entid].offset = nil
                Models[entid].offset_max = nil
                Models[entid].time = SysTime()
                return
            end
            
            IncomingMessage(idx, msg)
        end
    end
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
    
    if !data.origin then
        data.origin = ent:GetPos()
    end
    
    if data.grow then
        if !data.offset then
            data.offset_max = (ent:OBBMaxs() - ent:OBBMins()).z + 20
            data.offset = data.offset_max
        end
        
        if util.IsValidModel(data.pre || "") then
            local progress = data.offset / data.offset_max
            
            ent:SetRenderOrigin(data.origin - Vector(0,0, (data.offset_max - data.offset) / 2))
            ent:SetModel(data.pre)
            
            ent:SetModelScale(1 * progress, 0)
            ent:DrawModel()

            ent:SetModelScale(1.1 * progress, 0)
            render.MaterialOverride(Mat1)
            ent:DrawModel()
            
            ent:SetModel(data.cur)
        end
        
        ent:SetRenderOrigin(data.origin - Vector(0, 0, data.offset))
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
        if !ent.mining || ent.mining != ent:GetCrystal() then
            ent.mining = ent:GetCrystal()
            local crystal = Entity(ent.mining)
            ent:StopParticles()
            if ent.mining == 0 || !IsValid(crystal) then return end
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
            if ent.mining == 0 || !IsValid(crystal) then return end
            
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