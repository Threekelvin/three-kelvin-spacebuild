
include('shared.lua')

local POM_copy = {}

local function BuildResearchTable(dir)
	local Research = {}
	
	for k,v in pairs(TK.TD.ResearchData[dir] || {}) do
		Research[k] = 0
	end
	
	return Research
end

usermessage.Hook("TKOSSync", function(msg)
	local servertime = tonumber(msg:ReadString())
	TK.OSSync = math.ceil(servertime - os.time())
end)

hook.Add("Initialize", "SWDownload", function()
    function steamworks.Download(workshopPreviewID, bool, unknown, callback)
        if callback then callback() end
    end
    
    POM_copy = list.Get("PlayerOptionsModel")
end)

hook.Add("TKDBPlayerData", "PlayerModels", function(dbtable, idx, data)
    if dbtable != "player_info" then return end
    if idx != "rank" then return end
    
    local pmodels = list.GetForEdit("PlayerOptionsModel")
    local newlist = table.Copy(POM_copy)
    for k,v in pairs(newlist) do
        if !TK.PlyModels[v] then continue end
        if LocalPlayer():GetRank() < TK.PlyModels[v].rank || 1 then
            newlist[k] = nil
        end
        
        for _,sid in pairs(TK.PlyModels[v].sid || {}) do
            if LocalPlayer():SteamID() != sid then 
                newlist[k] = nil
            end
        end
    end
    
    pmodels = newlist
end)