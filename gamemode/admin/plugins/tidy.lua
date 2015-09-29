PLUGIN.Name = "Tidy"
PLUGIN.Prefix = "!"
PLUGIN.Command = "Tidy"
PLUGIN.Level = 1

if SERVER then
    function PLUGIN.Call(ply, arg)
        local class = "class C_PhysPropClientside"
        ply:ConCommand("r_cleardecals")
        ply:SendLua(string.format("for _,v in pairs(ents.GetAll()) do if v:GetClass()==%q then v:Remove() end end", class))
        TK.AM:SystemMessage({"Removed All Clientside Props / Decals"}, {ply}, 2)
    end
end
