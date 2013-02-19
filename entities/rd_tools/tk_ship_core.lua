
TOOL.Category	= "Ship Parts"
TOOL.Name		= "Ship Core"
TOOL.Limit		= 1
TOOL.Data		= {
	["models/sbep_community/d12airscrubber.mdl"]	= {power = -10},
}

TOOL.ClientConVar["ghd"] = 0

function TOOL:LeftClick(trace)
    if !trace.Hit then return end
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    if !ply:CheckLimit(self.Mode) then return false end
    local ent = ents.Create(self.Mode)
    ent:SetModel(self:SelectModel())
    ent:SetPos(trace.HitPos)
    local angles = trace.HitNormal:Angle() + Angle(90,0,0)
    ent:SetAngles(angles)
    ent:Spawn()
    ent:SetPos(trace.HitPos + trace.HitNormal * ((ent:OBBMaxs().z - ent:OBBMins().z) / 2 - ent:OBBCenter().z))
    
    if self:GetClientNumber("weld", 0) == 1 then
        local hit = trace.Entity
        if hit then
            if hit:IsWorld() then
                if self:GetClientNumber("weldingtoworld", 0) == 1 then
                    constraint.Weld(ent, hit, 0, 0, 0, true)
                end
            else
                constraint.Weld(ent, hit, 0, 0, 0, true)
            end
        end
    end
    
    
    local phys = ent:GetPhysicsObject()
    if phys:IsValid() then
        if(angles!=nil) then phys:SetAngles( angles ) end
        phys:Wake()
        if self:GetClientNumber("makefrozen", 1) == 1 then
            phys:EnableMotion(false)
        end
    end
    
    if self:GetClientNumber("ghd", 0) == 1 then
        ent:EnableGHD()
    end
    
    ply:AddCount(self.Mode, ent)
    
    undo.Create(self.Mode)
        undo.AddEntity(ent)
        undo.SetPlayer(ply)
    undo.Finish()

    ply:AddCleanup(self.Mode, ent)
    return true
end

if SERVER then return end

function TOOL.BuildCPanel(CPanel)
    local Weld = vgui.Create("DCheckBoxLabel")
    Weld:SetText("Weld")
    Weld:SetConVar("tk_ship_core_weld")
    Weld:SetValue(0)
    Weld:SizeToContents()
    CPanel:AddItem(Weld)
    
    local AllowWeldingToWorld = vgui.Create("DCheckBoxLabel")
    AllowWeldingToWorld:SetText("Weld To World")
    AllowWeldingToWorld:SetConVar("tk_ship_core_weldingtoworld")
    AllowWeldingToWorld:SetValue(0)
    AllowWeldingToWorld:SizeToContents()
    CPanel:AddItem(AllowWeldingToWorld)
    
    local MakeFrozen = vgui.Create("DCheckBoxLabel")
    MakeFrozen:SetText("Make Frozen")
    MakeFrozen:SetConVar("tk_ship_core_makefrozen")
    MakeFrozen:SetValue(1)
    MakeFrozen:SizeToContents()
    CPanel:AddItem(MakeFrozen)
    
    local GHD = vgui.Create("DCheckBoxLabel")
    GHD:SetText("Enable GHD")
    GHD:SetConVar("tk_ship_core_ghd")
    GHD:SetValue(0)
    GHD:SizeToContents()
    CPanel:AddItem(GHD)
    
    local List = vgui.Create("DPanelSelect")
    List:SetSize(0, 200)
    List:EnableVerticalScrollbar(true)
    CPanel:AddItem(List)
    
    for k,v in pairs(TK.RD.EntityData["tk_ship_core"]) do
        local icon = vgui.Create("SpawnIcon")
        icon.idx = k
        icon:SetModel(k)
        icon:SetSize(64, 64)
        List:AddPanel(icon, {["tk_ship_core_model"] = k, playgamesound = "ui/buttonclickrelease.wav"})
    end
    List:SortByMember("idx")
end