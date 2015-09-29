DEFINE_BASECLASS("player_default")

if CLIENT then
    CreateConVar("cl_playercolor", "0.24 0.34 0.41", {FCVAR_ARCHIVE,  FCVAR_USERINFO,  FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - !between 0-255")
    CreateConVar("cl_weaponcolor", "0.30 1.80 2.10", {FCVAR_ARCHIVE,  FCVAR_USERINFO,  FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - !between 0-255")
end

local PLAYER = {}
PLAYER.TauntCam = TauntCamera()
PLAYER.WalkSpeed = 200
PLAYER.RunSpeed = 400
PLAYER.TeammateNoCollide = false
PLAYER.AvoidPlayers = false

function PLAYER:SetupDataTables()
end

function PLAYER:Loadout()
    self.Player:StripWeapons()
    self.Player:StripAmmo()
    self.Player:Give("weapon_physcannon")
    self.Player:Give("weapon_physgun")
    self.Player:Give("gmod_camera")
    self.Player:Give("gmod_tool")
    self.Player:Give("none")
    local cl_defaultweapon = self.Player:GetInfo("cl_defaultweapon")

    if self.Player:HasWeapon(cl_defaultweapon) then
        self.Player:SelectWeapon(cl_defaultweapon)
    end
end

function PLAYER:Spawn()
    TK:SetSpawnPoint(self.Player, self.Player:Team())
    self.Player:TakeDamage(0)
    local col = self.Player:GetInfo("cl_playercolor")
    self.Player:SetPlayerColor(Vector(col))
    col = team.GetColor(self.Player:Team())
    self.Player:SetWeaponColor(Vector(col.r / 255, col.g / 255, col.b / 255))
    self.Player:SetupHands()
end

function PLAYER:ShouldDrawLocal()
    if self.TauntCam:ShouldDrawLocalPlayer(self.Player, self.Player:IsPlayingTaunt()) then return true end
end

function PLAYER:CreateMove(cmd)
    if self.TauntCam:CreateMove(cmd, self.Player, self.Player:IsPlayingTaunt()) then return true end
end

function PLAYER:CalcView(view)
    if self.TauntCam:CalcView(view, self.Player, self.Player:IsPlayingTaunt()) then return true end
end

player_manager.RegisterClass("player_tk", PLAYER, "player_default")
