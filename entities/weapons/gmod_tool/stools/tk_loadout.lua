TOOL.Category		= "Mining"
TOOL.Name			= "Loadout"
TOOL.Command		= nil
TOOL.ConfigName		= nil
TOOL.Tab = "3K Spacebuild"

TOOL.ClientConVar["dontweld"] = 0
TOOL.ClientConVar["allowweldingtoworld"] = 0
TOOL.ClientConVar["makefrozen"] = 1
TOOL.ClientConVar["item"] = 0
TOOL.ClientConVar["model"] = ""

if CLIENT then
	language.Add("tool.tk_loadout.name", "Player Loadout Tool")
	language.Add("tool.tk_loadout.desc", "Use to Spawn Items From Your Loadout")
	language.Add("tool.tk_loadout.0", "Left Click:    Right Click:    Reload:")
else

end

function TOOL:SelectModel()
    local str = self:GetClientInfo("model")
    return str
end

function TOOL:LeftClick(trace)
    if !trace.Hit then return end
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    local item = self:GetClientNumber("item", 0)
    if !TK.LO:CanSpawn(ply, item) then return end
    
	local pos = trace.HitPos
	local angles = trace.HitNormal:Angle() + Angle(90,0,0)
    local ent = TK.LO:SpawnItem(ply, item, pos, angles)
	ent:SetPos(trace.HitPos + trace.HitNormal * ((ent:OBBMaxs().z - ent:OBBMins().z) / 2 - ent:OBBCenter().z))
    
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
		if(angles!=nil) then phys:SetAngles( angles ) end
		phys:Wake()
		if(self:GetClientNumber("makefrozen", 0) == 1) then
			phys:EnableMotion( false )
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
    if !IsValid(self.GhostEntity) || self.GhostEntity:GetModel() != self:SelectModel() then
        self:MakeGhostEntity(self:SelectModel(), Vector(0,0,0), Angle(0,0,0))
    else
        local trace = self:GetOwner():GetEyeTrace()
        if !trace.Hit then return end
        self.GhostEntity:SetAngles(trace.HitNormal:Angle() + Angle(90,0,0))
        self.GhostEntity:SetPos(trace.HitPos + trace.HitNormal * ((self.GhostEntity:OBBMaxs().z - self.GhostEntity:OBBMins().z) / 2 - self.GhostEntity:OBBCenter().z))
    end	
end

if CLIENT then
    function TOOL.BuildCPanel(CPanel)
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
        List.Populate = function(self)
            self:Clear(true)
            self.SelectedPanel = nil
            RunConsoleCommand("tk_loadout_model", "")
            local loadout = TK.DB:GetPlayerData("player_loadout")
            
            for k,v in pairs(loadout) do
                if string.match(k, "[%w]+$") != "item" then continue end
                if v == 0 then continue end
                
                local item = TK.TD:GetItem(v)
                local icon = vgui.Create("SpawnIcon")
				icon.DoRightClick = function()
					RunConsoleCommand( "playgamesound", "ui/buttonclickrelease.wav" )
					SetClipboardText(item.mdl)
					GAMEMODE:AddNotify("Model path copied to clipboard.", NOTIFY_HINT, 5)
				end
                icon:SetModel(item.mdl)
                icon:SetSize(64, 64)
                icon:SetToolTip(item.name)
                self:AddPanel(icon, {tk_loadout_item = v, tk_loadout_model = item.mdl, playgamesound = "ui/buttonclickrelease.wav"})
            end
        end
        List:Populate()
        CPanel:AddItem(List)
        
        hook.Add("TKDBPlayerData", "tk_loadout", function(dtable, idx, data)
            if dtable != "player_loadout" then return end
            List:Populate()
        end)
    end
end