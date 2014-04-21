
GM.Name         = "3K Spacebuild"
GM.Author       = "Ghost400"
GM.Email        = "N/A"
GM.Website      = "threekelv.in"

jit.on()
DeriveGamemode("sandbox")
_R = debug.getregistry()

TK = TK or {}

///--- Teams ---\\\
team.SetUp(0, "Console", Color(151,211,255), false)
team.SetUp(1, "Mercenary", Color(147,147,150))
team.SetUp(2, "The Solar Empire", Color(235,175,75))
team.SetUp(3, "The New Lunar Republic", Color(75,75,235))
team.SetUp(4, "Changeling Empire", Color(175,235,75))
team.SetUp(5, "I <3 DOTA 2", Color(200,75,75))
///--- ---\\\

local function IsValidFolder(dir)
    if dir == "." or dir == ".." then return false end
    if string.GetExtensionFromFilename(dir) then return false end
    return true
end

local function LoadModules()
    local root = GM.FolderName .."/gamemode/"
    local files, dirs = file.Find(root.."*", "LUA")
    
    for _,dir in pairs(dirs) do
        if !IsValidFolder(dir) then continue end
        
        for _,lua in pairs(file.Find(root .. dir .."/*.lua", "LUA")) do
            local path = root .. dir .."/".. lua
            
            if lua:match("^sv_") then
                if SERVER then
                    include(path)
                end
            elseif lua:match("^sh_") then
                if SERVER then
                    AddCSLuaFile(path)
                    include(path)
                else
                    include(path)
                end
            elseif lua:match("^cl_") then
                if SERVER then
                    AddCSLuaFile(path)
                else
                    include(path)
                end
            end
        end
    end
end

LoadModules()