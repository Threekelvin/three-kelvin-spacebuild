
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include('shared.lua')

gameevent.Listen("player_connect")
gameevent.Listen("player_disconnect")