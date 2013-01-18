
local TKGC = {}

function TKGC:ExtractFlag(num, flag)
	if flag > 7 || num > 4 then return false end
	if flag >= 4 then
		flag = flag - 4
		if num == 4 then return true end
	end
	if flag >= 2 then
		flag = flag - 2
		if num == 2 then return true end
	end
	if flag >= 1 then
		flag = flag - 1
		if num == 1 then return true end
	end
	return false
end

function TKGC:WriteMessage()
	if TKGC:ExtractFlag(2, data.flag) then
		chat.AddText(Color(255,140,0), data.server.." [Admin] ", TK.AM.Rank.RGBA[data.rank], TK.AM.Rank.Tag[data.rank], team.GetColor(data.faction), data.name, Color(255,255,255), ": "..data.text)
	elseif TKGC:ExtractFlag(1, data.flag) then
		if TKGC:ExtractFlag(4, data.flag) then
			chat.AddText(Color(255,140,0), data.server, Color(30,160,40), " (Team) ", TK.AM.Rank.RGBA[data.rank], TK.AM.Rank.Tag[data.rank], team.GetColor(data.faction), data.name, " "..data.text)
		else
			chat.AddText(Color(255,140,0), data.server, Color(30,160,40), " (Team) ", TK.AM.Rank.RGBA[data.rank], TK.AM.Rank.Tag[data.rank], team.GetColor(data.faction), data.name, Color(255,255,255), ": "..data.text)
		end	
	elseif TKGC:ExtractFlag(4, data.flag) then
		chat.AddText(Color(255,140,0), data.server.." ", TK.AM.Rank.RGBA[data.rank], TK.AM.Rank.Tag[data.rank], team.GetColor(data.faction), data.name, " "..data.text)
	else
		chat.AddText(Color(255,140,0), data.server.." ", TK.AM.Rank.RGBA[data.rank], TK.AM.Rank.Tag[data.rank], team.GetColor(data.faction), data.name, Color(255,255,255), ": "..data.text)
	end
end

net.Receive("TKGC_Msg", function()
    local key = net.ReadFloat()
    if key == 1 then
        local flag = net.ReadFloat()
        local server = net.ReadString()
        local rank = net.ReadFloat()
        local faction = net.ReadFloat()
        local name = net.ReadString()
        local msg = net.ReadString()
        
        if TKGC:ExtractFlag(4, flag) then
            chat.AddText(Color(255,140,0), server.." [Admin] ", TK.AM.Rank.RGBA[rank], TK.AM.Rank.Tag[rank], team.GetColor(faction), name, Color(255,255,255), ": "..msg)
        elseif TKGC:ExtractFlag(2, flag) then
            if TKGC:ExtractFlag(1, flag) then
                chat.AddText(Color(255,140,0), server, Color(30,160,40), " (Team) ", TK.AM.Rank.RGBA[rank], TK.AM.Rank.Tag[rank], team.GetColor(faction), name, " "..msg)
            else
                chat.AddText(Color(255,140,0), server, Color(30,160,40), " (Team) ", TK.AM.Rank.RGBA[rank], TK.AM.Rank.Tag[rank], team.GetColor(faction), name, Color(255,255,255), ": "..msg)
            end	
        elseif TKGC:ExtractFlag(1, flag) then
            chat.AddText(Color(255,140,0), server.." ", TK.AM.Rank.RGBA[rank], TK.AM.Rank.Tag[rank], team.GetColor(faction), name, " "..msg)
        else
            chat.AddText(Color(255,140,0), server.." ", TK.AM.Rank.RGBA[rank], TK.AM.Rank.Tag[rank], team.GetColor(faction), name, Color(255,255,255), ": "..msg)
        end        
    elseif key == 2 then
        local server = net.ReadString()
        local msg = net.ReadString()
        
        chat.AddText(Color(255,140,0), server.." ", Color(255,255,255), msg)
    end
end)

