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
			local uid = LocalPlayer():GetNWString("UID")
			local spawned = TK.LO.SpawnedEnts[uid] || {}
			local building = TK.LO.BuildingEnts[uid] || {}
			local icons = {}
			for slot,id in pairs(loadout) do
				local found = false
				if string.match(slot, "[%w]+$") == "item" && id != 0 then
					for k,v in pairs(building) do
						if v.id == id then
							found = true
							table.insert(icons, {['id']=id, ['time']=v.time})
							break
						end
					end
					if found then continue end
					for k,v in pairs(spawned) do
						if v.itemid == id then
							found = true
							table.insert(icons, {['id']=id, ['time']=-1})
							break
						end
					end
					if !found then table.insert(icons, {['id']=id, ['time']=0}) end
				end
			end
            
            for k,v in pairs(icons) do
                
                local item = TK.TD:GetItem(v.id)
                local icon = vgui.Create("SpawnIcon")
				local overlay = vgui.Create("DButton", icon)
				overlay:SetText("")
				local w, h = icon:GetSize()
				overlay:SetSize( w, h )
				local r = w+h
				local cos, sin = math.cos, math.sin
				function overlay:Paint()
					local A = 0.0
					if v.time == 0 then A = 1.0
					elseif v.time > 0 then A = (v.time-CurTime())/TK.LO.RebuildTime end
					A = A * 2 * math.pi
					local verticies = {
						{x = w/2, y = h/2},
						{x = w/2, y = 0},
					}
					for i=1,4 do
						table.insert( verticies, {x = r*cos(i*A/4) + w/2, y = r*sin(i*A/4) + h/2} )
					end
					surface.SetDrawColor( 0,0,0,100 )
					surface.DrawPoly( verticies )
					surface.DrawRect( 0, 0, w, h )
				end
				function overlay:DoClick()
					self:GetParent():DoClick()
				end
				function overlay:DoRightClick()
					RunConsoleCommand( "playgamesound", "ui/buttonclickrelease.wav" )
					SetClipboardText(item.mdl)
					GAMEMODE:AddNotify("Model path copied to clipboard.", NOTIFY_HINT, 5)
				end
                icon:SetModel(item.mdl)
                icon:SetSize(64, 64)
                icon:SetToolTip(item.name)
                self:AddPanel(icon, {tk_loadout_item = v.id, tk_loadout_model = item.mdl, playgamesound = "ui/buttonclickrelease.wav"})
            end
        end
        List:Populate()
        CPanel:AddItem(List)
		TK.LO.SpawnList = List
        
        hook.Add("TKDBPlayerData", "tk_loadout", function(dtable, idx, data)
            if dtable != "player_loadout" then return end
            List:Populate()
        end)
    end
end