
///--- String Pool ---\\\
util.AddNetworkString("3k_term_key")
util.AddNetworkString("3k_term_test")
util.AddNetworkString("3k_term_request")

util.AddNetworkString("3k_term_ref_begin")
util.AddNetworkString("3k_term_ref_finish")

util.AddNetworkString("3k_terminal_resources_captcha_response")
util.AddNetworkString("3k_terminal_resources_captcha_challenge")
///--- ---\\\

local Terminal = {}

///--- Resources ---\\\
function Terminal.StorageToNode(ply, arg)
    local Node, res, amt = Entity(tonumber(arg[1])), arg[2], tonumber(arg[3])
    if !IsValid(Node) || Node:CPPIGetOwner() != ply then return end
    if !Node.IsTKRD || !Node.IsNode then print("error", Node) return end
    if (Node:GetPos() - TK.Settings.Term.Pos):LengthSqr() > TK.Settings.Term.Size then return end
    local storage = TK.DB:GetPlayerData(ply, "terminal_storage")
    if !storage[res] then return end
    if storage[res] < amt then return end
    
    local amt = Node:SupplyResource(res, amt)
    if amt <= 0 then return end

    TK.DB:UpdatePlayerData(ply, "terminal_storage", {[res] = storage[res] - amt})
end

function Terminal.NodeTostorage(ply, arg)
    local Node, res, amt = Entity(tonumber(arg[1])), arg[2], tonumber(arg[3])
    if !IsValid(Node) || Node:CPPIGetOwner() != ply then return end
    if !Node.IsTKRD || !Node.IsNode then return end
    if !TK.TD:AcceptResource(res) then return end
    if (Node:GetPos() - TK.Settings.Term.Pos):LengthSqr() > TK.Settings.Term.Size then return end
    local storage = TK.DB:GetPlayerData(ply, "terminal_storage")
    storage[res] = storage[res] || 0

    local amt = Node:ConsumeResource(res, amt)
    if amt <= 0 then return end

    TK.DB:UpdatePlayerData(ply, "terminal_storage", {[res] = math.floor(storage[res] + amt)})
end

function Terminal.GetCaptcha(ply)
    local setting = TK.DB:GetPlayerData(ply, "terminal_setting")
    return setting["captcha"]
end

function Terminal.NewCaptcha(ply)
    local captcha = string.random(5)
    TK.DB:UpdatePlayerData(ply, "terminal_setting", {["captcha"] = captcha})
    return captcha
end

net.Receive("3k_terminal_resources_captcha_challenge", function(len,ply)
    local challenge = net.ReadString()
    net.Start("3k_terminal_resources_captcha_response")
        net.WriteBit(string.lower(Terminal.GetCaptcha(ply)) == string.lower(challenge))
    net.Send(ply)
    Terminal.NewCaptcha(ply)
end)
///--- ---\\\

///--- Refinery ---\\\
function Terminal.StartRefine(ply, res)
    local storage, newstorage = TK.DB:GetPlayerData(ply, "terminal_storage"), {}
    local refinery, newrefinery = TK.DB:GetPlayerData(ply, "terminal_refinery"), {}
    local settings = TK.DB:GetPlayerData(ply, "terminal_setting")
    local newtime = 0
    
    for k,v in pairs(res) do
        if !storage[k] || storage[k] < v then continue end
        
        newstorage[k] = storage[k] - v
        newrefinery[k] = refinery[k] + v
        newtime = newtime + (v / TK.TD:Refine(ply, k))
    end
    
    if newtime > 0 then

        TK.DB:UpdatePlayerData(ply, "terminal_storage", newstorage)
        TK.DB:UpdatePlayerData(ply, "terminal_refinery", newrefinery)
        
        if settings.refine_length == 0 then
            newtime = math.floor(newtime)
            TK.DB:UpdatePlayerData(ply, "terminal_setting", {refine_started = true, refine_length = newtime})
        else
            newtime = math.floor(newtime + settings.refine_length)
            TK.DB:UpdatePlayerData(ply, "terminal_setting", {refine_length = newtime})
        end
        
        net.Start("3k_term_ref_start")
            net.WriteBit(true)
        net.Send(ply)
    end
