
local PLUGIN = {}
PLUGIN.Name       = "Restart"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Restart"
PLUGIN.Auto       = {"number"}
PLUGIN.Level      = 5

if SERVER then
	local Restart = false
	local function PlaySound(sound)
		for k,v in pairs(player.GetAll()) do
			v:ConCommand("playgamesound "..sound)
		end
	end

	util.AddNetworkString("HUD_WARNING")
	local function HUDwarning( ply, message )
		net.Start( "HUD_WARNING" )
			net.WriteString( "restart" )
			net.WriteString( message )
		net.Send( ply )
	end

	function PLUGIN.Call(ply, arg)
		if ply:HasAccess(PLUGIN.Level) then
			if !Restart then
				if table.Count(player.GetAll()) == 0 then
					RunConsoleCommand("changelevel", game.GetMap())
					return
				end
				Restart = true
				HUDwarning( player.GetAll(), "Restart in progress..." )
				RunConsoleCommand("sv_password", "restarting")
				local Time = math.Clamp(tonumber(arg[1]) || 120, 10, 120)
				
				TK.AM:SystemMessage({ply, " Has Started A Restart!"})
				
				timer.Create("server_restart", 1, 0, function()
					if Time == 120 then
						PlaySound('ambient/alarms/citadel_alert_loop2.wav')
						PlaySound('npc/overwatch/cityvoice/fcitadel_2minutestosingularity.wav')
						TK.AM:SystemMessage({"Server Restart In "..Time.." Seconds"})
					elseif Time == 90 then
						PlaySound('ambient/alarms/citadel_alert_loop2.wav')
					elseif Time == 60 then
						PlaySound('ambient/alarms/citadel_alert_loop2.wav')
						PlaySound('npc/overwatch/cityvoice/fcitadel_1minutetosingularity.wav')
						TK.AM:SystemMessage({"Server Restart In "..Time.." Seconds"})
					elseif Time == 45 then
						PlaySound('npc/overwatch/cityvoice/fcitadel_45sectosingularity.wav')
						TK.AM:SystemMessage({"Server Restart In "..Time.." Seconds"})
					elseif Time == 30 then
						PlaySound('ambient/alarms/citadel_alert_loop2.wav')
						PlaySound('npc/overwatch/cityvoice/fcitadel_30sectosingularity.wav')
						TK.AM:SystemMessage({"Server Restart In "..Time.." Seconds"})
					elseif Time == 15 then
						PlaySound('npc/overwatch/cityvoice/fcitadel_15sectosingularity.wav')
						TK.AM:SystemMessage({"Server Restart In "..Time.." Seconds"})
					elseif Time == 10 then
						PlaySound('npc/overwatch/cityvoice/fcitadel_10sectosingularity.wav')
						TK.AM:SystemMessage({"Server Restart In "..Time.." Seconds"})
					elseif Time < 10 then
						if Time <=0 then
							RunConsoleCommand("sv_password", "")
							RunConsoleCommand("changelevel", game.GetMap())
							timer.Remove("server_restart")
						end
						TK.AM:SystemMessage({"Server Restart In "..Time.." Seconds"})
					end
					
					Time = Time - 1
				end)
			else
				Restart = false
				HUDwarning( player.GetAll(), "" )
				RunConsoleCommand("sv_password", "")
				timer.Remove("server_restart")
				TK.AM:StopSounds()
				TK.AM:SystemMessage({ply, " Has Stopped The Restart!"})
			end
		else
			TK.AM:SystemMessage({"Access Denied!"}, {ply}, 1)
		end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)