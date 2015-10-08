TOOL.Category = "Mining"
TOOL.Name = "Loadout"
TOOL.Command = nil
TOOL.ConfigName = nil
TOOL.Tab = "3K Spacebuild"
TOOL.Build = true
TOOL.ClientConVar["dontweld"] = 0
TOOL.ClientConVar["allowweldingtoworld"] = 0
TOOL.ClientConVar["makefrozen"] = 1
TOOL.ClientConVar["item"] = ""

if CLIENT then
    language.Add("tool.tk_loadout.name", "Player Loadout Tool")
    language.Add("tool.tk_loadout.desc", "Use to Spawn Items From Your Loadout")
    language.Add("tool.tk_loadout.0", "Left Click:    Right Click:    Reload:")

    hook.Add("TKDB_Player_Data", "TKLO_tool", function(dtable, idx, data)
        if dtable ~= "player_terminal_loadout" or idx ~= "loadout" then return end
        if not LocalPlayer().GetWeapons then return end
        local tools = LocalPlayer():GetWeapons()

        for _, tool in pairs(tools) do
            if tool:GetClass() ~= "gmod_tool" then continue end
            tool.Tool["tk_loadout"].Build = true
            break
        end
    end)
end

function TOOL:SelectModel()
    local item = TK.LO:GetItem(self:GetClientInfo("item"))

    return item.mdl or ""
end

function TOOL:LeftClick(trace)
    if not trace.Hit then return end
    if CLIENT then return true end
    local ply, item, data = self:GetOwner(), self:GetClientInfo("item"), {}
    data.Class = self.Mode
    data.Model = self:SelectModel()
    data.Pos = trace.HitPos
    data.Angle = trace.HitNormal:Angle() + Angle(90, 0, 0)
    if not util.IsValidModel(data.Model) then return end
    local ent = TK.LO.MakeEntity(ply, data, item)
    if not IsValid(ent) then return false end
    ent:SetPos(trace.HitPos - trace.HitNormal * ent:OBBMins().z)

    if self:GetClientNumber("dontweld", 0) == 0 then
        local hit = trace.Entity

        if hit then
            if hit:IsWorld() then
                if self:GetClientNumber("allowweldingtoworld", 0) == 1 then
                    constraint.Weld(ent, hit, 0, 0, 0, true)
                end
            else
                constraint.Weld(ent, hit, 0, 0, 0, true)
            end
        end
    end

    local phys = ent:GetPhysicsObject()

    if phys:IsValid() then
        if (angles ~= nil) then
            phys:SetAngles(angles)
        end

        phys:Wake()

        if (self:GetClientNumber("makefrozen", 0) == 1) then
            phys:EnableMotion(false)
        end
    end

    undo.Create(ent.PrintName)
    undo.AddEntity(ent)
    undo.SetPlayer(ply)
    undo.Finish()
    ply:AddCleanup(ent.PrintName, ent)

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
    local DontWeld = vgui.Create("DCheckBoxLabel")
    DontWeld:SetText("Don't Weld")
    DontWeld:SetConVar("tk_loadout_dontweld")
    DontWeld:SetValue(1)
    DontWeld:SizeToContents()
    CPanel:AddItem(DontWeld)
    local AllowWeldingToWorld = vgui.Create("DCheckBoxLabel")
    AllowWeldingToWorld:SetText("Allow Welding To World")
    AllowWeldingToWorld:SetConVar("tk_loadout_allowweldingtoworld")
    AllowWeldingToWorld:SetValue(0)
    AllowWeldingToWorld:SizeToContents()
    CPanel:AddItem(AllowWeldingToWorld)
    local MakeFrozen = vgui.Create("DCheckBoxLabel")
    MakeFrozen:SetText("Make Frozen")
    MakeFrozen:SetConVar("tk_loadout_makefrozen")
    MakeFrozen:SetValue(1)
    MakeFrozen:SizeToContents()
    CPanel:AddItem(MakeFrozen)
    local List = vgui.Create("DPanelSelect")
    List:SetSize(0, 200)
    List:EnableVerticalScrollbar(true)
    CPanel:AddItem(List)
    local loadout = TK.DB:GetPlayerData("player_terminal_loadout").loadout

    for _, item_id in pairs(loadout) do
        local icon = vgui.Create("SpawnIcon")
        icon.idx = item_id
        icon.item = TK.LO:GetItem(item_id)

        function icon:DoRightClick()
            surface.PlaySound("ui/buttonclickrelease.wav")
            SetClipboardText(self.item.mdl)
            GAMEMODE:AddNotify("Model path copied to clipboard.", NOTIFY_HINT, 5)
        end

        icon:SetModel(icon.item.mdl)
        icon:SetSize(64, 64)
        icon:SetTooltip(icon.item.name)

        List:AddPanel(icon, {
            tk_loadout_item = item_id,
            playgamesound = "ui/buttonclickrelease.wav"
        })
    end

    List:SortByMember("idx")
    local items = List:GetItems()

    if table.Count(items) > 0 then
        List:SelectPanel(next(items))
    else
        RunConsoleCommand("tk_loadout_item", "")
    end
end
