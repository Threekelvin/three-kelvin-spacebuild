local Tool_Setup = {}
Tool_Setup.paths = {"rd_tools/",  "lo_tools/"}

function Tool_Setup:RunSetup(path)
    for _, t_file in pairs(file.Find(path .. "*.lua", "LUA")) do
        TOOL = ToolObj:Create()
        TOOL.Name = string.match(t_file, "[%w_]+")
        ---- Load Default Tool Data ----
        include("tksb/gamemode/library/in_tool_setup.lua")
        --------------------------------
        AddCSLuaFile(path .. t_file)
        include(path .. t_file)

        if SERVER then
            for k, v in pairs(TOOL.Data) do
                if util.IsValidModel(k) then
                    util.PrecacheModel(k)
                else
                    TOOL.Data[k] = nil
                end
            end

            TK.UP:SetDefaultLimit(TOOL.Mode, TOOL.Limit)
            duplicator.RegisterEntityClass(TOOL.Mode, TK.UP.MakeEntity, "Data")
        else
            language.Add("tool." .. TOOL.Mode .. ".name", TOOL.Name)
            language.Add("tool." .. TOOL.Mode .. ".desc", "Used to Spawn a " .. TOOL.Name)
            language.Add("tool." .. TOOL.Mode .. ".0", "Left Click: Spawn a " .. TOOL.Name)
            language.Add("sboxlimit_" .. TOOL.Mode, "You Have Hit the " .. TOOL.Name .. " Limit!")
        end

        cleanup.Register(TOOL.Name)
        TOOL.Command = nil
        TOOL.ConfigName = nil
        TOOL.Tab = "3K Spacebuild"
        TOOL:CreateConVars()
        SWEP.Tool[TOOL.Mode] = TOOL
        TOOL = nil
    end
end

for _,path in pairs(Tool_Setup.paths) do
    Tool_Setup:RunSetup(path)
end


TOOL = ToolObj:Create()
TOOL.Category = "3K Spacebuild"
TOOL.Mode = "tk_tools"
TOOL.Name = "3K Tools"
TOOL.Command = nil
TOOL.ConfigName = nil
TOOL.AddToMenu = false
if SERVER then return end

hook.Add("TKDB_Player_Data", "TK_Tool_Setup", function(dbtable, idx, val)
    for k, v in pairs(TK.UP.lists) do
        if not string.match(v .. "$", dbtable) then continue end
        if not LocalPlayer().GetWeapons then return end
        local tools = LocalPlayer():GetWeapons()

        for _, tool in pairs(tools) do
            if tool:GetClass() ~= "gmod_tool" then continue end

            for _, path in pairs(Tool_Setup.paths) do
                for _, t_file in pairs(file.Find(path .. "*.lua", "LUA")) do
                    tool.Tool[string.match(t_file, "[%w_]+")].Build = true
                end
            end

            break
        end
    end
end)
