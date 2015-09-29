include("shared.lua")

net.Receive("3k_teleporter_open", function()
    local ent = net.ReadEntity()
    local Panel = vgui.Create("DFrame")
    Panel:SetSize(400, 400)
    Panel:Center()
    Panel:SetTitle("3K Teleporter")
    Panel:ShowCloseButton(true)
    Panel:MakePopup()
    local List = vgui.Create("DPanelList", Panel)
    List:SetPos(5, 25)
    List:SetSize(390, 370)
    List:SetSpacing(5)
    List:SetPadding(5)
    List:EnableHorizontal(false)
    List:EnableVerticalScrollbar(true)
    List:Clear()

    for k, v in pairs(ents.FindByClass("tk_teleporter")) do
        if ent ~= v then
            local button = vgui.Create("DButton")
            button:SetSize(380, 25)
            button:SetText(v:GetNWString("Name", "Space"))

            button.DoClick = function()
                RunConsoleCommand("3k_teleporter_send", v:EntIndex())
                Panel:Remove()
            end

            List:AddItem(button)
        end
    end
end)
