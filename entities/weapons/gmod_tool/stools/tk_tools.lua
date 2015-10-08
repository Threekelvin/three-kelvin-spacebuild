TOOL = nil

for _, t_file in pairs(file.Find("rd_tools/*.lua", "LUA")) do
    TOOL = ToolObj:Create()
    TOOL.Name = string.match(t_file, "[%w_]+")
    TOOL.Mode = TOOL.Name
    TOOL.Category = "Other"
    TOOL.Limit = TK.UP.default
    TOOL.Data = {}
    TOOL.Build = true
    TOOL.ClientConVar["weld"] = 0
    TOOL.ClientConVar["weldingtoworld"] = 0
    TOOL.ClientConVar["makefrozen"] = 1
    TOOL.ClientConVar["model"] = ""

    if SERVER then
        function TOOL:SelectModel()
            local str = self:GetClientInfo("model")

            if not self.Data[str] or not TK.UP:HasSize(self:GetOwner(), self.Mode, self.Data[str].size) then
                for k, v in pairs(self.Data) do
                    if not v.size or v.size == "small" then return k end
                end
            end

            return str
        end
    else
        function TOOL:SelectModel()
            local str = self:GetClientInfo("model")

            if not self.Data[str] or not TK.UP:HasSize(self.Mode, self.Data[str].size) then
                for k, v in pairs(self.Data) do
                    if not v.size or v.size == "small" then return k end
                end
            end

            return str
        end
    end

    function TOOL:LeftClick(trace)
        if not trace.Hit then return end
        if CLIENT then return true end
        local ply, data = self:GetOwner(), {}
        data.Class = self.Mode
        data.Model = self:SelectModel()
        data.Pos = trace.HitPos
        data.Angle = trace.HitNormal:Angle() + Angle(90, 0, 0)
        if not util.IsValidModel(data.Model) then return end
        local ent = TK.UP.MakeEntity(ply, data)
        if not IsValid(ent) then return false end
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

        if not IsValid(self.GhostEntity) or self.GhostEntity:GetModel() ~= self:SelectModel() then
            self:MakeGhostEntity(self:SelectModel(), Vector(0, 0, 0), Angle(0, 0, 0))
        else
            local trace = self:GetOwner():GetEyeTrace()
            if not trace.Hit then return end
            self.GhostEntity:SetAngles(trace.HitNormal:Angle() + Angle(90, 0, 0))
            self.GhostEntity:SetPos(trace.HitPos - trace.HitNormal * self.GhostEntity:OBBMins().z)
        end

        if self.Build then
            local CPanel = controlpanel.Get(self.Mode)
            if not CPanel then return end
            CPanel:ClearControls()
            self.BuildCPanel(CPanel, self)
            self.Build = false
        end
    end

    function TOOL.BuildCPanel(CPanel, tool)
        if SERVER then return end
        if not tool then return end

        CPanel:AddControl("header", {
            description = "#tool." .. tool.Mode .. ".desc"
        })

        CPanel:AddControl("checkbox", {
            label = "Weld",
            command = tool.Mode .. "_weld"
        })

        CPanel:AddControl("checkbox", {
            label = "Weld to world",
            command = tool.Mode .. "_weldingtoworld"
        })

        CPanel:AddControl("checkbox", {
            label = "Make frozen",
            command = tool.Mode .. "_makefrozen"
        })

        CPanel:AddControl("label", {
            text = "Select Size:"
        })

        local List = vgui.Create("DPanelSelect")
        List:SetSize(0, 200)
        List:EnableVerticalScrollbar(true)
        CPanel:AddItem(List, nil)
        CPanel:InvalidateLayout()

        for k, v in pairs(tool.Data) do
            if not TK.UP:HasSize(tool.Mode, v.size) then continue end
            local icon = vgui.Create("SpawnIcon")
            icon.idx = k

            function icon:DoRightClick()
                surface.PlaySound("ui/buttonclickrelease.wav")
                SetClipboardText(self.idx)
                GAMEMODE:AddNotify("Model path copied to clipboard.", NOTIFY_HINT, 5)
            end

            icon:SetModel(k)
            icon:SetSize(64, 64)
            local tip = ""

            for res, amt in pairs(v) do
                if not TK.RD:IsResource(res) then continue end
                tip = tip .. TK.RD:GetResourceName(res) .. " = " .. amt .. "\n"
            end

            tip = string.sub(tip, 0, -2)
            icon:SetTooltip(tip == "" and k or tip)

            List:AddPanel(icon, {
                [tool.Mode .. "_model"] = k,
                playgamesound = "ui/buttonclickrelease.wav"
            }, nil)
        end

        local mdl = tool:SelectModel()

        for k, v in pairs(List:GetItems()) do
            if v.idx ~= mdl then continue end
            List:SelectPanel(v)
            break
        end
    end

    AddCSLuaFile("rd_tools/" .. t_file)
    include("rd_tools/" .. t_file)

    if SERVER then
        for k, v in pairs(TOOL.Data) do
            if util.IsValidModel(k) then
                util.PrecacheModel(k)
            else
                TOOL.Data[k] = nil
            end
        end

        TK.UP:SetDefaultLimit(TOOL.Mode, TOOL.Limit)
        duplicator.RegisterEntityClass(TOOL.Mode, TK.UP.MakeEntity, "Data")
    else
        language.Add("tool." .. TOOL.Mode .. ".name", TOOL.Name)
        language.Add("tool." .. TOOL.Mode .. ".desc", "Used to Spawn a " .. TOOL.Name)
        language.Add("tool." .. TOOL.Mode .. ".0", "Left Click: Spawn a " .. TOOL.Name)
        language.Add("sboxlimit_" .. TOOL.Mode, "You Have Hit the " .. TOOL.Name .. " Limit!")
    end

    cleanup.Register(TOOL.Name)
    TOOL.Command = nil
    TOOL.ConfigName = nil
    TOOL.Tab = "3K Spacebuild"
    TOOL:CreateConVars()
    SWEP.Tool[TOOL.Mode] = TOOL
    TOOL = nil
end

TOOL = ToolObj:Create()
TOOL.Category = "3K Spacebuild"
TOOL.Mode = "tk_tools"
TOOL.Name = "3K Tools"
TOOL.Command = nil
TOOL.ConfigName = nil
TOOL.AddToMenu = false

if CLIENT then
    hook.Add("TKDB_Player_Data", "TKTG", function(dbtable, idx, val)
        for k, v in pairs(TK.UP.lists) do
            if not string.match(v .. "$", dbtable) then continue end
            if not LocalPlayer().GetWeapons then return end
            local tools = LocalPlayer():GetWeapons()

            for _, tool in pairs(tools) do
                if tool:GetClass() ~= "gmod_tool" then continue end

                for _, t_file in pairs(file.Find("rd_tools/*.lua", "LUA")) do
                    tool.Tool[string.match(t_file, "[%w_]+")].Build = true
                end

                break
            end
        end
    end)
end
