
surface.CreateFont( "ScoreboardDefault",
{
	font		= "Helvetica",
	size		= 22,
	weight		= 800
})

surface.CreateFont( "ScoreboardDefaultTitle",
{
	font		= "Helvetica",
	size		= 32,
	weight		= 800
})

--
-- This defines a new panel type for the player row. The player row is given a player
-- and then from that point on it pretty much looks after itself. It updates player info
-- in the think function, and removes itself when the player leaves the server.
--
local PLAYER_LINE = 
{
	Init = function( self )

		local TextCol = Color(0, 0, 0, 255)

		self.AvatarButton = self:Add( "DButton" )
		self.AvatarButton:Dock( LEFT )
		self.AvatarButton:SetSize( 32, 32 )
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

		self.Avatar		= vgui.Create( "AvatarImage", self.AvatarButton )
		self.Avatar:SetSize( 32, 32 )
		self.Avatar:SetMouseInputEnabled( false )

		self.RankPanel	= self:Add( "DPanel" )
		self.RankPanel:Dock( LEFT )
		self.RankPanel:SetSize( 32, 32 )
		self.RankPanel.Paint = function() return true end
		
		self.Rank		= self.RankPanel:Add( "DImageButton" )
		self.Rank:SetSize( 16, 16 )
		self.Rank:SetPos( self.RankPanel:GetWide()/2 - 8, self.RankPanel:GetTall()/2 - 8)
        self.Rank.SetMaterial = function(btn, mat)
            btn.m_Image:SetMaterial(mat)
        end

		self.Name		= self:Add( "DLabel" )
		self.Name:Dock( LEFT )
		self.Name:SetWidth( 150 )
		self.Name:SetFont( "ScoreboardDefault" )
		self.Name:SetTextColor( TextCol )
		self.Name:SetContentAlignment( 4 )

		self.mute		= self:Add( "DImageButton" )
		self.mute:SetSize( 32, 32 )
		self.mute:Dock( RIGHT )

		self.Ping		= self:Add( "DLabel" )
		self.Ping:Dock( RIGHT )
		self.Ping:SetWidth( 50 )
		self.Ping:SetFont( "ScoreboardDefault" )
		self.Ping:SetTextColor( TextCol )
		self.Ping:SetContentAlignment( 5 )

		self.Playtime	= self:Add( "DLabel" )
		self.Playtime:Dock( FILL )
		self.Playtime:SetFont( "ScoreboardDefault" )
		self.Playtime:SetTextColor( TextCol )
		self.Playtime:SetContentAlignment( 6 )

		self.Score		= self:Add( "DLabel" )
		self.Score:Dock( LEFT )
		self.Score:SetWidth( 150 )
		self.Score:SetFont( "ScoreboardDefault" )
		self.Score:SetTextColor( TextCol )
		self.Score:SetContentAlignment( 6 )

		self:Dock( TOP )
		self:DockPadding( 3, 3, 3, 3 )
		self:SetHeight( 32 + 3*2 )
		self:DockMargin( 2, 0, 2, 2 )

	end,

	Setup = function( self, pl )

		self.Player = pl

		self.Avatar:SetPlayer( pl )
		self.Name:SetText( pl:Name() )

		self:Think( self )

		--local friend = self.Player:GetFriendStatus()
		--MsgN( pl, " Friend: ", friend )

	end,

	Think = function( self )

		if ( !IsValid( self.Player ) ) then
			self:Remove()
			return
		end
		
		if ( self.NumRank == nil || self.NumRank != self.Player:GetNWInt("TKRank", 0) ) then
			self.NumRank		=	self.Player:GetNWInt("TKRank", 0)
			self.Rank:SetMaterial( self.Player:GetIcon() )
			self.Rank:SetToolTip( self.Player:GetGroup() )
		end
		
		if ( self.StrName == nil || self.StrName != self.Player:Name() ) then
			self.StrName		=	self.Player:Name()
			self.Name:SetText( self.StrName )
		end

		if ( self.NumScore == nil || self.NumScore != self.Player:GetNWInt("TKScore", 0) ) then
			self.NumScore		=	self.Player:GetNWInt("TKScore", 0)
			self.Score:SetText( TK:Format(self.NumScore) )
		end

		if ( self.NumPlaytime == nil || self.NumPlaytime != self.Player:GetNWInt("TKPlaytime", 0) ) then
			self.NumPlaytime	=	self.Player:GetNWInt("TKPlaytime", 0)
			self.Playtime:SetText( TK:FormatTime(self.NumPlaytime) )
		end

		if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
			self.NumPing		=	self.Player:Ping()
			self.Ping:SetText( self.NumPing )
		end

		--
		-- Change the icon of the mute button based on state
		--
		if ( self.muted == nil || self.muted != self.Player:IsMuted() ) then

			self.muted = self.Player:IsMuted()
			if ( self.muted ) then
				self.mute:SetImage( "icon32/muted.png" )
			else
				self.mute:SetImage( "icon32/unmuted.png" )
			end

			self.mute.DoClick = function() self.Player:SetMuted( !self.muted ) end

		end

	end,

	Paint = function( self, w, h )

		if ( !IsValid( self.Player ) ) then
			return
		end

		--
		-- We draw our background a different colour based on the status of the player
		--

		col = team.GetColor(self.Player:Team())
		draw.RoundedBox( 4, 0, 0, w, h, col )

	end,
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" );

--
-- Here we define a new panel table for the scoreboard. It basically consists 
-- of a header and a scrollpanel - into which the player lines are placed.
--
local SCORE_BOARD = 
{
	Init = function( self )

		self.Header = self:Add( "Panel" )
		self.Header:Dock( TOP )
		self.Header:SetHeight( 75 )

		self.Name = self.Header:Add( "DLabel" )
		self.Name:SetFont( "ScoreboardDefaultTitle" )
		self.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
		self.Name:Dock( TOP )
		self.Name:SetHeight( 40 )
		self.Name:SetContentAlignment( 5 )
		self.Name:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )

		--self.NumPlayers = self.Header:Add( "DLabel" )
		--self.NumPlayers:SetFont( "ScoreboardDefault" )
		--self.NumPlayers:SetTextColor( Color( 255, 255, 255, 255 ) )
		--self.NumPlayers:SetPos( 0, 100 - 30 )
		--self.NumPlayers:SetSize( 300, 30 )
		--self.NumPlayers:SetContentAlignment( 4 )

		self.Scores = self:Add( "DScrollPanel" )
		self.Scores:Dock( FILL )
		
		
		self.Titles = self.Scores:Add( "DPanel" )
		
		self.Titles.Name = self.Titles:Add( "DLabel" )
		self.Titles.Name:Dock( LEFT )
		self.Titles.Name:SetWidth( 150 )
		self.Titles.Name:SetFont( "ScoreboardDefault" )
		self.Titles.Name:DockMargin( 64, 0, 0, 0 )
		self.Titles.Name:SetContentAlignment( 4 )
		self.Titles.Name:SetText( "Player" )
		
		self.Titles.Score = self.Titles:Add( "DLabel" )
		self.Titles.Score:Dock( LEFT )
		self.Titles.Score:SetWidth( 150 )
		self.Titles.Score:SetFont( "ScoreboardDefault" )
		self.Titles.Score:SetContentAlignment( 5 )
		self.Titles.Score:SetText( "Score" )
		
		self.Titles.Ping = self.Titles:Add( "DLabel" )
		self.Titles.Ping:Dock( RIGHT )
		self.Titles.Ping:SetWidth( 50 )
		self.Titles.Ping:SetFont( "ScoreboardDefault" )
		self.Titles.Ping:DockMargin( 0, 0, 32, 0 )
		self.Titles.Ping:SetContentAlignment( 5 )
		self.Titles.Ping:SetText( "Ping" )
		
		self.Titles.Playtime = self.Titles:Add( "DLabel" )
		self.Titles.Playtime:Dock( FILL )
		self.Titles.Playtime:SetFont( "ScoreboardDefault" )
		self.Titles.Playtime:SetContentAlignment( 5 )
		self.Titles.Playtime:SetText( "Playtime" )
		
		self.Titles:Dock( TOP )
		self.Titles:DockPadding( 3, 3, 3, 3 )
		self.Titles:SetHeight( 32 + 3*2 )
		self.Titles:DockMargin( 2, 0, 2, 2 )
		
		self.Titles.Paint = function() return true end
		self.Titles:SetZPos( -10 )

		self.lastSort = 0

	end,

	PerformLayout = function( self )

		self:SetSize( 700, ScrH() - 200 )
		self:SetPos( ScrW() / 2 - 350, 100 )

	end,

	Paint = function( self, w, h )

		--draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )

	end,

	SortPlayers = function( self, force )

		if ( CurTime() - self.lastSort < 1 and !force ) then return end

		Players = player.GetAll()
		table.sort( Players, function(a, b)
			if ( a:Team() > b:Team() ) then return true end
			if ( a:Team() == b:Team() ) then
				if ( a:GetNWInt("TKScore", 0) > b:GetNWInt("TKScore", 0) ) then return true end
				if ( a:GetNWInt("TKScore", 0) == b:GetNWInt("TKScore", 0) ) then
					if ( a:GetNWInt("TKPlaytime", 0) > b:GetNWInt("TKPlaytime", 0) ) then return true end
					if ( a:GetNWInt("TKPlaytime", 0) == b:GetNWInt("TKPlaytime", 0) ) then
						return a:Name() < b:Name()
					end
				end
			end
			return false
		end)
		self.plyrs = Players

		self.lastSort = CurTime()

	end,

	Think = function( self, w, h )

		self.Name:SetText( GetHostName() )

		--
		-- Loop through each player, and if one doesn't have a score entry - create it.
		--
		self:SortPlayers(false)

		local z = 0
		for id, pl in ipairs( self.plyrs ) do
            if !IsValid(pl) then continue end
			if ( !IsValid( pl.ScoreEntry ) ) then
				pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
				pl.ScoreEntry:Setup( pl )

				self.Scores:AddItem( pl.ScoreEntry )
			end
			pl.ScoreEntry:SetZPos(z)
			z = z + 1

		end		

	end,
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" );

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardShow( )
   Desc: Sets the scoreboard to visible
-----------------------------------------------------------]]
function GM:ScoreboardShow()

	if ( !IsValid( g_Scoreboard ) ) then
		g_Scoreboard = vgui.CreateFromTable( SCORE_BOARD )
	end

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:SortPlayers(true)
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled( false )
	end

end

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardHide( )
   Desc: Hides the scoreboard
-----------------------------------------------------------]]
function GM:ScoreboardHide()

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Hide()
	end

end


--[[---------------------------------------------------------
   Name: gamemode:HUDDrawScoreBoard( )
   Desc: If you prefer to draw your scoreboard the stupid way (without vgui)
-----------------------------------------------------------]]
function GM:HUDDrawScoreBoard()

end

