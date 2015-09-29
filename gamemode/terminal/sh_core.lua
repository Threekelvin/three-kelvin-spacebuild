TK.RT = TK.RT or {}
TK.RT.Radius = 1048576

local function LoadPages()
    for _, lua in pairs(file.Find(GM.FolderName .. "/gamemode/terminal/page/*.lua", "LUA")) do
        local path = GM.FolderName .. "/gamemode/terminal/page/" .. lua

        if SERVER then
            AddCSLuaFile(path)
        else
            include(path)
        end
    end
end

LoadPages()
