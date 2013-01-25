TOOL.Category		= "Constraints"
TOOL.Name			= "#Parent"
TOOL.Command		= nil
TOOL.ConfigName		= ""
TOOL.Parent = nil
TOOL.Selected = {}
TOOL.OldColor = {}

TOOL.ClientConVar["physics"] = "1"
TOOL.ClientConVar["mass"] = "1"

function TOOL:CanSelectEnt(trace)
    if !IsValid(trace.Entity) then return false end
	if trace.Entity:IsPlayer() then return false end
    if SERVER and !IsValid(trace.Entity:GetPhysicsObject()) then return false end
	return true
end

function TOOL:IsEntSelected(ent)
    if !IsValid(ent) then return false, false end
    local idx = ent:EntIndex()
    if self.Selected[idx] then
        if self.Parent == ent then
            return true, true
        else
            return true, false
        end
    end
    return false, false
end

function TOOL:SelectEnt(ent, ply)
    if !IsValid(ent) then return end
    local idx = ent:EntIndex()
    local col = ent:GetColor()
    ent:SetColor(IsValid(self.Parent) && Color(0, 200, 0, 100) || Color(200, 0, 0, 100))
    if !IsValid(self.Parent) then 
        self.Parent = ent
        ply:SendLua('GAMEMODE:AddNotify("Parent Selected", NOTIFY_HINT, 3)')
    end
    
    self.Selected[idx] = ent
    self.OldColor[idx] = col
end

function TOOL:UnSelectEnt(ent)
    if !IsValid(ent) then return end
    
    local idx = ent:EntIndex()
    ent:SetColor(self.OldColor[idx])
    if self.Parent == ent then self.Parent = nil end
    
    self.Selected[idx] = nil
    self.OldColor[idx] = nil
end

function TOOL:LeftClick(trace)
    if CLIENT then return self:CanSelectEnt(trace) end
    if !self:CanSelectEnt(trace) then return false end
    local ply = self:GetOwner()
    local ent = trace.Entity
    
    local sel, par = self:IsEntSelected(ent)
    if par then
        ply:SendLua('GAMEMODE:AddNotify("Can Not Unselect Parent", NOTIFY_ERROR, 3)')
    elseif !sel then
        self:SelectEnt(ent, ply)
    else
        self:UnSelectEnt(ent)
    end
end

function TOOL:RightClick(trace)
    if CLIENT then return true end
    local ply = self:GetOwner()
    
    if !IsValid(self.Parent) || !IsValid(self.Parent:GetPhysicsObject()) then
        ply:SendLua('GAMEMODE:AddNotify("No Valid Parent Selected", NOTIFY_ERROR, 3)')
        
        for k,v in pairs(self.Selected) do
            self:UnSelectEnt(ent)
        end
        return
    end
    
    for idx,ent in pairs(self.Selected) do
        if !IsValid(ent) then continue end
        if ent == self.Parent then
            if self:GetClientNumber("mass", 1) == 1 then
                ent:GetPhysicsObject():SetMass(5000)
                duplicator.StoreEntityModifier(ent, "mass", {Mass = 5000})
            end
            continue
        end
        
        if self.Parent:GetParent() == ent then 
            self:UnSelectEnt(ent) 
            continue
        end
        
        ent:SetParent(self.Parent)
        
        if self:GetClientNumber("physics", 1) == 1 then
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then 
                if self:GetClientNumber("mass", 1) == 1 then
                    phys:SetMass(500)
                    duplicator.StoreEntityModifier(ent, "mass", {Mass = 500})
                else
                    phys:SetMass(phys:GetMass())
                end
                
                phys:SetPos(ent:GetPos())
                phys:SetAngles(ent:GetAngles())
                constraint.Weld(self.Parent, ent, 0, 0, 0, false)
                phys:Wake()
            end
        else
            ent:SetNotSolid(true)
        end
        
        self:UnSelectEnt(ent)
    end
    
    self:UnSelectEnt(self.Parent)
    self.Selected = {}
	self.OldColor = {}
    ply:SendLua('GAMEMODE:AddNotify("Parenting Completed", NOTIFY_HINT, 3)')
end

function TOOL:Reload(trace)
    if CLIENT then return true end
    local ply = self:GetOwner()
    
    for idx,ent in pairs(self.Selected) do
        self:UnSelectEnt(ent)
    end
    
    self.Selected = {}
	self.OldColor = {}
end

if SERVER then return end

language.Add("tool.tk_parent.name", "Parent Tool")
language.Add("tool.tk_parent.desc", "Parent Entities To A Central Prop")
language.Add("tool.tk_parent.0", "Primary: Select Entity   Secondary: Parent   Reload: Clear Selection")

function TOOL.BuildCPanel(CPanel)
    local Physics = vgui.Create("DCheckBoxLabel")
    Physics:SetText("Enable Physics")
    Physics:SetConVar("tk_parent_physics")
    Physics:SetValue(1)
    Physics:SizeToContents()
    CPanel:AddItem(Physics)
    
    local Mass = vgui.Create("DCheckBoxLabel")
    Mass:SetText("Mass Balance")
    Mass:SetConVar("tk_parent_mass")
    Mass:SetValue(1)
    Mass:SizeToContents()
    CPanel:AddItem(Mass)
end