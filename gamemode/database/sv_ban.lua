TK.DB = TK.DB or {}

function TK.DB:AddBan(admin, tarid, tarip, length, reason)
    local a_sid = IsValid(admin) and admin:SteamID() or "Console"
    local a_ip = IsValid(admin) and admin:Ip() or TK:HostName()

    self:InsertQuery("server_ban_data", {
        ply_steamid = tarid,
        ply_ip = tarip,
        ban_start = "DB_TIME",
        ban_lenght = length,
        ban_reason = reason,
        adm_steamid = a_sid,
        adm_ip = a_ip
    })
end
