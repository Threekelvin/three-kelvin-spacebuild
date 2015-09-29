include("shared.lua")
local ShieldMat = Material("models/props_combine/combine_fenceglow")

local function ShieldRender(ent)
    if ent.Draw then
        ent:Draw()
    else
        ent:DrawModel()
    end

    ent:SetModelScale(1.01, 0)
    render.MaterialOverride(ShieldMat)
    ent:DrawModel()
    ent:SetModelScale(1, 0)
    render.MaterialOverride(nil)
end

net.Receive("TKCore", function()
    local ent, isHull = net.ReadEntity(), tobool(net.ReadBit())
    if not IsValid(ent) then return end

    if isHull then
        ent.RenderOverride = ShieldRender
    else
        ent.RenderOverride = nil
    end
end)