end

function Terminal.EndRefine(ply)
    local refinery, newrefinery = TK.DB:GetPlayerData(ply, "terminal_refinery"), {}
    local info = TK.DB:GetPlayerData(ply, "player_info")
    local totalvalue = 0
    
    for k,v in pairs(refinery) do
        if v > 0 then
            local value = TK.TD:Ore(ply, k)
            newrefinery[k] = 0
            totalvalue = totalvalue + (v * value)
        end
    end

    if totalvalue > 0 then
        local credits = math.floor(info.credits + totalvalue)
        local score = math.floor(info.score + totalvalue * 0.25)
        local exp = math.floor(info.exp + totalvalue * 0.125)
        
        TK.DB:UpdatePlayerData(ply, "player_info", {credits = credits, score = score, exp = exp})
        
        TK.DB:UpdatePlayerData(ply, "terminal_refinery", newrefinery)
        TK.DB:UpdatePlayerData(ply, "terminal_setting", {refine_started = 0, refine_length = 0})
        net.Start("3k_term_ref_finish")
        net.Send(ply)
    end
end

hook.Add("Initialize", "TKRefinery", function()
    timer.Create("TKRefinery", 10, 0, function()
        for k,v in pairs(player.GetAll()) do
            local settings = TK.DB:GetPlayerData(v, "terminal_setting")
            local complete = settings.refine_started + settings.refine_length
            if complete == 0 then continue end
            if TK.DB:OSTime() >= complete then
                Terminal.EndRefine(v)
            end
        end
    end)
end)

function Terminal.Refine(ply, arg)
    Terminal.StartRefine(ply, {[arg[1]] = tonumber(arg[2])})
end

function Terminal.RefineAll(ply, arg)
    local storage, res = TK.DB:GetPlayerData(ply, "terminal_storage"), {}
    res["asteroid_ore"] = storage["asteroid_ore"] || 0
    res["raw_tiberium"] = storage["raw_tiberium"] || 0
    
    Terminal.StartRefine(ply, res)
end

function Terminal.CancelRefine(ply, arg)
    local storage, newstorage = TK.DB:GetPlayerData(ply, "terminal_storage"), {}
    local refinery, newrefinery = TK.DB:GetPlayerData(ply, "terminal_refinery"), {}
    
    for k,v in pairs(refinery) do
        newstorage[k] = storage[k] + v
        newrefinery[k] = 0
    end

    TK.DB:UpdatePlayerData(ply, "terminal_storage", newstorage)
    TK.DB:UpdatePlayerData(ply, "terminal_refinery", newrefinery)
    TK.DB:UpdatePlayerData(ply, "terminal_setting", {refine_started = 0, refine_length = 0})
    
    net.Start("3k_term_ref_start")
        net.WriteBit(false)
    net.Send(ply)
end
///--- ---\\\

///--- Research ---\\\
function Terminal.AddResearch(ply, arg)
    local idx = arg[1]
    local upgrades = TK.DB:GetPlayerData(ply, "terminal_upgrades")
    local data = TK.TD:GetUpgrade(idx)
    local cost = TK.TD:ResearchCost(ply, idx)
    local info = TK.DB:GetPlayerData(ply, "player_info")
    
    if cost == 0 || info.exp < cost then return end
    for k,v in pairs(data.req || {}) do
        if upgrades[v] != TK.TD:GetUpgrade(v).maxlvl then
            return 
        end
    end


    TK.DB:UpdatePlayerData(ply, "terminal_upgrades", {[idx] = upgrades[idx] + 1})
    TK.DB:UpdatePlayerData(ply, "player_info", {exp = info.exp - cost})
