
local PLUGIN = {}
PLUGIN.Name       = "AFK"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "AFK"
PLUGIN.Auto       = {}
PLUGIN.Level      = 1

if SERVER then
	local Inputs = {IN_ATTACK, IN_JUMP, IN_DUCK, IN_FORWARD, IN_BACK, IN_USE, IN_LEFT, IN_RIGHT, IN_MOVELEFT, IN_MOVERIGHT, IN_ATTACK2, IN_RELOAD, IN_SCORE, IN_ZOOM, IN_ALT1, IN_ALT2}
	
	function PLUGIN.Call(ply, arg)
		if IsValid(ply) && ply:HasAccess(PLUGIN.Level) then
			if ply.afk then
				ply.afk = nil
				umsg.Start("TKAFK", ply)
					umsg.Bool(false)
				umsg.End()
				timer.Create("TK AFK "..tostring(ply), 600, 0, function() PLUGIN.Call(ply) end)
				TK.AM:RemoveAFKBubble(ply)
				TK.AM:SystemMessage({ply, " Is Back"})
			else
				ply.afk = true
				umsg.Start("TKAFK", ply)
					umsg.Bool(true)
				umsg.End()
				timer.Remove("TK AFK "..tostring(ply))
				TK.AM:AddAFKBubble(ply)
                
                local msg = '"..table.concat(arg || {}, " ").."'"
				TK.AM:SystemMessage({ply, " Is AFK ".. msg == "''" && "" || msg})
			end
		end
	end
	
	hook.Add("PlayerInitialSpawn", "TKAFKTimer", function(ply)
		timer.Create("TK AFK "..tostring(ply), 600, 0, function() PLUGIN.Call(ply) end)
	end)
	
	hook.Add("KeyPress", "TKAFKTimer", function(ply, key)
		if table.HasValue(Inputs, key) then
			if ply.afk then
				PLUGIN.Call(ply)
			else
				timer.Remove("TK AFK "..tostring(ply))
				timer.Create("TK AFK "..tostring(ply), 600, 0, function() PLUGIN.Call(ply) end)
			end
		end
	end)
	
	hook.Add("PlayerDisconnected", "TKAFKTimer", function(ply)
		timer.Remove("TK AFK "..tostring(ply))
	end)
else
	hook.Add("Initialize", "AFKInit", function()
		function GAMEMODE:TKafk(isAFK)
		end
	end)
	
	usermessage.Hook("TKAFK", function(msg)
		if msg:ReadBool() then
			hook.Add("HUDPaint", "TK_Blackout", function()
				local width, height = surface.ScreenWidth(), surface.ScreenHeight()
				draw.RoundedBox(0, 0, 0, width, height, Color(0,0,0,255))
				draw.SimpleText("You Are AFK!", "TKFont45", width / 2, height / 2, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			end)
			gamemode.Call("TKafk", true)
		else
			hook.Remove("HUDPaint", "TK_Blackout")
			gamemode.Call("TKafk", false)
		end
	end)
end

TK.AM:RegisterPlugin(PLUGIN)