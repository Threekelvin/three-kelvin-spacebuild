
include('shared.lua')

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
end)