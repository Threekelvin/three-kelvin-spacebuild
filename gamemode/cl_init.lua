
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

///--- Spawnmenu Legacy Addons ---\\\
local function GetLegacyAddons()
    local data = {}
    local files, folders = file.Find("addons/*", "GAME")
    for k,v in pairs(folders) do
        if !file.Exists("addons/" ..v.. "/addon.txt", "GAME") then continue end
        if !file.Exists("addons/" ..v.. "/models", "GAME") then continue end
        table.insert(data, v)
    end
    return data
end

local function PopulateNode(root, dir, parent, pnl, vp)
    local _, folders = file.Find(root .. dir .. "*", "GAME")
    for k,v in pairs(folders) do
        local child = parent:AddNode(v, "icon16/folder_database.png")
        PopulateNode(root, dir .. v .. "/", child, pnl, vp)
    end
    
    parent.DoClick = function()
        vp:Clear(true)
        
        local files = file.Find(root .. dir .. "*", "GAME")
        for k,v in pairs(files) do
            if string.match(v, "[%w]+$") != "mdl" then continue end
            local cp = spawnmenu.GetContentType("model")
            if cp then
                cp(vp, {model = dir .. v})
            end
        end
        
		pnl:SwitchPanel(vp)
    end
end

hook.Add("PopulateContent", "Legacy Addons", function(pnlContent, tree, node)
    local ViewPanel = vgui.Create("ContentContainer", pnlContent)
	ViewPanel:SetVisible(false)
    local parent = node:AddNode("Legacy Addons", "icon16/folder_database.png")
    
    for k,v in pairs(GetLegacyAddons()) do
        local child = parent:AddNode(v, "icon16/folder_database.png")
        PopulateNode("addons/" ..v.. "/", "models/", child, pnlContent, ViewPanel)
    end
end)
///--- ---\\\