
TK.PP = TK.PP or {}

TK.PP.Permissions = {
    ["Tool Gun"]    = 1,
    ["Grav Gun"]    = 2,
    ["Phys Gun"]    = 4,
    ["Use"]         = 8,
    ["Dupe"]        = 16,
    ["CPPI"]        = 32
}
TK.PP.BuddyPermissions = {"Tool Gun", "Grav Gun", "Phys Gun", "Use", "Dupe", "CPPI"}
TK.PP.SharePermissions = {"Tool Gun", "Grav Gun", "Phys Gun", "Use", "Dupe"}

CPPI = CPPI or {}
CPPI.CPPI_DEFER = -1
CPPI.CPPI_NOTIMPLEMENTED = -2

function CPPI:GetName()
    return "Prop Protection"
end

function CPPI:GetVersion()
    return "2"
end

function CPPI:GetInterfaceVersion()
    return 2
end

hook.Add("Initialize", "TKPP", function()
    function _R.Entity:UID()
        if !IsValid(self) then return false end
        local uid = self:GetNWString("UID", false)
        if uid then return uid end
        if !self:IsPlayer() then return false end
        uid = tostring(self:UniqueID())
        self:SetNWString("UID", uid)
        return uid
    end
end)