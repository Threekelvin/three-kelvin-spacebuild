--/--- String Pool ---\\\
util.AddNetworkString("3k_term_key")
util.AddNetworkString("3k_term_test")
util.AddNetworkString("3k_term_request")
util.AddNetworkString("3k_terminal_resources_captcha_response")
util.AddNetworkString("3k_terminal_resources_captcha_challenge")
--/--- ---\\\
local Terminal = {}

--/--- Resources ---\\\
function Terminal.StorageToNode(ply, arg, ent)
    local Node, res, amt = Entity(tonumber(arg[1])), arg[2], tonumber(arg[3])
    if not IsValid(Node) or Node:CPPIGetOwner() ~= ply then return end

    if not Node.IsTKRD or not Node.IsNode then
        print("error", Node)

        return
    end

    if (Node:GetPos() - ent:GetPos()):LengthSqr() > TK.RT.Radius then return end
    local storage = TK.DB:GetPlayerData(ply, "player_terminal_storage").storage
    if not storage[res] then return end
    if storage[res] < amt then return end
    amt = Node:SupplyResource(res, amt)
    if amt <= 0 then return end
    storage[res] = storage[res] - amt
    storage[res] = storage[res] == 0 and nil or storage[res]

    TK.DB:UpdatePlayer(ply, "player_terminal_storage", {
        storage = storage
    })
end

function Terminal.NodeTostorage(ply, arg, ent)
    local Node, res, amt = Entity(tonumber(arg[1])), arg[2], tonumber(arg[3])
    if not IsValid(Node) or Node:CPPIGetOwner() ~= ply then return end
    if not Node.IsTKRD or not Node.IsNode then return end
    if (Node:GetPos() - ent:GetPos()):LengthSqr() > TK.RT.Radius then return end
    local storage = TK.DB:GetPlayerData(ply, "player_terminal_storage").storage
    amt = Node:ConsumeResource(res, amt)
    if amt <= 0 then return end
    storage[res] = math.floor((storage[res] or 0) + amt)

    TK.DB:UpdatePlayer(ply, "player_terminal_storage", {
        storage = storage
    })
end

function Terminal.GetCaptcha(ply)
    local setting = TK.DB:GetPlayerData(ply, "player_settings")

    return setting["captcha"]
end

function Terminal.NewCaptcha(ply)
    local captcha = string.random(5)

    TK.DB:UpdatePlayer(ply, "player_settings", {
        captcha = captcha
    })

    return captcha
end

net.Receive("3k_terminal_resources_captcha_challenge", function(len, ply)
    local challenge = net.ReadString()
    net.Start("3k_terminal_resources_captcha_response")
    net.WriteBit(string.lower(Terminal.GetCaptcha(ply)) == string.lower(challenge))
    net.Send(ply)
    Terminal.NewCaptcha(ply)
end)

--/--- ---\\\
--/--- Research ---\\\
function Terminal.AddResearch(ply, arg, ent)
    local idx = arg[1]
    local upgrades = TK.DB:GetPlayerData(ply, "terminal_upgrades")
    local data = TK.TD:GetUpgrade(idx)
    local cost = TK.TD:ResearchCost(ply, idx)
    local info = TK.DB:GetPlayerData(ply, "player_info")
    if cost == 0 or info.exp < cost then return end

    for k, v in pairs(data.req or {}) do
        if upgrades[v] ~= TK.TD:GetUpgrade(v).maxlvl then return end
    end

    TK.DB:UpdatePlayer(ply, "terminal_upgrades", {
        [idx] = upgrades[idx] + 1
    })
end

--/--- ---\\\
--/--- Loadout ---\\\
function Terminal.SetSlot(ply, arg, ent)
    local slot, idx, item = arg[1], tonumber(arg[2]), arg[3]
    local loadout = TK.DB:GetPlayerData(ply, "player_terminal_loadout").loadout
    local inventory = TK.DB:GetPlayerData(ply, "player_terminal_inventory").inventory
    local valid_items = {}

    for k, v in pairs(inventory) do
        if not TK.LO:IsSlot(v, slot) then continue end
        table.insert(valid_items, v)
    end

    for k, v in pairs(loadout) do
        if string.match(k, "^[%w]+") ~= slot then continue end

        for _, itm in pairs(valid_items) do
            if itm ~= v then continue end
            valid_items[_] = nil
            break
        end
    end

    for k, v in pairs(valid_items) do
        if v ~= item then continue end
        loadout[slot .. "_" .. idx] = item

        TK.DB:UpdatePlayer(ply, "player_terminal_loadout", {
            loadout = loadout
        })

        break
    end
end

--/--- ---\\\
--/--- Terminal ConCommand ---\\\
local function CanCall(ply, ent)
    if not IsValid(ent) then return false end
    if ent:GetClass() ~= "tk_terminal" then return false end
    if (ply:GetPos() - ent:GetPos()):LengthSqr() > 22500 then return false end

    return true
end

local function BuildString(data)
    local str = [[]]

    for k, v in ipairs(data) do
        str = str .. string.char(v)
    end

    return str
end

local function BuildTable(data)
    return {string.byte(data, 1, string.len(data))}
end

net.Receive("3k_term_request", function(len, ply)
    local ent = net.ReadEntity()
    local data = BuildString(net.ReadTable())
    if not CanCall(ply, ent) then return end

    local arg = string.Explode(" ", data)
    local cmd = table.remove(arg, 1)

    if cmd == "storagetonode" then
        Terminal.StorageToNode(ply, arg, ent)
    elseif cmd == "nodetostorage" then
        Terminal.NodeTostorage(ply, arg, ent)
    elseif cmd == "addresearch" then
        Terminal.AddResearch(ply, arg, ent)
    elseif cmd == "setslot" then
        Terminal.SetSlot(ply, arg, ent)
    end
end)
