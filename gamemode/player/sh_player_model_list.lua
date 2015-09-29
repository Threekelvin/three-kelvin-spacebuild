local ply_models = {
    ["models/applejack_player.mdl"] = {
        rank = 2
    },
    ["models/bonbon_player.mdl"] = {
        rank = 2
    },
    ["models/celestia_player.mdl"] = {
        rank = 2
    },
    ["models/colgate_player.mdl"] = {
        rank = 2
    },
    ["models/daringdoo_player.mdl"] = {
        rank = 2
    },
    ["models/derpyhooves_player.mdl"] = {
        rank = 2
    },
    ["models/devpisti01_player.mdl"] = {
        rank = 2
    },
    ["models/fluttershy_player.mdl"] = {
        rank = 2
    },
    ["models/luna_player.mdl"] = {
        sid = {"STEAM_0:1:21860684"}
    },
    ["models/lyra_player.mdl"] = {
        rank = 2
    },
    ["models/octavia_player.mdl"] = {
        rank = 2
    },
    ["models/pinkiepie_player.mdl"] = {
        sid = {"STEAM_0:0:4832636"}
    },
    ["models/princesstwilight_player.mdl"] = {
        rank = 2
    },
    ["models/rainbowdash_player.mdl"] = {
        rank = 2
    },
    ["models/raindrops_player.mdl"] = {
        rank = 2
    },
    ["models/rarity_player.mdl"] = {
        rank = 2
    },
    ["models/roseluck_player.mdl"] = {
        rank = 2
    },
    ["models/spitfire_player.mdl"] = {
        sid = {"STEAM_0:1:17838782"}
    },
    ["models/trixie_player.mdl"] = {
        sid = {"STEAM_0:0:34442445"}
    },
    ["models/twilightsparkle_player.mdl"] = {
        rank = 2
    },
    ["models/vinyl_player.mdl"] = {
        rank = 2
    }
}

function TK:CanUsePlayerModel(ply, mdl)
    if not ply_models[mdl] then return true end

    if ply_models[mdl].sid then
        for k, v in pairs(ply_models[mdl].sid) do
            if ply:SteamID() == v then return true end
        end

        return false
    end

    if ply:GetRank() >= (ply_models[mdl].rank or 1) then return true end

    return false
end
