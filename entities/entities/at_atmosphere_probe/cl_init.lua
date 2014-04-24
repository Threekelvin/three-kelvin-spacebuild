
include("shared.lua")

local function Add(array, data)
    array[array.idx] = data
    array.idx = array.idx + 1
end

function ENT:Initialize()

end

function ENT:Draw()
    self:DrawModel()
    
    if (self:GetPos() - LocalPlayer():GetPos()):LengthSqr() > 262144 then return end
    if LocalPlayer():GetEyeTrace().Entity != self then return end
    
    local entdata = self:GetEntTable()
    entdata.powergrid = entdata.powergrid or 0
    local owner, uid = self:CPPIGetOwner()
    local name = "World"
    if IsValid(owner) then
        name = owner:Name()
    elseif uid then
        name = "Disconnected"
    end 
    
    local OverlayText = {self.PrintName, "\n", idx = 3}
    if entdata.netid == 0 then
        Add(OverlayText, "Not Connected\n")
    else
        Add(OverlayText, "Network ")
        Add(OverlayText, entdata.netid)
        Add(OverlayText, "\n")
    end
    
    Add(OverlayText, "Owner: ")
    Add(OverlayText, name)
    Add(OverlayText, "\nStatus: ")
    
    if self:GetActive() then
        Add(OverlayText, "On")
        Add(OverlayText, "\nPower Grid: ")
        if entdata.powergrid > 0 then
            Add(OverlayText, "+")
            Add(OverlayText, entdata.powergrid)
            Add(OverlayText, "KW")
        else
            Add(OverlayText, entdata.powergrid)
            Add(OverlayText, "KW")
        end
        
        Add(OverlayText, "\n\nAtmosphere Info")
        
        Add(OverlayText, "\nName: ")
        Add(OverlayText, entdata.data.id or "Space")
        Add(OverlayText, "\nTemperature: ")
        Add(OverlayText, entdata.data.temp or 3)
        Add(OverlayText, "\nGravity: ")
        Add(OverlayText, entdata.data.gravity or 0)
        for k,v in pairs(entdata.data.resources or {}) do
            Add(OverlayText, "\n")
            Add(OverlayText, TK.RD:GetResourceName(k))
            Add(OverlayText, ": ")
            Add(OverlayText, v)
            Add(OverlayText, "%")
        end
    else
        Add(OverlayText, "Off")
    end
    
    OverlayText.idx = nil
    AddWorldTip(nil, table.concat(OverlayText, ""), nil, self:LocalToWorld(self:OBBCenter()))
end

function ENT:DoMenu()
    if IsValid(self.Menu) then return end
    
    self.Menu = vgui.Create("DFrame")
    self.Menu:SetSize(400, 300)
    self.Menu:Center()
    self.Menu:SetTitle(self.PrintName)
    self.Menu:ShowCloseButton(true)
    self.Menu:SetDraggable(false)
    self.Menu:MakePopup()
end