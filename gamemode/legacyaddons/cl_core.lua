
local file = file
local Legacy = {}
Legacy.NextThink = 0
Legacy.Queue = {}

function Legacy:GetAddons()
    local data = {}
    local files, folders = file.Find("addons/*", "GAME")
    for k,v in pairs(folders || {}) do
        if !file.Exists("addons/" ..v.. "/addon.txt", "GAME") then continue end
        if !file.Exists("addons/" ..v.. "/models", "GAME") then continue end
        table.insert(data, v)
    end
    return data
end

function Legacy:PopulateNode(root, dir, parent, pnl, vp)
    local _, folders = file.Find(root .. dir .. "*", "GAME")
    for k,v in pairs(folders || {}) do
        local child = parent:AddNode(v, "icon16/folder_database.png")
        self:AddToQueue(root, dir .. v .. "/", child, pnl, vp)
    end
    
    parent.DoClick = function()
        vp:Clear(true)
        
        local files = file.Find(root .. dir .. "*", "GAME")
        for k,v in pairs(files || {}) do
            if !v:match(".mdl$") then continue end
            local cp = spawnmenu.GetContentType("model")
            if !cp then continue end
            cp(vp, {model = dir .. v})
        end
        
        pnl:SwitchPanel(vp)
    end
end

function Legacy:AddToQueue(root, dir, parent, pnl, vp)
    table.insert(self.Queue, {root, dir, parent, pnl, vp})
end

hook.Add("PopulateContent", "Legacy Addons", function(pnlContent, tree, node)
    local ViewPanel = vgui.Create("ContentContainer", pnlContent)
    ViewPanel:SetVisible(false)
    local parent = node:AddNode("Legacy Addons", "icon16/folder_database.png")
    
    for k,v in pairs(Legacy:GetAddons()) do
        local child = parent:AddNode(v, "icon16/folder_database.png")
        Legacy:AddToQueue("addons/" ..v.. "/", "models/", child, pnlContent, ViewPanel)
    end
end)


hook.Add("Tick", "LegacyAddons", function()
    if Legacy.NextThink > CurTime() then return end
    Legacy.NextThink = CurTime() + 0.1
    local id, data = next(Legacy.Queue)
    if !id then return end
    
    Legacy:PopulateNode(data[1], data[2], data[3], data[4], data[5])
    Legacy.Queue[id] = nil
end)