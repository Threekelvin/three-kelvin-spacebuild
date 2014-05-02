
TOOL = nil

for _,t_file in pairs(file.Find("rd_tools/*.lua", "LUA")) do
    TOOL            = ToolObj:Create()
    TOOL.Name       = string.match(t_file, "[%w_]+")
    TOOL.Mode       = TOOL.Name
    TOOL.Category   = "Other"
    TOOL.Limit      = TK.UP.default
    TOOL.Data       = {}
    TOOL.Build      = true
    
    TOOL.ClientConVar["weld"] = 0
    TOOL.ClientConVar["weldingtoworld"] = 0
    TOOL.ClientConVar["makefrozen"] = 1
    TOOL.ClientConVar["model"] = ""
    
    if SERVER then
        function TOOL:SelectModel()
            local str = self:GetClientInfo("model")
            if not self.Data[str] or not TK.UP:HasSize(self:GetOwner(), self.Mode, self.Data[str].size) then
                for k,v in pairs(self.Data) do
                    if not v.size or v.size == "small" then
                        return k
                    end
                end
            end
            return str
        end
    else
        function TOOL:SelectModel()
            local str = self:GetClientInfo("model")
            if not self.Data[str] or not TK.UP:HasSize(self.Mode, self.Data[str].size) then
                for k,v in pairs(self.Data) do
                    if not v.size or v.size == "small" then
                        return k
                    end
                end
            end
            return str
        end
    end
    

    function TOOL:LeftClick(trace)
        if !trace.Hit then return end
        if CLIENT then return true end
        
        local ply, data = self:GetOwner(), {}
        data.Class = self.Mode
        data.Model = self:SelectModel()
        data.Pos = trace.HitPos
        data.Angle = trace.HitNormal:Angle() + Angle(90,0,0)
        if not util.IsValidModel(data.Model) then return end
        
        local ent = TK.UP.MakeEntity(ply, data)
        if !IsValid(ent) then return false end
        ent:SetPos(trace.HitPos - trace.HitNormal * ent:OBBMins().z)
        
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
            phys:Wake()
            if self:GetClientNumber("makefrozen", 1) == 1 then
                phys:EnableMotion(false)
            end
        end
        
        undo.Create(self.Mode)
            undo.AddEntity(ent)
            undo.SetPlayer(ply)
        undo.Finish()

        ply:AddCleanup(self.Mode, ent)
        return true
    end
    
    function TOOL:RightClick(trace)
    
    end
    
    function TOOL:Reload(trace)

    end

    function TOOL:Think()
        if SERVER then return end
        
        if !IsValid(self.GhostEntity) or self.GhostEntity:GetModel() != self:SelectModel() then
            self:MakeGhostEntity(self:SelectModel(), Vector(0,0,0), Angle(0,0,0))
        else
            local trace = self:GetOwner():GetEyeTrace()
            if !trace.Hit then return end
            self.GhostEntity:SetAngles(trace.HitNormal:Angle() + Angle(90,0,0))
            self.GhostEntity:SetPos(trace.HitPos - trace.HitNormal * self.GhostEntity:OBBMins().z)
        end
        
        if not self.Build then return end
        local CPanel = controlpanel.Get(self.Mode)
		if not CPanel then return end
        
        self.Build = false
		CPanel:ClearControls()
		self.BuildCPanel(CPanel, self)
    end

    function TOOL.BuildCPanel(CPanel, tool)
        if SERVER then return end
        if not tool then return end

        local Weld = vgui.Create("DCheckBoxLabel")
        Weld:SetText("Weld")
        Weld:SetConVar(tool.Mode.."_weld")
        Weld:SetValue(0)
        Weld:SizeToContents()
        CPanel:AddItem(Weld)
        
        local AllowWeldingToWorld = vgui.Create("DCheckBoxLabel")
        AllowWeldingToWorld:SetText("Weld To World")
        AllowWeldingToWorld:SetConVar(tool.Mode.."_weldingtoworld")
        AllowWeldingToWorld:SetValue(0)
        AllowWeldingToWorld:SizeToContents()
        CPanel:AddItem(AllowWeldingToWorld)
        
        local MakeFrozen = vgui.Create("DCheckBoxLabel")
        MakeFrozen:SetText("Make Frozen")
        MakeFrozen:SetConVar(tool.Mode.."_makefrozen")
        MakeFrozen:SetValue(1)
        MakeFrozen:SizeToContents()
        CPanel:AddItem(MakeFrozen)
        
        local List = vgui.Create("DPanelSelect")
        List:SetSize(0, 200)
        List:EnableVerticalScrollbar(true)
        CPanel:AddItem(List)
        
        for k,v in pairs(tool.Data) do
            if not TK.UP:HasSize(tool.Mode, v.size) then continue end
            local icon = vgui.Create("SpawnIcon")
            icon.DoRightClick = function()
                surface.PlaySound("ui/buttonclickrelease.wav")
                SetClipboardText(k)
                GAMEMODE:AddNotify("Model path copied to clipboard.", NOTIFY_HINT, 5)
            end
            icon.idx = k
            icon:SetModel(k)
            icon:SetSize(64, 64)
            List:AddPanel(icon, {[tool.Mode .."_model"] = k, playgamesound = "ui/buttonclickrelease.wav"})
        end
        List:SortByMember("idx")
        
        local mdl = tool:SelectModel()
        for k,v in pairs(List:GetItems()) do
            if v.idx != mdl then continue end
            List:SelectPanel(v)
            break
        end
    end

    AddCSLuaFile("rd_tools/"..t_file)
    include("rd_tools/"..t_file)
    
    if SERVER then 
        for k,v in pairs(TOOL.Data) do
            if util.IsValidModel(k) then
                util.PrecacheModel(k)
            else
                TOOL.Data[k] = nil
            end
        end
        
        TK.UP:SetDefaultLimit(TOOL.Mode, TOOL.Limit)
        duplicator.RegisterEntityClass(TOOL.Mode, TK.UP.MakeEntity, "Data")
    else
        language.Add("tool."..TOOL.Mode..".name", TOOL.Name)
        language.Add("tool."..TOOL.Mode..".desc", "Use to Spawn a "..TOOL.Name)
        language.Add("tool."..TOOL.Mode..".0", "Left Click: Spawn a "..TOOL.Name)
        language.Add("sboxlimit_"..TOOL.Mode, "You Have Hit the "..TOOL.Name.." Limit!")
    end
    
    cleanup.Register(TOOL.Name)

    TOOL.Command         = nil
    TOOL.ConfigName      = nil
    TOOL.Tab             = "3K Spacebuild"
    TOOL:CreateConVars()
    SWEP.Tool[TOOL.Mode] = TOOL
    
    TOOL = nil
end

TOOL            = ToolObj:Create()
TOOL.Category   = "3K Spacebuild"
TOOL.Mode       = "tk_tools"
TOOL.Name       = "3K Tools"
TOOL.Command    = nil
TOOL.ConfigName = nil
TOOL.AddToMenu  = false

if SERVER then

else
    hook.Add("TKDB_Player_Data", "TKTG", function(dbtable, idx, val)
        for k,v in pairs(TK.UP.lists) do
            if not string.match(v .."$", dbtable) then continue end
            local tool = LocalPlayer():GetWeapon("gmod_tool")
            for _,t_file in pairs(file.Find("rd_tools/*.lua", "LUA")) do
                tool.Tool[string.match(t_file, "[%w_]+")].Build = true
            end
        end
    end)
end