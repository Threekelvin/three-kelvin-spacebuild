include("shared.lua")

surface.CreateFont("Terminal", {
    font = "home remedy",
    size = 128,
    weight = 400
})

surface.CreateFont("TKFont45", {
    font = "classic robot",
    size = 45,
    weight = 400
})

surface.CreateFont("TKFont30", {
    font = "classic robot",
    size = 30,
    weight = 400
})

surface.CreateFont("TKFont25", {
    font = "classic robot",
    size = 25,
    weight = 400
})

surface.CreateFont("TKFont20", {
    font = "classic robot",
    size = 20,
    weight = 400
})

surface.CreateFont("TKFont18", {
    font = "classic robot",
    size = 18,
    weight = 400
})

surface.CreateFont("TKFont15", {
    font = "classic robot",
    size = 15,
    weight = 400
})

surface.CreateFont("TKFont12", {
    font = "classic robot",
    size = 12,
    weight = 400
})

usermessage.Hook("TKOSSync", function(msg)
    local servertime = tonumber(msg:ReadString())
    TK.OSSync = math.ceil(servertime - os.time())
end)

hook.Add("Initialize", "ClientInit", function()
    RunConsoleCommand("r_eyemove", "0")
end)
