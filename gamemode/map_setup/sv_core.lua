

TK.MapSetup = TK.MapSetup or {
    Atmospheres = {},
    MapEntities = {},
    SpawnPoints = {},
    Resources   = {},
}

local function LoadMapSettings()
    local root = GM.FolderName .."/gamemode/map_setup/maps/"
    local files = file.Find(root.."*", "LUA")
    local map = string.match(game.GetMap(), "sb_[%w]+")

    for k,v in pairs(files) do
        if string.match(v, map) then
            if string.match(v, "^atmosphere_") then
                local data = file.Read(root..v, "LUA")
                TK.MapSetup.Atmospheres = util.KeyValuesToTable(data)
            elseif string.match(v, "^settings_") then
                include(root..v)
            end
        end
    end
end

hook.Add("Initialize", "3K_Map_Setup", function()
    for k,v in pairs(ents.GetAll()) do
        if !IsValid(v) then continue end
        if v:GetClass() == "func_dustcloud" then
            SafeRemoveEntity(v)
        end
    end
    
    local CleanUp = game.CleanUpMap
    function game.CleanUpMap(bln, filters)
        local data = filters or {}
        table.insert(data, "at_planet")
        table.insert(data, "at_star")
        
        CleanUp(bln, data)
        
        for k,v in pairs(ents.GetAll()) do
            if v:GetClass() != "func_dustcloud" then continue end
            SafeRemoveEntity(v)
        end
        
        if TK.MapSetup.Cleanup then
            TK.MapSetup.Cleanup()
        end

        for k,v in pairs(TK.MapSetup.MapEntities) do
            local ent = ents.Create(v.ent)
            if !IsValid(ent) then continue end
            if v.model then ent:SetModel(v.model) end

            ent:SetPos(v.pos)
            ent:SetAngles(v.ang)
            ent:Spawn()
            ent:SetUnFreezable(true)
            
            local phys = ent:GetPhysicsObject()
            if phys:IsValid() then phys:EnableMotion(false) end
            if v.notsolid then ent:SetNotSolid(true) end
            if v.color then 
                ent:SetColor(v.color)
                ent:SetRenderMode(RENDERMODE_TRANSALPHA)
            end
        end
    end
end)

hook.Add("InitPostEntity", "3K_Map_Setup", function()
    timer.Simple(1, function()
        game.CleanUpMap()
    end)
end)

LoadMapSettings()