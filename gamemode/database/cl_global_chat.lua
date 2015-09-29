TK.DB = TK.DB or {}

local function ExtractFlag(flag, id)
    return bit.band(id, flag) == id
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

        if ExtractFlag(flag, 4) then
            chat.AddText(Color(255, 140, 0), server .. " [Admin] ", TK.AM.Rank.RGBA[rank], TK.AM.Rank.Tag[rank], team.GetColor(faction), name, Color(255, 255, 255), ": " .. msg)
        elseif ExtractFlag(flag, 2) then
            if ExtractFlag(flag, 1) then
                chat.AddText(Color(255, 140, 0), server, Color(30, 160, 40), " (Team) ", TK.AM.Rank.RGBA[rank], TK.AM.Rank.Tag[rank], team.GetColor(faction), name, " " .. msg)
            else
                chat.AddText(Color(255, 140, 0), server, Color(30, 160, 40), " (Team) ", TK.AM.Rank.RGBA[rank], TK.AM.Rank.Tag[rank], team.GetColor(faction), name, Color(255, 255, 255), ": " .. msg)
            end
        elseif ExtractFlag(flag, 1) then
            chat.AddText(Color(255, 140, 0), server .. " ", TK.AM.Rank.RGBA[rank], TK.AM.Rank.Tag[rank], team.GetColor(faction), name, " " .. msg)
        else
            chat.AddText(Color(255, 140, 0), server .. " ", TK.AM.Rank.RGBA[rank], TK.AM.Rank.Tag[rank], team.GetColor(faction), name, Color(255, 255, 255), ": " .. msg)
        end
    elseif key == 2 then
        local server = net.ReadString()
        local msg = net.ReadString()
        chat.AddText(Color(255, 140, 0), server .. " ", Color(255, 255, 255), msg)
    end
end)
