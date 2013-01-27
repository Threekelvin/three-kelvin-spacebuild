
include('shared.lua')

local ponies = CreateClientConVar("3k_show_ponies", 1, true, false)
local truemodel = {}

local function ShouldChangeModel(ply)
    local mdl = ply:GetModel()
    if !util.IsValidModel(mdl) then return true end
    if !ponies:GetBool() && TK.PlyModels[mdl] then return true end
    return false
end

hook.Add("PrePlayerDraw", "Model", function(ply)
    if !ShouldChangeModel(ply) then return end
    truemodel[ply:UserID()] = ply:GetModel()
    ply:SetModel("models/player/kleiner")
end)

hook.Add("PostPlayerDraw", "Model", function(ply)
    local uid = ply:UserID()
    local mdl = truemodel[uid]
    if !mdl then return end
    if ply:GetModel() != "models/player/kleiner" then 
        truemodel[uid] = nil
        return
    end
    ply:SetModel(mdl)
    truemodel[uid] = nil
end)

usermessage.Hook("TKOSSync", function(msg)
	local servertime = tonumber(msg:ReadString())
	TK.OSSync = math.ceil(servertime - os.time())
end)

hook.Add("Initialize", "SWDownload", function()
    function steamworks.Download(workshopPreviewID, bool, unknown, callback)
        if callback then callback() end
    end
    
    list.Set("DesktopWindows", "PlayerEditor", {
        title		= "Player Model",
        icon		= "icon64/playermodel.png",
        width		= 960,
        height		= 700,
        onewindow	= true,
        init		= function( icon, window )

            local mdl = window:Add( "DModelPanel" )
            mdl:Dock( FILL )
            mdl:SetFOV(45)
            mdl:SetCamPos(Vector(90,0,60))

            local sheet = window:Add( "DPropertySheet" )
            sheet:Dock( RIGHT )
            sheet:SetSize( 370, 0 )

            local PanelSelect = sheet:Add( "DPanelSelect" )
    
            for name, model in SortedPairs(list.Get("PlayerOptionsModel")) do
                if TK:CanUsePlayerModel(LocalPlayer(), name) then
                    local icon = vgui.Create( "SpawnIcon" )
                    icon:SetModel( model )
                    icon:SetSize( 64, 64 )
                    icon:SetTooltip( name )
        
                    PanelSelect:AddPanel( icon, { cl_playermodel = name } )
                end
            end

            sheet:AddSheet( "Model", PanelSelect )

            local controls = window:Add( "DPanel" )
            controls:DockPadding( 8, 8, 8, 8 )

            local lbl = controls:Add( "DLabel" )
            lbl:SetText( "Player Color:" )
            lbl:SetTextColor( Color( 0, 0, 0, 255 ) )
            lbl:Dock( TOP )

            local plycol = controls:Add( "DColorMixer" )
            plycol:SetAlphaBar( false )
            plycol:SetPalette( false )
            plycol:Dock( TOP )
            plycol:SetSize( 200, 250 )
                
            sheet:AddSheet( "Colors", controls )

            local function UpdateFromConvars()
                local modelname = player_manager.TranslatePlayerModel( LocalPlayer():GetInfo( "cl_playermodel" ) )
                util.PrecacheModel( modelname )
                mdl:SetModel( modelname )
                mdl.Entity.GetPlayerColor = function() return Vector( GetConVarString( "cl_playercolor" ) ) end

                plycol:SetVector( Vector( GetConVarString( "cl_playercolor" ) ) );
            end
                
            local function UpdateFromControls()
                RunConsoleCommand( "cl_playercolor", tostring( plycol:GetVector() ) )
            end

            UpdateFromConvars();
            plycol.ValueChanged					= UpdateFromControls
            PanelSelect.OnActivePanelChanged	= function() timer.Simple( 0.1, UpdateFromConvars ) end
        end
    })
end)

player_manager.AddValidModel("Trixie", "models/trixie_player.mdl")
player_manager.AddValidModel("Derpy Hooves", "models/derpyhooves_player.mdl")
player_manager.AddValidModel("Celestia", "models/celestia.mdl")
player_manager.AddValidModel("Luna", "models/luna_player.mdl")
player_manager.AddValidModel("Lyra", "models/lyra_player.mdl")
player_manager.AddValidModel("Rainbow Dash", "models/rainbowdash_player.mdl")
player_manager.AddValidModel("Fluttershy", "models/fluttershy_player.mdl")
player_manager.AddValidModel("Pinkie Pie", "models/pinkiepie_player.mdl")
player_manager.AddValidModel("Rarity", "models/rarity_player.mdl")
player_manager.AddValidModel("Twilight Sparkle", "models/twilightsparkle_player.mdl")
player_manager.AddValidModel("Applejack", "models/applejack_player.mdl")
player_manager.AddValidModel("Bon Bon", "models/bonbon_player.mdl")
player_manager.AddValidModel("Colgate (Minuette)", "models/colgate_player.mdl")
player_manager.AddValidModel("Trixie (No Dress)", "models/trixienodress_player.mdl")
player_manager.AddValidModel("Vinyl Scratch", "models/vinyl_player.mdl")
player_manager.AddValidModel("Vinyl Scratch (Goggles)", "models/vinyl_goggles_player.mdl")
player_manager.AddValidModel("Raindrops", "models/raindrops_player.mdl")