
local Build = {}
local concmd = "tk_sbep_build_mode_"
Build.enable = CreateClientConVar(concmd.."enabled", 0, true, true)
CreateClientConVar(concmd.."skinmatch", 0, true, true)
Build.sprites = CreateClientConVar(concmd.."sprites", 1, true, false)
Build.orientation = CreateClientConVar(concmd.."orientation", 0, true, false)

Build.partdata = list.Get("SBEP_PartAssemblyData")
Build.targets = {}
Build.sprite = {
	SWSH = { Material( "sprites/sbep_assembler_tool/SWSHblue"		) , { 42 , 30 } } ,
	SWDH = { Material( "sprites/sbep_assembler_tool/SWDHgreen"		) , { 21 , 30 } } ,
	DWSH = { Material( "sprites/sbep_assembler_tool/DWSHred"		) , { 42 , 15 } } ,
	DWDH = { Material( "sprites/sbep_assembler_tool/DWDHyellow"		) , { 42 , 30 } } ,
	INSR = { Material( "sprites/sbep_assembler_tool/Insert"			) , { 42 , 15 } } ,
	HNGR = { Material( "sprites/sbep_assembler_tool/HangarSnap"		) , { 38 , 38 } } ,
	
	ESML = { Material( "sprites/sbep_assembler_tool/ESML"			) , { 35 , 35 } } ,
	ELRG = { Material( "sprites/sbep_assembler_tool/ELRG"			) , { 35 , 35 } } ,
	
	LRC1 = { Material( "sprites/sbep_assembler_tool/LRC1"			) , { 42 , 30 } } ,
	LRC2 = { Material( "sprites/sbep_assembler_tool/LRC1"			) , { 42 , 30 } } ,
	LRC3 = { Material( "sprites/sbep_assembler_tool/LRC3"			) , { 42 , 30 } } ,
	LRC4 = { Material( "sprites/sbep_assembler_tool/LRC3"			) , { 42 , 30 } } ,
	LRC5 = { Material( "sprites/sbep_assembler_tool/LRC5"			) , { 21 , 30 } } ,
	LRC6 = { Material( "sprites/sbep_assembler_tool/LRC5"			) , { 21 , 30 } } ,
	
	MBSH = { Material( "sprites/sbep_assembler_tool/MBSH"			) , { 35 , 35 } } ,
	
	MOD1x1 = { Material( "sprites/sbep_assembler_tool/mod1x1"		) , { 35 , 35 } } ,
	MOD2x1 = { Material( "sprites/sbep_assembler_tool/mod2x1"		) , { 35 , 35 } } ,
	MOD3x1 = { Material( "sprites/sbep_assembler_tool/mod3x1"		) , { 35 , 35 } } ,
	MOD3x2 = { Material( "sprites/sbep_assembler_tool/mod3x2"		) , { 35 , 35 } } ,
	MOD1x1e = { Material( "sprites/sbep_assembler_tool/ESML"		) , { 35 , 35 } } ,
	MOD3x2e = { Material( "sprites/sbep_assembler_tool/ELRG"		) , { 35 , 35 } } ,
}
Build.beam = Material("sprites/physbeam")

function Build.MakeMenu(Panel)
    local Enable = vgui.Create("DCheckBoxLabel")
    Enable:SetText("Enable")
	Enable:SetConVar(concmd.."enabled")
	Enable:SetValue(1)
	Enable:SizeToContents()
	Panel:AddItem(Enable)
	
	local SkinMatch = vgui.Create("DCheckBoxLabel")
	SkinMatch:SetText("Skin Match")
	SkinMatch:SetConVar(concmd.."skinmatch")
	SkinMatch:SetValue(1)
	SkinMatch:SizeToContents()
	Panel:AddItem(SkinMatch)
	
	local Sprites = vgui.Create("DCheckBoxLabel")
	Sprites:SetText("Show Sprites")
	Sprites:SetConVar(concmd.."sprites")
	Sprites:SetValue(1)
	Sprites:SizeToContents()
	Panel:AddItem(Sprites)
	
	local Orientation = vgui.Create("DCheckBoxLabel")
	Orientation:SetText("Show Orientation")
	Orientation:SetConVar(concmd.."orientation")
	Orientation:SetValue(1)
	Orientation:SizeToContents()
	Panel:AddItem(Orientation)
end

function Build.OnPickUp(ply, ent)
	if !Build.enable:GetBool() then return end
	if !Build.partdata[ent:GetModel()] then return end
	Build.prop = ent
end

function Build.OnDrop(ply, ent)
	Build.prop = nil
end

function Build.HUDPaint()
	if !Build.enable:GetBool() then return end
	if !IsValid(Build.prop) then return end
	local ent = Build.prop
	cam.Start3D(EyePos(), EyeAngles())
		if Build.sprites:GetBool() then
			for k,v in pairs(Build.partdata[ent:GetModel()]) do
				local mat = Build.sprite[v.type][1]
				local size = Build.sprite[v.type][2]
				render.SetMaterial(mat)
				render.DrawSprite(ent:LocalToWorld(v.pos), size[1], size[2], Color(255,255,255,255))
			end
			
			for _,ent in pairs(Build.targets) do
				if IsValid(ent) then
					for k,v in pairs(Build.partdata[ent:GetModel()]) do
						local mat = Build.sprite[v.type][1]
						local size = Build.sprite[v.type][2]
						render.SetMaterial(mat)
						render.DrawSprite(ent:LocalToWorld(v.pos), size[1], size[2], Color(255,255,255,255))
					end
				end
			end
		end
		
		if Build.orientation:GetBool() then
			local center, size = ent:OBBCenter(), (ent:OBBMaxs() - ent:OBBMins()) / 2
			render.SetMaterial(Build.beam)
            
            render.DrawBeam(ent:LocalToWorld(center + Vector(size.x + 50, 0, 0)), ent:LocalToWorld(center), 50, 1, 1, Color(255, 0, 0, 125))
            render.DrawBeam(ent:LocalToWorld(center + Vector(0, size.y + 50, 0)), ent:LocalToWorld(center), 50, 1, 1, Color(0, 255, 0, 125))
            render.DrawBeam(ent:LocalToWorld(center + Vector(0, 0, size.z + 50)), ent:LocalToWorld(center), 50, 1, 1, Color(0, 0, 255, 125))
		end 
	cam.End3D()
end

hook.Add("PopulateToolMenu", "TK_SBEPBuild", function()
	spawnmenu.AddToolMenuOption("Options", "Player", "SBEPBuildMode", "SBEP Build Mode", "", "", Build.MakeMenu, {SwitchConVar = "3k_sbep_build_mode_enabled"})
end)

hook.Add("Initialize", "TK_SBEPBuild", function()
	timer.Create("SBEP_Build_Mode", 1, 0, function()
		if !IsValid(Build.prop) then return end
		
		Build.targets = {}
		for k,v in pairs(TK:FindInSphere(Build.prop:GetPos(), Build.prop:BoundingRadius() + 250)) do
			if Build.partdata[v:GetModel()] then
				table.insert(Build.targets, v)
			end
		end
	end)
end)

hook.Add("PhysgunPickup", "TK_SBEPBuild", Build.OnPickUp)
hook.Add("PhysgunDrop", "TK_SBEPBuild", Build.OnDrop)
hook.Add("HUDPaint", "TK_SBEPBuild", Build.HUDPaint)