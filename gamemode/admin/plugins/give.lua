
local PLUGIN = {}
PLUGIN.Name       = "Give Credits"
PLUGIN.Prefix     = "!"
PLUGIN.Command    = "Give"
PLUGIN.Level      = 1

if SERVER then
	function PLUGIN.Call(ply, arg)
        if !IsValid(ply) then return end
        local count, targets = TK.AM:FindPlayer(arg[1])
        
        if count == 0 then
            TK.AM:SystemMessage({"No Target Found"}, {ply}, 2)
        elseif count > 1 then
            TK.AM:SystemMessage({"Multiple Targets Found"}, {ply}, 2)	
        else
            local tar = targets[1]
            local amount = tonumber(arg[2])
            if !amount || amount <= 0 then
                TK.AM:SystemMessage({"Invalid Amount"}, {ply}, 2)	
                return
            end
            
            amount = math.floor(amount)
            
            local credits = TK.DB:GetPlayerData(ply, "player_info").credits
            if amount > credits then return end
            
            TK.DB:UpdatePlayerData(ply, "player_info", {credits = credits - amount})
            local credits = TK.DB:GetPlayerData(tar, "player_info").credits
            TK.DB:UpdatePlayerData(tar, "player_info", {credits = credits + amount})
            
            TK.AM:SystemMessage({"Given ", tar, " "..TK:Format(amount).." Credits"}, {ply}, 2)
            TK.AM:SystemMessage({"Recived ", TK:Format(amount).." Credits From ", ply}, {tar}, 2)
        end
	end
else

end

TK.AM:RegisterPlugin(PLUGIN)