end
///--- ---\\\

///--- Loadout ---\\\
function Terminal.SetSlot(ply, arg)
    local slot, idx, item = arg[1], tonumber(arg[2]), tonumber(arg[3])
    local loadout = TK.DB:GetPlayerData(ply, "player_loadout")
    local inventory = TK.DB:GetPlayerData(ply, "player_inventory").inventory
    local validitems = {}
    
    for k,v in pairs(inventory) do
        if !TK.TD:IsSlot(slot, v) then continue end
        table.insert(validitems, v)
    end
    
    for k,v in pairs(loadout) do
        if string.match(k, "^[%w]+") != slot then continue end
        if string.match(k, "[%w]+$") != "item" then continue end

        for _,itm in pairs(validitems) do
            if itm != v then continue end
            validitems[_] = nil
            break
        end
    end
    
    for k,v in pairs(validitems) do
        if v != item then continue end
        TK.DB:UpdatePlayerData(ply, "player_loadout", {[slot.. "_" ..idx.. "_item"] = item})
        break
    end
end
///--- ---\\\

///--- Market ---\\\

///--- ---\\\

///--- Terminal ConCommand ---\\\
local SecureInfo = {}
local SecureKeys = {}

local function CanCall(ply)
    for k,v in pairs(ents.FindByClass("tk_terminal")) do
        if (ply:GetPos() - v:GetPos()):LengthSqr() < 22500 then
            return true
        end
    end
    return false
end

local function BuildString(data)
    local str = [[]]
    for k,v in ipairs(data) do
        str = str .. string.char(v)
    end
    return str
end

local function BuildTable(data)
    return {string.byte(data, 1, string.len(data))}
end

net.Receive("3k_term_key", function(len, ply)
    local uid = ply:UID()
    if SecureKeys[uid] then return end
    SecureKeys[uid] = {}
    
    SecureKeys[uid].encrypt_key = BuildString(net.ReadTable())
    SecureKeys[uid].decrypt_key = BuildString(net.ReadTable())

    SecureInfo[uid] = string.random(32)
    local crypt = aeslua.encrypt(SecureKeys[uid].decrypt_key, SecureInfo[uid])
    
    net.Start("3k_term_test")
        net.WriteTable(BuildTable(crypt))
    net.Send(ply)
end)

net.Receive("3k_term_request", function(len, ply)
    local uid = ply:UID()
    if !CanCall(ply) then return end

    local pwd = BuildString(net.ReadTable())
    local crypt =  BuildString(net.ReadTable())
    local arg = aeslua.decrypt(SecureKeys[uid].encrypt_key, crypt)

    if pwd == SecureInfo[uid] then
        arg = string.Explode(" ", arg)
        local cmd = table.remove(arg, 1)
        
        if cmd == "storagetonode" then
            Terminal.StorageToNode(ply, arg)
        elseif cmd == "nodetostorage" then
            Terminal.NodeTostorage(ply, arg)
        elseif cmd == "refine" then
            Terminal.Refine(ply, arg)
        elseif cmd == "refineall" then
            Terminal.RefineAll(ply, arg)
        elseif cmd == "cancelrefine" then
            Terminal.CancelRefine(ply, arg)
        elseif cmd == "addresearch" then
            Terminal.AddResearch(ply, arg)
        elseif cmd == "setslot" then
            Terminal.SetSlot(ply, arg)
        end
    end
    
    SecureInfo[uid] = string.random(32)
    local crypt = aeslua.encrypt(SecureKeys[uid].decrypt_key, SecureInfo[uid])
    
    net.Start("3k_term_test")
        net.WriteTable(BuildTable(crypt))
    net.Send(ply)
end)

hook.Add("PlayerDisconnected", "term", function(ply)
    local uid = ply:UID()
    SecureInfo[uid] = nil
    SecureKeys[uid] = nil
end)
///--- ---\\\