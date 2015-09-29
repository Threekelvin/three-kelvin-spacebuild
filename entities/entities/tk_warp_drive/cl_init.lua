include("shared.lua")

local function Add(array, data)
    array[array.idx] = data
    array.idx = array.idx + 1
end

function ENT:Draw()
    self:DrawModel()
    if Wire_Render then Wire_Render(self) end
    
    if (self:GetPos() - LocalPlayer():GetPos()):LengthSqr() > 262144 then return end
    if LocalPlayer():GetEyeTrace().Entity != self then return end
    
    local entdata = self:GetEntTable()
    local res, gen = {}, {}
    for k,v in pairs(entdata.res) do
        if v.gen then
            gen[TK.RD:GetResourceName(k)] = k
        else
            res[TK.RD:GetResourceName(k)] = k
        end
    end
    local owner , uid = self:CPPIGetOwner()
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
    
    if self:IsGenerator() then
        Add(OverlayText, "\nStatus: ")
        Add(OverlayText, self:GetActive() && "On" || "Off")
        Add(OverlayText, "\nPower Grid: ")
        
        if entdata.powergrid > 0 then
            Add(OverlayText, "+")
            Add(OverlayText, entdata.powergrid)
            Add(OverlayText, "kW")
        else
            Add(OverlayText, entdata.powergrid)
            Add(OverlayText, "kW")
        end
    end
    
    Add(OverlayText, "\nSpooled: ")
    Add(OverlayText, math.Round(entdata.data.spool || 0, 2))
    Add(OverlayText, "%\n")
    
    if table.Count(res) > 0 then
        Add(OverlayText, "\nResources:\n")
        for k,v in pairs(res) do
            Add(OverlayText, k)
            Add(OverlayText, ": ")
            Add(OverlayText, self:GetResourceAmount(v))
            Add(OverlayText, "/")
            Add(OverlayText, self:GetResourceCapacity(v))
            Add(OverlayText, "\n")
        end
    end
    
    if table.Count(gen) > 0 then
        Add(OverlayText, "\nGenerates:\n")
        for k,v in pairs(gen) do
            Add(OverlayText, k)
            Add(OverlayText, ": ")
            Add(OverlayText, self:GetResourceAmount(v))
            Add(OverlayText, "/")
            Add(OverlayText, self:GetResourceCapacity(v))
            Add(OverlayText, "\n")
        end
    end
    
    if OverlayText[#OverlayText] != "\n" then
        Add(OverlayText, "\n")
    end
    OverlayText.idx = nil
    AddWorldTip(nil, table.concat(OverlayText, ""), nil, self:LocalToWorld(self:OBBCenter()))
end